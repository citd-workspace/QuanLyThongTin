// Danh sách các chức năng demo (Procedure / Function / Trigger / Cursor).
// File này CHỈ chứa mô tả + câu lệnh gọi. Mã nguồn Procedure/Trigger (B2) được đọc
// trực tiếp từ SQL Server bằng OBJECT_DEFINITION, dữ liệu các bảng (B3, B5) cũng đọc từ DB.

const p = (name, label, type, def) => ({ name, label, type, default: def });

const SP_BY_ID = {
  title: 'Bảng SanPham (sản phẩm đang xét)',
  sql: 'SELECT maSP, tenSP, giaNhap, giaBan, soLuongTon FROM SanPham WHERE maSP = @maSP',
};
const HD_BY_ID = {
  title: 'Bảng HoaDon (hóa đơn đang xét)',
  sql: 'SELECT maHD, ngayLap, maKH, maNV, tongTien FROM HoaDon WHERE maHD = @maHD',
};
const CTHD_BY_HD = {
  title: 'Bảng ChiTietHoaDon (của hóa đơn đang xét)',
  sql: 'SELECT maCTHD, maHD, maSP, soLuongBan, donGia FROM ChiTietHoaDon WHERE maHD = @maHD ORDER BY maCTHD',
};

const cursorScript = `DECLARE @MaSP VARCHAR(10);
DECLARE @TenSP NVARCHAR(100);
DECLARE @SoLuongTon INT;

DECLARE Cur_KiemTraTonKho CURSOR FOR
SELECT MaSP, TenSP, SoLuongTon FROM SanPham;

OPEN Cur_KiemTraTonKho;
FETCH NEXT FROM Cur_KiemTraTonKho INTO @MaSP, @TenSP, @SoLuongTon;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @SoLuongTon = 0
        PRINT N'LOG: Sản phẩm ' + @MaSP + N' - ' + @TenSP + N' | Tình trạng: HẾT HÀNG';
    ELSE IF @SoLuongTon < 100
        PRINT N'LOG: Sản phẩm ' + @MaSP + N' - ' + @TenSP + N' | Tình trạng: SẮP HẾT HÀNG | Tồn: ' + CAST(@SoLuongTon AS NVARCHAR(20));
    ELSE
        PRINT N'LOG: Sản phẩm ' + @MaSP + N' - ' + @TenSP + N' | Tình trạng: CÒN HÀNG | Tồn: ' + CAST(@SoLuongTon AS NVARCHAR(20));

    FETCH NEXT FROM Cur_KiemTraTonKho INTO @MaSP, @TenSP, @SoLuongTon;
END;

CLOSE Cur_KiemTraTonKho;
DEALLOCATE Cur_KiemTraTonKho;`;

