-- Seed data. Run AFTER schema.sql.
-- Default admin account: admin@barangay.com / admin123  (CHANGE THE PASSWORD IN PRODUCTION)
USE barangayconnect;

-- Admin account is created by backend/scripts_create_admin.js (run it after npm install)

INSERT INTO emergency_contacts (name, category, phone_number, address) VALUES
('Barangay Hall', 'Barangay Hall', '09170000001', 'Barangay Hall'),
('Police Station', 'Police', '09170000002', 'Municipal Hall Grounds'),
('Fire Station', 'Fire', '09170000003', 'Rizal St.'),
('Health Center', 'Health', '09170000004', 'Health Center Building');

INSERT INTO announcements (title, content, category, posted_by) VALUES
('Welcome to BarangayConnect', 'You can now view announcements, submit service requests and report concerns using this app.', 'General', 1);

INSERT INTO events (title, description, event_date, location, posted_by) VALUES
('Barangay Assembly', 'Quarterly barangay assembly. All residents are invited.', '2026-10-15 09:00:00', 'Barangay Covered Court', 1);
