DROP DATABASE IF EXISTS BTL2;
CREATE DATABASE BTL2;
USE BTL2;

CREATE TABLE HangThanhVien (
    TenHangThanhVien VARCHAR(50) PRIMARY KEY,
    DiemToiThieu INT DEFAULT 0,
    CHECK (DiemToiThieu >= 0)
);

CREATE TABLE NguoiDung (
    MaNguoiDung VARCHAR(50) PRIMARY KEY,
    TenDangNhap VARCHAR(50) NOT NULL UNIQUE,
    MatKhau VARCHAR(255) NOT NULL,
    SoDienThoai VARCHAR(20),
    MaNguoiGioiThieu VARCHAR(50),
    Ho VARCHAR(50) NOT NULL,
    Ten VARCHAR(50) NOT NULL,
    NgaySinh INT,
    ThangSinh INT,
    NamSinh INT,
    GioiTinh VARCHAR(10),
    QuocGia VARCHAR(50),
    ThanhPho VARCHAR(50),
    MaBuuDien VARCHAR(20),
    DiaChi VARCHAR(255),
    SoHoChieu VARCHAR(50) UNIQUE,
    NoiCap VARCHAR(100),
    NgayHetHan DATE,
    MaGioiThieu VARCHAR(50) UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT CHK_TuGioiThieu CHECK (MaNguoiGioiThieu <> MaGioiThieu),
    CONSTRAINT CHK_GioiTinh CHECK (GioiTinh IN ('Nam', 'Nữ', 'Khác')),
    CONSTRAINT CHK_NgaySinh CHECK (NgaySinh BETWEEN 1 AND 31),
    CONSTRAINT CHK_ThangSinh CHECK (ThangSinh BETWEEN 1 AND 12),
    CONSTRAINT CHK_Email CHECK (Email LIKE '%_@__%.__%')
);

CREATE TABLE HangThanhVien_UuDai (
    TenHangThanhVien VARCHAR(50),
    UuDai VARCHAR(255),
    PRIMARY KEY (TenHangThanhVien, UuDai), 
    FOREIGN KEY (TenHangThanhVien) REFERENCES HangThanhVien(TenHangThanhVien)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE KhachHang (
    MaNguoiDung VARCHAR(50) PRIMARY KEY,
    TenHangThanhVien VARCHAR(50) DEFAULT 'Đồng',
    SoThichDuLich VARCHAR(255),
    NgonNguSuDung VARCHAR(50),
    LoaiTienTeSuDung VARCHAR(10),
    DiemTichLuy INT DEFAULT 0,
    
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung) 
        ON DELETE CASCADE,
    FOREIGN KEY (TenHangThanhVien) REFERENCES HangThanhVien(TenHangThanhVien),
    CHECK (DiemTichLuy >= 0)
);

CREATE TABLE QuanTriVien (
    MaNguoiDung VARCHAR(50) PRIMARY KEY,
    NgayBatDauLam DATE NOT NULL,
    QuyenHan VARCHAR(50),
    BoPhan VARCHAR(50),
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung) 
        ON DELETE CASCADE
);

CREATE TABLE ChuSoHuu (
    MaNguoiDung VARCHAR(50) PRIMARY KEY,
    MaSoThue VARCHAR(50) NOT NULL UNIQUE,
    TenPhapNhanKinhDoanh VARCHAR(255) NOT NULL,
    TenNganHang VARCHAR(100) NOT NULL,
    SoTaiKhoan VARCHAR(50) NOT NULL,
    TenNguoiThuHuong VARCHAR(100) NOT NULL,
    TrangThaiXacMinh VARCHAR(50) DEFAULT 'Chờ xác minh',
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung) 
        ON DELETE CASCADE,
    CHECK (TrangThaiXacMinh IN ('Chờ xác minh', 'Đã xác minh', 'Bị từ chối'))
);

CREATE TABLE KhachHang_LKMXH (
    `MaNguoiDung - KhachHang` VARCHAR(50),
    LienKetMangXaHoi VARCHAR(255),
    PRIMARY KEY (`MaNguoiDung - KhachHang`, LienKetMangXaHoi),
    FOREIGN KEY (`MaNguoiDung - KhachHang`) REFERENCES KhachHang(MaNguoiDung) 
        ON DELETE CASCADE
);

