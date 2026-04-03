#!/bin/bash
# =============================================================
# renew-license.sh — Cập nhật License Key HD Transport
# =============================================================
# MỤC ĐÍCH:
#   Thay thế HD_LICENSE_KEY trong file .env.local và restart
#   container để áp dụng ngay, mà KHÔNG cần cài lại từ đầu.
#
# CÁCH DÙNG:
#   cd /var/www/hd-installer
#   sudo ./renew-license.sh
#
# YÊU CẦU:
#   - Đã chạy ./setup.sh ít nhất 1 lần
#   - File .env.local phải tồn tại tại đường dẫn ENV_FILE bên dưới
#   - Có quyền sudo
#
# LƯU Ý:
#   - Script CHỈ thay dòng HD_LICENSE_KEY=, các biến khác giữ nguyên
#   - License Key do HD Transport cấp (tạo bằng HD_KeyGen_Trum_Cuoi.html)
# =============================================================
set -e

ENV_FILE="/var/www/hd-installer/transport-app/.env.local"
APP_DIR="/var/www/hd-installer/transport-app"

clear
echo "========================================================"
echo "🔑 HD TRANSPORT - CẬP NHẬT LICENSE KEY"
echo "========================================================"

# Kiểm tra file .env.local tồn tại
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Không tìm thấy file .env.local tại: $ENV_FILE"
    echo "   Vui lòng chạy ./setup.sh trước."
    exit 1
fi

# Hiển thị license hiện tại (che bớt)
CURRENT_KEY=$(grep "^HD_LICENSE_KEY=" "$ENV_FILE" | cut -d'=' -f2-)
if [ -n "$CURRENT_KEY" ]; then
    MASKED="${CURRENT_KEY:0:6}****${CURRENT_KEY: -4}"
    echo ""
    echo "📋 License hiện tại: $MASKED"
fi

# Nhập license mới
echo ""
read -p "🔑 Nhập License Key mới: " NEW_LICENSE

if [ -z "$NEW_LICENSE" ]; then
    echo "❌ License Key không được để trống."
    exit 1
fi

# Cập nhật HD_LICENSE_KEY trong .env.local
if grep -q "^HD_LICENSE_KEY=" "$ENV_FILE"; then
    sed -i "s|^HD_LICENSE_KEY=.*|HD_LICENSE_KEY=$NEW_LICENSE|" "$ENV_FILE"
else
    echo "HD_LICENSE_KEY=$NEW_LICENSE" >> "$ENV_FILE"
fi

echo ""
echo "✅ Đã cập nhật License Key thành công."

# Restart container để áp dụng
echo "🔄 Đang khởi động lại hệ thống để áp dụng..."
cd "$APP_DIR"
sudo docker compose down
sudo docker compose up -d

echo ""
echo "🎉 XONG! License mới đã được kích hoạt."
echo ""

# Xác nhận lại
echo "📋 Kiểm tra license trong container:"
sudo docker exec "$(sudo docker compose ps -q app)" env | grep HD_LICENSE || true
