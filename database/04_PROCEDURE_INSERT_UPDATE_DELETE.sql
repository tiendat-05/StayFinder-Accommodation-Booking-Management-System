USE BTL2;

DELIMITER //

CREATE PROCEDURE sp_InsertNguoiDung(
    IN p_MaNguoiDung VARCHAR(50),
    IN p_TenDangNhap VARCHAR(50),
    IN p_MatKhau VARCHAR(255),
    IN p_SoDienThoai VARCHAR(20),
    IN p_MaNguoiGioiThieu VARCHAR(50),
    IN p_Ho VARCHAR(50),
    IN p_Ten VARCHAR(50),
    IN p_NgaySinh INT,
    IN p_ThangSinh INT,
    IN p_NamSinh INT,
    IN p_GioiTinh VARCHAR(10),
    IN p_QuocGia VARCHAR(50),
    IN p_ThanhPho VARCHAR(50),
    IN p_MaBuuDien VARCHAR(20),
    IN p_DiaChi VARCHAR(255),
    IN p_SoHoChieu VARCHAR(50),
    IN p_NoiCap VARCHAR(100),
    IN p_NgayHetHan DATE,
    IN p_MaGioiThieu VARCHAR(50),
    IN p_Email VARCHAR(100)
)
BEGIN
    IF p_MaNguoiDung IS NULL OR p_MaNguoiDung = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Mã người dùng không được để trống!';
    END IF;

    IF p_TenDangNhap IS NULL OR p_TenDangNhap = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Tên đăng nhập không được để trống!';
    END IF;

    IF p_MatKhau IS NULL OR p_MatKhau = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Mật khẩu không được để trống!';
    END IF;

    IF p_Ho IS NULL OR p_Ho = '' OR p_Ten IS NULL OR p_Ten = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Họ và tên không được để trống!';
    END IF;

    IF p_Email IS NULL OR p_Email = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Email không được để trống!';
    END IF;

    IF p_MaGioiThieu = p_MaNguoiGioiThieu THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Người dùng không được tự giới thiệu bản thân!';
    END IF;

    IF p_GioiTinh NOT IN ('Nam', 'Nữ', 'Khác') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Giới tính không hợp lệ!';
    END IF;

    IF p_NgaySinh < 1 OR p_NgaySinh > 31 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Ngày sinh không hợp lệ!';
    END IF;

    IF p_ThangSinh < 1 OR p_ThangSinh > 12 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Tháng sinh không hợp lệ!';
    END IF;

    IF p_Email NOT LIKE '%_@__%.__%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Định dạng email không hợp lệ!';
    END IF;

    IF ( YEAR(CURDATE()) - p_NamSinh ) < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Người dùng phải từ 18 tuổi trở lên!';
    END IF;

    IF EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = p_MaNguoiDung) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Mã người dùng đã tồn tại!';
    END IF;

    IF EXISTS (SELECT 1 FROM NguoiDung WHERE TenDangNhap = p_TenDangNhap) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Tên đăng nhập đã tồn tại!';
    END IF;

    IF EXISTS (SELECT 1 FROM NguoiDung WHERE Email = p_Email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Email đã tồn tại!';
    END IF;

    INSERT INTO NguoiDung(
        MaNguoiDung, TenDangNhap, MatKhau, SoDienThoai, MaNguoiGioiThieu,
        Ho, Ten, NgaySinh, ThangSinh, NamSinh, GioiTinh,
        QuocGia, ThanhPho, MaBuuDien, DiaChi,
        SoHoChieu, NoiCap, NgayHetHan, MaGioiThieu, Email
    )
    VALUES(
        p_MaNguoiDung, p_TenDangNhap, p_MatKhau, p_SoDienThoai, p_MaNguoiGioiThieu,
        p_Ho, p_Ten, p_NgaySinh, p_ThangSinh, p_NamSinh, p_GioiTinh,
        p_QuocGia, p_ThanhPho, p_MaBuuDien, p_DiaChi,
        p_SoHoChieu, p_NoiCap, p_NgayHetHan, p_MaGioiThieu, p_Email
    );
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_InsertChoO(
    IN p_MaChoO VARCHAR(50),
    IN p_TenChoO VARCHAR(255),
    IN p_SoNha VARCHAR(50),
    IN p_TenDuong VARCHAR(255),
    IN p_MaBuuDien VARCHAR(20),
    IN p_ThanhPho VARCHAR(100),
    IN p_QuocGia VARCHAR(100),
    IN p_MoTa TEXT
)
BEGIN

    IF EXISTS (SELECT 1 FROM ChoO WHERE MaChoO = p_MaChoO) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Mã chỗ ở này đã tồn tại trên hệ thống!';
    END IF;

    IF p_TenChoO IS NULL OR TRIM(p_TenChoO) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Tên chỗ ở không được để trống!';
    END IF;

    IF p_TenDuong IS NULL OR p_ThanhPho IS NULL OR p_QuocGia IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Thông tin địa chỉ (Đường, Thành phố, Quốc gia) không được thiếu!';
    END IF;

    INSERT INTO ChoO (
        MaChoO, TenChoO, SoNha, TenDuong, MaBuuDien,
        ThanhPho, QuocGia, DiemDanhGiaTrungBinh,
        MoTaTongQuat, TrangThaiXacNhan
    )
    VALUES (
        p_MaChoO, p_TenChoO, p_SoNha, p_TenDuong, p_MaBuuDien,
        p_ThanhPho, p_QuocGia, 0.0,
        p_MoTa, 'Cho xac nhan'
    );

    SELECT 'Thêm chỗ ở mới thành công!' AS Message;
END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_InsertDonDatPhong(
    IN p_MaDonDatPhong VARCHAR(50),
    IN p_NgayNhanPhong DATE,
    IN p_NgayTraPhong DATE,
    IN p_MaKhachHang VARCHAR(50)
)
BEGIN
    IF p_MaDonDatPhong IS NULL OR TRIM(p_MaDonDatPhong) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Mã đơn đặt phòng không được để trống!';
    END IF;

    IF EXISTS (SELECT 1 FROM DonDatPhong WHERE MaDonDatPhong = p_MaDonDatPhong) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Mã đơn đặt phòng đã tồn tại!';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaNguoiDung = p_MaKhachHang) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Mã khách hàng không tồn tại!';
    END IF;

    IF p_NgayNhanPhong < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Ngày nhận phòng không thể nhỏ hơn ngày hiện tại!';
    END IF;

    IF p_NgayTraPhong <= p_NgayNhanPhong THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 ngày!';
    END IF;

    INSERT INTO DonDatPhong (
        MaDonDatPhong,
        NgayTao,
        NgayNhanPhong,
        NgayTraPhong,
        DemLuuTru,
        TongSoTien,
        TrangThaiXuLy,
        `MaNguoiDung - KhachHang`
    )
    VALUES (
        p_MaDonDatPhong,
        NOW(),
        p_NgayNhanPhong,
        p_NgayTraPhong,
        DATEDIFF(p_NgayTraPhong, p_NgayNhanPhong),
        0,
        'Đang chờ duyệt',
        p_MaKhachHang
    );

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_UpdateNguoiDung(
    IN p_MaNguoiDung VARCHAR(50),
    IN p_TenDangNhap VARCHAR(50),
    IN p_MatKhau VARCHAR(255),
    IN p_SoDienThoai VARCHAR(20),
    IN p_MaNguoiGioiThieu VARCHAR(50),
    IN p_Ho VARCHAR(50),
    IN p_Ten VARCHAR(50),
    IN p_NgaySinh INT,
    IN p_ThangSinh INT,
    IN p_NamSinh INT,
    IN p_GioiTinh VARCHAR(10),
    IN p_QuocGia VARCHAR(50),
    IN p_ThanhPho VARCHAR(50),
    IN p_MaBuuDien VARCHAR(20),
    IN p_DiaChi VARCHAR(255),
    IN p_SoHoChieu VARCHAR(50),
    IN p_NoiCap VARCHAR(100),
    IN p_NgayHetHan DATE,
    IN p_MaGioiThieu VARCHAR(50),
    IN p_Email VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = p_MaNguoiDung) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Mã người dùng không tồn tại!';
    END IF;

    IF p_TenDangNhap IS NULL OR p_TenDangNhap = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Tên đăng nhập không được để trống!';
    END IF;

    IF p_Ho IS NULL OR p_Ho = '' OR p_Ten IS NULL OR p_Ten = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Họ và tên không được để trống!';
    END IF;

    IF p_Email IS NULL OR p_Email = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Email không được để trống!';
    END IF;

    IF p_MaGioiThieu = p_MaNguoiGioiThieu THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Người dùng không được tự giới thiệu bản thân!';
    END IF;

    IF p_GioiTinh NOT IN ('Nam', 'Nữ', 'Khác') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Giới tính không hợp lệ!';
    END IF;

    IF (p_NgaySinh < 1 OR p_NgaySinh > 31) OR (p_ThangSinh < 1 OR p_ThangSinh > 12) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Ngày tháng sinh không hợp lệ!';
    END IF;

    IF p_Email NOT LIKE '%_@__%.__%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Định dạng email không hợp lệ!';
    END IF;

    IF (YEAR(CURDATE()) - p_NamSinh) < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Người dùng phải từ 18 tuổi trở lên!';
    END IF;

    IF EXISTS (SELECT 1 FROM NguoiDung WHERE TenDangNhap = p_TenDangNhap AND MaNguoiDung <> p_MaNguoiDung) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Tên đăng nhập đã được sử dụng bởi người khác!';
    END IF;

    IF EXISTS (SELECT 1 FROM NguoiDung WHERE SoHoChieu = p_SoHoChieu AND MaNguoiDung <> p_MaNguoiDung) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Số hộ chiếu đã được sử dụng bởi người khác!';
    END IF;

    IF EXISTS (SELECT 1 FROM NguoiDung WHERE Email = p_Email AND MaNguoiDung <> p_MaNguoiDung) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Email đã được sử dụng bởi người khác!';
    END IF;

    UPDATE NguoiDung
    SET
        TenDangNhap = p_TenDangNhap,
        MatKhau = p_MatKhau,
        SoDienThoai = p_SoDienThoai,
        MaNguoiGioiThieu = p_MaNguoiGioiThieu,
        Ho = p_Ho,
        Ten = p_Ten,
        NgaySinh = p_NgaySinh,
        ThangSinh = p_ThangSinh,
        NamSinh = p_NamSinh,
        GioiTinh = p_GioiTinh,
        QuocGia = p_QuocGia,
        ThanhPho = p_ThanhPho,
        MaBuuDien = p_MaBuuDien,
        DiaChi = p_DiaChi,
        SoHoChieu = p_SoHoChieu,
        NoiCap = p_NoiCap,
        NgayHetHan = p_NgayHetHan,
        MaGioiThieu = p_MaGioiThieu,
        Email = p_Email
    WHERE MaNguoiDung = p_MaNguoiDung;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_UpdateChoO(
    IN p_MaChoO VARCHAR(50),
    IN p_TenChoO VARCHAR(255),
    IN p_SoNha VARCHAR(50),
    IN p_TenDuong VARCHAR(255),
    IN p_MaBuuDien VARCHAR(20),
    IN p_ThanhPho VARCHAR(100),
    IN p_QuocGia VARCHAR(100),
    IN p_MoTa TEXT,
    IN p_TrangThai VARCHAR(50),
    IN p_MaQTV VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ChoO WHERE MaChoO = p_MaChoO) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không tìm thấy mã chỗ ở để cập nhật!';
    END IF;

    IF p_TenChoO IS NULL OR TRIM(p_TenChoO) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Tên chỗ ở không được để trống!';
    END IF;

    IF p_TrangThai NOT IN ('Cho xac nhan', 'Da xac nhan', 'Tu choi') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Trạng thái xác nhận không hợp lệ! (Chỉ chấp nhận: Cho xac nhan, Da xac nhan, Tu choi)';
    END IF;

    IF p_MaQTV IS NOT NULL AND NOT EXISTS (SELECT 1 FROM QuanTriVien WHERE MaNguoiDung = p_MaQTV) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Mã quản trị viên không tồn tại!';
    END IF;

    UPDATE ChoO
    SET
        TenChoO = p_TenChoO,
        SoNha = p_SoNha,
        TenDuong = p_TenDuong,
        MaBuuDien = p_MaBuuDien,
        ThanhPho = p_ThanhPho,
        QuocGia = p_QuocGia,
        MoTaTongQuat = p_MoTa,
        TrangThaiXacNhan = p_TrangThai,
        `MaNguoiDung - QuanTriVien` = p_MaQTV
    WHERE MaChoO = p_MaChoO;

END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_UpdateDonDatPhong(
    IN p_MaDonDatPhong VARCHAR(50),
    IN p_NgayNhanPhong DATE,
    IN p_NgayTraPhong DATE,
    IN p_TrangThai VARCHAR(50),
    IN p_MaQTV VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM DonDatPhong WHERE MaDonDatPhong = p_MaDonDatPhong) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không tìm thấy mã đơn đặt phòng để cập nhật!';
    END IF;

    IF p_NgayTraPhong <= p_NgayNhanPhong THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 ngày!';
    END IF;

    IF p_TrangThai NOT IN ('Đang chờ duyệt', 'Đang chờ thanh toán', 'Đã tất toán', 'Đã hủy', 'Đã trả phòng') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Trạng thái xử lý không hợp lệ!';
    END IF;

    IF p_MaQTV IS NOT NULL AND NOT EXISTS (SELECT 1 FROM QuanTriVien WHERE MaNguoiDung = p_MaQTV) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Mã quản trị viên không tồn tại!';
    END IF;

    UPDATE DonDatPhong
    SET
        NgayNhanPhong = p_NgayNhanPhong,
        NgayTraPhong = p_NgayTraPhong,
        DemLuuTru = DATEDIFF(p_NgayTraPhong, p_NgayNhanPhong),
        TrangThaiXuLy = p_TrangThai,
        `MaNguoiDung - QuanTriVien` = p_MaQTV
    WHERE MaDonDatPhong = p_MaDonDatPhong;

END //

DELIMITER ;

--Mục đích của thủ tục sp_DeleteNguoiDung : Loại bỏ thông tin người dùng khỏi hệ thống khi họ yêu cầu xóa tài khoản hoặc khi dữ liệu bị nhập sai/trùng lặp.
--Lý do: Để tối ưu không gian lưu trữ và đảm bảo quyền riêng tư của người dùng .
--Khi được:
--  Người dùng không có các giao dịch tài chính đang xử lý.
--  Người dùng không phải là chủ sở hữu (ChuSoHuu) đang có các chỗ ở (ChoO) đang cho thuê.
--  Người dùng không phải là quản trị viên (QuanTriVien) đang chịu trách nhiệm duyệt các đơn hàng hoặc bài đánh giá chưa hoàn tất.
--Khi KHÔNG được:
--  Khi mã người dùng không tồn tại.
--  Khách hàng (KhachHang) đang có đơn đặt phòng (DonDatPhong) ở trạng thái 'Đang chờ duyệt' hoặc 'Đang chờ thanh toán'.
--  Quản trị viên đang có các tác vụ hệ thống chưa bàn giao.



DELIMITER //

CREATE PROCEDURE sp_DeleteNguoiDung(
    IN p_MaNguoiDung VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NguoiDung WHERE MaNguoiDung = p_MaNguoiDung) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không tìm thấy mã người dùng để xóa!';
    END IF;

    IF EXISTS (
        SELECT 1 FROM DonDatPhong
        WHERE `MaNguoiDung - KhachHang` = p_MaNguoiDung
        AND TrangThaiXuLy IN ('Đang chờ duyệt', 'Đang chờ thanh toán')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không thể xóa khách hàng đang có đơn đặt phòng chờ xử lý!';
    END IF;

    IF EXISTS (
        SELECT 1 FROM SoHuu
        WHERE `MaNguoiDung - ChuSoHuu` = p_MaNguoiDung
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Người dùng này đang là chủ sở hữu của một hoặc nhiều chỗ ở. Hãy xóa dữ liệu sở hữu trước!';
    END IF;

    UPDATE NguoiDung
    SET MaNguoiGioiThieu = NULL
    WHERE MaNguoiGioiThieu = (SELECT MaGioiThieu FROM NguoiDung WHERE MaNguoiDung = p_MaNguoiDung);

    DELETE FROM NguoiDung WHERE MaNguoiDung = p_MaNguoiDung;


END //

DELIMITER ;

-- Mục đích của thủ tục sp_DeleteChoO: Loại bỏ thông tin một Chỗ ở (Khách sạn, Villa, Resort...) khỏi hệ thống khi ngừng kinh doanh hoặc nhập liệu sai.
-- Lý do: Để đảm bảo danh sách hiển thị cho khách hàng luôn là những chỗ ở đang thực sự hoạt động, tránh việc khách đặt nhầm chỗ đã đóng cửa.
-- Khi được xóa:
--   Mã chỗ ở tồn tại trong hệ thống.
--   Chỗ ở này không còn bất kỳ đơn đặt phòng nào đang trong quá trình xử lý.
--   Tất cả các dịch vụ đi kèm và hình ảnh liên quan đã sẵn sàng để xóa (thông qua cơ chế CASCADE).
-- Khi KHÔNG được xóa:
--   Mã chỗ ở không tồn tại trên hệ thống.
--   Chỗ ở hiện đang có các đơn đặt phòng ở trạng thái 'Đang chờ duyệt' hoặc 'Đang chờ thanh toán'.
--   (Nếu xóa lúc này sẽ làm mất dữ liệu của khách hàng đang chờ nhận phòng, gây tranh chấp tài chính).

DELIMITER //

CREATE PROCEDURE sp_DeleteChoO(
    IN p_MaChoO VARCHAR(50)
)
BEGIN

    IF NOT EXISTS (SELECT 1 FROM ChoO WHERE MaChoO = p_MaChoO) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Không tìm thấy chỗ ở để xóa!';
    END IF;

    IF EXISTS (
        SELECT 1 FROM ApDung ad
        JOIN DonDatPhong d ON ad.MaDonDatPhong = d.MaDonDatPhong
        JOIN LoaiPhong lp ON ad.MaLoaiPhong = lp.MaLoaiPhong
        WHERE lp.MaChoO = p_MaChoO
        AND d.TrangThaiXuLy = 'Đang chờ thanh toán'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Không thể xóa chỗ ở đang có khách đặt phòng chờ xử lý!';
    END IF;

    DELETE FROM ChoO WHERE MaChoO = p_MaChoO;

    SELECT 'Xóa chỗ ở thành công!' AS Message;
END; //

DELIMITER ;

-- Mục đích của thủ tục sp_DeleteDonDatPhong: Xóa bỏ bản ghi của một đơn đặt phòng cụ thể khỏi cơ sở dữ liệu.
-- Lý do: Loại bỏ các đơn đặt phòng "rác", đơn đặt thử nghiệm hoặc các đơn đã bị hủy từ lâu để làm sạch dữ liệu và tối ưu không gian lưu trữ.
-- Khi được xóa:
--   Mã đơn đặt phòng tồn tại trên hệ thống.
--   Đơn đặt phòng đang ở trạng thái 'Đã hủy'. (Đây là những đơn không phát sinh doanh thu và không có khách lưu trú).
-- Khi KHÔNG được xóa:
--   Mã đơn đặt phòng không tồn tại.
--   Đơn đặt phòng đang ở trạng thái hoạt động: 'Đang chờ duyệt', 'Đang chờ thanh toán'.
--   Đơn đặt phòng đã hoàn tất: 'Đã tất toán' hoặc 'Đã trả phòng'.
--   (Lý do không cho xóa đơn đã hoàn tất: Để giữ lại lịch sử giao dịch phục vụ việc báo cáo doanh thu, đối soát tài chính và giải quyết khiếu nại của khách hàng sau này).

DELIMITER //

CREATE PROCEDURE sp_DeleteDonDatPhong(
    IN p_MaDonDatPhong VARCHAR(50)
)
BEGIN

    IF NOT EXISTS (SELECT 1 FROM DonDatPhong WHERE MaDonDatPhong = p_MaDonDatPhong) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Đơn hàng không tồn tại!';
    END IF;


    IF NOT EXISTS (
        SELECT 1 FROM DonDatPhong
        WHERE MaDonDatPhong = p_MaDonDatPhong AND TrangThaiXuLy = 'Đã hủy'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Chỉ có thể xóa những đơn đặt phòng đã ở trạng thái Đã hủy!';
    END IF;


    DELETE FROM DonDatPhong WHERE MaDonDatPhong = p_MaDonDatPhong;

    SELECT 'Xóa đơn đặt phòng thành công!' AS Message;
END //

DELIMITER ;

-- CALL sp_InsertChoO(
--     'LM', 'Land Mark 81', '720A', 'Đường Điện Biên Phủ Quận Bình Thạnh', '70000', 
--     'Hồ Chí Minh', 'Việt Nam', 'LandMark81 nằm trong khu đô thị Vinhomes Central Park, bên bờ sông Sài Gòn, với lối vào chính từ Điện Biên Phủ và Nguyễn Hữu Cảnh.', ''
-- );

-- CALL sp_InsertChoO(
--     'LM81', 'Land Mark 81', '720A', 'Đường Điện Biên Phủ Quận Bình Thạnh', '70000', 
--     'Hồ Chí Minh', 'Việt Nam', 'LandMark81 nằm trong khu đô thị Vinhomes Central Park, bên bờ sông Sài Gòn, với lối vào chính từ Điện Biên Phủ và Nguyễn Hữu Cảnh.'
-- );

-- CALL sp_UpdateChoO(
-- 'LM81', 'Land Mark 81', '720A', 'Đường Điện Biên Phủ Quận Bình Thạnh', '70000', 
--     'Hồ Chí Minh', 'Việt Nam', 'LandMark81 nằm trong khu đô thị Vinhomes Central Park, bên bờ sông Sài Gòn, với lối vào chính từ Điện Biên Phủ và Nguyễn Hữu Cảnh.', 'Da xac nhan', 'ADM003'
-- );

-- CALL sp_DeleteChoO('LM81');
-- CALL sp_DeleteChoO('LM');