// Run AFTER npm install and schema.sql:
//   node scripts_create_admin.js
// Creates (or resets) the default administrator account.
// Default credentials: admin@barangay.com / admin123  -- CHANGE THESE.
const bcrypt = require('bcryptjs');
const pool = require('./src/db');

async function main() {
  const email = process.env.ADMIN_EMAIL || 'admin@barangay.com';
  const password = process.env.ADMIN_PASSWORD || 'admin123';
  const hash = await bcrypt.hash(password, 10);
  await pool.query(
    `INSERT INTO users (full_name, email, password_hash, phone_number, address, role, status)
     VALUES ('Barangay Administrator', ?, ?, '09170000000', 'Barangay Hall', 'admin', 'active')
     ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash)`,
    [email, hash]
  );
  console.log(`Admin ready: ${email} / ${password}`);
  process.exit(0);
}
main().catch((e) => { console.error(e); process.exit(1); });
