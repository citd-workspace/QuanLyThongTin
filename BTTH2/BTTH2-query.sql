/* A. STORED PROCEDURES VỚI THAM SỐ VÀO
1. Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH. Trước khi insert dữ liệu cần kiểm tra 
MSHH đã tồn tại trong table HOCHAM chưa, nếu chưa thì trả về giá trị 0.

2. Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH. Trước khi insert dữ liệu cần kiểm tra 
MSGV trong table GIAOVIEN có trùng không, nếu trùng thì trả về giá trị 0.

3. Giống (1) và (2) kiểm tra xem MSGV có trùng không? MSHH có tồn tại chưa? Nếu MSGV trùng thì trả về 0. 
Nếu MSHH chưa tồn tại trả về 1, ngược lại cho insert dữ liệu.

4. Đưa vào MSDT cũ, TENDT mới. Hãy cập nhật tên đề tài mới với mã đề tài cũ không đổi nếu không tìm thấy trả về 0, 
ngược lại cập nhật và trả về 1.

5. Tham số đưa vào MSSV, TENSV mới, DIACHI mới. Hãy cập nhật sinh viên trên với MSSV không đổi, nếu không tìm thấy trả về 0, 
ngược lại cập nhật và trả về 1.
*/

CREATE PROCEDURE sp_InsertGiaoVien_1(
 	@p_msgv CHAR(5), 
    @p_tengv NVARCHAR(30), 
    @p_sodt NVARCHAR(10), 
    @p_diachi VARCHAR(50), 
    @p_mshh INT, 
    @p_namhh INT
)
AS 
BEGIN
	IF NOT EXISTS (SELECT 1 FROM hocham WHERE mshh = @p_mshh)
	BEGIN 
		RETURN 0;
	END
	
	INSERT INTO giaovien (MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH)
    VALUES (@p_msgv, @p_tengv, @p_sodt, @p_diachi, @p_mshh, @p_namhh);
END

EXEC sp_InsertGiaoVien_1('00205', N'Nguyen Van A', '0901234567', N'TP.HCM', 3, '2026-01-01');

-- --------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_InsertGiaoVien_2(
 	@p_msgv CHAR(5), 
    @p_tengv NVARCHAR(30), 
    @p_sodt NVARCHAR(10), 
    @p_diachi VARCHAR(50), 
    @p_mshh INT, 
    @p_namhh INT
)
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM giaovien WHERE msgv = @p_msgv)
	BEGIN 
		RETURN 0;
	END
	
	INSERT INTO giaovien (MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH)
    VALUES (@p_msgv, @p_tengv, @p_sodt, @p_diachi, @p_mshh, @p_namhh);
END

EXEC sp_InsertGiaoVien_2('00206', N'Pham Thi B', '0901234567', N'TP.HCM', 3, '2026-01-01');

-- --------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_InsertGiaoVien_3(
 	@p_msgv CHAR(5), 
    @p_tengv NVARCHAR(30), 
    @p_sodt NVARCHAR(10), 
    @p_diachi VARCHAR(50), 
    @p_mshh INT, 
    @p_namhh INT
)
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM giaovien WHERE msgv = @p_msgv)
	BEGIN 
		RETURN 0;
	END
	
	IF NOT EXISTS (SELECT 1 FROM hocham WHERE mshh = @p_mshh)
	BEGIN 
		RETURN 0;
	END
	
	INSERT INTO giaovien (MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH)
    VALUES (@p_msgv, @p_tengv, @p_sodt, @p_diachi, @p_mshh, @p_namhh);
END

-- --------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE sp_updateDeTai(
	@p_msdt CHAR(6),
	@p_tendt NVARCHAR(30)
)
AS 
BEGIN
	IF NOT EXISTS (SELECT 1 FROM detai WHERE msdt = @p_msdt)
	BEGIN 
		RETURN 0;
	END
	
	UPDATE detai SET tendt = @p_tendt
	WHERE msdt = @p_msdt;
	
	RETURN 1;
