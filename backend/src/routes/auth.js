const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const { jwtSecret } = require('../config');
const { authenticateToken } = require('../middleware/auth');

function sign(user) {
  return jwt.sign({ id: user.user_id, email: user.email, role: user.role }, jwtSecret, {
    expiresIn: '7d',
  });
}

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { full_name, email, password, phone_number, address } = req.body;
    if (!full_name || !email || !password || !phone_number) {
      return res.status(400).json({ message: 'full_name, email, password and phone_number are required' });
    }
    const [existing] = await pool.query('SELECT user_id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) return res.status(409).json({ message: 'Email already registered' });

    const hash = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      `INSERT INTO users (full_name, email, password_hash, phone_number, address, role, status)
       VALUES (?, ?, ?, ?, ?, 'resident', 'active')`,
      [full_name, email, hash, phone_number, address || null]
    );
    const [rows] = await pool.query('SELECT * FROM users WHERE user_id = ?', [result.insertId]);
    const user = rows[0];
    res.status(201).json({ token: sign(user), user: publicUser(user) });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ message: 'email and password required' });
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) return res.status(401).json({ message: 'Invalid email or password' });
    const user = rows[0];
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ message: 'Invalid email or password' });
    if (user.status !== 'active') return res.status(403).json({ message: 'Account is inactive' });
    res.json({ token: sign(user), user: publicUser(user) });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// POST /api/auth/logout  (JWT is stateless; client discards token)
router.post('/logout', authenticateToken, (req, res) => {
  res.json({ message: 'Logged out' });
});

function publicUser(u) {
  return {
    user_id: u.user_id,
    full_name: u.full_name,
    email: u.email,
    phone_number: u.phone_number,
    address: u.address,
    role: u.role,
    profile_photo: u.profile_photo,
    status: u.status,
    date_registered: u.date_registered,
  };
}

module.exports = router;
