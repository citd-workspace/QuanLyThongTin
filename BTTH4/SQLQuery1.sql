SELECT 
    ROW_NUMBER() OVER (ORDER BY mssv) AS STT,
    mssv AS MSSV,
    tensv AS [TÊN SINH VIÊN],
    sdt AS [SỐ ĐT],
    lop AS [LỚP],
    diachi AS [ĐỊA CHỈ]
FROM sinhvien


DROP VIEW v_DiemUyVien
CREATE VIEW v_DiemUyVien AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY dt.MSDT) AS STT,
    dt.MSDT,
    dt.TENDT AS [TÊN ĐỀ TÀI],
    gv.MSGV,
    gv.TENGV AS [TÊN GIÁO VIÊN],
    uv.DIEM
FROM DETAI dt
JOIN GV_UVDT uv ON dt.MSDT = uv.MSDT
JOIN GIAOVIEN gv ON uv.MSGV = gv.MSGV