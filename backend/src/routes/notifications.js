const router = require('express').Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');

// GET /api/notifications
router.get('/', authenticateToken, async (req, res) => {
  const [rows] = await pool.query(
    'SELECT * FROM notifications WHERE user_id = ? ORDER BY date_sent DESC', [req.user.id]);
  res.json(rows);
});

// PUT /api/notifications/:id/read
router.put('/:id/read', authenticateToken, async (req, res) => {
  await pool.query(
    'UPDATE notifications SET is_read = true WHERE notification_id = ? AND user_id = ?',
    [req.params.id, req.user.id]);
  res.json({ message: 'Marked as read' });
});

module.exports = router;
