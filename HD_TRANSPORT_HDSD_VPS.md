# 📗 Hướng Dẫn Cài Đặt Hệ Thống HD Transport (Bao gồm License)

Chào mừng bạn đến với **HD Transport**! Đây là tài liệu hướng dẫn nhanh để bạn tự khởi tạo cỗ máy điều hành vận tải chuyên nghiệp trên máy chủ riêng (VPS) của mình chỉ trong vài phút.

---

## 🛠 BƯỚC 1: CHUẨN BỊ (Cần có trước khi cài)
Hãy đảm bảo bạn đã có sẵn 4 yếu tố sau:
1. **Máy chủ (VPS):** Hệ điều hành **Ubuntu 22.04**, cấu hình tối thiểu 2GB RAM.
2. **Tên miền (Domain):** Đã trỏ bản ghi **A** về địa chỉ IP của VPS (VD: `app.congty.com`).
3. **Mật mã Supabase:** API URL và các KEY (Lấy từ project Supabase của bạn).
4. **Mã Bản Quyền (License Key):** Đoạn mã dài do HD Transport cấp riêng cho tên miền của bạn.

---

## 🚀 BƯỚC 2: CÀI ĐẶT 1 CHẠM (Magic Setup)
Bạn chỉ cần đăng nhập vào VPS qua Terminal (quyền `root`) và chạy duy nhất 2 dòng lệnh sau:

```bash
# 1. Tải bộ cài đặt siêu nhẹ từ GitHub
git clone https://github.com/Quang181198/hd-installer.git
cd hd-installer

# 2. Phù phép hệ thống
chmod +x setup.sh
./setup.sh
```

### Quá trình cài đặt sẽ hỏi bạn:
- **Tên miền:** Nhập tên miền bạn đã chuẩn bị ở Bước 1.
- **Supabase Info:** Dán các thông số API URL và Key tương ứng.
- **License Key:** Dán mã bản quyền dài mà chúng tôi đã cung cấp.
- **Admin Account:** Tự tạo Email và Mật khẩu cho tài khoản Giám đốc.

⏳ **Thời gian chờ:** Khoảng 2-3 phút. Hệ thống sẽ tự động kéo **Hộp Đen (Docker Image)** từ GitHub về. Bạn hoàn toàn không cần lo lắng về việc cấu hình code hay máy chủ.

---

## 🌐 BƯỚC 3: TRẢI NGHIỆM
Khi màn hình hiện dòng chữ **"🎉 HOÀN TẤT CÀI ĐẶT HỘP ĐEN!"**, bạn có thể mở trình duyệt:
1. Truy cập: `https://ten-mien-cua-ban.com`
2. Đăng nhập bằng tài khoản Giám đốc vừa tạo.

---

## 🔧 Bảo trì & Nâng cấp (Dành cho Giám đốc)
Khi chúng tôi thông báo có phiên bản mới, bạn chỉ cần gõ:
```bash
cd ~/transport-app
sudo ./scripts/update-vps.sh
```
Hệ thống sẽ tự thay thế bản cũ bằng bản mới nhất trong vài giây. Dữ liệu của bạn luôn được giữ an toàn tuyệt đối trên Supabase.

---
*Chúc bạn có những chuyến đi thành công cùng HD Transport!*
