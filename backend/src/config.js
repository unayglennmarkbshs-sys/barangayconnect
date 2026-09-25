require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  db: {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'barangayconnect',
  },
  jwtSecret: process.env.JWT_SECRET || 'dev_secret_change_me',
  baseUrl: process.env.BASE_URL || 'http://localhost:3000',
};
