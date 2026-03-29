#!/bin/bash
set -e

echo "========================================================"
echo "🚀 HD TRANSPORT - TRÌNH KHỞI TẠO HỆ THỐNG (SAAS)"
echo "========================================================"

# 1. Tạo thư mục làm việc sạch sẽ
mkdir -p transport-app/scripts && cd transport-app

# 2. Tự động sinh file docker-compose.yml (Hộp Đen)
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  app:
    image: ghcr.io/quang181198/transport-web:latest
    restart: unless-stopped
    env_file: [.env.local]
    expose: ["3000"]
  caddy:
    image: caddy:alpine
    restart: unless-stopped
    ports: ["80:80", "443:443"]
    environment: { VPS_DOMAIN: \${VPS_DOMAIN} }
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    depends_on: [app]
volumes: { caddy_data: {}, caddy_config: {} }
EOF

# 3. Tự động sinh file Caddyfile
cat <<EOF > Caddyfile
{ email admin@{\$VPS_DOMAIN} }
{\$VPS_DOMAIN} { reverse_proxy app:3000 }
EOF

# 4. Tự động sinh file Install & Update con
cat <<EOF > scripts/install-vps.sh
#!/bin/bash
set -e
read -p "❓ Nhập Tên miền (VD: app.congty.com): " VPS_DOMAIN
echo "VPS_DOMAIN=\$VPS_DOMAIN" > .env
sudo docker run --rm -it -v \$(pwd):/app -w /app ghcr.io/quang181198/transport-web:latest npx tsx scripts/setup.ts
sudo docker compose pull
sudo docker compose up -d
EOF

cat <<EOF > scripts/update-vps.sh
#!/bin/bash
sudo docker compose pull app && sudo docker compose up -d
EOF

chmod +x scripts/*.sh

# 5. Kích hoạt trình cài đặt ngay lập tức
sudo ./scripts/install-vps.sh

echo "🎉 HOÀN TẤT CÀI ĐẶT HỘP ĐEN!"
