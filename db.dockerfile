# Menggunakan base image FrankenPHP PHP 8.3
FROM dunglas/frankenphp:latest

# Mengatur direktori kerja di dalam container
WORKDIR /app

# Menyalin executable Composer dari image Composer yang terpisah
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# --- Dependensi dan Persiapan Esensial ---
RUN apt-get update && \
    apt-get install -y \
    zip \
    libzip-dev \
    curl \
    iputils-ping \
    default-mysql-client \
    netcat-traditional \
    autoconf \
    g++ \
    make \
    && \
    docker-php-ext-install zip pcntl pdo pdo_mysql sockets && \
    pecl install redis && docker-php-ext-enable redis && \
    apt-get purge -y --auto-remove autoconf g++ make && \
    rm -rf /var/lib/apt/lists/*

# --- Menyalin SELURUH Aplikasi Pertama ---
# Ini memastikan semua file Laravel, termasuk `bootstrap/app.php` dan `artisan`,
# sudah ada sebelum Composer menginstal dependensi dan menjalankan script-nya.
COPY --chown=www-data:www-data . /app

# --- Konfigurasi dan Instalasi Composer ---
ENV COMPOSER_PROCESS_TIMEOUT=600 \
    COMPOSER_MEMORY_LIMIT=-1

RUN echo "--- Menginstal dependensi Composer ---" && \
    composer install --no-interaction --prefer-dist --optimize-autoloader --verbose

# --- Pastikan izin file yang benar setelah semua di-copy dan Composer dijalankan ---
# Walaupun sudah ada `--chown` di atas, memastikan izin di `storage` dan `bootstrap/cache`
# secara eksplisit lagi adalah praktik yang baik.
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# --- Salin entrypoint script ---
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Mengekspos port yang akan didengarkan oleh FrankenPHP
EXPOSE 8002

# Perintah yang akan dijalankan saat container dimulai (akan dieksekusi oleh entrypoint.sh)
CMD ["php", "artisan", "octane:start", "--host=0.0.0.0", "--port=8002", "--server=frankenphp", "--workers=auto"]
