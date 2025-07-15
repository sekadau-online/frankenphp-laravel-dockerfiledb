# Menggunakan base image Caddy resmi
FROM caddy:2.7.5-alpine

# Mengatur direktori kerja di dalam container
WORKDIR /app

# Menyalin Caddyfile ke lokasi default Caddy
# Pastikan Caddyfile Anda bernama 'Caddyfile' dan berada di direktori yang sama dengan Dockerfile ini
COPY Caddyfile /etc/caddy/Caddyfile

# Menyalin direktori publik aplikasi Laravel.
# Ini diperlukan agar Caddy dapat melayani file statis secara langsung.
COPY public /app/public

# Mengekspos port default Caddy (HTTP)
EXPOSE 80
# Jika Anda mengaktifkan HTTPS, Caddy juga akan menggunakan port 443
EXPOSE 443

# Perintah default untuk menjalankan Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
