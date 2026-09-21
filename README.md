# Quản lý thông tin - Project README

Dự án này là một bài tập quản lý cơ sở dữ liệu cho hệ thống siêu thị, tập trung vào việc xây dựng và quản lý dữ liệu liên quan đến sản phẩm, nhân viên, khách hàng, nhà cung cấp, phiếu nhập, hóa đơn và tồn kho.

## Thư mục Assignment

Thư mục [Assignment](Assignment) chứa các file SQL chính để tạo, khởi tạo và xử lý cơ sở dữ liệu cho hệ thống.

### 1. [Assignment/schema.sql](Assignment/schema.sql)
- File này định nghĩa cấu trúc cơ sở dữ liệu cho hệ thống siêu thị.
- Bao gồm các bảng như:
  - `TaiKhoan`
  - `DanhMuc`
  - `NhaCungCap`
  - `KhachHang`
  - `NhanVien`
  - `SanPham`
  - `PhieuNhap`
  - `HoaDon`
  - `ChiTietPhieuNhap`
  - `ChiTietHoaDon`
- File này là phần "khung dữ liệu" của dự án, dùng để tạo database và các quan hệ giữa các bảng.

### 2. [Assignment/DDL_querries.sql](Assignment/DDL_querries.sql)
- File này chứa các câu lệnh DDL và các đối tượng nghiệp vụ nâng cao của database.
- Bao gồm:
  - Stored procedure để thêm khách hàng, tìm kiếm sản phẩm, thống kê doanh thu, kiểm tra hàng sắp hết, cập nhật giá bán.
  - Function để tính tổng doanh thu theo ngày, kiểm tra tồn kho, và lấy hóa đơn của khách hàng.
  - Trigger để tự động cập nhật tồn kho, tổng tiền hóa đơn, kiểm tra số lượng bán và giá bán hợp lệ.
- Đây là phần xử lý logic nghiệp vụ và ràng buộc dữ liệu trong hệ thống.

### 3. [Assignment/DML_querries.sql](Assignment/DML_querries.sql)
- File này chứa dữ liệu mẫu để nạp vào database.
- Bao gồm:
  - Thêm tài khoản người dùng.
  - Thêm danh mục sản phẩm.
  - Thêm nhà cung cấp, khách hàng, nhân viên.
  - Thêm sản phẩm và phiếu nhập.
  - Thêm hóa đơn và chi tiết hóa đơn.
- File này giúp kiểm tra và chạy thử hệ thống với dữ liệu thực tế mẫu.

## Mục tiêu của dự án

Dự án này mô phỏng một hệ thống quản lý siêu thị với các chức năng chính:
- Quản lý tài khoản và phân quyền nhân viên.
- Quản lý danh mục và sản phẩm.
- Quản lý nhà cung cấp và nhập hàng.
- Quản lý khách hàng và hóa đơn bán hàng.
- Theo dõi tồn kho và doanh thu.
- Áp dụng các trigger, procedure, function để tự động hóa nghiệp vụ.

## Hướng dẫn sử dụng

1. Chạy file [Assignment/schema.sql](Assignment/schema.sql) để tạo cơ sở dữ liệu và bảng dữ liệu.
2. Chạy file [Assignment/DDL_querries.sql](Assignment/DDL_querries.sql) để tạo stored procedure, function và trigger.
3. Chạy file [Assignment/DML_querries.sql](Assignment/DML_querries.sql) để nhập dữ liệu mẫu.

> Đây là một bài tập về cơ sở dữ liệu SQL, phù hợp để thực hành thiết kế schema, thao tác dữ liệu và logic nghiệp vụ trong hệ thống quản lý siêu thị.