CREATE TABLE ChoO (
    MaChoO VARCHAR(50) PRIMARY KEY,
    TenChoO VARCHAR(255) NOT NULL,
    SoNha VARCHAR(50),
    TenDuong VARCHAR(255) NOT NULL,
    MaBuuDien VARCHAR(20) NOT NULL,
    ThanhPho VARCHAR(100) NOT NULL,
    QuocGia VARCHAR(100) NOT NULL,
    DiemDanhGiaTrungBinh DECIMAL(2,1) DEFAULT 0,
    MoTaTongQuat TEXT,
    TrangThaiXacNhan VARCHAR(50) DEFAULT 'Cho xac nhan',
    `MaNguoiDung - QuanTriVien` VARCHAR(50),
    FOREIGN KEY (`MaNguoiDung - QuanTriVien`) REFERENCES QuanTriVien(MaNguoiDung)
        ON DELETE SET NULL,
    CHECK (TrangThaiXacNhan IN ('Cho xac nhan', 'Da xac nhan', 'Tu choi'))
);

CREATE TABLE SoHuu (
    `MaNguoiDung - ChuSoHuu` VARCHAR(50),
    MaChoO VARCHAR(50),
    PRIMARY KEY (`MaNguoiDung - ChuSoHuu`, MaChoO),
    FOREIGN KEY (`MaNguoiDung - ChuSoHuu`) REFERENCES ChuSoHuu(MaNguoiDung) 
        ON DELETE CASCADE,
    FOREIGN KEY (MaChoO) REFERENCES ChoO(MaChoO) 
        ON DELETE CASCADE
);

CREATE TABLE ChoO_HinhAnh (
    MaChoO VARCHAR(50),
    HinhAnh VARCHAR(255),
    PRIMARY KEY (MaChoO, HinhAnh),
    FOREIGN KEY (MaChoO) REFERENCES ChoO(MaChoO) 
        ON DELETE CASCADE
);

CREATE TABLE ChoO_TienIch (
    MaChoO VARCHAR(50),
    TienIch VARCHAR(255),
    PRIMARY KEY (MaChoO, TienIch),
    FOREIGN KEY (MaChoO) REFERENCES ChoO(MaChoO) 
        ON DELETE CASCADE
);

CREATE TABLE KhachSan (
    MaChoO VARCHAR(50) PRIMARY KEY,
    TieuChuanSao INT,
    DichVuDuaDonTaiSanBay VARCHAR(255),
    FOREIGN KEY (MaChoO) REFERENCES ChoO(MaChoO) 
        ON DELETE CASCADE,
    CHECK (TieuChuanSao BETWEEN 1 AND 5)
);

CREATE TABLE Resort (
    MaChoO VARCHAR(50) PRIMARY KEY,
    XeDienNoiKhu VARCHAR(255),
    FOREIGN KEY (MaChoO) REFERENCES ChoO(MaChoO) 
        ON DELETE CASCADE
);

CREATE TABLE Resort_ChungChiBaoVeMoiTruong (
    `MaChoO - Resort` VARCHAR(50),
    ChungChiBaoVeMoiTruong VARCHAR(255),
    PRIMARY KEY (`MaChoO - Resort`, ChungChiBaoVeMoiTruong),
    FOREIGN KEY (`MaChoO - Resort`) REFERENCES Resort(MaChoO)
        ON DELETE CASCADE
);

CREATE TABLE Resort_DichVuCaoCap (
    `MaChoO - Resort` VARCHAR(50),
    DichVuCaoCap VARCHAR(255),
    PRIMARY KEY (`MaChoO - Resort`, DichVuCaoCap),
    FOREIGN KEY (`MaChoO - Resort`) REFERENCES Resort(MaChoO)
        ON DELETE CASCADE
);

CREATE TABLE Villa (
    MaChoO VARCHAR(50) PRIMARY KEY,
    DienTichKhuonVien FLOAT,
    KhoangCachGanNhatDenKhuTrungTam FLOAT,
    FOREIGN KEY (MaChoO) REFERENCES ChoO(MaChoO) 
        ON DELETE CASCADE,
    CHECK (DienTichKhuonVien > 0),
    CHECK (KhoangCachGanNhatDenKhuTrungTam >= 0)
);

