-- Burnout Pulse AI Admin
-- รันด้วยบัญชีผู้ดูแล MySQL ใน phpMyAdmin เพียงครั้งเดียว
-- หากตาราง registered_users หรือ user_logs มีอยู่แล้ว CREATE TABLE IF NOT EXISTS จะไม่ลบข้อมูลเดิม

CREATE DATABASE IF NOT EXISTS my_database
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE my_database;

-- ตารางพนักงาน ใช้ชื่อ/บัตรตามโค้ด Python ที่มีอยู่
CREATE TABLE IF NOT EXISTS registered_users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  rfid_uid VARCHAR(50) NOT NULL,
  username VARCHAR(150) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_registered_users_rfid (rfid_uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ตารางผลจาก Python modules; หน้า Admin อ่านตารางนี้อัตโนมัติ
CREATE TABLE IF NOT EXISTS user_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  recorded_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  rfid_uid VARCHAR(50) NOT NULL,
  camera_state TINYINT NULL COMMENT '0 = Normal, 1 = Abnormal/Risk',
  hrv DECIMAL(10,3) NULL,
  survey_answer DECIMAL(10,2) NULL,
  PRIMARY KEY (id),
  KEY idx_user_logs_time (recorded_time),
  KEY idx_user_logs_rfid_time (rfid_uid, recorded_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ตารางผู้มาเยือนสำหรับเมนูเดิมในหน้าเว็บ
CREATE TABLE IF NOT EXISTS visitor_cards (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  rfid_uid VARCHAR(50) NOT NULL,
  username VARCHAR(150) NOT NULL,
  organization VARCHAR(150) NULL,
  purpose VARCHAR(255) NULL,
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_visitor_cards_rfid (rfid_uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- สร้างบัญชีที่ PHP ใช้เชื่อมต่อจากเครื่องเดียวกับ MySQL
-- รหัสผ่านนี้ต้องตรงกับ DB_PASS ใน api/config.php
CREATE USER IF NOT EXISTS 'burnout_app'@'localhost' IDENTIFIED BY 'ChangeThisDbPassword!2026';
ALTER USER 'burnout_app'@'localhost' IDENTIFIED BY 'ChangeThisDbPassword!2026';
GRANT SELECT, INSERT, UPDATE, DELETE ON my_database.* TO 'burnout_app'@'localhost';
FLUSH PRIVILEGES;