END

-- --------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE sp_updateSinhVien(
	@p_mssv CHAR(8),
	@p_tensv NVARCHAR(30),
	@p_diachi NVARCHAR(50)
)
AS 
BEGIN
	IF NOT EXISTS (SELECT 1 FROM sinhvien WHERE mssv = @p_mssv)
	BEGIN 
		RETURN 0;
	END

	UPDATE sinhvien 
	SET tensv = @p_tensv,
		diachi = @p_diachi
	WHERE mssv = @p_mssv;
	
	RETURN 1;
END


/* B. STORED PROCEDURES VỚI THAM SỐ VÀO VÀ RA
1. Đưa vào TENHV trả ra: Số GV thỏa học vị, nếu không tìm thấy trả về 0.

2. Đưa vào MSDT cho biết: Điểm trung bình của đề tài, nếu không tìm thấy trả về 0.

3. Đưa vào TENGV trả ra: SDT của giáo viên đó, nếu không tìm thấy trả về 0.
Nếu trùng tên thì có báo lỗi không? Tại sao? Làm sao để hiện thông báo có bao nhiêu giáo viên trùng tên và trả về các SDT.

4. Đưa vào MSHD cho biết: Điểm trung bình các đề tài của hội đồng đó.

5. Đưa vào TENGV cho biết: Số đề tài hướng dẫn, số đề tài phản biện do giáo viên đó phụ trách. 
Nếu trùng tên thì có báo lỗi không hay hệ thống sẽ đếm tất cả các đề tài của những giáo viên trùng tên đó?
*/

CREATE PROCEDURE sp_getHocVi(
	@p_tenhv NVARCHAR(30),
	@p_count INT OUTPUT
)
AS 
BEGIN
	SELECT @p_count = COUNT(gv.msgv)
	FROM giaovien gv 
	JOIN hocvi hv ON gv.mshv = hv.mshv
	WHERE hv.tenhv = @p_tenhv;
	
	IF @p_count = 0
		SET @p_count = 0;
	RETURN @p_count;
END

-- --------------------------------------------------------------------------------------------------------------

-- B2
CREATE PROCEDURE sp_getDiemTB_DeTai(
	@p_msdt CHAR(6),
	@p_diemtb FLOAT OUTPUT
)
AS 
BEGIN
	IF NOT EXISTS (SELECT 1 FROM detai WHERE msdt = @p_msdt)
	BEGIN 
		SET @p_diemtb = 0;
		RETURN 0;
	END
	
	SELECT @p_diemtb = AVG(diem)
	FROM gv_uvdt
	WHERE msdt = @p_msdt;
	
	IF @p_diemtb IS NULL
		SET @p_diemtb = 0;
		
	RETURN 1;
END

-- --------------------------------------------------------------------------------------------------------------

-- B3
-- Nếu trùng tên thì không báo lỗi, mà sẽ trả về thông báo số lương giáo viên trùng tên và danh sách sdt
-- Lý do: Tên giáo viên không phải là khó chính (PK) nên có thể trùng. Hệ thống nên xử lý gracefully
CREATE PROCEDURE sp_getSDT_GiaoVien(
	@p_tengv NVARCHAR(30),
	@p_sodt NVARCHAR(10) OUTPUT,
	@p_count INT OUTPUT,
	@p_message NVARCHAR(200) OUTPUT
)
AS 
BEGIN
	DECLARE @gv_count INT;
	
	SELECT @gv_count = COUNT(*) FROM giaovien WHERE tengv = @p_tengv;
	
	IF @gv_count = 0
	BEGIN
		SET @p_sodt = '0';
		SET @p_count = 0;
		SET @p_message = N'Khong tim thay giao vien';
		RETURN 0;
	END
	
	IF @gv_count > 1
	BEGIN
		-- Co trung ten: tra ve thong bao va danh sach SDT
		SET @p_count = @gv_count;
		SET @p_message = N'Co ' + CAST(@gv_count AS NVARCHAR) + N' giao vien trung ten. Danh sach SDT: ';
		
		DECLARE @sodt_list NVARCHAR(MAX) = '';
		SELECT @sodt_list = @sodt_list + sodt + '; '
		FROM giaovien
		WHERE tengv = @p_tengv;
		
		SET @p_message = @p_message + @sodt_list;
		SET @p_sodt = LEFT(@sodt_list, 10);
		RETURN 2;
	END
	
	-- Co duy nhat 1 GV
	SELECT @p_sodt = sodt FROM giaovien WHERE tengv = @p_tengv;
	SET @p_count = 1;
	SET @p_message = N'Tim thay 1 giao vien';
	RETURN 1;
