use QuanLySieuThi;
go

-- (7) Stored Procedure
-- thêm khách hàng 
CREATE PROCEDURE sp_ThemKhachHang
    @hoTen nvarchar(100), @sdt varchar(15), @diaChi nvarchar(255),@email varchar(100)
AS
    BEGIN
        INSERT INTO KhachHang(HoTen, SDT, DiaChi, Email) values (@hoTen, @sdt, @diaChi, @email);
    END;
go

-- EXEC
EXEC sp_ThemKhachHang 
    N'Đoàn Chấn Phong', 
    '0899966591', 
    N'Tân Bình, TP.HCM', 
    'doanchanphong@gmail.com';
go

-- tìm kiếm sản phẩm theo tên
CREATE PROCEDURE sp_TimKiemSanPhamTheoTen
    @keyword nvarchar(100)
AS
    BEGIN
        SELECT * FROM SanPham WHERE tenSP LIKE '%' + @keyword + '%';
    END;
go

-- EXEC
EXEC sp_TimKiemSanPhamTheoTen N'Sữa';
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

-- EXEC
EXEC sp_ThongKeDoanhThuTheoNhanVien;
go

-- lấy danh sách sản phẩm sắp hết hàng 
CREATE PROCEDURE sp_LayDanhSachSanPhamSapHetHangTheoSoLuong @soLuongTon int
AS
    BEGIN
        SELECT maSP, tenSP, soLuongTon FROM SanPham WHERE soLuongTon < @soLuongTon;
    END;
go

-- EXEC
EXEC sp_LayDanhSachSanPhamSapHetHangTheoSoLuong 40;
go

--cập nhật giá sản phẩm 
CREATE PROCEDURE sp_CapNhatGiaSanPham
    @maSP varchar(10), @giaBanMoi FLOAT
AS
    BEGIN
        UPDATE SanPham SET giaBan = @giaBanMoi WHERE maSP = @maSP;
    END;
go

-- BEFORE UPDATE
SELECT * FROM SanPham WHERE maSP = 'SP01';

-- EXEC
EXEC sp_CapNhatGiaSanPham 'SP01', 40000;

-- AFTER UPDATE
SELECT * FROM SanPham WHERE maSP = 'SP01';
go

-- 6. Thống kê doanh thu theo khoảng ngày
CREATE PROCEDURE sp_ThongKeDoanhThuTheoKhoangNgay
    @tuNgay DATE,
    @denNgay DATE
AS
BEGIN
    SELECT 
        CAST(ngayLap AS DATE) AS Ngay,
        COUNT(maHD) AS SoHoaDon,
        SUM(tongTien) AS TongDoanhThu
    FROM HoaDon
    WHERE CAST(ngayLap AS DATE) BETWEEN @tuNgay AND @denNgay
    GROUP BY CAST(ngayLap AS DATE)
    ORDER BY Ngay;
END;
go

-- EXEC
EXEC sp_ThongKeDoanhThuTheoKhoangNgay '2024-01-01', '2024-12-31';
go

-- 7. Tìm danh sách hóa đơn theo khách hàng
CREATE PROCEDURE sp_TimHoaDonTheoKhachHang
    @maKH INT
AS
BEGIN
    SELECT 
        hd.maHD,
        hd.ngayLap,
        kh.hoTen AS TenKhachHang,
        nv.hoTen AS TenNhanVien,
        hd.tongTien
    FROM HoaDon hd
    JOIN KhachHang kh ON hd.maKH = kh.maKH
    JOIN NhanVien nv ON hd.maNV = nv.maNV
    WHERE hd.maKH = @maKH
    ORDER BY hd.ngayLap;
END;
go

-- EXEC
EXEC sp_TimHoaDonTheoKhachHang 1;
go

-- (5) Functions:
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

-- EXEC
SELECT dbo.fn_TinhTongDoanhThuNgay('2026-09-02') AS 'Doanh thu';
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

-- EXEC
SELECT dbo.fn_KiemTraSoLuongTonSanPham('SP01') AS 'Số lượng tồn';
go

-- lấy danh sách hóa đơn của khách hàng return table
CREATE FUNCTION fn_LayDanhSachHoaDonCuaKhachHang(@maKH int)
RETURNS TABLE
AS
    RETURN(
        SELECT maHD,ngayLap,tongTien FROM HoaDon WHERE maKH = @maKH
    );
go

-- EXEC
SELECT * FROM dbo.fn_LayDanhSachHoaDonCuaKhachHang(1);
go

