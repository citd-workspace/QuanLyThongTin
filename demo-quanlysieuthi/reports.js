// Các biểu đồ trực quan hóa trực tiếp trên HTML (dữ liệu truy vấn từ SQL Server mỗi lần mở).
module.exports = [
  {
    id: 'doanh-thu-ngay', title: 'Doanh thu theo ngày', unit: 'VNĐ',
    sql: `SELECT CONVERT(varchar(10), d, 23) AS label, SUM(tongTien) AS value
          FROM (SELECT CAST(ngayLap AS DATE) AS d, tongTien FROM HoaDon) x
          GROUP BY d ORDER BY d`,
  },
  {
    id: 'doanh-thu-nhan-vien', title: 'Doanh thu theo nhân viên', unit: 'VNĐ',
    sql: `SELECT nv.hoTen AS label, SUM(hd.tongTien) AS value
          FROM HoaDon hd JOIN NhanVien nv ON nv.maNV = hd.maNV
          GROUP BY nv.maNV, nv.hoTen ORDER BY value DESC`,
  },
  {
    id: 'top-san-pham', title: 'Top 10 sản phẩm bán chạy (theo số lượng)', unit: 'sản phẩm',
    sql: `SELECT TOP 10 sp.tenSP AS label, SUM(ct.soLuongBan) AS value
          FROM ChiTietHoaDon ct JOIN SanPham sp ON sp.maSP = ct.maSP
          GROUP BY sp.maSP, sp.tenSP ORDER BY value DESC`,
  },
  {
    id: 'ton-kho-danh-muc', title: 'Tồn kho theo danh mục', unit: 'sản phẩm',
    sql: `SELECT dm.tenDM AS label, SUM(sp.soLuongTon) AS value
          FROM SanPham sp JOIN DanhMuc dm ON dm.maDM = sp.maDM
          GROUP BY dm.maDM, dm.tenDM ORDER BY value DESC`,
  },
];
