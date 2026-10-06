USE QuanLySieuThi;
GO

-- 1. TẠO CÁC ROLE (NHÓM QUYỀN)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'r_QuanLy')
    CREATE ROLE r_QuanLy;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'r_ThuNgan')
    CREATE ROLE r_ThuNgan;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'r_ThuKho')
    CREATE ROLE r_ThuKho;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'r_QuanLyDuLieu')
    CREATE ROLE r_QuanLyDuLieu;
GO

-- 2. CẤP QUYỀN HẠN CHI TIẾT CHO TỪNG ROLE

-- A. QUẢN LÝ (r_QuanLy)
GRANT SELECT ON dbo.HoaDon TO r_QuanLy;
GRANT SELECT ON dbo.ChiTietHoaDon TO r_QuanLy;
GRANT SELECT ON dbo.PhieuNhap TO r_QuanLy;
GRANT SELECT ON dbo.ChiTietPhieuNhap TO r_QuanLy;
GRANT SELECT ON dbo.SanPham TO r_QuanLy;
GRANT SELECT ON dbo.NhanVien TO r_QuanLy;
GRANT SELECT ON dbo.KhachHang TO r_QuanLy;

GRANT EXECUTE ON dbo.sp_ThongKeDoanhThuTheoNhanVien TO r_QuanLy;
GRANT EXECUTE ON dbo.sp_ThongKeDoanhThuTheoKhoangNgay TO r_QuanLy;
GRANT EXECUTE ON dbo.sp_LayDanhSachSanPhamSapHetHangTheoSoLuong TO r_QuanLy;
GRANT EXECUTE ON dbo.fn_TinhTongDoanhThuNgay TO r_QuanLy;

-- B. NHÂN VIÊN BÁN HÀNG / THU NGÂN (r_ThuNgan)
GRANT SELECT ON dbo.SanPham TO r_ThuNgan;
GRANT SELECT ON dbo.KhachHang TO r_ThuNgan;
GRANT SELECT ON dbo.HoaDon TO r_ThuNgan;
GRANT SELECT ON dbo.ChiTietHoaDon TO r_ThuNgan;

GRANT INSERT ON dbo.HoaDon TO r_ThuNgan;
GRANT INSERT ON dbo.ChiTietHoaDon TO r_ThuNgan;
GRANT INSERT ON dbo.KhachHang TO r_ThuNgan;

GRANT EXECUTE ON dbo.sp_ThemKhachHang TO r_ThuNgan;
GRANT EXECUTE ON dbo.sp_TimKiemSanPhamTheoTen TO r_ThuNgan;
GRANT EXECUTE ON dbo.sp_TimHoaDonTheoKhachHang TO r_ThuNgan;
GRANT EXECUTE ON dbo.fn_KiemTraSoLuongTonSanPham TO r_ThuNgan;
GRANT EXECUTE ON dbo.fn_TinhTongTienHoaDon TO r_ThuNgan;

-- C. THỦ KHO (r_ThuKho)
GRANT SELECT ON dbo.SanPham TO r_ThuKho;
GRANT SELECT ON dbo.DanhMuc TO r_ThuKho;
GRANT SELECT ON dbo.NhaCungCap TO r_ThuKho;
GRANT SELECT ON dbo.PhieuNhap TO r_ThuKho;
GRANT SELECT ON dbo.ChiTietPhieuNhap TO r_ThuKho;

GRANT INSERT ON dbo.PhieuNhap TO r_ThuKho;
GRANT INSERT ON dbo.ChiTietPhieuNhap TO r_ThuKho;

GRANT EXECUTE ON dbo.sp_LayDanhSachSanPhamSapHetHangTheoSoLuong TO r_ThuKho;
GRANT EXECUTE ON dbo.fn_KiemTraSoLuongTonSanPham TO r_ThuKho;

-- D. NHÂN VIÊN QUẢN LÝ DỮ LIỆU (r_QuanLyDuLieu)
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.SanPham TO r_QuanLyDuLieu;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.DanhMuc TO r_QuanLyDuLieu;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.NhaCungCap TO r_QuanLyDuLieu;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.KhachHang TO r_QuanLyDuLieu;

GRANT EXECUTE ON dbo.sp_CapNhatGiaSanPham TO r_QuanLyDuLieu;
GO

-- 3. STORED PROCEDURE XÁC THỰC VÀ TRẢ VỀ VAI TRÒ DÙNG CHO PHÂN QUYỀN HỆ THỐNG
CREATE PROCEDURE sp_KiemTraDangNhap
    @tenDangNhap NVARCHAR(50),
    @matKhau NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        tk.maTK,
        tk.tenDangNhap,
        tk.vaiTro,
        CASE tk.vaiTro
            WHEN 1 THEN N'Quản lý'
            WHEN 2 THEN N'Thu ngân'
            WHEN 3 THEN N'Thủ kho'
            WHEN 0 THEN N'Nhân viên dữ liệu'
        END AS TenVaiTro,
        nv.maNV,
        nv.hoTen AS TenNhanVien,
        nv.chucVu
    FROM TaiKhoan tk
    LEFT JOIN NhanVien nv ON tk.maTK = nv.maTK
    WHERE tk.tenDangNhap = @tenDangNhap 
      AND tk.matKhau = @matKhau 
      AND tk.trangThai = 1;
END;
GO
