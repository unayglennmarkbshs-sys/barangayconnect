const jwt = require('jsonwebtoken');
const { jwtSecret } = require('../config');

function authenticateToken(req, res, next) {
  const header = req.headers['authorization'];
  const token = header && header.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'Missing token' });
  try {
    req.user = jwt.verify(token, jwtSecret); // { id, role, email }
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

function requireAdmin(req, res, next) {
  if (req.user && (req.user.role === 'admin' || req.user.role === 'official')) {
    return next();
  }
  return res.status(403).json({ message: 'Admin access required' });
}

module.exports = { authenticateToken, requireAdmin };
