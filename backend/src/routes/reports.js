const router = require('express').Router();
const pool = require('../db');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// GET /api/reports/summary  (dashboard counts)
router.get('/summary', authenticateToken, requireAdmin, async (req, res) => {
  const [users] = await pool.query("SELECT COUNT(*) AS c FROM users WHERE role = 'resident'");
  const [pendingRequests] = await pool.query("SELECT COUNT(*) AS c FROM service_requests WHERE status = 'pending'");
  const [totalRequests] = await pool.query('SELECT COUNT(*) AS c FROM service_requests');
  const [openConcerns] = await pool.query("SELECT COUNT(*) AS c FROM concerns WHERE status IN ('pending','reviewed')");
  const [totalConcerns] = await pool.query('SELECT COUNT(*) AS c FROM concerns');
  const [announcements] = await pool.query("SELECT COUNT(*) AS c FROM announcements WHERE status = 'published'");
  const [byRequestStatus] = await pool.query(
    'SELECT status, COUNT(*) AS count FROM service_requests GROUP BY status');
  const [byConcernStatus] = await pool.query(
    'SELECT status, COUNT(*) AS count FROM concerns GROUP BY status');
  res.json({
    total_residents: users[0].c,
    pending_requests: pendingRequests[0].c,
    total_requests: totalRequests[0].c,
    open_concerns: openConcerns[0].c,
    total_concerns: totalConcerns[0].c,
    announcements: announcements[0].c,
    requests_by_status: byRequestStatus,
    concerns_by_status: byConcernStatus,
  });
});

module.exports = router;
