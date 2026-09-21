create database QuanLySieuThi;
go

use QuanLySieuThi;
go

create table TaiKhoan (
    maTK int primary key identity(1,1),
    tenDangNhap nvarchar(50) not null,
    matKhau nvarchar(50) not null,
    vaiTro int check (vaiTro in (0,1,2,3)) not null,
    trangThai bit default 1
);
go

create table DanhMuc (
    maDM varchar(10) primary key,
    tenDM nvarchar(100) not null,
    mota nvarchar(200) not null
);
go

create table NhaCungCap (
    maNCC varchar(10) primary key,
    tenNCC nvarchar(100) not null,
    diaChi nvarchar(200) not null,
    sdt nvarchar(15) not null,
    email varchar(100) not null
);
go

create table KhachHang (
    maKH int primary key identity(1,1),
    hoTen nvarchar(100) not null,
    sdt varchar(15),
    diaChi nvarchar(255),
    email varchar(100)
);
go

create table NhanVien (
    maNV int primary key identity(1,1),
    hoTen nvarchar(100) not null,
    gioiTinh bit check (gioiTinh in (0,1)) not null,
    ngaySinh date not null,
    sdt nvarchar(15) not null,
    diaChi nvarchar(200) not null,
    chucVu nvarchar(50) not null,
    maTK int foreign key references TaiKhoan(maTK)
);
go

create table SanPham(
    maSP varchar(10) primary key,
    tenSP nvarchar(100) not null,
    donViTinh nvarchar(50) not null,
    giaBan float not null,
    giaNhap float not null,
    soLuongTon int default 0,
    maDM varchar(10) foreign key references DanhMuc(maDM)
);
go

create table PhieuNhap (
    maPN int primary key identity(1,1),
    ngayNhap datetime default getdate(),
    maNCC varchar(10) references nhacungcap(mancc),
    maNV int references NhanVien(maNV),
    tongTien float
);
go

create table HoaDon (
    maHD int primary key identity(1,1),
    ngayLap datetime default getdate(),
    maKH int foreign key references KhachHang(maKH),
    maNV int foreign key references NhanVien(maNV),
    tongTien float
);
go

create table ChiTietPhieuNhap (
    maCTPN int primary key identity(1,1),
    maPN int foreign key references PhieuNhap(maPN),
    maSP varchar(10) foreign key references SanPham(maSP),
    soLuongNhap int not null,
    giaNhap float not null
);
go

create table ChiTietHoaDon (
    maCTHD int primary key identity(1,1),
    maHD int foreign key references HoaDon(maHD),
    maSP varchar(10) foreign key references SanPham(maSP),
    soLuongBan int not null,
    donGia float not null
);
go
