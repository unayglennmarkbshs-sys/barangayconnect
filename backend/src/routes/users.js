const router = require('express').Router();
const bcrypt = require('bcryptjs');
const pool = require('../db');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

function publicUser(u) {
  return {
    user_id: u.user_id, full_name: u.full_name, email: u.email,
    phone_number: u.phone_number, address: u.address, role: u.role,
    profile_photo: u.profile_photo, status: u.status, date_registered: u.date_registered,
  };
}

// GET /api/users/me
router.get('/me', authenticateToken, async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM users WHERE user_id = ?', [req.user.id]);
  if (rows.length === 0) return res.status(404).json({ message: 'User not found' });
  res.json(publicUser(rows[0]));
});

// PUT /api/users/me
router.put('/me', authenticateToken, async (req, res) => {
  try {
    const { full_name, phone_number, address, profile_photo, password } = req.body;
    const fields = [];
    const params = [];
    if (full_name !== undefined) { fields.push('full_name = ?'); params.push(full_name); }
    if (phone_number !== undefined) { fields.push('phone_number = ?'); params.push(phone_number); }
    if (address !== undefined) { fields.push('address = ?'); params.push(address); }
    if (profile_photo !== undefined) { fields.push('profile_photo = ?'); params.push(profile_photo); }
    if (password) { fields.push('password_hash = ?'); params.push(await bcrypt.hash(password, 10)); }
    if (fields.length === 0) return res.status(400).json({ message: 'Nothing to update' });
    params.push(req.user.id);
    await pool.query(`UPDATE users SET ${fields.join(', ')} WHERE user_id = ?`, params);
    const [rows] = await pool.query('SELECT * FROM users WHERE user_id = ?', [req.user.id]);
    res.json(publicUser(rows[0]));
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// GET /api/users?search=
router.get('/', authenticateToken, requireAdmin, async (req, res) => {
  const search = req.query.search ? `%${req.query.search}%` : '%';
  const [rows] = await pool.query(
    'SELECT * FROM users WHERE full_name LIKE ? OR email LIKE ? ORDER BY user_id DESC', [search, search]);
  res.json(rows.map(publicUser));
});

// PUT /api/users/:id/status
router.put('/:id/status', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { status } = req.body; // active | inactive
    if (!['active', 'inactive'].includes(status)) return res.status(400).json({ message: 'Invalid status' });
    await pool.query('UPDATE users SET status = ? WHERE user_id = ?', [status, req.params.id]);
    const [rows] = await pool.query('SELECT * FROM users WHERE user_id = ?', [req.params.id]);
    res.json(publicUser(rows[0]));
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;
