USE BTL2;

DELIMITER $$
DROP FUNCTION IF EXISTS fn_TinhDoanhThuChoO $$

CREATE FUNCTION fn_TinhDoanhThuChoO (
    p_MaChoO VARCHAR(50),
    p_Start DATE,
    p_End DATE
) 
RETURNS DECIMAL(15,2)
READS SQL DATA
BEGIN
    DECLARE v_TongDoanhThu DECIMAL(15,2) DEFAULT 0;
    DECLARE v_MaDon VARCHAR(50);
    DECLARE v_TrangThai VARCHAR(50);
    DECLARE v_SoTien DECIMAL(15,2);
    
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_Count INT;

    DECLARE cur_DonDatPhong CURSOR FOR
        SELECT DISTINCT ddp.MaDonDatPhong, ddp.TrangThaiXuLy
        FROM DonDatPhong ddp
        JOIN ApDung ad ON ddp.MaDonDatPhong = ad.MaDonDatPhong
        JOIN LoaiPhong lp ON ad.MaLoaiPhong = lp.MaLoaiPhong
        WHERE lp.MaChoO = p_MaChoO
          AND ddp.NgayTraPhong >= p_Start 
          AND ddp.NgayTraPhong <= p_End;
          
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    IF p_Start IS NULL OR p_End IS NULL OR p_Start > p_End THEN 
        RETURN -1; 
    END IF;
    
    SELECT COUNT(*) INTO v_Count FROM ChoO WHERE MaChoO = p_MaChoO;
    IF v_Count = 0 THEN 
        RETURN -1; 
    END IF;

    OPEN cur_DonDatPhong;
    read_loop: LOOP
        FETCH cur_DonDatPhong INTO v_MaDon, v_TrangThai;
        IF done THEN 
            LEAVE read_loop; 
        END IF;

        SET v_SoTien = 0;

        IF v_TrangThai IN ('Đã tất toán', 'Đã trả phòng') THEN
            
            SELECT IFNULL(SUM(SoTienDaThanhToan), 0) INTO v_SoTien
            FROM GiaoDichThanhToan
            WHERE MaDonDatPhong = v_MaDon
              AND TinhTrang IN ('Đã tất toán', 'Đã thanh toán 1 phần');
              
            SET v_TongDoanhThu = v_TongDoanhThu + v_SoTien;
        END IF;
    END LOOP;

    CLOSE cur_DonDatPhong;
    RETURN v_TongDoanhThu;
END; $$
DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS fn_TinhDiemTichLuy $$

