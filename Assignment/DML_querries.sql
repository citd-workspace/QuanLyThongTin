create database QuanLySieuThi;
go

insert into TaiKhoan (tenDangNhap, matKhau, vaiTro, trangThai) values
(N'admin_hoang', N'Admin@2026', 1, 1),
(N'thukho_dung', N'Kho@2026#', 3, 1),
(N'thungan_lan', N'ThuNganLan@1', 2, 1),
(N'thungan_mai', N'ThuNganMai@2', 2, 1),
(N'nv_quang', N'QuangData@123', 0, 1),
(N'quanly_phong', N'Phong@12345', 1, 1),
(N'thungan_linh', N'LinhTN@2026', 2, 1),
(N'thukho_minh', N'MinhKho@123', 3, 1),
(N'nv_tuan', N'TuanNV@111', 0, 1),
(N'thungan_hoa', N'HoaThuNgan@', 2, 0); 
go

insert into DanhMuc (maDM, tenDM, mota) values
('DM01', N'Sữa & Chế phẩm sữa', N'Sữa tươi, sữa chua, bơ, phô mai'),
('DM02', N'Bánh kẹo & Snack', N'Các loại bánh quy, kẹo, snack'),
('DM03', N'Đồ uống giải khát', N'Nước ngọt, nước ép, trà đóng chai'),
('DM04', N'Mì & Thực phẩm ăn liền', N'Mì, phở, cháo ăn liền'),
('DM05', N'Gia vị & Đồ khô', N'Nước mắm, dầu ăn, đường, muối'),
('DM06', N'Hóa mỹ phẩm', N'Dầu gội, sữa tắm, kem đánh răng'),
('DM07', N'Chăm sóc nhà cửa', N'Bột giặt, nước rửa chén, lau sàn'),
('DM08', N'Thực phẩm đông lạnh', N'Xúc xích, cá viên, há cảo'),
('DM09', N'Trái cây & Rau củ', N'Trái cây tươi, rau củ quả theo ngày'),
('DM10', N'Mẹ & Bé', N'Tã bỉm, sữa bột trẻ em');
go

insert into NhaCungCap (maNCC, tenNCC, diaChi, sdt, email) values
('NCC01', N'Công ty Cổ phần Sữa Việt Nam (Vinamilk)', N'10 Tân Trào, Quận 7, TP.HCM', N'02854155555', 'vinamilk@vinamilk.com'),
('NCC02', N'Suntory PepsiCo Việt Nam', N'88 Đồng Khởi, Quận 1, TP.HCM', N'02838219445', 'pepsico@suntory.com'),
('NCC03', N'Acecook Việt Nam', N'KCN Tân Bình, Tân Phú, TP.HCM', N'02838154064', 'acecook@acecook.com'),
('NCC04', N'Mondelez Kinh Đô', N'138 Hai Bà Trưng, Quận 1, TP.HCM', N'02838270838', 'kinhdo@mdlz.com'),
('NCC05', N'Dầu thực vật Cái Lân (CALOFIC)', N'KCN Cái Lân, Hạ Long, Quảng Ninh', N'02033846997', 'calofic@calofic.com'),
('NCC06', N'Unilever Việt Nam', N'156 Nguyễn Lương Bằng, Quận 7, TP.HCM', N'02854135686', 'cskh@unilever.com'),
('NCC07', N'Masan Consumer', N'23 Lê Duẩn, Quận 1, TP.HCM', N'02862563862', 'masan@masanconsumer.com'),
('NCC08', N'Nestlé Việt Nam', N'KCN Biên Hòa 2, Đồng Nai', N'02513836681', 'nestle@vn.nestle.com'),
('NCC09', N'CP Việt Nam', N'KCN Biên Hòa 2, Đồng Nai', N'02513836251', 'cpvietnam@cp.com'),
('NCC10', N'Procter & Gamble (P&G)', N'Khu công nghiệp Đồng An, Bình Dương', N'02743831200', 'pg.vietnam@pg.com');
go

