from fastapi import APIRouter, Query, Path
from typing import Optional, List
from accommodation import search_cho_o, get_all_cho_o, create_cho_o, update_cho_o, delete_cho_o
from schemas import ChoOCreate, ChoOUpdate

router = APIRouter(prefix="/api/cho-o", tags=["Chỗ Ở"])

@router.get("/all")
def get_all():
    """
    Lấy tất cả chỗ ở (bao gồm cả chỗ ở chưa có chủ sở hữu).
    Dùng cho Admin page — sp_SearchChoO dùng INNER JOIN SoHuu nên không hiển thị chỗ ở mới tạo.
    """
    return get_all_cho_o()

@router.get("/search")
def get_search_cho_o(
    thanh_pho: Optional[str] = Query(None, description="Từ khóa tìm lời theo thành phố"),
    ten_cho_o: Optional[str] = Query(None, description="Từ khóa tìm theo tên chỗ ở")
):
    """
    Tìm kiếm chỗ ở dựa trên thành phố hoặc tên. 
    Gọi trực tiếp procedure sp_SearchChoO từ Database.
    """
    return search_cho_o(thanh_pho, ten_cho_o)

@router.post("/")
def post_create_cho_o(cho_o: ChoOCreate):
    """Thêm một chỗ ở mới gọi sp_InsertChoO."""
    return create_cho_o(cho_o)

@router.put("/")
def put_update_cho_o(cho_o: ChoOUpdate):
    """Cập nhật thông tin chỗ ở gọi sp_UpdateChoO."""
    return update_cho_o(cho_o)

@router.delete("/{ma_cho_o}")
def remove_cho_o(ma_cho_o: str = Path(..., description="Mã chỗ ở cần xóa")):
    """Xóa chỗ ở gọi sp_DeleteChoO. Chặn xóa nếu có đơn đặt phòng chưa xử lý."""
    return delete_cho_o(ma_cho_o)