--create database [QuanLyDeTai]

use QuanLyDeTai

create table sinhvien
(
	mssv		char(8)			primary key,
	tensv		nvarchar(30)	not null,
	sdt			varchar(10),
	lop			char(10)		not null,
	diachi		nvarchar(50)	not null
)


create table detai
(
	msdt		char(6)			primary key,
	tendt		nvarchar(30)	not null
)


create table sv_detai
(
	mssv		char(8)			foreign key references sinhvien(mssv),
	msdt		char(6)			foreign key references detai(msdt),
	primary key (mssv, msdt)
)


create table hocham
(
	mshh		int				primary key identity,
	tenhh		nvarchar(20)	not null
)


create table giaovien
(
	msgv		char(5)			primary key,
	tengv		nvarchar(30)	not null,
	diachi		nvarchar(50)	not null,
	sodt		varchar(10)		not null,
	mshh		int				foreign key references hocham(mshh),
	namhh		smalldatetime	not null
)


create table hocvi
(
	mshv		int				primary key identity,
	tenhv		nvarchar(20)	not null
)


create table chuyennganh
(
	mscn		int				primary key identity,
	tencn		nvarchar(30)	not null
)


create table gv_hv_cn
(
	msgv		char(5)			foreign key references giaovien(msgv),
	mshv		int				foreign key references hocvi(mshv),
	mscn		int				foreign key references chuyennganh(mscn),
	nam			smalldatetime	not null,
	primary key (msgv, mshv, mscn)
)


create table gv_hddt
(
	msgv		char(5)			foreign key references giaovien(msgv),
	msdt		char(6)			foreign key references detai(msdt),
	diem		float			not null,
	primary key (msgv, msdt)
)


create table gv_pbdt
(
	msgv		char(5)			foreign key references giaovien(msgv),
	msdt		char(6)			foreign key references detai(msdt),
	diem		float			not null,
	primary key (msgv, msdt)
)


create table gv_uvdt
(
	msgv		char(5)			foreign key references giaovien(msgv),
	msdt		char(6)			foreign key references detai(msdt),
	diem		float			not null,
	primary key (msgv, msdt)
)


create table hoidong
(
	mshd		int				primary key identity,
	phong		int,
	tgbd		smalldatetime,
	ngayhd		smalldatetime	not null,
	tinhtrang	nvarchar(30)	not null,
	msgv		char(5)			foreign key references giaovien(msgv)
)


create table hoidong_gv
(
	mshd		int				foreign key references hoidong(mshd),
	msgv		char(5)			foreign key references giaovien(msgv),
	primary key (mshd, msgv)
)


create table hoidong_dt
(
	mshd		int				foreign key references hoidong(mshd),
	msdt		char(6)			foreign key references detai(msdt),
	quyetdinh	nvarchar(10),
	primary key (mshd, msdt)
)


-- insert data
insert into sinhvien(mssv, tensv, sdt, lop, diachi) values
('13520001', N'Nguyễn Văn An', '0906762255', 'SE103.U32', N'THỦ ĐỨC'),
('13520002', N'Phan Tấn Đạt', '0975672350', ' IE204.T21', N'QUẬN 1'),
('13520003', N'Nguyễn Anh Hải', '0947578688', 'IE205.R12', N'QUẬN 9'),
('13520004', N'Phạm Tài', '0956757869', 'IE202.A22', N'QUẬN 1'),
('13520005', N'Lê Thúy Hằng', '0976668688', 'SE304.E22', N'THỦ ĐỨC'),
('13520006', N'Ưng Hồng Ân', '0957475898', 'IE208.F33', N'QUẬN 2')


insert into detai(msdt, tendt) values
('97001', N'Quản lý thư viện'),
('97002', N'Nhận dạng vân tay'),
('97003', N'Bán đấu giá trên mạng'),
('97004', N'Quản lý siêu thị'),
('97005', N'Xử lý ảnh'),
('97006', N'Hệ giải toán thông minh')


insert into sv_detai(mssv, msdt) values
('13520001', '97004'),
('13520002', '97005'),
('13520003', '97001'),
('13520004', '97002'),
('13520005', '97003'),
('13520006', '97005')


insert into hocham(tenhh) values
(N'PHÓ GIÁO SƯ'),
(N'GIÁO SƯ')


insert into giaovien(msgv, tengv, diachi, sodt, mshh, namhh) values
('00201', N'Trần Trung', N'Bến Tre', '35353535',  1, '1996-01-01'),
('00202', N'Nguyễn Văn An', N'Tiền Giang', '67868688',  1, '1996-01-01'),
('00203', N'Trần Thu Trang', N'Cần Thơ', '74758687',  1, '1996-01-01'),
('00204', N'Nguyễn Thị Loan', N'TP.HCM', '56575868',  2, '2005-01-01'),
('00205', N'Chu Tiến', N'Hà Nội', '46466646',  2, '2005-01-01')


insert into hocvi(tenhv) values
(N'Kỹ sư'),
(N'Cử nhân'),
(N'Thạc sĩ'),
(N'Tiến sĩ'),
(N'Tiến sĩ Khoa học')


insert into chuyennganh(tencn) values
(N'Công nghệ Web'),
(N'Mạng xã hội'),
(N'Quản lý CNTT'),
(N'GIS')


insert into gv_hv_cn(msgv, mshv, mscn, nam) values
('00201', 1, 1, '2013-01-01'),
('00201', 1, 2, '2013-01-01'),
('00201', 2, 1, '2014-01-01'),
('00202', 3, 2, '2013-01-01'),
('00203', 2, 4, '2014-01-01'),
('00204', 3, 2, '2014-01-01')


insert into gv_hddt(msgv, msdt, diem) values
('00201', '97001', 8),
('00202', '97002', 7),
('00205', '97001', 9),
('00204', '97004', 7),
('00203', '97005', 9)


insert into gv_pbdt(msgv, msdt, diem) values
('00201', '97005', 8),
('00202', '97001', 7),
('00205', '97004', 9),
('00204', '97003', 7),
('00203', '97002', 9)


insert into gv_uvdt(msgv, msdt, diem) values
('00205', '97005', 8),
('00202', '97005', 7),
('00204', '97005', 9),
('00203', '97001', 7),
('00204', '97001', 9),
('00205', '97001', 8),
('00203', '97003', 7),
('00201', '97003', 9),
('00202', '97003', 7),
('00201', '97004', 9),
('00202', '97004', 8),
('00203', '97004', 7),
('00201', '97002', 9),
('00204', '97002', 7),
('00205', '97002', 9),
('00201', '97006', 9),
('00202', '97006', 7),
('00204', '97006', 9)


insert into hoidong(phong, tgbd, ngayhd, tinhtrang, msgv) values
('002', '07:00:00', '2014-11-29', N'Thật', '00201'),
('102', '07:00:00', '2014-12-05', N'Thật', '00202'),
('003', '08:00:00', '2014-12-06', N'Thật', '00203')


insert into hoidong_gv (mshd, msgv) values
(1, '00201'),
(1, '00202'),
(1, '00203'),
(1, '00204'),
(2, '00203'),
(2, '00202'),
(2, '00205'),
(2, '00204'),
(3, '00201'),
(3, '00202'),
(3, '00203'),
(3, '00204')


insert into hoidong_dt (mshd, msdt, quyetdinh) values
(1, '97001', N'Được'),
(1, '97002', N'Được'),
(2, '97001', N'Không'),
(2, '97004', N'Không'),
(1, '97005', N'Được'),
(3, '97001', N'Không'),
(3, '97002', N'Được')