CREATE TABLE CanHo (
    MaChoO VARCHAR(50) PRIMARY KEY,
    PhiQuanLyDinhKy DECIMAL(10,2),
    HuongBanCong VARCHAR(50),
    FOREIGN KEY (MaChoO) REFERENCES ChoO(MaChoO) 
        ON DELETE CASCADE,
    CHECK (PhiQuanLyDinhKy >= 0)
);


CREATE TABLE TienNghi (
    MaTienNghi VARCHAR(50) PRIMARY KEY,
    TenTienNghi VARCHAR(255) NOT NULL,
    MoTaChiTiet TEXT
);

CREATE TABLE LoaiPhong (
    MaLoaiPhong VARCHAR(50) PRIMARY KEY,
    MaChoO VARCHAR(50) NOT NULL,
    TenLoaiPhong VARCHAR(255) NOT NULL,
    SoLuongPhongTrong INT DEFAULT 0,
    SucChuaToiDa VARCHAR(50) NOT NULL,
    FOREIGN KEY (MaChoO) REFERENCES ChoO(MaChoO) 
        ON DELETE CASCADE
);

CREATE TABLE TrangBi (
    MaLoaiPhong VARCHAR(50),
    MaTienNghi VARCHAR(50),
    PRIMARY KEY (MaLoaiPhong, MaTienNghi),
    FOREIGN KEY (MaLoaiPhong) REFERENCES LoaiPhong(MaLoaiPhong) 
        ON DELETE CASCADE,
    FOREIGN KEY (MaTienNghi) REFERENCES TienNghi(MaTienNghi) 
        ON DELETE CASCADE
);



CREATE TABLE LoaiPhong_BoTriGiuongNgu (
    MaLoaiPhong VARCHAR(50),
    BoTriGiuongNgu VARCHAR(255),
    PRIMARY KEY (MaLoaiPhong, BoTriGiuongNgu),
    FOREIGN KEY (MaLoaiPhong) REFERENCES LoaiPhong(MaLoaiPhong) 
        ON DELETE CASCADE
);

CREATE TABLE PhongVatLy (
    MaLoaiPhong VARCHAR(50),
    SoPhong VARCHAR(50),
    ViTriTang VARCHAR(50),
    TinhTrangHienTai VARCHAR(50) DEFAULT 'Còn trống',
    PRIMARY KEY (MaLoaiPhong, SoPhong),
    FOREIGN KEY (MaLoaiPhong) REFERENCES LoaiPhong(MaLoaiPhong) 
        ON DELETE CASCADE,
    CHECK (TinhTrangHienTai IN ('Còn trống', 'Đang sử dụng', 'Đang sửa chữa')) 
);

CREATE TABLE GoiDichVu (
    MaLoaiPhong VARCHAR(50),
    MaGoi VARCHAR(50),
    GiaBan DECIMAL(10,2) NOT NULL,
    CacLuaChon TEXT,
    ChinhSachHuy TEXT,
    
    PRIMARY KEY (MaLoaiPhong, MaGoi),
    FOREIGN KEY (MaLoaiPhong) REFERENCES LoaiPhong(MaLoaiPhong) ON DELETE CASCADE,
    CHECK (GiaBan >= 0)
);

CREATE TABLE DonDatPhong (
    MaDonDatPhong VARCHAR(50) PRIMARY KEY,
    NgayTao DATETIME DEFAULT CURRENT_TIMESTAMP,
    NgayNhanPhong DATE NOT NULL,
    NgayTraPhong DATE NOT NULL,
    DemLuuTru INT,
    TongSoTien DECIMAL(15,2),
    TrangThaiXuLy VARCHAR(50) DEFAULT 'Đang chờ thanh toán',
    `MaNguoiDung - KhachHang` VARCHAR(50) NOT NULL,
    
    FOREIGN KEY (`MaNguoiDung - KhachHang`) REFERENCES KhachHang(MaNguoiDung) 
        ON DELETE CASCADE,
    CHECK (NgayTraPhong >= NgayNhanPhong),
    CHECK (TrangThaiXuLy IN ('Đang chờ thanh toán', 'Đã tất toán', 'Đã hủy', 'Đã trả phòng'))
);

