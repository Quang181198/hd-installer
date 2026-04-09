# 🚛 HD TRANSPORT - HƯỚNG DẪN VẬN HÀNH VPS (Multi-Tenant SaaS)

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

| # | Thông tin | Ví dụ |
|---|-----------|-------|
| 1 | Tên miền | `dieuhanh.congty.com` |
| 2 | PostgreSQL Connection String | `postgresql://postgres.xxx:pw@...` |
| 3 | Supabase URL | `https://xxx.supabase.co` |
| 4 | Supabase Anon Key | `eyJhbGci...` |
| 5 | Supabase Service Role Key | `eyJhbGci...` |
| 6 | Tên Công Ty (Tenant) | `Công Ty ABC` |
| 7 | Slug Tenant | `cong-ty-abc` |
| 8 | Email Admin | `admin@congty.com` |
| 9 | Mật khẩu Admin | Tối thiểu 6 ký tự |
| 10 | Mã License Key | Do HD Transport cấp |

> Script tự động cài Docker, chạy schema + tất cả migrations (bao gồm multi-tenant), tạo Tenant + Admin, cấu hình HTTPS và khởi động hệ thống.

### Bước 3 — Bật Custom Access Token Hook (BẮT BUỘC)

> ⚠️ **Bước này bắt buộc để multi-tenant hoạt động đúng.**

1. Vào **Supabase Dashboard** → **Authentication** → **Hooks**
2. Bật **Custom Access Token Hook**
3. Chọn schema: `public`, function: `custom_access_token_hook`
4. Nhấn **Save**

### Bước 4 — Ghi lại file `.env.local` (nếu cần)

> Thông thường, `setup.sh` đã tự tạo file này. Nếu cần ghi lại thủ công:

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

Truy cập trang web qua tên miền đã cấu hình → Đăng nhập bằng Email Admin đã tạo.

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

## 🏢 PHẦN 3: QUẢN LÝ TENANT & USERS

### Dùng HD Admin Console (Super Admin)

Mở file `Admin_tools/HD_Admin_Console.html` bằng trình duyệt. Công cụ này có 2 tab:

| Tab | Chức năng |
|-----|-----------|
| **Cấp Phép Bản Quyền** | Tạo License Key cho khách hàng |
| **Quản Lý Tenant** | CRUD Tenant, xem/thêm User, Reset Password |

**Luồng onboarding khách mới:**
1. Mở Admin Console → tab Quản Lý Tenant → **Thêm Tenant**
2. Nhập Slug, Tên Công Ty, Gói, Email + Mật khẩu Admin đầu tiên
3. Bật Custom Access Token Hook trên Supabase (nếu chưa bật)
4. Cấp License Key → tab Cấp Phép Bản Quyền → nhập tên miền + ngày hết hạn
5. Gửi thông tin đăng nhập + License Key cho khách

### Dùng Settings trong App (Tenant Admin)

Tenant Admin đăng nhập app → **Settings** → có 2 tab:

| Tab | Chức năng |
|-----|-----------|
| **🏢 Công ty** | Cấu hình thương hiệu, logo, thông tin công ty |
| **👥 Người dùng** | Thêm/sửa user, phân quyền, reset mật khẩu |

---

## 🧹 PHẦN 4: CÀI LẠI TỪ ĐẦU (KHI CẦN)

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
# → Sau đó thực hiện lại Bước 3 (bật Custom Access Token Hook)
```

---

## 🛑 PHẦN 5: XEM LOG KHI CÓ SỰ CỐ

```bash
cd /var/www/hd-installer/transport-app
sudo docker compose logs app --tail=50     # Log ứng dụng
sudo docker compose logs caddy --tail=30   # Log HTTPS
```

---

## 📋 TÓM TẮT CẤU TRÚC DATABASE (Multi-Tenant)

| Bảng | Vai trò |
|------|---------|
| `tenants` | Danh sách công ty (slug, name, plan, max_users) |
| `user_profiles` | Users thuộc tenant (role, is_active, tenant_id) |
| `bookings` | Đơn hàng (scoped by tenant_id) |
| `assignments` | Phân công xe/lái xe (scoped by tenant_id) |
| `vehicles` / `drivers` | Tài nguyên (scoped by tenant_id) |
| `app_settings` | Cấu hình công ty (scoped by tenant_id) |

> Tất cả bảng business đều có `tenant_id` NOT NULL + RLS policy tự động lọc theo JWT claim `tenant_id`.