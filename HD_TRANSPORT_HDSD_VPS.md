# 🚛 HD TRANSPORT - HƯỚNG DẪN VẬN HÀNH VPS

---

## 🔌 KẾT NỐI VPS

```bash
ssh root@<IP_VPS>
```

---

## 🚀 PHẦN 1: CÀI ĐẶT LẦN ĐẦU (VPS TRỐNG)

### Bước 1 — Tải bộ cài

```bash
mkdir -p /var/www && cd /var/www
git clone https://github.com/Quang181198/hd-installer.git
cd hd-installer
chmod +x setup.sh update.sh
```

### Bước 2 — Chạy cài đặt

```bash
./setup.sh
```

Trong lúc chạy, bạn sẽ được hỏi:
- **Tên miền** (VD: `dieuhanh.congty.com`)
- **4 thông số Supabase** (lấy tại Supabase → Project Settings)
- **Mã License Key** (do HD Transport cấp)

> Script tự động cài Docker, kéo Image, cấu hình HTTPS và khởi động hệ thống.

### Bước 3 — Ghi lại file `.env.local` (BẮT BUỘC)

> ⚠️ Sau khi `./setup.sh` chạy xong, bạn phải thực hiện bước này để tránh lỗi.

Dán lệnh dưới vào VPS, **thay các giá trị `XXXX` bằng dữ liệu thực của bạn**:

```bash
cat > /var/www/hd-installer/transport-app/.env.local << 'EOF'
NEXT_PUBLIC_SUPABASE_URL=https://XXXX.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=XXXX
SUPABASE_SERVICE_ROLE_KEY=XXXX
HD_LICENSE_KEY=XXXX
NEXT_PUBLIC_APP_NAME=HD Transport Management
NEXT_PUBLIC_APP_URL=https://ten-mien-cua-ban.com
EOF
```

Sau đó khởi động lại:

```bash
cd /var/www/hd-installer/transport-app
sudo docker compose down && sudo docker compose up -d
```

### ✅ Kiểm tra hoạt động

```bash
# Xem container đang chạy
sudo docker ps

# Kiểm tra env đã đúng chưa
sudo docker exec transport-app-app-1 env | grep -E "NEXT_PUBLIC|HD_LICENSE"
```

Truy cập trang web qua tên miền đã cấu hình.

---

## 🔄 PHẦN 2: CẬP NHẬT KHI CÓ CODE MỚI

Chỉ cần **1 lệnh duy nhất**:

```bash
cd /var/www/hd-installer && sudo ./update.sh
```

> File `.env.local`, cấu hình và dữ liệu database **không bị ảnh hưởng**.

### ❌ Nếu gặp lỗi `git pull bị chặn`

```
error: Your local changes to the following files would be overwritten by merge: setup.sh
```

Chạy lệnh này để bỏ qua và lấy bản mới:

```bash
cd /var/www/hd-installer
git reset --hard origin/main && git pull
chmod +x setup.sh update.sh
sudo ./update.sh
```

---

## 🔑 CẤP MÃ LICENSE CHO KHÁCH HÀNG

1. Mở file `HD_KeyGen_Trum_Cuoi.html` bằng trình duyệt
2. Nhập tên miền + ngày hết hạn → Copy mã
3. Khách hàng dán mã vào file `.env.local` tại dòng `HD_LICENSE_KEY=`

---

## 🧹 CÀI LẠI TỪ ĐẦU (KHI CẦN)

Dùng khi đổi Supabase, đổi tên miền, hoặc lỗi nặng:

```bash
# Dọn sạch
cd /var/www/hd-installer/transport-app && sudo docker compose down
cd /var/www/hd-installer && sudo rm -rf transport-app
sudo docker image rm ghcr.io/quang181198/transport-web:latest -f

# Cài lại
git reset --hard origin/main && git pull
chmod +x setup.sh update.sh
./setup.sh
# → Sau đó thực hiện lại Bước 3 (ghi .env.local)
```

---

## 🛑 XEM LOG KHI CÓ SỰ CỐ

```bash
cd /var/www/hd-installer/transport-app
sudo docker compose logs app --tail=50     # Log ứng dụng
sudo docker compose logs caddy --tail=30  # Log HTTPS
```