CREATE TABLE ApDung (
    MaDonDatPhong VARCHAR(50),
    MaLoaiPhong VARCHAR(50),
    MaGoi VARCHAR(50),
    SoLuongPhong INT NOT NULL,
    PRIMARY KEY (MaDonDatPhong, MaLoaiPhong, MaGoi),
    FOREIGN KEY (MaDonDatPhong) REFERENCES DonDatPhong(MaDonDatPhong) 
        ON DELETE CASCADE,
    FOREIGN KEY (MaLoaiPhong, MaGoi) REFERENCES GoiDichVu(MaLoaiPhong, MaGoi) 
        ON DELETE CASCADE,
    CHECK (SoLuongPhong > 0)
);

CREATE TABLE GiaoDichThanhToan (
    MaDonDatPhong VARCHAR(50),
    MaGiaoDich VARCHAR(50),
    PhuongThucThanhToan VARCHAR(50),
    TinhTrang VARCHAR(50),
    SoLanGiaoDich INT DEFAULT 1,
    SoTienDaThanhToan DECIMAL(15,2) NOT NULL,
    LoaiGiaoDich VARCHAR(50),
    ThoiGianThucHien DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (MaDonDatPhong, MaGiaoDich),
    FOREIGN KEY (MaDonDatPhong) REFERENCES DonDatPhong(MaDonDatPhong) 
        ON DELETE CASCADE,
    CHECK (SoTienDaThanhToan >= 0),
    CHECK (SoLanGiaoDich > 0)
);

CREATE TABLE QuyDinh (
    MaQuyDinh VARCHAR(50) PRIMARY KEY,
    TenQuyDinh VARCHAR(255) NOT NULL,
    NoiDung TEXT
);

CREATE TABLE TuanThu (
    MaQuyDinh VARCHAR(50),
    MaLoaiPhong VARCHAR(50),
    SoPhong VARCHAR(50),
    PRIMARY KEY (MaQuyDinh, MaLoaiPhong, SoPhong),
    FOREIGN KEY (MaQuyDinh) REFERENCES QuyDinh(MaQuyDinh) 
        ON DELETE CASCADE,
    FOREIGN KEY (MaLoaiPhong, SoPhong) REFERENCES PhongVatLy(MaLoaiPhong, SoPhong) 
        ON DELETE CASCADE
);

CREATE TABLE BaiDanhGia (
    MaBaiDanhGia VARCHAR(50) PRIMARY KEY,
    MaDonDatPhong VARCHAR(50) NOT NULL,
    `MaNguoiDung - QuanTriVien` VARCHAR(50), 
    NoiDungBaiDanhGia TEXT,
    DiemSo DECIMAL(3,2) NOT NULL,
    NgayDangBai DATETIME DEFAULT CURRENT_TIMESTAMP,
    NgayPhanHoi DATETIME,
    NoiDungPhanHoi TEXT,
    TrangThaiKiemDuyet VARCHAR(50) DEFAULT 'Chờ duyệt',
    FOREIGN KEY (MaDonDatPhong) REFERENCES DonDatPhong(MaDonDatPhong) 
        ON DELETE CASCADE,
    FOREIGN KEY (`MaNguoiDung - QuanTriVien`) REFERENCES QuanTriVien(MaNguoiDung) 
        ON DELETE SET NULL,
    CHECK (DiemSo BETWEEN 1 AND 5),
    CHECK (NgayPhanHoi >= NgayDangBai),
    CHECK (TrangThaiKiemDuyet IN ('Chờ duyệt', 'Đã duyệt', 'Không hợp lệ'))
);

CREATE TABLE BaiDanhGia_HinhAnhVideo (
    MaBaiDanhGia VARCHAR(50),
    HinhAnhVideo VARCHAR(255),
    PRIMARY KEY (MaBaiDanhGia, HinhAnhVideo),
    FOREIGN KEY (MaBaiDanhGia) REFERENCES BaiDanhGia(MaBaiDanhGia) 
        ON DELETE CASCADE
);