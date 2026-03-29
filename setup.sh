#!/bin/bash
set -e

# Tiền tố đồng bộ: Đưa người dùng vào thư mục làm việc chuẩn
echo "========================================================"
echo "🚀 HD TRANSPORT - TRÌNH KHỞI TẠO HỆ THỐNG (SAAS)"
echo "========================================================"

# 1. Tạo thư mục làm việc sạch sẽ
mkdir -p transport-app/scripts && cd transport-app

# 2. Tự động sinh file docker-compose.yml 
# Sử dụng Block Style (thụt lề) để đảm bảo không lỗi cú pháp YAML
cat <<INNER_EOF > docker-compose.yml
version: '3.8'
services:
  app:
    image: ghcr.io/quang181198/transport-web:latest
    restart: unless-stopped
    env_file:
      - .env.local
    expose:
      - "3000"

  caddy:
    image: caddy:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    environment:
      - VPS_DOMAIN=\${VPS_DOMAIN}
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - app

volumes:
  caddy_data:
  caddy_config:
INNER_EOF

# 3. Tự động sinh file Caddyfile
cat <<INNER_EOF > Caddyfile
{
  email admin@{\$VPS_DOMAIN}
}

{\$VPS_DOMAIN} {
  reverse_proxy app:3000
}
INNER_EOF

# 4. Tự động sinh file Install & Update con
cat <<INNER_EOF > scripts/install-vps.sh
#!/bin/bash
set -e
echo "🟢 Đang cài đặt HD Transport..."

# QUAN TRỌNG: Phải kéo Hộp Đen mới nhất từ GitHub VỀ TRƯỚC khi chạy cài đặt
echo "📥 Đang kiểm tra và tải Hộp Đen mới nhất từ GitHub (Bản vá lỗi scripts)..."
sudo docker pull ghcr.io/quang181198/transport-web:latest

read -p "❓ Nhập Tên miền (VD: dieuhanh.abc.com): " VPS_DOMAIN
echo "VPS_DOMAIN=\$VPS_DOMAIN" > .env

# CHẠY SETUP TRONG CONTAINER: 
# Chúng ta KHÔNG dùng -v (pwd):/app để tránh đè mất thư mục /app trong container.
# Chúng ta dùng -v (pwd):/host và sao chép file cấu hình (.env.local) ra ngoài host.
sudo docker run --rm -it \\
    -v \$(pwd):/host \\
    -w /app \\
    ghcr.io/quang181198/transport-web:latest \\
    bash -c "npx tsx scripts/setup.ts && cp .env.local /host/"

sudo docker compose up -d
echo "🎉 XONG! Truy cập: https://\$VPS_DOMAIN"
INNER_EOF

cat <<INNER_EOF > scripts/update-vps.sh
#!/bin/bash
echo "📥 Đang kéo bản cập nhật Hộp Đen mới nhất..."
sudo docker pull ghcr.io/quang181198/transport-web:latest
sudo docker compose up -d
echo "✅ Đã cập nhật xong!"
INNER_EOF

chmod +x scripts/*.sh

# 5. Kích hoạt trình cài đặt ngay lập tức
sudo ./scripts/install-vps.sh
