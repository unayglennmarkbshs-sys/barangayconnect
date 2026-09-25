const router = require('express').Router();
const pool = require('../db');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// GET /api/events
router.get('/', authenticateToken, async (req, res) => {
  const [rows] = await pool.query(
    `SELECT e.*, u.full_name AS posted_by_name
     FROM events e LEFT JOIN users u ON e.posted_by = u.user_id
     ORDER BY e.event_date ASC`);
  res.json(rows);
});

// POST /api/events
router.post('/', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { title, description, event_date, location } = req.body;
    if (!title || !event_date) return res.status(400).json({ message: 'title and event_date required' });
    const [result] = await pool.query(
      'INSERT INTO events (title, description, event_date, location, posted_by) VALUES (?, ?, ?, ?, ?)',
      [title, description || null, event_date, location || null, req.user.id]);
    const [rows] = await pool.query('SELECT * FROM events WHERE event_id = ?', [result.insertId]);
    await pool.query(
      `INSERT INTO notifications (user_id, title, message, type)
       SELECT user_id, 'Upcoming Event', ?, 'event' FROM users WHERE status = 'active'`,
      [`Upcoming event: ${title} on ${event_date}`]);
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;
