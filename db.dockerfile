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
    autoconf \
    g++ \
    make \
    && \
    docker-php-ext-install zip pcntl pdo pdo_mysql && \
    pecl install redis && docker-php-ext-enable redis && \
    apt-get purge -y --auto-remove autoconf g++ make && \
    rm -rf /var/lib/apt/lists/*

# --- Menyalin SELURUH Aplikasi Pertama ---
COPY --chown=www-data:www-data . /app

# --- Konfigurasi dan Instalasi Composer ---
ENV COMPOSER_PROCESS_TIMEOUT=600 \
    COMPOSER_MEMORY_LIMIT=-1

RUN echo "--- Memeriksa konektivitas ke Packagist ---" && \
    curl -vvv --max-time 30 https://repo.packagist.org/packages.json || true && \
    echo "--- Menginstal dependensi Composer ---" && \
    composer install --no-interaction --prefer-dist --optimize-autoloader --verbose && \
    echo "--- Menginstal Laravel Octane ---" && \
    composer require laravel/octane --no-interaction --prefer-dist --verbose

# --- Instalasi dan Optimasi Laravel Octane ---
RUN composer dump-autoload && \
    php artisan octane:install --server=frankenphp --force

# Mengekspos port yang akan didengarkan oleh FrankenPHP
EXPOSE 8002

# Perintah yang akan dijalankan saat container dimulai
CMD php artisan optimize && \
    php artisan octane:start --host=0.0.0.0 --port=8002 --server=frankenphp --workers=4
