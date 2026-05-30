# 🏨 StayFinder — Hệ thống Quản lý Đặt phòng

Bài tập lớn 2 · Hệ Cơ sở Dữ liệu · HK252

> Nền tảng tìm kiếm và quản lý chỗ ở (khách sạn, căn hộ, resort, villa) kết nối chủ sở hữu và khách hàng.

---

## 📁 Cấu trúc dự án

```
temp/
├── README.md               ← File này
├── prd.md                  ← Tài liệu yêu cầu sản phẩm
├── database/               ← SQL scripts (tạo bảng, insert data, procedure, trigger, function)
│   ├── 01_CREATEALLTABLE.sql
│   ├── 02_INSERTDATA.sql
│   ├── 03_UPDATEDERIVEDDATA.sql
│   ├── 04_PROCEDURE_INSERT_UPDATE_DELETE.sql
│   ├── 05_PROCEDURE_SEARCH.sql
│   ├── 06_FUNCTION.sql
│   └── 07_TRIGGER.sql
├── backend/                ← FastAPI (Python)
│   ├── main.py
│   ├── database.py
│   ├── accommodation.py
│   ├── schemas.py
│   ├── requirements.txt
│   ├── .env                ← Cấu hình kết nối MySQL (TỰ TẠO)
│   └── routers/
│       ├── accom_routers.py
│       └── api_stats.py
└── frontend/               ← ReactJS + Vite + Tailwind CSS
    ├── index.html
    ├── vite.config.js
    ├── package.json
    └── src/
        ├── main.jsx
        ├── App.jsx
        ├── index.css
        ├── api/index.js
        ├── components/
        └── pages/
```

---

## ⚙️ Yêu cầu cài đặt

| Phần mềm | Phiên bản khuyến nghị | Kiểm tra |
|-----------|----------------------|----------|
| **Node.js** | >= 18 | `node -v` |
| **npm** | >= 9 | `npm -v` |
| **Python** | >= 3.9 | `python --version` |
| **MySQL Server** | 8.0+ | `mysql --version` |
| **MySQL Workbench** | (tùy chọn) | Để quản lý DB trực quan |

---

## 🚀 Hướng dẫn chạy (Từng bước)

### Bước 1: Khởi tạo Database

1. **Mở MySQL Workbench** (hoặc MySQL CLI).

2. **Chạy các file SQL theo thứ tự** trong thư mục `database/`:

   ```sql
   -- Chạy lần lượt từng file:
   SOURCE 01_CREATEALLTABLE.sql;
   SOURCE 02_INSERTDATA.sql;
   SOURCE 03_UPDATEDERIVEDDATA.sql;
   SOURCE 04_PROCEDURE_INSERT_UPDATE_DELETE.sql;
   SOURCE 05_PROCEDURE_SEARCH.sql;
   SOURCE 06_FUNCTION.sql;
   SOURCE 07_TRIGGER.sql;
   ```

   Hoặc mở từng file trong MySQL Workbench và nhấn ⚡ **Execute**.

> **Lưu ý:** Database mặc định tên `BTL2`. Nếu file SQL có lệnh `CREATE DATABASE`, nó sẽ tự tạo. Nếu không, hãy tạo trước:
> ```sql
> CREATE DATABASE IF NOT EXISTS BTL2;
> USE BTL2;
> ```

---

### Bước 2: Cấu hình Backend

1. **Mở terminal** và di chuyển vào thư mục backend:
   ```bash
   cd backend
   ```

2. **Tạo file `.env`** (nếu chưa có) cùng thư mục với `main.py`:
   ```env
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=mat_khau_mysql_cua_ban
   DB_NAME=BTL2
   ```

   > ⚠️ **Quan trọng:** Thay `mat_khau_mysql_cua_ban` bằng mật khẩu root MySQL thực tế.
   > Nếu không nhớ mật khẩu, mở MySQL Workbench → xem connection đang dùng.

3. **Cài đặt thư viện Python:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Chạy Backend:**
   ```bash
   python -m uvicorn main:app --reload --port 8000 &
   ```
   

