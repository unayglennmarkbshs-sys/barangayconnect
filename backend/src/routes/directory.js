const router = require('express').Router();
const pool = require('../db');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// GET /api/emergency-contacts
router.get('/', authenticateToken, async (req, res) => {
  const [rows] = await pool.query('SELECT * FROM emergency_contacts ORDER BY category, name');
  res.json(rows);
});

// POST /api/emergency-contacts  (add/update by name)
router.post('/', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { name, category, phone_number, address } = req.body;
    if (!name || !category || !phone_number) {
      return res.status(400).json({ message: 'name, category, phone_number required' });
    }
    const [result] = await pool.query(
      'INSERT INTO emergency_contacts (name, category, phone_number, address) VALUES (?, ?, ?, ?)',
      [name, category, phone_number, address || null]);
    const [rows] = await pool.query('SELECT * FROM emergency_contacts WHERE contact_id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;