module.exports = [
  // ===================== STORED PROCEDURE =====================
  {
    id: 'sp-them-khach-hang', group: 'procedure', object: 'sp_ThemKhachHang',
    title: 'sp_ThemKhachHang',
    problem: 'Xây dựng Stored Procedure thêm một khách hàng mới vào bảng KhachHang.',
    params: [
      p('hoTen', 'Họ tên', 'nvarchar', 'Nguyễn Thị Demo'),
      p('sdt', 'SĐT', 'varchar', '0900000001'),
      p('diaChi', 'Địa chỉ', 'nvarchar', 'Thủ Đức, TP.HCM'),
      p('email', 'Email', 'varchar', 'demo@gmail.com'),
    ],
    exec: 'EXEC dbo.sp_ThemKhachHang @hoTen, @sdt, @diaChi, @email',
    tables: [{ title: 'Bảng KhachHang (5 khách hàng mới nhất)', sql: 'SELECT TOP 5 * FROM KhachHang ORDER BY maKH DESC' }],
  },
  {
    id: 'sp-tim-san-pham', group: 'procedure', object: 'sp_TimKiemSanPhamTheoTen',
    title: 'sp_TimKiemSanPhamTheoTen',
    problem: 'Xây dựng Stored Procedure tìm kiếm sản phẩm theo từ khóa trong tên sản phẩm.',
    params: [p('keyword', 'Từ khóa', 'nvarchar', 'Sữa')],
    exec: 'EXEC dbo.sp_TimKiemSanPhamTheoTen @keyword',
    tables: [{ title: 'Bảng SanPham (toàn bộ)', sql: 'SELECT maSP, tenSP, donViTinh, giaBan, soLuongTon FROM SanPham' }],
  },
  {
    id: 'sp-doanh-thu-nhan-vien', group: 'procedure', object: 'sp_ThongKeDoanhThuTheoNhanVien',
    title: 'sp_ThongKeDoanhThuTheoNhanVien',
    problem: 'Xây dựng Stored Procedure thống kê tổng doanh thu theo từng nhân viên lập hóa đơn.',
    params: [],
    exec: 'EXEC dbo.sp_ThongKeDoanhThuTheoNhanVien',
    tables: [
      { title: 'Bảng HoaDon', sql: 'SELECT maHD, ngayLap, maKH, maNV, tongTien FROM HoaDon ORDER BY maHD' },
      { title: 'Bảng NhanVien', sql: 'SELECT maNV, hoTen, chucVu FROM NhanVien' },
    ],
  },
  {
    id: 'sp-sap-het-hang', group: 'procedure', object: 'sp_LayDanhSachSanPhamSapHetHangTheoSoLuong',
    title: 'sp_LayDanhSachSanPhamSapHetHangTheoSoLuong',
    problem: 'Xây dựng Stored Procedure liệt kê các sản phẩm có số lượng tồn nhỏ hơn một ngưỡng cho trước.',
    params: [p('soLuongTon', 'Ngưỡng tồn kho', 'int', 40)],
    exec: 'EXEC dbo.sp_LayDanhSachSanPhamSapHetHangTheoSoLuong @soLuongTon',
    tables: [{ title: 'Bảng SanPham (sắp xếp theo tồn kho)', sql: 'SELECT maSP, tenSP, soLuongTon FROM SanPham ORDER BY soLuongTon' }],
  },
  {
    id: 'sp-cap-nhat-gia', group: 'procedure', object: 'sp_CapNhatGiaSanPham',
    title: 'sp_CapNhatGiaSanPham',
    problem: 'Xây dựng Stored Procedure cập nhật giá bán mới cho một sản phẩm (trigger kiểm tra giá bán >= giá nhập sẽ tự kích hoạt).',
    params: [p('maSP', 'Mã sản phẩm', 'varchar', 'SP01'), p('giaBanMoi', 'Giá bán mới', 'float', 40000)],
    exec: 'EXEC dbo.sp_CapNhatGiaSanPham @maSP, @giaBanMoi',
    tables: [SP_BY_ID],
  },
  {
    id: 'sp-doanh-thu-khoang-ngay', group: 'procedure', object: 'sp_ThongKeDoanhThuTheoKhoangNgay',
    title: 'sp_ThongKeDoanhThuTheoKhoangNgay',
    problem: 'Xây dựng Stored Procedure thống kê số hóa đơn và doanh thu theo từng ngày trong một khoảng thời gian.',
    params: [p('tuNgay', 'Từ ngày', 'date', '2026-09-01'), p('denNgay', 'Đến ngày', 'date', '2026-09-30')],
    exec: 'EXEC dbo.sp_ThongKeDoanhThuTheoKhoangNgay @tuNgay, @denNgay',
    tables: [{ title: 'Bảng HoaDon', sql: 'SELECT maHD, ngayLap, maKH, maNV, tongTien FROM HoaDon ORDER BY ngayLap' }],
  },
  {
    id: 'sp-hoa-don-khach-hang', group: 'procedure', object: 'sp_TimHoaDonTheoKhachHang',
    title: 'sp_TimHoaDonTheoKhachHang',
    problem: 'Xây dựng Stored Procedure tìm tất cả hóa đơn của một khách hàng (kèm tên khách hàng, tên nhân viên).',
    params: [p('maKH', 'Mã khách hàng', 'int', 1)],
    exec: 'EXEC dbo.sp_TimHoaDonTheoKhachHang @maKH',
    tables: [{ title: 'Bảng HoaDon của khách hàng đang xét', sql: 'SELECT maHD, ngayLap, maKH, maNV, tongTien FROM HoaDon WHERE maKH = @maKH' }],
  },

  // ===================== FUNCTION =====================
  {
    id: 'fn-doanh-thu-ngay', group: 'function', object: 'fn_TinhTongDoanhThuNgay',
    title: 'fn_TinhTongDoanhThuNgay',
    problem: 'Xây dựng Scalar Function tính tổng doanh thu của một ngày.',
    params: [p('ngay', 'Ngày', 'date', '2026-09-02')],
    exec: 'SELECT dbo.fn_TinhTongDoanhThuNgay(CAST(@ngay AS DATE)) AS DoanhThu',
    tables: [{ title: 'Bảng HoaDon của ngày đang xét', sql: 'SELECT maHD, ngayLap, maKH, maNV, tongTien FROM HoaDon WHERE CAST(ngayLap AS DATE) = CAST(@ngay AS DATE)' }],
  },
  {
    id: 'fn-ton-kho', group: 'function', object: 'fn_KiemTraSoLuongTonSanPham',
    title: 'fn_KiemTraSoLuongTonSanPham',
    problem: 'Xây dựng Scalar Function trả về số lượng tồn của một sản phẩm.',
    params: [p('maSP', 'Mã sản phẩm', 'varchar', 'SP01')],
    exec: 'SELECT dbo.fn_KiemTraSoLuongTonSanPham(@maSP) AS SoLuongTon',
    tables: [SP_BY_ID],
  },
  {
    id: 'fn-hoa-don-khach-hang', group: 'function', object: 'fn_LayDanhSachHoaDonCuaKhachHang',
    title: 'fn_LayDanhSachHoaDonCuaKhachHang',
    problem: 'Xây dựng Table-valued Function trả về danh sách hóa đơn của một khách hàng.',
    params: [p('maKH', 'Mã khách hàng', 'int', 1)],
    exec: 'SELECT * FROM dbo.fn_LayDanhSachHoaDonCuaKhachHang(@maKH)',
    tables: [{ title: 'Bảng HoaDon', sql: 'SELECT maHD, ngayLap, maKH, maNV, tongTien FROM HoaDon ORDER BY maKH, maHD' }],
  },
  {
    id: 'fn-tong-tien-hoa-don', group: 'function', object: 'fn_TinhTongTienHoaDon',
    title: 'fn_TinhTongTienHoaDon',
    problem: 'Xây dựng Scalar Function tính tổng tiền của một hóa đơn từ các dòng chi tiết.',
    params: [p('maHD', 'Mã hóa đơn', 'int', 2)],
    exec: 'SELECT dbo.fn_TinhTongTienHoaDon(@maHD) AS TongTienHoaDon',
    tables: [CTHD_BY_HD],
  },
  {
    id: 'fn-tong-so-luong-ban', group: 'function', object: 'fn_TongSoLuongBanSanPham',
    title: 'fn_TongSoLuongBanSanPham',
    problem: 'Xây dựng Scalar Function tính tổng số lượng đã bán của một sản phẩm.',
    params: [p('maSP', 'Mã sản phẩm', 'varchar', 'SP01')],
    exec: 'SELECT dbo.fn_TongSoLuongBanSanPham(@maSP) AS TongSoLuongBan',
    tables: [{ title: 'Bảng ChiTietHoaDon (của sản phẩm đang xét)', sql: 'SELECT maCTHD, maHD, maSP, soLuongBan, donGia FROM ChiTietHoaDon WHERE maSP = @maSP' }],
  },

  // ===================== TRIGGER =====================
  {
    id: 'trg-tru-kho', group: 'trigger', object: 'trg_TruToKhoKhiBanHang',
    title: 'trg_TruToKhoKhiBanHang',
    problem: 'Xây dựng Trigger tự động trừ số lượng tồn kho của sản phẩm khi thêm một dòng vào ChiTietHoaDon. (Các trigger khác trên ChiTietHoaDon cũng sẽ kích hoạt theo.)',
    params: [p('maHD', 'Mã hóa đơn', 'int', 1), p('maSP', 'Mã sản phẩm', 'varchar', 'SP01'), p('soLuongBan', 'Số lượng bán', 'int', 5), p('donGia', 'Đơn giá', 'float', 15000)],
    exec: 'INSERT INTO ChiTietHoaDon(maHD, maSP, soLuongBan, donGia) VALUES (@maHD, @maSP, @soLuongBan, @donGia)',
    tables: [SP_BY_ID, CTHD_BY_HD],
  },
  {
    id: 'trg-cong-kho', group: 'trigger', object: 'trg_CongTonKhoKhiNhapHang',
    title: 'trg_CongTonKhoKhiNhapHang',
    problem: 'Xây dựng Trigger tự động cộng số lượng tồn kho khi thêm một dòng vào ChiTietPhieuNhap.',
    params: [p('maPN', 'Mã phiếu nhập', 'int', 1), p('maSP', 'Mã sản phẩm', 'varchar', 'SP01'), p('soLuongNhap', 'Số lượng nhập', 'int', 20), p('giaNhap', 'Giá nhập', 'float', 10000)],
    exec: 'INSERT INTO ChiTietPhieuNhap(maPN, maSP, soLuongNhap, giaNhap) VALUES (@maPN, @maSP, @soLuongNhap, @giaNhap)',
    tables: [SP_BY_ID, { title: 'Bảng ChiTietPhieuNhap (của phiếu nhập đang xét)', sql: 'SELECT maCTPN, maPN, maSP, soLuongNhap, giaNhap FROM ChiTietPhieuNhap WHERE maPN = @maPN ORDER BY maCTPN' }],
  },
  {
    id: 'trg-kiem-tra-ton', group: 'trigger', object: 'trg_KiemTraSoLuongTonKhiBanHang',
    title: 'trg_KiemTraSoLuongTonKhiBanHang',
    problem: 'Xây dựng Trigger INSTEAD OF INSERT chặn việc bán hàng khi số lượng mua lớn hơn số lượng tồn. Mặc định thử bán 1000 sản phẩm để trigger chặn lại.',
    params: [p('maHD', 'Mã hóa đơn', 'int', 1), p('maSP', 'Mã sản phẩm', 'varchar', 'SP01'), p('soLuongBan', 'Số lượng bán', 'int', 1000), p('donGia', 'Đơn giá', 'float', 15000)],
    exec: 'INSERT INTO ChiTietHoaDon(maHD, maSP, soLuongBan, donGia) VALUES (@maHD, @maSP, @soLuongBan, @donGia)',
    tables: [SP_BY_ID, CTHD_BY_HD],
  },
  {
    id: 'trg-tong-tien', group: 'trigger', object: 'trg_CapNhatTongTienHoaDon',
    title: 'trg_CapNhatTongTienHoaDon',
    problem: 'Xây dựng Trigger tự động cập nhật HoaDon.tongTien mỗi khi thêm một dòng vào ChiTietHoaDon.',
    params: [p('maHD', 'Mã hóa đơn', 'int', 1), p('maSP', 'Mã sản phẩm', 'varchar', 'SP02'), p('soLuongBan', 'Số lượng bán', 'int', 2), p('donGia', 'Đơn giá', 'float', 20000)],
    exec: 'INSERT INTO ChiTietHoaDon(maHD, maSP, soLuongBan, donGia) VALUES (@maHD, @maSP, @soLuongBan, @donGia)',
    tables: [HD_BY_ID, CTHD_BY_HD],
  },
  {
    id: 'trg-gia-ban', group: 'trigger', object: 'trg_KiemTraGiaBanSanPham',
    title: 'trg_KiemTraGiaBanSanPham',
    problem: 'Xây dựng Trigger ngăn cập nhật giá bán nhỏ hơn giá nhập của sản phẩm. Mặc định đặt giá bán 10.000 (< giá nhập) để trigger hủy thao tác.',
    params: [p('maSP', 'Mã sản phẩm', 'varchar', 'SP01'), p('giaBan', 'Giá bán mới', 'float', 10000)],
    exec: 'UPDATE SanPham SET giaBan = @giaBan WHERE maSP = @maSP',
    tables: [SP_BY_ID],
  },

  // ===================== CURSOR =====================
  {
    id: 'cursor-ton-kho', group: 'cursor', object: null,
    title: 'Cursor kiểm tra tồn kho',
    problem: 'Dùng Cursor duyệt từng sản phẩm và in ra tình trạng tồn kho (HẾT HÀNG / SẮP HẾT HÀNG / CÒN HÀNG). Kết quả hiển thị ở phần LOG (PRINT).',
    params: [],
    exec: cursorScript,
    tables: [{ title: 'Bảng SanPham', sql: 'SELECT maSP, tenSP, soLuongTon FROM SanPham ORDER BY maSP' }],
  },
];
