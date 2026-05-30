USE BTL2;

SET SQL_SAFE_UPDATES = 0;

UPDATE DonDatPhong 
SET DemLuuTru = DATEDIFF(NgayTraPhong, NgayNhanPhong)
WHERE DemLuuTru IS NULL;

UPDATE DonDatPhong d
JOIN (
    SELECT 
        a.MaDonDatPhong, 
        SUM(a.SoLuongPhong * g.GiaBan) AS Tien1Dem
    FROM ApDung a
    JOIN GoiDichVu g ON a.MaLoaiPhong = g.MaLoaiPhong AND a.MaGoi = g.MaGoi
    GROUP BY a.MaDonDatPhong
) t ON d.MaDonDatPhong = t.MaDonDatPhong
SET d.TongSoTien = t.Tien1Dem * d.DemLuuTru
WHERE d.TongSoTien IS NULL;

UPDATE ChoO c
LEFT JOIN (
    SELECT 
        lp.MaChoO, 
        ROUND(AVG(dg.DiemSo), 1) AS DiemTrungBinh
    FROM BaiDanhGia dg
    JOIN ApDung ad ON dg.MaDonDatPhong = ad.MaDonDatPhong
    JOIN LoaiPhong lp ON ad.MaLoaiPhong = lp.MaLoaiPhong
    GROUP BY lp.MaChoO
) t ON c.MaChoO = t.MaChoO
SET c.DiemDanhGiaTrungBinh = IFNULL(t.DiemTrungBinh, 0);

SET SQL_SAFE_UPDATES = 1;