END

-- --------------------------------------------------------------------------------------------------------------
-- B4
CREATE PROCEDURE sp_getDiemTB_HoiDong(
	@p_mshd INT,
	@p_diemtb FLOAT OUTPUT
)
AS 
BEGIN
	IF NOT EXISTS (SELECT 1 FROM hoidong WHERE mshd = @p_mshd)
	BEGIN 
		SET @p_diemtb = 0;
		RETURN 0;
	END
	
	SELECT @p_diemtb = AVG(uv.diem)
	FROM hoidong_dt hd
	JOIN gv_uvdt uv ON hd.msdt = uv.msdt
	WHERE hd.mshd = @p_mshd;
	
	IF @p_diemtb IS NULL
		SET @p_diemtb = 0;
		
	RETURN 1;
END

-- --------------------------------------------------------------------------------------------------------------

-- B5
-- Nếu trùng tên: Hệ thống sẽ lấy tất cả các đề tài của những giáo viên trùng tên đó (không báo lỗi)
CREATE PROCEDURE sp_getDeTaiCount_GiaoVien(
	@p_tengv NVARCHAR(30),
	@p_soluong_hddt INT OUTPUT,
	@p_soluong_pbdt INT OUTPUT,
	@p_message NVARCHAR(200) OUTPUT
)
AS 
BEGIN
	DECLARE @gv_count INT;
	
	SELECT @gv_count = COUNT(*) FROM giaovien WHERE tengv = @p_tengv;
	
	IF @gv_count = 0
	BEGIN
		SET @p_soluong_hddt = 0;
		SET @p_soluong_pbdt = 0;
		SET @p_message = N'Khong tim thay giao vien';
		RETURN 0;
	END
	
	IF @gv_count > 1
	BEGIN
		SET @p_message = N'Co ' + CAST(@gv_count AS NVARCHAR) + N' giao vien trung ten. Dang dem tat ca de tai cuac GV nay.';
	END
	ELSE
	BEGIN
		SET @p_message = N'Tim thay 1 giao vien';
	END
	
	SELECT @p_soluong_hddt = COUNT(DISTINCT hd.msdt)
	FROM giaovien gv
	JOIN gv_hddt hd ON gv.msgv = hd.msgv
	WHERE gv.tengv = @p_tengv;
	
	SELECT @p_soluong_pbdt = COUNT(DISTINCT pb.msdt)
	FROM giaovien gv
	JOIN gv_pbdt pb ON gv.msgv = pb.msgv
	WHERE gv.tengv = @p_tengv;
	
	IF @p_soluong_hddt IS NULL SET @p_soluong_hddt = 0;
	IF @p_soluong_pbdt IS NULL SET @p_soluong_pbdt = 0;
	
	RETURN 1;
END

-- --------------------------------------------------------------------------------------------------------------


/* C. TRIGGER
1. Tạo Trigger thỏa mãn điều kiện khi xóa một đề tài sẽ xóa các thông tin liên quan.

2. Tạo Trigger thỏa mãn ràng buộc là khi đổi 1 mã số giáo viên (MSGV) thì sẽ thay đổi các thông tin liên quan.

3. Tạo Trigger thỏa mãn ràng buộc là một hội đồng không quá 10 đề tài. Dùng “Group by” có được không? Giải thích.

4. Tạo Trigger thỏa mãn ràng buộc là một đề tài không quá 2 sinh viên. Dùng “Group by” có được không? Giải thích.

5. Tạo Trigger thỏa mãn ràng buộc là một giáo viên muốn có học hàm PGS phải là tiến sĩ.
*/