CREATE FUNCTION fn_TinhDiemTichLuy (
    p_MaNguoiDung VARCHAR(50)
) 
RETURNS INT
READS SQL DATA
BEGIN

    DECLARE v_TongDiemAccumulated INT DEFAULT 0;
    DECLARE v_MaGioiThieuCuaToi VARCHAR(50);
    DECLARE v_Count INT;

    SELECT COUNT(*) INTO v_Count FROM KhachHang WHERE MaNguoiDung = p_MaNguoiDung;
    IF v_Count = 0 THEN RETURN -1; END IF;


    -- KHỐI 1: TÍNH ĐIỂM CÁ NHÂN
    BLOCK1: BEGIN
        DECLARE v_MaDon VARCHAR(50);
        DECLARE v_TrangThai VARCHAR(50);
        DECLARE v_Hang VARCHAR(50);
        DECLARE v_PaidAmount DECIMAL(15,2);
        DECLARE v_HeSo DECIMAL(3,2);
        DECLARE v_DiemDonNay INT;
        DECLARE done1 INT DEFAULT FALSE;
        
        DECLARE cur_MyBookings CURSOR FOR
            SELECT ddp.MaDonDatPhong, ddp.TrangThaiXuLy, kh.TenHangThanhVien 
            FROM DonDatPhong ddp
            JOIN KhachHang kh ON ddp.`MaNguoiDung - KhachHang` = kh.MaNguoiDung
            WHERE ddp.`MaNguoiDung - KhachHang` = p_MaNguoiDung;
            
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;
        
        OPEN cur_MyBookings;
        loop1: LOOP
            FETCH cur_MyBookings INTO v_MaDon, v_TrangThai, v_Hang;
            IF done1 THEN LEAVE loop1; END IF;

            IF v_TrangThai IN ('Đã tất toán', 'Đã trả phòng') THEN
                SELECT IFNULL(SUM(SoTienDaThanhToan), 0) INTO v_PaidAmount
                FROM GiaoDichThanhToan
                WHERE MaDonDatPhong = v_MaDon 
                  AND TinhTrang IN ('Đã tất toán', 'Đã thanh toán 1 phần');
                
                IF v_PaidAmount > 0 THEN
                    IF v_Hang = 'Đồng' THEN SET v_HeSo = 1.0;
                    ELSEIF v_Hang = 'Bạc' THEN SET v_HeSo = 1.1;
                    ELSEIF v_Hang = 'Vàng' THEN SET v_HeSo = 1.2;
                    ELSEIF v_Hang = 'Bạch Kim' THEN SET v_HeSo = 1.5;
                    ELSEIF v_Hang = 'Kim Cương' THEN SET v_HeSo = 1.7;
                    ELSE SET v_HeSo = 1.0; END IF;
                    
                    SET v_DiemDonNay = 200 + (FLOOR(v_PaidAmount / 1000000) * 1000);
                    
                    SET v_TongDiemAccumulated = v_TongDiemAccumulated + FLOOR(v_DiemDonNay * v_HeSo);
                END IF;
            END IF;
        END LOOP loop1;
        CLOSE cur_MyBookings;
    END BLOCK1;

    -- KHỐI 2: TÍNH ĐIỂM 10% TỪ NGƯỜI ĐƯỢC GIỚI THIỆU 
    SELECT MaGioiThieu INTO v_MaGioiThieuCuaToi FROM NguoiDung WHERE MaNguoiDung = p_MaNguoiDung;

    IF v_MaGioiThieuCuaToi IS NOT NULL THEN
        BLOCK2: BEGIN
            DECLARE v_MaNguoiDuocGT VARCHAR(50);
            DECLARE v_PointsOfReferredUser INT DEFAULT 0;
            DECLARE done2 INT DEFAULT FALSE;
            
            DECLARE cur_Referrals CURSOR FOR
                SELECT MaNguoiDung FROM NguoiDung WHERE MaNguoiGioiThieu = v_MaGioiThieuCuaToi;
                
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
            
            OPEN cur_Referrals;
            loop2: LOOP
                FETCH cur_Referrals INTO v_MaNguoiDuocGT;
                IF done2 THEN LEAVE loop2; END IF;
                
                SET v_PointsOfReferredUser = 0;

                SELECT IFNULL(SUM(FLOOR((200 + FLOOR(TotalSpent / 1000000) * 1000) * HeSo)), 0) 
                INTO v_PointsOfReferredUser
                FROM (
                    SELECT 
                        SUM(gd.SoTienDaThanhToan) as TotalSpent,
                        CASE 
                            WHEN kh.TenHangThanhVien = 'Đồng' THEN 1.0
                            WHEN kh.TenHangThanhVien = 'Bạc' THEN 1.1
                            WHEN kh.TenHangThanhVien = 'Vàng' THEN 1.2
                            WHEN kh.TenHangThanhVien = 'Bạch Kim' THEN 1.5
                            WHEN kh.TenHangThanhVien = 'Kim Cương' THEN 1.7
                            ELSE 1.0 
                        END as HeSo
                    FROM GiaoDichThanhToan gd
                    JOIN DonDatPhong ddp ON gd.MaDonDatPhong = ddp.MaDonDatPhong
                    JOIN KhachHang kh ON ddp.`MaNguoiDung - KhachHang` = kh.MaNguoiDung
                    WHERE ddp.`MaNguoiDung - KhachHang` = v_MaNguoiDuocGT
                      AND ddp.TrangThaiXuLy IN ('Đã tất toán', 'Đã trả phòng')
                      AND gd.TinhTrang IN ('Đã tất toán', 'Đã thanh toán 1 phần')
                    GROUP BY ddp.MaDonDatPhong
                    HAVING TotalSpent > 0
                ) AS SubQuery;
                
                IF v_PointsOfReferredUser > 0 THEN
                    SET v_TongDiemAccumulated = v_TongDiemAccumulated + FLOOR(v_PointsOfReferredUser * 0.1);
                END IF;
            END LOOP loop2;
            CLOSE cur_Referrals;
        END BLOCK2;
    END IF;

    RETURN v_TongDiemAccumulated;
END; $$
DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS sp_UpdateHangThanhVien //

CREATE PROCEDURE sp_UpdateHangThanhVien(
    IN p_MaNguoiDung VARCHAR(50)
)
BEGIN
    DECLARE v_CurrentPoints INT;
    DECLARE v_NewTier VARCHAR(50);
    DECLARE v_Count INT;

    SELECT COUNT(*) INTO v_Count FROM KhachHang WHERE MaNguoiDung = p_MaNguoiDung;
    
    IF v_Count > 0 THEN
        SET v_CurrentPoints = fn_TinhDiemTichLuy(p_MaNguoiDung);

        SELECT TenHangThanhVien INTO v_NewTier
        FROM HangThanhVien
        WHERE v_CurrentPoints >= DiemToiThieu
        ORDER BY DiemToiThieu DESC
        LIMIT 1;

        UPDATE KhachHang
        SET TenHangThanhVien = v_NewTier,
            DiemTichLuy = v_CurrentPoints
        WHERE MaNguoiDung = p_MaNguoiDung;
        
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Không tìm thấy mã khách hàng!';
    END IF;
END; //

DELIMITER ;

-- Truy vấn Tính tổng doanh thu của các Chỗ ở tại thành phố London trong quý 2 năm 2017

SELECT 
    MaChoO, 
    TenChoO, 
    ThanhPho,
    fn_TinhDoanhThuChoO(MaChoO, '2017-04-01', '2017-06-30') AS DoanhThuQ2_2017
FROM ChoO
WHERE ThanhPho = 'London' 
  AND fn_TinhDoanhThuChoO(MaChoO, '2017-04-01', '2017-06-30') > 0
ORDER BY DoanhThuQ2_2017 DESC;


-- CALL sp_UpdateHangThanhVien('CUS001');
-- CALL sp_UpdateHangThanhVien('CUS002');
-- CALL sp_UpdateHangThanhVien('CUS003');
