use QuanLySieuThi;
go

-- (5) Stored Procedure
-- thêm khách hàng 
CREATE PROCEDURE sp_ThemKhachHang
    @hoTen nvarchar(100), @sdt varchar(15), @diaChi nvarchar(255),@email varchar(100)
AS
    BEGIN
        INSERT INTO KhachHang(HoTen, SDT, DiaChi, Email) values (@hoTen, @sdt, @diaChi, @email);
    END;
go

-- tìm kiếm sản phẩm theo tên
CREATE PROCEDURE sp_TimKiemSanPhamTheoTen
    @keyword nvarchar(100)
AS
    BEGIN
        SELECT * FROM SanPham WHERE tenSP LIKE '%' + @keyword + '%';
    END;
go

-- Thống kê doan hthu theo nhân viên
CREATE PROCEDURE sp_ThongKeDoanhThuTheoNhanVien
AS
    BEGIN
        SELECT nv.maNV, nv.hoTen, SUM(hd.tongTien) as N'Tổng doanh thu'
        FROM NhanVien nv JOIN HoaDon hd ON nv.maNV = hd.maNV
        GROUP BY nv.maNV, nv.hoTen;
    END;
go

-- lấy danh sách sản phẩm sắp hết hàng 
CREATE PROCEDURE sp_LayDanhSachSanPhamSapHetHangTheoSoLuong @soLuongTon int
AS
    BEGIN
        SELECT maSP, tenSP, soLuongTon FROM SanPham WHERE soLuongTon < @soLuongTon;
    END;
go

--cập nhật giá sản phẩm 
CREATE PROCEDURE sp_CapNhatGiaSanPham
    @maSP varchar(10), @giaBanMoi FLOAT
AS
    BEGIN
        UPDATE SanPham SET giaBan = @giaBanMoi WHERE maSP = @maSP;
    END;
go

-- (3) Functions:
-- tính tổng doanh thu 1 ngày
CREATE FUNCTION fn_TinhTongDoanhThuNgay(@ngay date)
RETURNS FLOAT
AS
    BEGIN
        DECLARE @tongDoanhThu FLOAT;
        SELECT @tongDoanhThu = SUM(tongTien) FROM HoaDon WHERE cast(ngayLap as date) = @ngay;
        return isnull(@tongDoanhThu, 0);
    END;
go

-- kiểm tra số lượng tồn của sản phẩm return int
CREATE FUNCTION fn_KiemTraSoLuongTonSanPham(@maSP varchar(10))
RETURNS INT
AS 
    BEGIN
        DECLARE @soLuongTon INT;
        SELECT @soLuongTon = soLuongTon FROM SanPham WHERE maSP = @maSP;
        return isnull(@soLuongTon, 0);;
    END;
go

-- lấy danh sách hóa đơn của khách hàng return table
CREATE FUNCTION fn_LayDanhSachHoaDonCuaKhachHang(@maKH int)
RETURNS TABLE
AS
    RETURN(
        SELECT maHD,ngayLap,tongTien FROM HoaDon WHERE maKH = @maKH
    );
go

-- (5) Triggers:
-- 1. Tự động trừ tồn kho khi bán hàng
CREATE TRIGGER trg_TruToKhoKhiBanHang on ChiTietHoaDon
AFTER INSERT
AS
BEGIN
    BEGIN TRY
        UPDATE SanPham
        SET soLuongTon = soLuongTon - inserted.soLuongBan
        FROM SanPham JOIN inserted ON SanPham.maSP = inserted.maSP;
        
        PRINT N'LOG THÀNH CÔNG: Đã trừ tồn kho tự động!';
    END TRY
    BEGIN CATCH
        PRINT N'LOG LỖI: Quá trình trừ tồn kho thất bại. Chi tiết: ' + ERROR_MESSAGE();
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    END CATCH
END;
go

-- 2. Tự động cộng tồn kho khi nhập hàng
CREATE TRIGGER trg_CongTonKhoKhiNhapHang on ChiTietPhieuNhap
AFTER INSERT
AS
BEGIN
    BEGIN TRY
        UPDATE SanPham
        SET soLuongTon = soLuongTon + inserted.soLuongNhap
        FROM SanPham JOIN inserted ON SanPham.maSP = inserted.maSP;
        
        PRINT N'LOG THÀNH CÔNG: Đã cộng tồn kho tự động!';
    END TRY
    BEGIN CATCH
        PRINT N'LOG LỖI: Quá trình cộng tồn kho thất bại. Chi tiết: ' + ERROR_MESSAGE();
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    END CATCH
END;
go

-- 3. Chặn không cho phép bán nếu số lượng mua lớn hơn số lượng tồn
CREATE TRIGGER trg_KiemTraSoLuongTonKhiBanHang on ChiTietHoaDon INSTEAD OF INSERT
AS
BEGIN 
    BEGIN TRY
        DECLARE @maSP varchar(10), @slBan int, @slTon int;
        SELECT @maSP = maSP, @slBan = soLuongBan FROM inserted;
        SELECT @slTon = soLuongTon FROM SanPham WHERE maSP = @maSP;

        IF (@slBan > @slTon)
        BEGIN
            -- Quăng lỗi 16 để nhảy thẳng xuống CATCH
            RAISERROR(N'Không đủ hàng để bán!', 16, 1);
        END
        ELSE
        BEGIN
            INSERT INTO ChiTietHoaDon(maHD, maSP, soLuongBan, donGia) 
            SELECT maHD, maSP, soLuongBan, donGia FROM inserted;
            
            PRINT N'LOG THÀNH CÔNG: Hợp lệ, đã chèn chi tiết hóa đơn!';
        END
    END TRY
    BEGIN CATCH
        PRINT N'LOG LỖI: Giao dịch bị chặn. Chi tiết: ' + ERROR_MESSAGE();
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    END CATCH
END;
go

-- 4. Tự động cập nhật tổng tiền cho hóa đơn
CREATE TRIGGER trg_CapNhatTongTienHoaDon on ChiTietHoaDon
AFTER INSERT
AS
BEGIN
    BEGIN TRY
        DECLARE @maHD int;
        SELECT @maHD = maHD FROM inserted;

        UPDATE HoaDon
        SET TongTien = (SELECT SUM(soLuongBan * donGia) FROM ChiTietHoaDon WHERE maHD = @maHD)
        WHERE maHD = @maHD;
        
        PRINT N'LOG THÀNH CÔNG: Đã cập nhật tổng tiền hóa đơn!';
    END TRY
    BEGIN CATCH
        PRINT N'LOG LỖI: Không thể cập nhật tổng tiền. Chi tiết: ' + ERROR_MESSAGE();
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    END CATCH
END;
go

-- 5. Ngăn nhập nhầm giá bán < giá nhập
CREATE TRIGGER trg_KiemTraGiaBanSanPham on SanPham
AFTER UPDATE
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM inserted WHERE giaBan < giaNhap)
        BEGIN
            RAISERROR(N'Giá bán không được nhỏ hơn giá nhập!', 16, 1);
        END
        ELSE
        BEGIN
            PRINT N'LOG THÀNH CÔNG: Cập nhật giá sản phẩm hợp lệ!';
        END
    END TRY
    BEGIN CATCH
        PRINT N'LOG LỖI: Thao tác sửa giá bị hủy bỏ. Chi tiết: ' + ERROR_MESSAGE();
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    END CATCH
END;
go
