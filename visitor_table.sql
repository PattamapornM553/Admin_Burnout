-- รันบน phpMyAdmin ของ MySQL Server 10.26.1.95 (my_database) เพียงครั้งเดียว
-- ไม่มีการลบหรือแก้ตาราง registered_users, user_logs
USE my_database;
CREATE TABLE IF NOT EXISTS visitor_cards (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  rfid_uid VARCHAR(50) NOT NULL,
  username VARCHAR(150) NOT NULL,
  organization VARCHAR(150) NULL,
  purpose VARCHAR(255) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_visitor_cards_rfid (rfid_uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
