#!/bin/bash
# ============================================================
# HD TRANSPORT - AUTO DEPLOY SCRIPT
# Tác dụng: Kéo bản mới nhất và khởi động lại hệ thống
# Sử dụng: sudo ./update.sh
# ============================================================

set -e

APP_DIR="/var/www/hd-installer/transport-app"
IMAGE="ghcr.io/quang181198/transport-web:latest"

clear
echo "========================================================"
echo "🔄 HD TRANSPORT - CẬP NHẬT HỆ THỐNG TỰ ĐỘNG"
echo "========================================================"
echo ""

# 1. Kiểm tra thư mục tồn tại
if [ ! -d "$APP_DIR" ]; then
    echo "❌ Không tìm thấy thư mục $APP_DIR"
    echo "   Vui lòng chạy ./setup.sh trước."
    exit 1
fi

# 2. Kiểm tra file .env.local
if [ ! -f "$APP_DIR/.env.local" ]; then
    echo "❌ Không tìm thấy file .env.local trong $APP_DIR"
    echo "   Vui lòng chạy ./setup.sh để cài đặt lại."
    exit 1
fi

echo "📥 Đang kéo bản mới nhất từ GitHub Container Registry..."
sudo docker pull $IMAGE

echo ""
echo "🔁 Đang khởi động lại hệ thống với bản mới..."
cd $APP_DIR
sudo docker compose down
sudo docker compose up -d

echo ""
echo "⏳ Đang chờ hệ thống khởi động (10 giây)..."
sleep 10

echo ""
echo "📊 Trạng thái hệ thống:"
sudo docker compose ps

echo ""
echo "========================================================"
echo "✅ CẬP NHẬT HOÀN TẤT!"
echo "========================================================"
echo ""

# Hiển thị domain đang chạy
DOMAIN=$(grep VPS_DOMAIN "$APP_DIR/.env" 2>/dev/null | cut -d'=' -f2 || echo "")
if [ -n "$DOMAIN" ]; then
    echo "🌐 Truy cập: https://$DOMAIN"
else
    echo "🌐 Truy cập trang web của bạn để kiểm tra."
fi
echo ""
