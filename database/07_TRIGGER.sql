USE BTL2;

-- TRIGGER NGHIỆP VỤ: Kiểm tra số lượng phòng trống tại 1 khung thời gian trước khi tạo 1 đơn đặt phòng

-- Các thao tác DML có thể gây ra lỗi về ràng buộc số lượng phòng khi tạo đơn đặt phòng bao gồm:
-- INSERT 1 dòng dữ liệu mới vào bảng ApDung có SoLuongPhong nhiều hơn SoLuongPhongTrong 
-- UPDATE SoLuongPhong lớn hơn SoLuongPhongTrong ở 1 dòng dữ liệu trong bảng ApDung
-- UPDATE NgayNhanPhong, NgayTraPhong trong bảng DonDatPhong sang các ngày có SoLuongPhongTrong bằng 0 hoặc ít hơn SoLuongPhong

DELIMITER //

CREATE TRIGGER trg_CHECKOVERBOOKING_INSERTAPDUNG
BEFORE INSERT ON ApDung
FOR EACH ROW
BEGIN
    DECLARE v_NgayNhan DATE;
    DECLARE v_NgayTra Date;
    DECLARE v_SoPhongTrong INT;
    DECLARE v_TongSoPhongVatLy INT;
    DECLARE v_SoPhongDangSuDung INT;

    SELECT NgayNhanPhong, NgayTraPhong INTO v_NgayNhan, v_NgayTra
    FROM DonDatPhong
    WHERE MaDonDatPhong = NEW.MaDonDatPhong;

    SELECT COUNT(*) INTO v_TongSoPhongVatLy
    FROM PhongVatLy
    WHERE MaLoaiPhong = NEW.MaLoaiPhong;

    SELECT COALESCE (SUM(ad.SoLuongPhong), 0) INTO v_SoPhongDangSuDung
    FROM ApDung ad
    JOIN DonDatPhong d ON ad.MaDonDatPhong = d.MaDonDatPhong
    WHERE ad.MaLoaiPhong = NEW.MaLoaiPhong AND d.TrangThaiXuLy IN ('Đang chờ thanh toán', 'Đã tất toán') 
    AND (d.NgayNhanPhong < v_NgayTra AND d.NgayTraPhong > v_NgayNhan);

    SET v_SoPhongTrong = v_TongSoPhongVatLy - v_SoPhongDangSuDung;

    IF NEW.SoLuongPhong > v_SoPhongTrong THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không còn đủ phòng trong thời gian này (INSERT APDUNG)';
    END IF;
END; //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_CHECKOVERBOOKING_UPDATEAPDUNG
BEFORE UPDATE ON ApDung
FOR EACH ROW
BEGIN
    DECLARE v_NgayNhan DATE;
    DECLARE v_NgayTra DATE;
    DECLARE v_TongSoPhongVatLy INT;
    DECLARE v_SoPhongDangSuDung INT;

    SELECT NgayNhanPhong, NgayTraPhong INTO v_NgayNhan, v_NgayTra
    FROM DonDatPhong
    WHERE MaDonDatPhong = NEW.MaDonDatPhong;

    SELECT COUNT(*) INTO v_TongSoPhongVatLy
    FROM PhongVatLy
    WHERE MaLoaiPhong = NEW.MaLoaiPhong;

    SELECT COALESCE(SUM(ad.SoLuongPhong), 0) INTO v_SoPhongDangSuDung
    FROM ApDung ad
    JOIN DonDatPhong d ON ad.MaDonDatPhong = d.MaDonDatPhong
    WHERE ad.MaLoaiPhong = NEW.MaLoaiPhong 
      AND d.TrangThaiXuLy IN ('Đang chờ thanh toán', 'Đã tất toán') 
      AND (d.NgayNhanPhong < v_NgayTra AND d.NgayTraPhong > v_NgayNhan)
      AND NOT (ad.MaDonDatPhong = OLD.MaDonDatPhong 
               AND ad.MaLoaiPhong = OLD.MaLoaiPhong 
               AND ad.MaGoi = OLD.MaGoi);

    IF NEW.SoLuongPhong + v_SoPhongDangSuDung > v_TongSoPhongVatLy THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không còn đủ phòng trong thời gian này (UPDATE SOLUONGPHONG - APDUNG)';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_CHECKOVERBOOKING_UPDATEDONDATPHONG
