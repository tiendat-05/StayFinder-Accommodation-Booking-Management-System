"""
api_stats.py - API của Thành viên 3

Nhiệm vụ trong gói công việc:
1. GET /api/thong-ke/doanh-thu
   - Gọi procedure sp_StatisticRevenueByCity(ThanhPho, DoanhThuToiThieu)
   - Trả về kết quả gom nhóm doanh thu.

2. GET /api/khach-hang/{id}/diem-tich-luy
   - Gọi function fn_TinhDiemTichLuy(id)
   - Đây là API mở rộng để lấy điểm cộng khi báo cáo.
"""

from __future__ import annotations

from decimal import Decimal
from typing import Any, Dict

from fastapi import APIRouter, HTTPException, Path, Query, status

from database import call_function, call_procedure
from schemas import MemberPointsApiResponse, RevenueStatApiResponse

router = APIRouter(tags=["Thống kê chỗ ở và Tính toán hạng thành viên"])


def _normalize_required_text(value: str, field_name: str) -> str:
    """Chuẩn hóa chuỗi bắt buộc và báo lỗi rõ nếu người dùng bỏ trống."""
    normalized = value.strip() if value is not None else ""
    if not normalized:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"{field_name} không được để trống.",
        )
    return normalized


@router.get(
    "/api/thong-ke/doanh-thu",
    response_model=RevenueStatApiResponse,
    summary="Thống kê doanh thu theo thành phố",
)
def thong_ke_doanh_thu(
    ThanhPho: str = Query(
        ...,
        description="Thành phố cần thống kê doanh thu. Ví dụ: Amsterdam, London, Paris.",
        examples=["Amsterdam"],
    ),
    DoanhThuToiThieu: Decimal = Query(
        Decimal("0"),
        ge=0,
        description="Chỉ lấy các chỗ ở có tổng doanh thu từ mức này trở lên.",
        examples=[0],
    ),
) -> Dict[str, Any]:
    """
    Gọi procedure:
        CALL sp_StatisticRevenueByCity(ThanhPho, DoanhThuToiThieu)

    Lưu ý:
    - Nhóm đang dùng procedure thống kê doanh thu dựa trên các đơn có
    DonDatPhong.TrangThaiXuLy = 'Đã trả phòng'.
    """
    thanh_pho = _normalize_required_text(ThanhPho, "ThanhPho")

    rows = call_procedure(
        "sp_StatisticRevenueByCity",
        [thanh_pho, DoanhThuToiThieu],
    )

    tong_doanh_thu_toan_bo = sum(float(row.get("TongDoanhThu") or 0) for row in rows)
    tong_so_don_hang = sum(int(row.get("SoLuongDonHang") or 0) for row in rows)

    return {
        "success": True,
        "message": "Thống kê doanh thu theo thành phố thành công.",
        "filters": {
            "ThanhPho": thanh_pho,
            "DoanhThuToiThieu": float(DoanhThuToiThieu),
        },
        "summary": {
            "SoChoOThoaDieuKien": len(rows),
            "TongSoDonHang": tong_so_don_hang,
            "TongDoanhThuToanBo": tong_doanh_thu_toan_bo,
        },
        "data": rows,
    }


@router.get(
    "/api/khach-hang/{id}/diem-tich-luy",
    response_model=MemberPointsApiResponse,
    summary="Tính điểm tích lũy của khách hàng",
)
def tinh_diem_tich_luy(
    id: str = Path(  # noqa: A002 - giữ đúng path /{id} theo yêu cầu đề bài nhóm giao
        ...,
        description="Mã người dùng khách hàng. Ví dụ: CUS001, CUS003.",
        examples=["CUS001"],
    ),
) -> Dict[str, Any]:
    """
    Gọi function:
        SELECT fn_TinhDiemTichLuy(id)

    Quy ước theo function nhóm đã viết:
    - Trả về số điểm nếu khách hàng tồn tại.
    - Trả về -1 nếu mã khách hàng không tồn tại trong bảng KhachHang.
    """
    ma_khach_hang = _normalize_required_text(id, "id")

    diem_tich_luy = call_function(
        "fn_TinhDiemTichLuy",
        [ma_khach_hang],
        result_alias="DiemTichLuy",
    )

    if diem_tich_luy is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Function fn_TinhDiemTichLuy không trả về dữ liệu.",
        )

    try:
        diem_tich_luy_int = int(diem_tich_luy)
    except (TypeError, ValueError) as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Kết quả điểm tích lũy không hợp lệ.",
        ) from exc

    if diem_tich_luy_int == -1:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Không tìm thấy khách hàng có mã {ma_khach_hang} trong bảng KhachHang.",
        )

    return {
        "success": True,
        "message": "Tính điểm tích lũy khách hàng thành công.",
        "data": {
            "MaNguoiDung": ma_khach_hang,
            "DiemTichLuy": diem_tich_luy_int,
            "TongDiem": diem_tich_luy_int,
            "GhiChu": "Điểm được tính trực tiếp từ function fn_TinhDiemTichLuy trong MySQL.",
        },
    }
