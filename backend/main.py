from __future__ import annotations

from typing import Any, Dict

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers.accom_routers import router as accom_router 
from routers.api_stats import router as stats_router

from database import test_connection

app = FastAPI(
    title="Hệ thống Quản lý Đặt phòng Khách sạn - BTL2",
    description="API phục vụ bài tập lớn số 2 - Hệ CSDL",
    version="1.0.0",
)

# Cấu hình CORS để Frontend/Swagger/Postman có thể gọi API dễ dàng trong giai đoạn demo.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- KẾT NỐI ROUTER CỦA THÀNH VIÊN 3 ---
# Endpoint được tạo:
# - GET /api/thong-ke/doanh-thu
# - GET /api/khach-hang/{id}/diem-tich-luy
app.include_router(accom_router)
app.include_router(stats_router)


@app.get("/")
def root() -> Dict[str, str]:
    return {
        "message": "Chào mừng đến với API Hệ thống Đặt phòng Khách sạn!",
        "docs": "/docs",
        "health": "/health",
        "api_doanh_thu": "/api/thong-ke/doanh-thu",
        "api_diem_tich_luy": "/api/khach-hang/{id}/diem-tich-luy",
    }


@app.get("/health")
def health_check() -> Dict[str, Any]:
    db_ok = test_connection()
    return {
        "api": "ok",
        "database": "connected" if db_ok else "not_connected",
    }