-- C1
CREATE TRIGGER trg_DeleteDeTai_Cascade
ON detai
INSTEAD OF DELETE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Xoa cac ban ghi lien quan trong gv_uvdt
	DELETE FROM gv_uvdt WHERE msdt IN (SELECT msdt FROM deleted);
	
	-- Xoa cac ban ghi lien quan trong gv_hddt
	DELETE FROM gv_hddt WHERE msdt IN (SELECT msdt FROM deleted);
	
	-- Xoa cac ban ghi lien quan trong gv_pbdt
	DELETE FROM gv_pbdt WHERE msdt IN (SELECT msdt FROM deleted);
	
	-- Xoa cac ban ghi lien quan trong sv_detai
	DELETE FROM sv_detai WHERE msdt IN (SELECT msdt FROM deleted);
	
	-- Xoa cac ban ghi lien quan trong hoidong_dt
	DELETE FROM hoidong_dt WHERE msdt IN (SELECT msdt FROM deleted);
	
	-- Cuoi cung xoa de tai chinh
	DELETE FROM detai WHERE msdt IN (SELECT msdt FROM deleted);
END

-- --------------------------------------------------------------------------------------------------------------

-- C2
CREATE TRIGGER trg_UpdateMSGV_Cascade
ON giaovien
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	IF UPDATE(msgv)
	BEGIN
		-- Kiem tra co thuc su doi MSGV khong
		IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON i.msgv <> d.msgv)
		BEGIN
			-- Cap nhat gv_hv_cn
			UPDATE gv_hv_cn SET msgv = i.msgv
			FROM inserted i
			JOIN deleted d ON gv_hv_cn.msgv = d.msgv;
			
			-- Cap nhat gv_hddt
			UPDATE gv_hddt SET msgv = i.msgv
			FROM inserted i
			JOIN deleted d ON gv_hddt.msgv = d.msgv;
			
			-- Cap nhat gv_pbdt
			UPDATE gv_pbdt SET msgv = i.msgv
			FROM inserted i
			JOIN deleted d ON gv_pbdt.msgv = d.msgv;
			
			-- Cap nhat gv_uvdt
			UPDATE gv_uvdt SET msgv = i.msgv
			FROM inserted i
			JOIN deleted d ON gv_uvdt.msgv = d.msgv;
			
			-- Cap nhat hoidong (msgv chu toa)
			UPDATE hoidong SET msgv = i.msgv
			FROM inserted i
			JOIN deleted d ON hoidong.msgv = d.msgv;
			
			-- Cap nhat hoidong_gv
			UPDATE hoidong_gv SET msgv = i.msgv
			FROM inserted i
			JOIN deleted d ON hoidong_gv.msgv = d.msgv;
		END
	END
END

-- --------------------------------------------------------------------------------------------------------------

