#!/bin/bash
set -e

# 0. LÀM SẠCH MÀN HÌNH THEO Ý BẠN
clear

echo "========================================================"
echo "🚀 HD TRANSPORT - TRÌNH KHỞI TẠO HỆ THỐNG (SAAS PRO)"
echo "========================================================"

# 1. KIỂM TRA VÀ CÀI ĐẶT DOCKER TỰ ĐỘNG
if ! command -v docker &> /dev/null; then
    echo "🟡 Docker chưa được cài đặt. Đang tiến hành cài đặt Docker (Mất khoảng 1-2 phút)..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    sudo rm get-docker.sh
    echo "✅ Cài đặt Docker thành công."
fi

if ! docker compose version &> /dev/null; then
    echo "🟡 Docker Compose chưa được cài đặt. Đang tiến hành tải plugin..."
    sudo apt-get update && sudo apt-get install -y docker-compose-plugin
    echo "✅ Cài đặt Docker Compose thành công."
fi

# 2. Tạo thư mục làm việc sạch sẽ
mkdir -p transport-app/scripts && cd transport-app

# 3. Tự động sinh file docker-compose.yml (THÊM DNS ĐỂ GIẢI QUYẾT LỖI SSL)
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
    dns:
      - 8.8.8.8
      - 1.1.1.1

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
    dns:
      - 8.8.8.8
      - 1.1.1.1

volumes:
  caddy_data:
  caddy_config:
INNER_EOF

# 4. Tự động sinh file Caddyfile
cat <<INNER_EOF > Caddyfile
{
  email admin@{\$VPS_DOMAIN}
}

{\$VPS_DOMAIN} {
  reverse_proxy app:3000
}
INNER_EOF

# 5. Tự động sinh file Install & Update con
cat <<INNER_EOF > scripts/install-vps.sh
#!/bin/bash
set -e
echo "🟢 Đang cài đặt HD Transport..."

# PHẢI PULL TRƯỚC ĐỂ LẤY BẢN ĐÚC JS MỚI NHẤT
echo "📥 Đang kiểm tra và tải Hộp Đen mới nhất (Bản Pro JS)..."
sudo docker pull ghcr.io/quang181198/transport-web:latest

read -p "❓ Nhập Tên miền (VD: dieuhanh.abc.com): " VPS_DOMAIN
echo "VPS_DOMAIN=\$VPS_DOMAIN" > .env

# CHẠY SETUP TRONG CONTAINER: Dùng node chạy setup.js
sudo docker run --rm -it \\
    -u root \\
    -v \$(pwd):/host \\
    -w /app \\
    ghcr.io/quang181198/transport-web:latest \\
    sh -c "node scripts/setup.js && cp .env.local /host/"

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

# 6. Kích hoạt trình cài đặt ngay lập tức
sudo ./scripts/install-vps.sh
