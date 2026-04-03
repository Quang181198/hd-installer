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
chmod +x setup.sh update.sh renew-license.sh
sudo ./update.sh
```

---

## 🔑 CẤP MÃ LICENSE CHO KHÁCH HÀNG

1. Mở file `HD_KeyGen_Trum_Cuoi.html` bằng trình duyệt
2. Nhập tên miền + ngày hết hạn → Copy mã
3. Khách hàng dán mã vào file `.env.local` tại dòng `HD_LICENSE_KEY=`

---

## 🔄 CẬP NHẬT LICENSE KEY (KHÔNG CẦN CÀI LẠI)

Dùng khi license hết hạn hoặc cần đổi mã mới cho khách hàng.

### Bước 1 — Chạy script gia hạn

```bash
cd /var/www/hd-installer && sudo ./renew-license.sh
```

Script sẽ tự động:
- Hiển thị license hiện tại (đã che bớt)
- Yêu cầu nhập License Key mới
- Cập nhật file `.env.local` (chỉ thay dòng `HD_LICENSE_KEY=`, giữ nguyên các biến khác)
- Khởi động lại container để áp dụng ngay

### Bước 2 — Kiểm tra sau khi gia hạn

```bash
# Xác nhận license mới đã được áp dụng
sudo docker exec transport-app-app-1 env | grep HD_LICENSE
```

> ⚠️ Nếu lệnh trên báo lỗi tên container, kiểm tra tên thực bằng: `sudo docker ps`

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
Transport-SaaS-Multi-Tenant
nano
https://yeduwmuejiwtflnkzkkq.supabase.co

HD_Transporttravel
nano
https://spdjyopcjvskkbrlqiud.supabase.co


Migrate database

npx supabase db dump --db-url "$OLD_DB_URL" -f schema.sql

export OLD_DB_URL='postgresql://postgres.yeduwmuejiwtflnkzkkq:NMQuang%40181198@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres'
export NEW_DB_URL='postgresql://postgres.spdjyopcjvskkbrlqiud:NMQuang%40181198@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres'       


psql "$NEW_DB_URL" -c "select now();"
npx supabase db dump --db-url "$OLD_DB_URL" -f schema.sql
psql --single-transaction --variable ON_ERROR_STOP=1 --file schema.sql --dbname "$NEW_DB_URL"

npx supabase db dump --db-url "$OLD_DB_URL" -f data.sql --use-copy --data-only -x "storage.buckets_vectors" -x "storage.vector_indexes"
psql --single-transaction --variable ON_ERROR_STOP=1 --file data.sql --dbname "$NEW_DB_URL"