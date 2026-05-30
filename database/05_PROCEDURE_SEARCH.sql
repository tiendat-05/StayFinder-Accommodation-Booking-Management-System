USE BTL2;

DELIMITER //

CREATE PROCEDURE sp_SearchChoO(
    IN p_KeywordThanhPho VARCHAR(100),
    IN p_KeywordTenChoO VARCHAR(255)
)
BEGIN
    SELECT
        c.MaChoO,
        c.TenChoO,
        c.ThanhPho,
        c.QuocGia,
        c.DiemDanhGiaTrungBinh,
        c.TrangThaiXacNhan,
        CONCAT(n.Ho, ' ', n.Ten) AS TenChuSoHuu,
        n.Email AS EmailChuSoHuu
    FROM ChoO c
    JOIN SoHuu sh ON c.MaChoO = sh.MaChoO
    JOIN NguoiDung n ON sh.`MaNguoiDung - ChuSoHuu` = n.MaNguoiDung
    WHERE
        (p_KeywordThanhPho IS NULL OR c.ThanhPho LIKE CONCAT('%', p_KeywordThanhPho, '%'))
        AND
        (p_KeywordTenChoO IS NULL OR c.TenChoO LIKE CONCAT('%', p_KeywordTenChoO, '%'))
    ORDER BY
        c.DiemDanhGiaTrungBinh DESC;
END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_StatisticRevenueByCity(
    IN p_ThanhPho VARCHAR(100),
    IN p_DoanhThuToiThieu DECIMAL(15,2)
)
BEGIN
    SELECT
        c.MaChoO,
        c.TenChoO,
        c.ThanhPho,
        COUNT(DISTINCT d.MaDonDatPhong) AS SoLuongDonHang,
        SUM(d.TongSoTien) AS TongDoanhThu
    FROM ChoO c
    JOIN LoaiPhong lp ON c.MaChoO = lp.MaChoO
    JOIN ApDung ad ON lp.MaLoaiPhong = ad.MaLoaiPhong
    JOIN DonDatPhong d ON ad.MaDonDatPhong = d.MaDonDatPhong
    WHERE
        c.ThanhPho = p_ThanhPho
        AND d.TrangThaiXuLy = 'Đã trả phòng'
    GROUP BY
        c.MaChoO, c.TenChoO, c.ThanhPho
    HAVING
        SUM(d.TongSoTien) >= p_DoanhThuToiThieu
    ORDER BY
        TongDoanhThu DESC;
END; //

DELIMITER ;

-- CALL sp_SearchChoO('Paris', NULL);
-- CALL sp_StatisticRevenueByCity('London', 0);
-- CALL sp_StatisticRevenueByCity('London', 300000000);