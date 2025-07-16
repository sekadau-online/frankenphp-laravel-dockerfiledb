-- init.sql
-- Ini akan dijalankan saat kontainer MariaDB pertama kali dimulai.

-- Mengatur password untuk user 'root' untuk koneksi dari mana saja (termasuk localhost dan kontainer lain).
-- GANTI 'YourRootPassword123!' dengan nilai APP_ROOT_PASSWORD dari .env Anda
ALTER USER 'root'@'%' IDENTIFIED BY '123';
FLUSH PRIVILEGES;

-- Membuat user aplikasi jika belum ada dan memberikan semua hak akses ke database 'app1'.
-- GANTI 'fyvkyou' dengan nilai DB_USER dari .env Anda
-- GANTI 'YourUserPassword123!' dengan nilai APP_DB_PASSWORD dari .env Anda
CREATE USER IF NOT EXISTS 'fyvkyou'@'%' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON app1.* TO 'fyvkyou'@'%';
FLUSH PRIVILEGES;

-- Jika Anda ingin user 'root' juga memiliki akses dari host mana pun (opsional, tapi bisa membantu debugging)
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Perintah ini memastikan database 'app1' ada
CREATE DATABASE IF NOT EXISTS app1;
