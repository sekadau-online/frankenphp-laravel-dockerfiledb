#!/bin/bash

# --- Tunggu sampai database siap ---
echo "Waiting for database..."
while ! nc -z db 3306; do
  sleep 1
done
echo "Database is ready!"

# --- Jalankan migrasi Laravel ---
# Ini HARUS berjalan pertama kali setelah DB siap, untuk membuat tabel.
echo "Running Laravel migrations..."
php artisan migrate --force

# --- Jalankan perintah-perintah Laravel penting lainnya (setelah migrasi) ---
# Commands that need a fully set-up database and Laravel environment.
echo "Generating Laravel key and storage link..."
php artisan key:generate --force # Pastikan APP_KEY sudah digenerate
php artisan storage:link --force # Buat symlink storage jika belum ada

# --- Bersihkan dan Optimalkan Cache Laravel ---
# Sekarang baru aman membersihkan cache karena tabel DB sudah ada.
echo "Clearing and optimizing Laravel caches..."
php artisan config:clear
php artisan route:clear
php artisan artisan view:clear
php artisan optimize:clear
php artisan cache:clear # Pindahkan ini ke sini, setelah migrasi

# --- Jalankan Optimize (optional, bisa juga digabung dengan optimize:clear) ---
php artisan optimize

# --- Jalankan perintah utama kontainer ---
echo "Starting FrankenPHP/Octane..."
exec "$@"
