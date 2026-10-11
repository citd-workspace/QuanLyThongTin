-- 3.1. -- CAU 3.1. Tạo ra 3 users: GIANGVIEN, GIAOVU và SINHVIEN, đặt mật khẩu tuỳ ý. 
USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'GIANGVIEN')
    CREATE LOGIN [GIANGVIEN] WITH PASSWORD = 'GV@123456';
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'GIAOVU')
    CREATE LOGIN [GIAOVU] WITH PASSWORD = 'GVu@123456';
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'SINHVIEN')
    CREATE LOGIN [SINHVIEN] WITH PASSWORD = 'SV@123456';
GO

-- TAO / GAN LAI USER VOI LOGIN TUONG UNG
USE QLDT;
GO
IF USER_ID(N'GIANGVIEN') IS NULL
    CREATE USER [GIANGVIEN] FOR LOGIN [GIANGVIEN];
ELSE
    ALTER USER [GIANGVIEN] WITH LOGIN = [GIANGVIEN];
GO
IF USER_ID(N'GIAOVU') IS NULL
    CREATE USER [GIAOVU] FOR LOGIN [GIAOVU];
ELSE
    ALTER USER [GIAOVU] WITH LOGIN = [GIAOVU];
GO
IF USER_ID(N'SINHVIEN') IS NULL
    CREATE USER [SINHVIEN] FOR LOGIN [SINHVIEN];
ELSE
    ALTER USER [SINHVIEN] WITH LOGIN = [SINHVIEN];
GO

-- CAU 3.2. PHAN QUYEN
-- GIAOVU: xem va cap nhat tat ca cac bang
GRANT SELECT, UPDATE ON SCHEMA::dbo TO [GIAOVU];
GO

-- GIANGVIEN: xem thong tin giang vien, de tai huong dan/phan bien/uy vien, hoi dong.
GRANT SELECT ON OBJECT::dbo.giaovien       TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.hocham         TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.hocvi          TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.chuyennganh    TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.gv_hv_cn       TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.detai          TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.gv_hddt        TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.gv_pbdt        TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.gv_uvdt        TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.hoidong        TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.hoidong_gv     TO [GIANGVIEN];
GRANT SELECT ON OBJECT::dbo.hoidong_dt     TO [GIANGVIEN];
GO

-- GIANGVIEN chi cap nhat dong thong tin duoc gan voi database user.
REVOKE UPDATE ON SCHEMA::dbo FROM [GIANGVIEN];
REVOKE UPDATE ON OBJECT::dbo.giaovien FROM [GIANGVIEN];
GO

-- Tao bang anh xa user SQL Server <-> ma giang vien (neu chua co).
IF OBJECT_ID(N'dbo.taikhoan_gv', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.taikhoan_gv
    (
        tenuser SYSNAME NOT NULL PRIMARY KEY,
        msgv CHAR(5) NOT NULL UNIQUE,
        CONSTRAINT FK_taikhoan_gv_giaovien
            FOREIGN KEY (msgv) REFERENCES dbo.giaovien(msgv)
    );
END;
GO

-- Anh xa tai khoan GIANGVIEN voi mot giang vien co that trong CSDL.
IF EXISTS (SELECT 1 FROM dbo.giaovien WHERE msgv = '00201')
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.taikhoan_gv WHERE tenuser = N'GIANGVIEN')
        UPDATE dbo.taikhoan_gv
        SET msgv = '00201'
        WHERE tenuser = N'GIANGVIEN' AND msgv <> '00201';
    ELSE
        INSERT INTO dbo.taikhoan_gv (tenuser, msgv)
        VALUES (N'GIANGVIEN', '00201');
END
GO

-- View loc thong tin cua giang vien dang dang nhap.
CREATE OR ALTER VIEW dbo.vw_thongtin_gv_cuatoi
AS
    SELECT gv.msgv, gv.tengv, gv.diachi, gv.sodt, gv.mshh, gv.namhh
    FROM dbo.giaovien AS gv
    WHERE gv.msgv =
    (
        SELECT tk.msgv
        FROM dbo.taikhoan_gv AS tk
        WHERE tk.tenuser = USER_NAME()
    )
WITH CHECK OPTION;
GO

GRANT SELECT ON OBJECT::dbo.vw_thongtin_gv_cuatoi TO [GIANGVIEN];
-- Thu hoi grant UPDATE toan view cu (neu da tung cap).
REVOKE UPDATE ON OBJECT::dbo.vw_thongtin_gv_cuatoi FROM [GIANGVIEN];
-- Chi duoc sua cac cot thong tin, khong duoc sua cot khoa msgv.
GRANT UPDATE (tengv, diachi, sodt, mshh, namhh)
    ON OBJECT::dbo.vw_thongtin_gv_cuatoi TO [GIANGVIEN];
GO

-- SINHVIEN: xem thong tin sinh vien, hoi dong va de tai.
GRANT SELECT ON OBJECT::dbo.sinhvien      TO [SINHVIEN];
GRANT SELECT ON OBJECT::dbo.hoidong       TO [SINHVIEN];
GRANT SELECT ON OBJECT::dbo.hoidong_gv    TO [SINHVIEN];
GRANT SELECT ON OBJECT::dbo.hoidong_dt    TO [SINHVIEN];
GRANT SELECT ON OBJECT::dbo.detai         TO [SINHVIEN];
GO

-- Khong cap UPDATE cho SINHVIEN.
REVOKE UPDATE ON SCHEMA::dbo FROM [SINHVIEN];
GO

-- Cam xoa du lieu cho ca ba user
DENY DELETE ON SCHEMA::dbo TO [GIAOVU], [GIANGVIEN], [SINHVIEN];
GO
