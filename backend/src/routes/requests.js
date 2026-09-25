const router = require('express').Router();
const pool = require('../db');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

const REQUEST_TYPES = ['clearance', 'certificate', 'residency', 'indigency', 'appointment', 'other'];
const STATUSES = ['pending', 'in review', 'approved', 'released', 'rejected'];

// POST /api/requests
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { request_type, purpose, description } = req.body;
    if (!REQUEST_TYPES.includes(request_type)) return res.status(400).json({ message: 'Invalid request_type' });
    const [result] = await pool.query(
      `INSERT INTO service_requests (user_id, request_type, purpose, description, status)
       VALUES (?, ?, ?, ?, 'pending')`,
      [req.user.id, request_type, purpose || null, description || null]);
    const requestId = result.insertId;
    await pool.query(
      'INSERT INTO request_status_history (request_id, status, updated_by) VALUES (?, ?, ?)',
      [requestId, 'pending', req.user.id]);
    const [rows] = await pool.query('SELECT * FROM service_requests WHERE request_id = ?', [requestId]);
    res.status(201).json(rows[0]);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// GET /api/requests/mine
router.get('/mine', authenticateToken, async (req, res) => {
  const [rows] = await pool.query(
    `SELECT r.*, u.full_name AS resident_name
     FROM service_requests r JOIN users u ON r.user_id = u.user_id
     WHERE r.user_id = ? ORDER BY r.date_submitted DESC`, [req.user.id]);
  res.json(rows);
});

// GET /api/requests/:id  (owner or admin)
router.get('/:id', authenticateToken, async (req, res) => {
  const [rows] = await pool.query(
    `SELECT r.*, u.full_name AS resident_name FROM service_requests r
     JOIN users u ON r.user_id = u.user_id WHERE r.request_id = ?`, [req.params.id]);
  if (rows.length === 0) return res.status(404).json({ message: 'Request not found' });
  const request = rows[0];
  if (request.user_id !== req.user.id && !['admin', 'official'].includes(req.user.role)) {
    return res.status(403).json({ message: 'Not allowed' });
  }
  const [history] = await pool.query(
    `SELECT h.*, u.full_name AS updated_by_name
     FROM request_status_history h JOIN users u ON h.updated_by = u.user_id
     WHERE h.request_id = ? ORDER BY h.date_updated ASC`, [req.params.id]);
  res.json({ ...request, history });
});

// GET /api/requests?status=
router.get('/', authenticateToken, requireAdmin, async (req, res) => {
  const status = req.query.status && STATUSES.includes(req.query.status) ? req.query.status : null;
  const sql = `SELECT r.*, u.full_name AS resident_name
     FROM service_requests r JOIN users u ON r.user_id = u.user_id
     ${status ? 'WHERE r.status = ?' : ''} ORDER BY r.date_submitted DESC`;
  const [rows] = await pool.query(sql, status ? [status] : []);
  res.json(rows);
});

// PUT /api/requests/:id/status
router.put('/:id/status', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { status, remarks } = req.body;
    if (!STATUSES.includes(status)) return res.status(400).json({ message: 'Invalid status' });
    const [rows] = await pool.query('SELECT * FROM service_requests WHERE request_id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: 'Request not found' });
    const request = rows[0];
    await pool.query(
      'UPDATE service_requests SET status = ?, handled_by = ?, date_updated = NOW() WHERE request_id = ?',
      [status, req.user.id, req.params.id]);
    await pool.query(
      'INSERT INTO request_status_history (request_id, status, remarks, updated_by) VALUES (?, ?, ?, ?)',
      [req.params.id, status, remarks || null, req.user.id]);
    await pool.query(
      `INSERT INTO notifications (user_id, title, message, type)
       VALUES (?, 'Request Update', ?, 'request_update')`,
      [request.user_id, `Your ${request.request_type} request is now "${status}".${remarks ? ' ' + remarks : ''}`]);
    res.json({ message: 'Status updated' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;