-- 4. Tính tổng tiền của một hóa đơn
CREATE FUNCTION fn_TinhTongTienHoaDon
(
    @maHD INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @tongTien FLOAT;

    SELECT @tongTien = SUM(soLuongBan * donGia)
    FROM ChiTietHoaDon
    WHERE maHD = @maHD;

    RETURN ISNULL(@tongTien, 0);
END;
go

-- EXEC
SELECT dbo.fn_TinhTongTienHoaDon(2) AS N'Tổng tiền hóa đơn';
go

-- 5. Tính tổng số lượng đã bán của một sản phẩm
CREATE FUNCTION fn_TongSoLuongBanSanPham
(
    @maSP VARCHAR(10)
)
RETURNS INT
AS
BEGIN
    DECLARE @tongSoLuong INT;

    SELECT @tongSoLuong = SUM(soLuongBan)
    FROM ChiTietHoaDon
    WHERE maSP = @maSP;

    RETURN ISNULL(@tongSoLuong, 0);
END;
go

-- EXEC
SELECT dbo.fn_TongSoLuongBanSanPham('SP01') AS N'Tổng số lượng bán';
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

-- BEFORE TRIGGER
SELECT maSP, tenSP, soLuongTon FROM SanPham WHERE maSP = 'SP01';

-- TRIGGER EVENT
INSERT INTO ChiTietHoaDon(maHD, maSP, soLuongBan, donGia) 
VALUES (1, 'SP01', 5, 15000);

-- AFTER TRIGGER
SELECT maSP, tenSP, soLuongTon FROM SanPham WHERE maSP = 'SP01';
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

-- BEFORE TRIGGER
SELECT maSP, tenSP, soLuongTon FROM SanPham WHERE maSP = 'SP01';

-- TRIGGER EVENT
INSERT INTO ChiTietPhieuNhap(maPN, maSP, soLuongNhap, giaNhap) 
VALUES (1, 'SP01', 20, 10000);

-- AFTER TRIGGER
SELECT maSP, tenSP, soLuongTon FROM SanPham WHERE maSP = 'SP01';
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

-- BEFORE TRIGGER
SELECT maSP, tenSP, soLuongTon FROM SanPham WHERE maSP = 'SP01';

-- TRIGGER EVENT
INSERT INTO ChiTietHoaDon(maHD, maSP, soLuongBan, donGia) 
VALUES (1, 'SP01', 1000, 15000);

-- AFTER TRIGGER
SELECT * FROM ChiTietHoaDon WHERE maHD = 1 AND maSP = 'SP01';
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

-- BEFORE TRIGGER
SELECT maHD, tongTien FROM HoaDon WHERE maHD = 1;

-- TRIGGER EVENT
INSERT INTO ChiTietHoaDon(maHD, maSP, soLuongBan, donGia) 
VALUES (1, 'SP02', 2, 20000);

-- AFTER TRIGGER
SELECT maHD, tongTien FROM HoaDon WHERE maHD = 1;
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

-- BEFORE TRIGGER
INSERT INTO SanPham(maSP, tenSP, giaNhap, giaBan, soLuongTon)
VALUES ('SP99', N'Sản phẩm thử nghiệm', 50000, 40000, 10);

-- TRIGGER EVENT
UPDATE SanPham 
SET giaBan = 10000 
WHERE maSP = 'SP01';

-- AFTER TRIGGER
SELECT maSP, tenSP, giaNhap, giaBan FROM SanPham WHERE maSP = 'SP01';
go

-- (1) Cursor
-- Kiểm tra tình trạng tồn kho của từng sản phẩm
DECLARE @MaSP VARCHAR(10);
DECLARE @TenSP NVARCHAR(100);
DECLARE @SoLuongTon INT;

DECLARE Cur_KiemTraTonKho CURSOR FOR
SELECT MaSP, TenSP, SoLuongTon
FROM SanPham;

OPEN Cur_KiemTraTonKho;

FETCH NEXT FROM Cur_KiemTraTonKho
INTO @MaSP, @TenSP, @SoLuongTon;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @SoLuongTon = 0
    BEGIN
        PRINT N'LOG: Sản phẩm ' + @MaSP 
            + N' - ' + @TenSP 
            + N' | Tình trạng: HẾT HÀNG';
    END
    ELSE IF @SoLuongTon < 100
    BEGIN
        PRINT N'LOG: Sản phẩm ' + @MaSP 
            + N' - ' + @TenSP 
            + N' | Tình trạng: SẮP HẾT HÀNG'
            + N' | Tồn: ' 
            + CAST(@SoLuongTon AS NVARCHAR(20));
    END
    ELSE
    BEGIN
        PRINT N'LOG: Sản phẩm ' + @MaSP 
            + N' - ' + @TenSP 
            + N' | Tình trạng: CÒN HÀNG'
            + N' | Tồn: ' 
            + CAST(@SoLuongTon AS NVARCHAR(20));
    END;

    FETCH NEXT FROM Cur_KiemTraTonKho
    INTO @MaSP, @TenSP, @SoLuongTon;
END;

CLOSE Cur_KiemTraTonKho;
DEALLOCATE Cur_KiemTraTonKho;
go