BEFORE UPDATE ON DonDatPhong
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_MaLoaiPhong VARCHAR(50);
    DECLARE v_SoLuongCuaDonNay INT;
    DECLARE v_TongSoPhongVatLy INT;
    DECLARE v_SoPhongDonKhacDung INT;

    DECLARE cur_RoomTypes CURSOR FOR 
        SELECT MaLoaiPhong, SUM(SoLuongPhong)
        FROM ApDung
        WHERE MaDonDatPhong = NEW.MaDonDatPhong
        GROUP BY MaLoaiPhong;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    IF (OLD.NgayNhanPhong <> NEW.NgayNhanPhong OR OLD.NgayTraPhong <> NEW.NgayTraPhong) 
       AND NEW.TrangThaiXuLy IN ('Đang chờ thanh toán', 'Đã tất toán') THEN
        
        OPEN cur_RoomTypes;
        read_loop: LOOP
            FETCH cur_RoomTypes INTO v_MaLoaiPhong, v_SoLuongCuaDonNay;
            IF done THEN LEAVE read_loop; END IF;

            SELECT COUNT(*) INTO v_TongSoPhongVatLy
            FROM PhongVatLy
            WHERE MaLoaiPhong = v_MaLoaiPhong;

            SELECT COALESCE(SUM(ad.SoLuongPhong), 0) INTO v_SoPhongDonKhacDung
            FROM ApDung ad
            JOIN DonDatPhong d ON ad.MaDonDatPhong = d.MaDonDatPhong
            WHERE ad.MaLoaiPhong = v_MaLoaiPhong 
              AND d.MaDonDatPhong <> NEW.MaDonDatPhong
              AND d.TrangThaiXuLy IN ('Đang chờ thanh toán', 'Đã tất toán')
              AND (d.NgayNhanPhong < NEW.NgayTraPhong AND d.NgayTraPhong > NEW.NgayNhanPhong);

            IF v_SoLuongCuaDonNay + v_SoPhongDonKhacDung > v_TongSoPhongVatLy THEN
                CLOSE cur_RoomTypes;
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Lỗi: Không còn đủ phòng trong thời gian này (UPDATE NGAYNHANPHONG/NGAYTRAPHONG - DONDATPHONG)';
            END IF;
        END LOOP;
        CLOSE cur_RoomTypes;
    END IF;
END //

DELIMITER ;

--TRIGGER THUỘC TÍNH DẪN XUẤT(ĐÊM LƯU TRÚ, TỔNG SỐ TIỀN, ĐIỂM ĐÁNH GIÁ TRUNG BÌNH)

-- Các thao tác DML làm thay đổi thuộc tính dẫn xuất đêm lưu trú trong đơn đặt phòng
-- Insert NgayNhanPhong, NgayTraPhong trên bảng DonDatPhong
-- Update NgayNhanPhong, NgayTraPhong trên bảng DonDatPhong
DELIMITER //

CREATE TRIGGER trg_TINHDEMLUUTRU
BEFORE INSERT ON DonDatPhong
FOR EACH ROW
BEGIN
    SET NEW.DemLuuTru = DATEDIFF(NEW.NgayTraPhong, NEW.NgayNhanPhong);
    
END; //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_CAPNHATDEMLUUTRU
BEFORE UPDATE ON DonDatPhong
FOR EACH ROW
BEGIN
    IF NEW.NgayNhanPhong <> OLD.NgayNhanPhong OR NEW.NgayTraPhong <> OLD.NgayTraPhong THEN
        SET NEW.DemLuuTru = DATEDIFF(NEW.NgayTraPhong, NEW.NgayNhanPhong);
    END IF;
END; //

DELIMITER ;

-- Các thao tác DML làm thay đổi thuộc tính dẫn xuất tổng số tiến trong đơn đặt phòng
-- Insert 1 dòng dữ liệu mới vào bảng ApDung
-- Update GoiDichVu trong bảng ApDung
-- Update LoaiPhong trong bảng ApDung
-- Update SoLuongPhong trong bảng ApDung
-- Update NgayTraPhong, NgayNhanPhong trong bảng DonDatPhong
-- Update GiaBan trong bảng GoiDichVu
-- Delete 1 dòng dữ liệu trong bảng ApDung

DELIMITER //


CREATE TRIGGER trg_TinhTongTienDonDatPhong
AFTER INSERT ON ApDung
FOR EACH ROW
BEGIN
    DECLARE v_DemLuuTru INT;
    DECLARE v_TongTien1Dem DECIMAL(15,2);

    SELECT DemLuuTru INTO v_DemLuuTru
    FROM DonDatPhong
    WHERE MaDonDatPhong = NEW.MaDonDatPhong;

    SELECT COALESCE(SUM(a.SoLuongPhong * g.GiaBan), 0) INTO v_TongTien1Dem
    FROM ApDung a
    JOIN GoiDichVu g ON a.MaLoaiPhong = g.MaLoaiPhong AND a.MaGoi = g.MaGoi
    WHERE a.MaDonDatPhong = NEW.MaDonDatPhong;

    UPDATE DonDatPhong
    SET TongSoTien = v_TongTien1Dem * v_DemLuuTru
    WHERE MaDonDatPhong = NEW.MaDonDatPhong;

END; //

DELIMITER ;

