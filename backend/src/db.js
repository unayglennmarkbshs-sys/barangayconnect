const mysql = require('mysql2/promise');
const { db } = require('./config');

const pool = mysql.createPool({
  ...db,
  waitForConnections: true,
  connectionLimit: 10,
  namedPlaceholders: true,
});

module.exports = pool;