5. **Kiểm tra:** Mở trình duyệt → truy cập:
   - Trang chủ API: [http://localhost:8000](http://localhost:8000)
   - Health check: [http://localhost:8000/health](http://localhost:8000/health) → phải hiện `"database": "connected"`
   - Swagger docs: [http://localhost:8000/docs](http://localhost:8000/docs)

---

### Bước 3: Chạy Frontend

1. **Mở terminal mới** (giữ backend chạy ở terminal cũ) và di chuyển vào thư mục frontend:
   ```bash
   cd frontend
   ```

2. **Cài đặt dependencies:**
   ```bash
   npm install
   ```

3. **Chạy dev server:**
   ```bash
   npm run dev
   ```

4. **Mở trình duyệt:** [http://localhost:5173](http://localhost:5173)

---

## 🖥️ Các trang giao diện

| Trang | URL | Mô tả |
|-------|-----|--------|
| 🔍 **Tìm kiếm** | `http://localhost:5173/` | Trang chủ — tìm kiếm chỗ ở theo thành phố/tên |
| ⚙️ **Quản lý** | `http://localhost:5173/admin` | CRUD chỗ ở (Thêm / Sửa / Xóa) |
| 📊 **Thống kê** | `http://localhost:5173/stats` | Báo cáo doanh thu + Điểm tích lũy khách hàng |

---

## 🔌 API Endpoints

| Method | Endpoint | Chức năng |
|--------|----------|-----------|
| `GET` | `/api/cho-o/search?thanh_pho=&ten_cho_o=` | Tìm kiếm chỗ ở |
| `POST` | `/api/cho-o/` | Thêm chỗ ở mới |
| `PUT` | `/api/cho-o/` | Cập nhật chỗ ở |
| `DELETE` | `/api/cho-o/{ma_cho_o}` | Xóa chỗ ở |
| `GET` | `/api/thong-ke/doanh-thu?ThanhPho=&DoanhThuToiThieu=` | Thống kê doanh thu |
| `GET` | `/api/khach-hang/{id}/diem-tich-luy` | Điểm tích lũy khách hàng |
| `GET` | `/health` | Kiểm tra kết nối DB |

> 📖 Xem Swagger UI đầy đủ tại: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## ❓ Xử lý sự cố thường gặp

### 1. Lỗi "Không thể kết nối Database"

**Nguyên nhân:** Backend không kết nối được MySQL.

**Kiểm tra:**
- ✅ MySQL Server đang chạy? → Mở **Services** (Win+R → `services.msc`) → tìm `MySQL80` → phải ở trạng thái **Running**
- ✅ Mật khẩu đúng chưa? → Test bằng MySQL Workbench hoặc:
  ```bash
  mysql -u root -p
  ```
  Nhập mật khẩu → nếu vào được thì mật khẩu đúng → copy vào `.env`
- ✅ Database `BTL2` tồn tại chưa? → Trong MySQL chạy `SHOW DATABASES;`
- ✅ File `.env` đúng thư mục? → Phải nằm cùng thư mục với `main.py`
- ✅ Restart backend sau khi sửa `.env`:
  ```bash
  # Tắt backend (Ctrl+C) rồi chạy lại
  uvicorn main:app --reload --port 8000
  ```

### 2. Lỗi 502 Bad Gateway trên Frontend

**Nguyên nhân:** Backend chưa chạy hoặc không ở port 8000.

**Giải pháp:** Đảm bảo backend đang chạy ở port 8000 (xem Bước 2.4).

### 3. Lỗi "EPERM" hoặc "Execution Policy" khi chạy npm/npx

**Giải pháp:** Mở PowerShell với quyền Administrator và chạy:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 4. Lỗi khi xóa chỗ ở

**Nguyên nhân:** Chỗ ở đang có đơn đặt phòng chưa xử lý → Database từ chối xóa (đúng logic nghiệp vụ).

**Giải pháp:** Xử lý hết đơn đặt phòng liên quan trước khi xóa.

---

## 📦 Tech Stack

| Layer | Công nghệ |
|-------|-----------|
| **Database** | MySQL 8.0 (Stored Procedures, Triggers, Functions) |
| **Backend** | Python + FastAPI + mysql-connector-python |
| **Frontend** | ReactJS (Vite) + Tailwind CSS v4 |

---

## 👥 Nhóm thực hiện

Bài tập lớn 2 — Hệ Cơ sở Dữ liệu — HK252
