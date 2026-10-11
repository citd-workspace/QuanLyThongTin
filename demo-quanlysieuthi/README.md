# Demo QuanLySieuThi – IE103

Backend: Node.js (Express + mssql). Frontend: HTML/CSS/JS thuần.
Mọi dữ liệu và mã nguồn Procedure/Trigger hiển thị trên web đều được đọc từ SQL Server.

## 1. Chuẩn bị database
1. Chạy `schema.sql` (tạo database + bảng).
2. Chạy `DML_querries.sql` (dữ liệu mẫu). **Xóa dòng `create database QuanLySieuThi; go` ở đầu file** và thêm `use QuanLySieuThi; go` (database đã tồn tại).
3. Chạy `DDL_querries.sql` để tạo Procedure / Function / Trigger. Chỉ cần các lệnh `CREATE`; các lệnh EXEC/INSERT/UPDATE thử ở cuối mỗi phần sẽ làm thay đổi dữ liệu mẫu, có thể bỏ qua.
4. (Tùy chọn) `phanquyen.sql`.
5. SQL Server cần bật **SQL Server Authentication** và **TCP/IP** (SQL Server Configuration Manager, port 1433), có một login SQL (vd: `sa`).

## 2. Chạy web
```
npm install
copy .env.example .env     (Windows)   |   cp .env.example .env   (Mac/Linux)
# sửa .env cho đúng
npm start
```
Mở http://localhost:3000

## 3. Cấu trúc
- `server.js`: API, kết nối SQL Server, chạy lệnh trong transaction.
- `demos.js`: danh sách chức năng demo (bài toán, câu lệnh thực thi, bảng liên quan).
- `reports.js`: các truy vấn cho biểu đồ phần B.
- `public/`: giao diện (index.html, app.js, style.css). Ảnh Tableau/Power BI bỏ vào `public/reports/`.

## 4. Thêm chức năng demo mới
Thêm một object vào `demos.js` với: `id`, `group`, `object` (tên procedure/trigger trong DB), `problem`, `params`, `exec`, `tables`.
