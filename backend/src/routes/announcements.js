const router = require('express').Router();
const pool = require('../db');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// GET /api/announcements
router.get('/', authenticateToken, async (req, res) => {
  const [rows] = await pool.query(
    `SELECT a.*, u.full_name AS posted_by_name
     FROM announcements a LEFT JOIN users u ON a.posted_by = u.user_id
     WHERE a.status = 'published' ORDER BY a.date_posted DESC`);
  res.json(rows);
});

// GET /api/announcements/all  (admin, includes archived)
router.get('/all', authenticateToken, requireAdmin, async (req, res) => {
  const [rows] = await pool.query(
    `SELECT a.*, u.full_name AS posted_by_name
     FROM announcements a LEFT JOIN users u ON a.posted_by = u.user_id
     ORDER BY a.date_posted DESC`);
  res.json(rows);
});

// POST /api/announcements
router.post('/', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { title, content, category } = req.body;
    if (!title || !content) return res.status(400).json({ message: 'title and content required' });
    const [result] = await pool.query(
      `INSERT INTO announcements (title, content, category, posted_by, status)
       VALUES (?, ?, ?, ?, 'published')`,
      [title, content, category || null, req.user.id]);
    const [rows] = await pool.query('SELECT * FROM announcements WHERE announcement_id = ?', [result.insertId]);
    await notifyAll(pool, 'New Announcement', title, 'announcement');
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// PUT /api/announcements/:id
router.put('/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { title, content, category, status } = req.body;
    await pool.query(
      `UPDATE announcements SET title = ?, content = ?, category = ?, status = ?, date_updated = NOW()
       WHERE announcement_id = ?`,
      [title, content, category || null, status || 'published', req.params.id]);
    const [rows] = await pool.query('SELECT * FROM announcements WHERE announcement_id = ?', [req.params.id]);
    res.json(rows[0]);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// DELETE /api/announcements/:id  (archive)
router.delete('/:id', authenticateToken, requireAdmin, async (req, res) => {
  await pool.query("UPDATE announcements SET status = 'archived', date_updated = NOW() WHERE announcement_id = ?",
    [req.params.id]);
  res.json({ message: 'Announcement archived' });
});

async function notifyAll(pool, title, message, type) {
  const [users] = await pool.query("SELECT user_id FROM users WHERE status = 'active'");
  if (users.length === 0) return;
  const values = users.map((u) => [u.user_id, title, message, type]);
  await pool.query(
    'INSERT INTO notifications (user_id, title, message, type) VALUES ?', [values]);
}

module.exports = router;
module.exports.notifyAll = notifyAll;