insert into KhachHang (hoTen, sdt, diaChi, email) values
(N'Nguyễn Văn An', '0903123456', N'12 Lê Lợi, Quận 1, TP.HCM', 'an.nguyen@gmail.com'),
(N'Trần Thị Bích', '0918234567', N'45 Nguyễn Đình Chiểu, Quận 1, TP.HCM', 'bich.tran@yahoo.com'),
(N'Lê Hoàng Cường', '0934345678', N'88 CMT8, Quận 3, TP.HCM', 'cuong.le@gmail.com'),
(N'Phạm Minh Duy', '0989456789', N'102 Hai Bà Trưng, Quận 1, TP.HCM', 'duy.pham@outlook.com'),
(N'Vũ Thị Hồng Hạnh', '0978567890', N'23 Nam Kỳ Khởi Nghĩa, Quận 3, TP.HCM', 'hanh.vu@gmail.com'),
(N'Đặng Quốc Huy', '0945678901', N'56 Điện Biên Phủ, Bình Thạnh, TP.HCM', 'huy.dang@gmail.com'),
(N'Bùi Thu Trang', '0923789012', N'77 Phan Đăng Lưu, Phú Nhuận, TP.HCM', 'trang.bui@gmail.com'),
(N'Hồ Ngọc Tuấn', '0961890123', N'15 Hoàng Văn Thụ, Phú Nhuận, TP.HCM', 'tuan.ho@gmail.com'),
(N'Đỗ Mai Lan', '0912901234', N'34 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM', 'lan.do@gmail.com'),
(N'Ngô Bảo Long', '0938012345', N'90 Bạch Đằng, Bình Thạnh, TP.HCM', 'long.ngo@gmail.com'),
(N'Lý Mạc Sầu', '0988112233', N'123 Vạn Kiếp, Bình Thạnh, TP.HCM', 'sau.ly@gmail.com'),
(N'Quách Tĩnh', '0909998877', N'456 Đinh Tiên Hoàng, Quận 1, TP.HCM', 'tinh.quach@gmail.com'),
(N'Hoàng Dung', '0933445566', N'789 Nguyễn Trãi, Quận 5, TP.HCM', 'dung.hoang@gmail.com'),
(N'Đoàn Dự', '0977665544', N'321 Hùng Vương, Quận 5, TP.HCM', 'du.doan@gmail.com'),
(N'Hư Trúc', '0911223344', N'654 Võ Văn Kiệt, Quận 6, TP.HCM', 'truc.hu@gmail.com');
go

insert into NhanVien (hoTen, gioiTinh, ngaySinh, sdt, diaChi, chucVu, maTK) values
(N'Trịnh Hoàng Long', 1, '1988-04-12', N'0909112233', N'15 Ung Văn Khiêm, Bình Thạnh, TP.HCM', N'Quản lý cửa hàng', 1),
(N'Vũ Tiến Dũng', 1, '1993-08-20', N'0908223344', N'204 Nơ Trang Long, Bình Thạnh, TP.HCM', N'Thủ kho', 2),
(N'Đinh Tuyết Lan', 0, '2001-11-05', N'0907334455', N'35 Nguyễn Văn Đậu, Phú Nhuận, TP.HCM', N'Thu ngân', 3),
(N'Lê Thị Ngọc Mai', 0, '2002-02-18', N'0906445566', N'58 Thích Quảng Đức, Phú Nhuận, TP.HCM', N'Thu ngân', 4),
(N'Trần Nhật Quang', 1, '1999-07-29', N'0905556677', N'112 Đinh Bộ Lĩnh, Bình Thạnh, TP.HCM', N'Nhân viên dữ liệu', 5),
(N'Đoàn Chấn Phong', 1, '2000-01-15', N'0933123123', N'Làng Đại Học, Thủ Đức, TP.HCM', N'Quản lý ca', 6),
(N'Nguyễn Mỹ Linh', 0, '1998-05-10', N'0944234234', N'45 Lê Văn Sỹ, Tân Bình, TP.HCM', N'Thu ngân', 7),
(N'Hồ Quang Minh', 1, '1995-12-01', N'0955345345', N'67 Âu Cơ, Tân Phú, TP.HCM', N'Thủ kho', 8),
(N'Phạm Anh Tuấn', 1, '2001-08-25', N'0966456456', N'89 Lũy Bán Bích, Tân Phú, TP.HCM', N'Nhân viên dữ liệu', 9),
(N'Trần Thanh Hoa', 0, '2003-03-08', N'0977567567', N'10 Lý Thường Kiệt, Tân Bình, TP.HCM', N'Thu ngân', 10);
go