-- --Trigger CHECKOVERBOOKING
-- INSERT INTO `DonDatPhong` (`MaDonDatPhong`, `NgayTao`, `NgayNhanPhong`, `NgayTraPhong`, `TrangThaiXuLy`, `MaNguoiDung - KhachHang`) VALUES ('RSV041', '2026-05-10 16:49:00', '2026-05-11', '2026-05-16', DEFAULT, 'CUS003');
-- INSERT INTO `ApDung` (`MaDonDatPhong`, `MaGoi`, `MaLoaiPhong`, `SoLuongPhong`) VALUES ('RSV041', 'PKG0096', 'LM_DR01', '5');

-- INSERT INTO `DonDatPhong` (`MaDonDatPhong`, `NgayTao`, `NgayNhanPhong`, `NgayTraPhong`, `TrangThaiXuLy`, `MaNguoiDung - KhachHang`) VALUES ('RSV042', '2026-05-11 12:36:00', '2026-05-18', '2026-05-20', DEFAULT, 'CUS005');
-- INSERT INTO `ApDung` (`MaDonDatPhong`, `MaGoi`, `MaLoaiPhong`, `SoLuongPhong`) VALUES ('RSV042', 'PKG0096', 'LM_DR01', '3');

-- INSERT INTO `ApDung` (`MaDonDatPhong`, `MaGoi`, `MaLoaiPhong`, `SoLuongPhong`) VALUES ('RSV041', 'PKG0097', 'LM_DR01', '3');

-- UPDATE `ApDung` 
-- SET SoLuongPhong = '8' 
-- WHERE MaDonDatPhong = 'RSV041' AND MaLoaiPhong = 'LM_DR01';

-- UPDATE `DonDatPhong` 
-- SET NgayNhanPhong = '2026-05-11', NgayTraPhong = '2026-05-15' 
-- WHERE MaDonDatPhong = 'RSV042';

-- --Trigger thuộc tính dẫn xuất đêm lưu trú
-- INSERT INTO `DonDatPhong` (`MaDonDatPhong`, `NgayTao`, `NgayNhanPhong`, `NgayTraPhong`, `TrangThaiXuLy`, `MaNguoiDung - KhachHang`) VALUES ('RSV043', '2026-05-12 13:39:00', '2026-06-01', '2026-06-03', DEFAULT, 'CUS007');

-- UPDATE DonDatPhong 
-- SET NgayTraPhong = '2026-06-07' 
-- WHERE MaDonDatPhong = 'RSV043';

-- --Trigger thuộc tính dẫn xuất tổng số tiền
-- INSERT INTO `ApDung` (`MaDonDatPhong`, `MaGoi`, `MaLoaiPhong`, `SoLuongPhong`) VALUES ('RSV043', 'PKG0098', 'LM_DR01', '2');

-- -- Các thao tác DML làm thay đổi thuộc tính dẫn xuất điểm đánh giá trung bình của chỗ ở
-- -- UPDATE TrangThaiKiemDuyet của 1 bài đánh giá thành "Đã duyệt" 
-- -- DELETE 1 dòng dữ liệu trên bảng BaiDanhGia

-- DELIMITER //

-- CREATE TRIGGER trg_TinhDiemDanhGiaTrungBinh
-- AFTER UPDATE ON BaiDanhGia
-- FOR EACH ROW
-- BEGIN
--     DECLARE v_MaChoO VARCHAR(50);
--     DECLARE v_DiemTrungBinh DECIMAL(2,1);

--     IF OLD.TrangThaiKiemDuyet <> 'Đã duyệt' AND NEW.TrangThaiKiemDuyet = 'Đã duyệt' THEN
        
--         SELECT lp.MaChoO INTO v_MaChoO
--         FROM DonDatPhong d
--         JOIN ApDung a ON d.MaDonDatPhong = a.MaDonDatPhong
--         JOIN LoaiPhong lp ON a.MaLoaiPhong = lp.MaLoaiPhong
--         WHERE d.MaDonDatPhong = NEW.MaDonDatPhong
--         LIMIT 1;

--         SELECT COALESCE(AVG(b.DiemSo), 0) INTO v_DiemTrungBinh
--         FROM BaiDanhGia b
--         JOIN DonDatPhong d2 ON b.MaDonDatPhong = d2.MaDonDatPhong
--         JOIN ApDung a2 ON d2.MaDonDatPhong = a2.MaDonDatPhong
--         JOIN LoaiPhong lp2 ON a2.MaLoaiPhong = lp2.MaLoaiPhong
--         WHERE lp2.MaChoO = v_MaChoO 
--           AND b.TrangThaiKiemDuyet = 'Đã duyệt';

--         UPDATE ChoO 
--         SET DiemDanhGiaTrungBinh = v_DiemTrungBinh 
--         WHERE MaChoO = v_MaChoO;
        
--     END IF;
-- END; //

-- DELIMITER ;