-- C3
-- Giai thich: DUNG Group by KHONG duoc trong trigger AFTER INSERT/UPDATE vi trigger chay moi lan INSERT/UPDATE,
-- can kiem tra tong so de tai cua hoi dong moi (mshd trong inserted). Group by dung de tong hop du lieu,
-- nhung trong trigger can kiem tra dieu kien voi gia tri moi vua insert/update. Nen dung COUNT(*) voi WHERE mshd = @mshd_moi.
CREATE TRIGGER trg_HoiDong_Max10DeTai
ON hoidong_dt
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (
		SELECT 1
		FROM inserted i
		JOIN hoidong_dt hd ON i.mshd = hd.mshd
		GROUP BY i.mshd
		HAVING COUNT(*) > 10
	)
	BEGIN
		RAISERROR(N'Mot hoi dong khong duoc qua 10 de tai!', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END

-- --------------------------------------------------------------------------------------------------------------

-- C4
-- Giai thich: Tuong tu C3, DUNG Group by KHONG duoc trong trigger vi can kiem tra ngay lap tuc.
-- Can dem so sinh vien cua de tai vua duoc insert/update (msdt trong inserted).
CREATE TRIGGER trg_DeTai_Max2SinhVien
ON sv_detai
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (
		SELECT 1
		FROM inserted i
		JOIN sv_detai sd ON i.msdt = sd.msdt
		GROUP BY i.msdt
		HAVING COUNT(*) > 2
	)
	BEGIN
		RAISERROR(N'Mot de tai khong duoc qua 2 sinh vien!', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END

-- --------------------------------------------------------------------------------------------------------------

-- C5
-- Kiem tra: Khi insert/update giaovien voi mshh = 'PHO GIAO SU' (mshh=1) thi phai co hoc vi 'Tien si' (mshv=4) hoac 'Tien si Khoa hoc' (mshv=5)
CREATE TRIGGER trg_GiaoVien_PGS_Phai_TienSi
ON giaovien
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (
		SELECT 1
		FROM inserted i
		JOIN hocham h ON i.mshh = h.mshh
		LEFT JOIN gv_hv_cn gv ON i.msgv = gv.msgv
		LEFT JOIN hocvi hv ON gv.mshv = hv.mshv
		WHERE h.tenhh = N'PHO GIAO SU'
		AND (hv.tenhv <> N'TIEN SI' AND hv.tenhv <> N'TIEN SI KHOA HOC')
	)
	BEGIN
		RAISERROR(N'Giao vien co hoc ham Pho Giao Su phai la Tien si hoac Tien si Khoa hoc!', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END
END

-- --------------------------------------------------------------------------------------------------------------


/* D. FUNCTION
1. Viết hàm tính điểm trung bình của một đề tài. Giá trị trả về là điểm trung bình ứng với mã số đề tài nhập vào.

2. Trả về kết quả của đề tài theo MSDT nhập vào. Kết quả là DAT nếu như điểm trung bình từ 5 trở lên, 
và KHONGDAT nếu như điểm trung bình dưới 5.

3. Đưa vào MSDT, trả về mã số và họ tên của các sinh viên thực hiện đề tài.
*/

-- D1
CREATE FUNCTION fn_GetDiemTB_DeTai(@p_msdt CHAR(6))
RETURNS FLOAT
AS
BEGIN
	DECLARE @diemtb FLOAT;
	
	SELECT @diemtb = AVG(diem)
	FROM gv_uvdt
	WHERE msdt = @p_msdt;
	
	IF @diemtb IS NULL
		SET @diemtb = 0;
	
	RETURN @diemtb;
END

-- --------------------------------------------------------------------------------------------------------------

-- D2
CREATE FUNCTION fn_GetKetQua_DeTai(@p_msdt CHAR(6))
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @diemtb FLOAT;
	DECLARE @ketqua NVARCHAR(10);
	
	SELECT @diemtb = AVG(diem)
	FROM gv_uvdt
	WHERE msdt = @p_msdt;
	
	IF @diemtb IS NULL OR @diemtb < 5
		SET @ketqua = N'KHONGDAT';
	ELSE
		SET @ketqua = N'DAT';
	
	RETURN @ketqua;
END

-- --------------------------------------------------------------------------------------------------------------

-- D3
CREATE FUNCTION fn_GetSinhVien_DeTai(@p_msdt CHAR(6))
RETURNS @result TABLE (
	mssv CHAR(8),
	tensv NVARCHAR(30)
)
AS
BEGIN
	INSERT INTO @result (mssv, tensv)
	SELECT sv.mssv, sv.tensv
	FROM sinhvien sv
	JOIN sv_detai sd ON sv.mssv = sd.mssv
	WHERE sd.msdt = @p_msdt;
	
	RETURN;
END

-- --------------------------------------------------------------------------------------------------------------


/* E. CURSOR
Tạo một bảng tên là DETAI_DIEM. Cấu trúc bảng như sau: DETAI_DIEM(MSDT, DIEMTB)

1. Viết Cursor tính điểm trung bình cho từng đề tài. Sau đó lưu kết quả vào bảng DETAI_DIEM.

2. Gom các bước xử lý của Cursor ở câu 1 vào một Stored Procedure.

3. Tạo thêm cột XEPLOAI có kiểu là NVARCCHAR(20) trong bảng DETAI_DIEM, 
viết Cursor cập nhật kết quả xếp loại cho mỗi đề tài như sau:
*/

-- Tao bang DETAI_DIEM
IF OBJECT_ID('DETAI_DIEM', 'U') IS NOT NULL
    DROP TABLE DETAI_DIEM;

CREATE TABLE DETAI_DIEM (
	MSDT CHAR(6) PRIMARY KEY,
	DIEMTB FLOAT,
	XEPLOAI NVARCHAR(20)
);

-- --------------------------------------------------------------------------------------------------------------

-- E1
DECLARE @msdt CHAR(6);
DECLARE @diemtb FLOAT;

DECLARE cur_diemtb CURSOR FOR
SELECT msdt FROM detai;

OPEN cur_diemtb;
FETCH NEXT FROM cur_diemtb INTO @msdt;

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @diemtb = AVG(diem)
	FROM gv_uvdt
	WHERE msdt = @msdt;
	
	IF @diemtb IS NULL
		SET @diemtb = 0;
	
	INSERT INTO DETAI_DIEM (MSDT, DIEMTB)
	VALUES (@msdt, @diemtb);
	
	FETCH NEXT FROM cur_diemtb INTO @msdt;
END

CLOSE cur_diemtb;
DEALLOCATE cur_diemtb;

-- --------------------------------------------------------------------------------------------------------------

-- E2
CREATE PROCEDURE sp_CapNhatDiemTB_DeTai
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Xoa du lieu cu
	DELETE FROM DETAI_DIEM;
	
	DECLARE @msdt CHAR(6);
	DECLARE @diemtb FLOAT;

	DECLARE cur_diemtb CURSOR FOR
	SELECT msdt FROM detai;

	OPEN cur_diemtb;
	FETCH NEXT FROM cur_diemtb INTO @msdt;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @diemtb = AVG(diem)
		FROM gv_uvdt
		WHERE msdt = @msdt;
		
		IF @diemtb IS NULL
			SET @diemtb = 0;
		
		INSERT INTO DETAI_DIEM (MSDT, DIEMTB)
		VALUES (@msdt, @diemtb);
		
		FETCH NEXT FROM cur_diemtb INTO @msdt;
	END

	CLOSE cur_diemtb;
	DEALLOCATE cur_diemtb;
END

-- --------------------------------------------------------------------------------------------------------------

-- E3
DECLARE @msdt CHAR(6);
DECLARE @diemtb FLOAT;
DECLARE @xeploai NVARCHAR(20);

DECLARE cur_xeploai CURSOR FOR
SELECT MSDT, DIEMTB FROM DETAI_DIEM;

OPEN cur_xeploai;
FETCH NEXT FROM cur_xeploai INTO @msdt, @diemtb;

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @diemtb >= 8
		SET @xeploai = N'XUAT SAC';
	ELSE IF @diemtb >= 7
		SET @xeploai = N'GIOI';
	ELSE IF @diemtb >= 6.5
		SET @xeploai = N'KHA';
	ELSE IF @diemtb >= 5
		SET @xeploai = N'TRUNG BINH';
	ELSE
		SET @xeploai = N'YEU';
	
	UPDATE DETAI_DIEM
	SET XEPLOAI = @xeploai
	WHERE MSDT = @msdt;
	
	FETCH NEXT FROM cur_xeploai INTO @msdt, @diemtb;
END

CLOSE cur_xeploai;
DEALLOCATE cur_xeploai;

-- --------------------------------------------------------------------------------------------------------------