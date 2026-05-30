from __future__ import annotations

from decimal import Decimal
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


# ==============================
# Schema sẵn có của nhóm
# ==============================

class SearchChoORequest(BaseModel):
    keyword_thanh_pho: Optional[str] = None
    keyword_ten_cho_o: Optional[str] = None


class ChoOResponse(BaseModel):
    MaChoO: str
    TenChoO: str
    ThanhPho: str
    QuocGia: str
    DiemDanhGiaTrungBinh: float
    TrangThaiXacNhan: str
    TenChuSoHuu: str
    EmailChuSoHuu: str


class ChoOCreate(BaseModel):
    TenChoO: str
    SoNha: Optional[str] = None
    TenDuong: str
    MaBuuDien: str
    ThanhPho: str
    QuocGia: str
    MoTa: Optional[str] = None


class ChoOUpdate(BaseModel):
    MaChoO: str  # required for identifying which record to update
    TenChoO: str
    SoNha: Optional[str] = None
    TenDuong: str
    MaBuuDien: str
    ThanhPho: str
    QuocGia: str
    MoTa: Optional[str] = None
    MaQTV: Optional[str] = None
    TrangThai: str  # 'Cho xac nhan', 'Da xac nhan', 'Tu choi'


# ==============================
# Schema cho Gói công việc 3
# ==============================

class RevenueStatRequest(BaseModel):
    ThanhPho: str = Field(..., examples=["Amsterdam"])
    DoanhThuToiThieu: Decimal = Field(default=0, ge=0, examples=[0])


class RevenueStatResponse(BaseModel):
    MaChoO: str
    TenChoO: str
    ThanhPho: str
    SoLuongDonHang: int
    TongDoanhThu: Decimal | float


class RevenueSummary(BaseModel):
    SoChoOThoaDieuKien: int
    TongSoDonHang: int
    TongDoanhThuToanBo: Decimal | float


class RevenueStatApiResponse(BaseModel):
    success: bool
    message: str
    filters: Dict[str, Any]
    summary: RevenueSummary
    data: List[RevenueStatResponse]


class MemberPointsResponse(BaseModel):
    MaNguoiDung: str
    DiemTichLuy: int
    # Giữ thêm TongDiem để nếu nhóm đã dùng schema cũ thì không bị lệch quá nhiều.
    TongDiem: int
    GhiChu: Optional[str] = None


class MemberPointsApiResponse(BaseModel):
    success: bool
    message: str
    data: MemberPointsResponse


class HealthResponse(BaseModel):
    api: str
    database: str
