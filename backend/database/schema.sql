-- BarangayConnect database schema
-- Matches Section 3.2 (Table Schemas) of the System Design Document.

CREATE DATABASE IF NOT EXISTS barangayconnect;
USE barangayconnect;

CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  address VARCHAR(150) NULL,
  role ENUM('resident','admin','official') NOT NULL DEFAULT 'resident',
  profile_photo VARCHAR(255) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  date_registered DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS announcements (
  announcement_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(50) NULL,
  posted_by INT NOT NULL,
  date_posted DATETIME DEFAULT CURRENT_TIMESTAMP,
  date_updated DATETIME NULL,
  status ENUM('published','archived') NOT NULL DEFAULT 'published',
  FOREIGN KEY (posted_by) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS events (
  event_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  description TEXT NULL,
  event_date DATETIME NOT NULL,
  location VARCHAR(150) NULL,
  posted_by INT NOT NULL,
  date_posted DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (posted_by) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS service_requests (
  request_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  request_type ENUM('clearance','certificate','residency','indigency','appointment','other') NOT NULL,
  purpose VARCHAR(200) NULL,
  description TEXT NULL,
  status ENUM('pending','in review','approved','released','rejected') NOT NULL DEFAULT 'pending',
  handled_by INT NULL,
  date_submitted DATETIME DEFAULT CURRENT_TIMESTAMP,
  date_updated DATETIME NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (handled_by) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS request_status_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  request_id INT NOT NULL,
  status ENUM('pending','in review','approved','released','rejected') NOT NULL,
  remarks VARCHAR(255) NULL,
  updated_by INT NOT NULL,
  date_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (request_id) REFERENCES service_requests(request_id) ON DELETE CASCADE,
  FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS concerns (
  concern_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(50) NULL,
  status ENUM('pending','reviewed','resolved','dismissed') NOT NULL DEFAULT 'pending',
  handled_by INT NULL,
  date_submitted DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (handled_by) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS concern_attachments (
  attachment_id INT AUTO_INCREMENT PRIMARY KEY,
  concern_id INT NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  file_type VARCHAR(20) NULL,
  date_uploaded DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (concern_id) REFERENCES concerns(concern_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(100) NOT NULL,
  message VARCHAR(255) NOT NULL,
  type ENUM('announcement','request_update','concern_update','event') NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  date_sent DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS emergency_contacts (
  contact_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  address VARCHAR(150) NULL
);
