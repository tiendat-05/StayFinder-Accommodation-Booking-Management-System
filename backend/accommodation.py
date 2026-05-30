import mysql.connector
from fastapi import HTTPException
from database import get_db_connection, serialize_rows
from schemas import ChoOCreate, ChoOUpdate

def search_cho_o(thanh_pho: str = None, ten_cho_o: str = None):
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Không thể kết nối Database")

    # Sử dụng dictionary=True để kết quả trả về dạng JSON (key-value)
    cursor = conn.cursor(dictionary=True)
    results = []
    
    try:
        # Chuẩn bị tham số cho sp_SearchChoO(p_KeywordThanhPho, p_KeywordTenChoO)
        # Nếu tham số là chuỗi rỗng, ta nên chuyển về None để khớp với logic IS NULL trong SQL
        args = (
            thanh_pho if thanh_pho else None, 
            ten_cho_o if ten_cho_o else None
        )
        
        # Gọi Stored Procedure
        cursor.callproc('sp_SearchChoO', args)
        
        # Lấy kết quả từ các tập lệnh SELECT bên trong procedure
        for result in cursor.stored_results():
            results.extend(result.fetchall())
            
        # Serialize Decimal/datetime sang JSON-friendly types
        return serialize_rows(results)
        
    except mysql.connector.Error as err:
        # Trả về lỗi chi tiết từ MySQL (ví dụ lỗi SIGNAL SQLSTATE)
        raise HTTPException(status_code=400, detail=f"Lỗi Database: {err.msg}")
    finally:
        cursor.close()
        conn.close()

def get_all_cho_o():
    """
    Lấy tất cả chỗ ở trực tiếp từ bảng ChoO (LEFT JOIN SoHuu/NguoiDung).
    Dùng cho Admin page — sp_SearchChoO dùng INNER JOIN SoHuu nên chỗ ở
    chưa có chủ sở hữu (mới tạo) sẽ không hiện. Hàm này khắc phục điều đó.
    """
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Không thể kết nối Database")

    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT
                c.MaChoO,
                c.TenChoO,
                c.SoNha,
                c.TenDuong,
                c.MaBuuDien,
                c.ThanhPho,
                c.QuocGia,
                c.DiemDanhGiaTrungBinh,
                c.MoTaTongQuat AS MoTa,
                c.TrangThaiXacNhan,
                c.`MaNguoiDung - QuanTriVien` AS MaQTV,
                CONCAT(n.Ho, ' ', n.Ten) AS TenChuSoHuu,
                n.Email AS EmailChuSoHuu
            FROM ChoO c
            LEFT JOIN SoHuu sh ON c.MaChoO = sh.MaChoO
            LEFT JOIN NguoiDung n ON sh.`MaNguoiDung - ChuSoHuu` = n.MaNguoiDung
            ORDER BY
                CASE c.TrangThaiXacNhan
                    WHEN 'Cho xac nhan' THEN 1
                    WHEN 'Da xac nhan' THEN 2
                    WHEN 'Tu choi' THEN 3
                END,
                c.DiemDanhGiaTrungBinh DESC
        """)
        results = cursor.fetchall()
        return serialize_rows(results)
    except mysql.connector.Error as err:
        raise HTTPException(status_code=400, detail=f"Lỗi Database: {err.msg}")
    finally:
        cursor.close()
        conn.close()

# Mã quản trị viên mặc định cho duyệt chỗ ở (ADM003 - Duyệt chỗ ở và đơn đặt phòng)
DEFAULT_MA_QTV = 'ADM003'


def _generate_ma_cho_o(ten_cho_o: str, cursor) -> str:
    """
    Tạo MaChoO từ chữ cái đầu tiên của mỗi từ trong tên chỗ ở (viết hoa).
    VD: 'Saigon Grand Hotel' → 'SGH'
    Nếu đã tồn tại, thêm số: 'SGH2', 'SGH3', ...
    """
    words = ten_cho_o.strip().split()
    prefix = ''.join(w[0].upper() for w in words if w)
    if not prefix:
        prefix = 'CHO'

    # Kiểm tra mã đã tồn tại chưa
    cursor.execute("SELECT MaChoO FROM ChoO WHERE MaChoO = %s", (prefix,))
    if cursor.fetchone() is None:
        return prefix

    # Tìm số tiếp theo
    cursor.execute(
        "SELECT MaChoO FROM ChoO WHERE MaChoO LIKE %s ORDER BY MaChoO",
        (f"{prefix}%",)
    )
    existing = [row[0] for row in cursor.fetchall()]

    counter = 2
    while f"{prefix}{counter}" in existing:
        counter += 1
    return f"{prefix}{counter}"


def create_cho_o(cho_o: ChoOCreate):
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Không thể kết nối Database")
    cursor = conn.cursor()
    try:
        # Auto-generate MaChoO từ tên chỗ ở
        ma_cho_o = _generate_ma_cho_o(cho_o.TenChoO, cursor)

        args = (
            ma_cho_o, cho_o.TenChoO, cho_o.SoNha, cho_o.TenDuong,
            cho_o.MaBuuDien, cho_o.ThanhPho, cho_o.QuocGia, cho_o.MoTa
        )
        cursor.callproc('sp_InsertChoO', args)
        conn.commit()
        return {"message": f"Thêm chỗ ở thành công! Mã chỗ ở: {ma_cho_o}", "MaChoO": ma_cho_o}
    except mysql.connector.Error as err:
        # Bắt lỗi logic từ SIGNAL SQLSTATE trong SQL
        raise HTTPException(status_code=400, detail=f"Lỗi: {err.msg}")
    finally:
        cursor.close()
        conn.close()

def update_cho_o(cho_o: ChoOUpdate):
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Không thể kết nối Database")
    cursor = conn.cursor()
    try:
        args = (
            cho_o.MaChoO, cho_o.TenChoO, cho_o.SoNha, cho_o.TenDuong,
            cho_o.MaBuuDien, cho_o.ThanhPho, cho_o.QuocGia, cho_o.MoTa,
            cho_o.TrangThai, cho_o.MaQTV
        )
        cursor.callproc('sp_UpdateChoO', args)
        conn.commit()
        return {"message": "Cập nhật chỗ ở thành công!"}
    except mysql.connector.Error as err:
        raise HTTPException(status_code=400, detail=f"Lỗi: {err.msg}")
    finally:
        cursor.close()
        conn.close()

def delete_cho_o(ma_cho_o: str):
    conn = get_db_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="Không thể kết nối Database")
    cursor = conn.cursor()
    try:
        cursor.callproc('sp_DeleteChoO', (ma_cho_o,))
        conn.commit()
        return {"message": "Xóa chỗ ở thành công!"}
    except mysql.connector.Error as err:
        # Quan trọng: Hiển thị lỗi nếu đang có khách đặt phòng không cho xóa
        raise HTTPException(status_code=400, detail=f"Lỗi: {err.msg}")
    finally:
        cursor.close()
        conn.close()