insert into SanPham (maSP, tenSP, donViTinh, giaBan, giaNhap, soLuongTon, maDM) values
('SP01', N'Sữa tươi Vinamilk 1L', N'Hộp', 36000, 29000, 120, 'DM01'),
('SP02', N'Sữa chua Vinamilk 100g', N'Hộp', 7500, 5800, 300, 'DM01'),
('SP03', N'Pepsi lon 320ml', N'Lon', 10500, 7800, 250, 'DM03'),
('SP04', N'Aquafina 500ml', N'Chai', 6000, 4200, 350, 'DM03'),
('SP05', N'Sting dâu 320ml', N'Lon', 11500, 8600, 220, 'DM03'),
('SP06', N'Mì Hảo Hảo tôm chua cay', N'Gói', 4500, 3400, 600, 'DM04'),
('SP07', N'Snack Lay''s vị tự nhiên', N'Gói', 14000, 10500, 160, 'DM02'),
('SP08', N'Dầu ăn Simply 1L', N'Chai', 58000, 47500, 95, 'DM05'),
('SP09', N'Dầu gội Clear Men 630g', N'Chai', 165000, 140000, 50, 'DM06'),
('SP10', N'Sữa tắm Lifebuoy 850g', N'Chai', 145000, 120000, 65, 'DM06'),
('SP11', N'Bột giặt OMO 4.5kg', N'Túi', 185000, 155000, 40, 'DM07'),
('SP12', N'Nước rửa chén Sunlight 3.8kg', N'Can', 110000, 90000, 80, 'DM07'),
('SP13', N'Xúc xích CP Vườn Trường', N'Gói', 45000, 35000, 150, 'DM08'),
('SP14', N'Cá viên chiên CP 500g', N'Gói', 55000, 42000, 100, 'DM08'),
('SP15', N'Táo đỏ Gala New Zealand', N'Kg', 85000, 65000, 45, 'DM09'),
('SP16', N'Cải chíp VietGAP', N'Kg', 25000, 18000, 30, 'DM09'),
('SP17', N'Tã quần Huggies size L 68 miếng', N'Bịch', 315000, 260000, 25, 'DM10'),
('SP18', N'Sữa bột NAN Optipro số 3', N'Hộp', 450000, 390000, 20, 'DM10'),
('SP19', N'Nước mắm Chinsu cá hồi', N'Chai', 42000, 34000, 110, 'DM05'),
('SP20', N'Bánh Chocopie 12 cái', N'Hộp', 55000, 45000, 130, 'DM02');
go

insert into PhieuNhap (ngayNhap, maNCC, maNV, tongTien) values
('2026-08-01', 'NCC01', 2, 8700000),
('2026-08-02', 'NCC02', 8, 3340000),
('2026-08-05', 'NCC03', 2, 1700000),
('2026-08-07', 'NCC04', 8, 3150000),
('2026-08-10', 'NCC05', 2, 2375000),
('2026-08-12', 'NCC06', 8, 7000000),
('2026-08-15', 'NCC07', 2, 3400000),
('2026-08-18', 'NCC08', 8, 7800000),
('2026-08-20', 'NCC09', 2, 3850000),
('2026-08-25', 'NCC10', 8, 5200000);
go

insert into ChiTietPhieuNhap (maPN, maSP, soLuongNhap, giaNhap) values
(1, 'SP01', 100, 29000), 
(1, 'SP02', 100, 58000), 
(2, 'SP03', 100, 7800),  
(2, 'SP04', 100, 4200),   
(2, 'SP05', 100, 8600),   
(2, 'SP02', 50,  25600),  
(3, 'SP06', 500, 3400),   
(4, 'SP07', 300, 10500),  
(5, 'SP08', 50,  47500),  
(6, 'SP09', 50,  140000), 
(7, 'SP19', 100, 34000),  
(8, 'SP18', 20,  390000), 
(9, 'SP13', 50,  35000),  
(9, 'SP14', 50,  42000),  
(10, 'SP17', 20, 260000); 
go

insert into HoaDon (ngayLap, maKH, maNV, tongTien) values
('2026-09-01 09:10', 1, 3, 108000),
('2026-09-01 10:45', 2, 4, 30000),
('2026-09-02 11:20', 3, 7, 22500),
('2026-09-02 14:35', 4, 3, 58000),
('2026-09-03 17:05', 5, 4, 330000),
('2026-09-03 18:40', 6, 7, 185000),
('2026-09-04 12:15', 7, 3, 110000),
('2026-09-04 19:30', 8, 4, 25000),
('2026-09-05 10:00', 9, 7, 315000),
('2026-09-05 16:50', 10, 3, 450000),
('2026-09-06 08:30', 11, 4, 165000),
('2026-09-06 14:15', 12, 7, 42000),
('2026-09-07 11:00', 13, 3, 85000),
('2026-09-07 19:45', 14, 4, 55000),
('2026-09-08 20:15', 15, 7, 145000);
go

insert into ChiTietHoaDon (maHD, maSP, soLuongBan, donGia) values
(1, 'SP01', 3, 36000),    
(2, 'SP04', 5, 6000),     
(3, 'SP02', 3, 7500),     
(4, 'SP08', 1, 58000),    
(5, 'SP09', 2, 165000),   
(6, 'SP11', 1, 185000),   
(7, 'SP12', 1, 110000),   
(8, 'SP16', 1, 25000),    
(9, 'SP17', 1, 315000),   
(10, 'SP18', 1, 450000),  
(11, 'SP20', 3, 55000),   
(12, 'SP19', 1, 42000),   
(13, 'SP15', 1, 85000),   
(14, 'SP14', 1, 55000),   
(15, 'SP10', 1, 145000),  
(1, 'SP06', 5, 4500),     
(2, 'SP03', 2, 10500),
(3, 'SP07', 2, 14000),
(4, 'SP13', 1, 45000),
(5, 'SP01', 2, 36000);
go