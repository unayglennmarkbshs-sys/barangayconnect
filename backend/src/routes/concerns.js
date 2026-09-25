const router = require('express').Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pool = require('../db');
const { baseUrl } = require('../config');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const uploadDir = path.join(__dirname, '..', '..', 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });
const upload = multer({
  storage: multer.diskStorage({
    destination: uploadDir,
    filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname.replace(/\s+/g, '_')}`),
  }),
  limits: { fileSize: 5 * 1024 * 1024 },
});

const CONCERN_STATUSES = ['pending', 'reviewed', 'resolved', 'dismissed'];

// POST /api/concerns
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { title, description, category } = req.body;
    if (!title || !description) return res.status(400).json({ message: 'title and description required' });
    const [result] = await pool.query(
      `INSERT INTO concerns (user_id, title, description, category, status)
       VALUES (?, ?, ?, ?, 'pending')`,
      [req.user.id, title, description, category || null]);
    const [rows] = await pool.query('SELECT * FROM concerns WHERE concern_id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// POST /api/concerns/:id/attachments  (multipart form-data, field name: file)
router.post('/:id/attachments', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'No file uploaded' });
    await pool.query(
      'INSERT INTO concern_attachments (concern_id, file_path, file_type) VALUES (?, ?, ?)',
      [req.params.id, req.file.filename, req.file.mimetype]);
    res.status(201).json({ message: 'File uploaded', file_path: req.file.filename });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// GET /api/concerns/mine
router.get('/mine', authenticateToken, async (req, res) => {
  const [rows] = await pool.query(
    'SELECT * FROM concerns WHERE user_id = ? ORDER BY date_submitted DESC', [req.user.id]);
  res.json(rows);
});

// GET /api/concerns?status=
router.get('/', authenticateToken, requireAdmin, async (req, res) => {
  const status = req.query.status && CONCERN_STATUSES.includes(req.query.status) ? req.query.status : null;
  const sql = `SELECT c.*, u.full_name AS resident_name
     FROM concerns c JOIN users u ON c.user_id = u.user_id
     ${status ? 'WHERE c.status = ?' : ''} ORDER BY c.date_submitted DESC`;
  const [rows] = await pool.query(sql, status ? [status] : []);
  res.json(rows);
});

// GET /api/concerns/:id  (owner or admin) with attachments
router.get('/:id', authenticateToken, async (req, res) => {
  const [rows] = await pool.query(
    `SELECT c.*, u.full_name AS resident_name FROM concerns c
     JOIN users u ON c.user_id = u.user_id WHERE c.concern_id = ?`, [req.params.id]);
  if (rows.length === 0) return res.status(404).json({ message: 'Concern not found' });
  const concern = rows[0];
  if (concern.user_id !== req.user.id && !['admin', 'official'].includes(req.user.role)) {
    return res.status(403).json({ message: 'Not allowed' });
  }
  const [attachments] = await pool.query(
    'SELECT * FROM concern_attachments WHERE concern_id = ?', [req.params.id]);
  res.json({
    ...concern,
    attachments: attachments.map((a) => ({
      ...a,
      url: `${baseUrl}/uploads/${a.file_path}`,
    })),
  });
});

// PUT /api/concerns/:id/status
router.put('/:id/status', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { status } = req.body;
    if (!CONCERN_STATUSES.includes(status)) return res.status(400).json({ message: 'Invalid status' });
    const [rows] = await pool.query('SELECT * FROM concerns WHERE concern_id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: 'Concern not found' });
    await pool.query('UPDATE concerns SET status = ?, handled_by = ? WHERE concern_id = ?',
      [status, req.user.id, req.params.id]);
    await pool.query(
      `INSERT INTO notifications (user_id, title, message, type)
       VALUES (?, 'Concern Update', ?, 'concern_update')`,
      [rows[0].user_id, `Your concern "${rows[0].title}" is now "${status}".`]);
    res.json({ message: 'Status updated' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;
