"""
database.py - Kết nối MySQL và hàm gọi procedure/function cho BTL2.

File này giữ phong cách mysql.connector giống file database.py nhóm đã gửi,
đồng thời bổ sung các hàm cần cho Gói công việc 3:
- call_procedure(): gọi stored procedure sp_StatisticRevenueByCity
- call_function(): gọi function fn_TinhDiemTichLuy
- test_connection(): kiểm tra kết nối CSDL cho /health

Cách cấu hình khuyến nghị:
Tạo file .env cùng cấp main.py, ví dụ:
    DB_HOST=localhost
    DB_PORT=3306
    DB_USER=root
    DB_PASSWORD=123456
    DB_NAME=BTL2
"""

from __future__ import annotations

import os
import re
from datetime import date, datetime
from decimal import Decimal
from typing import Any, Dict, Iterable, List, Sequence

import mysql.connector
from dotenv import load_dotenv
from fastapi import HTTPException, status
from mysql.connector import Error

load_dotenv()

# Có thể cấu hình bằng .env. Nếu chưa có .env, các giá trị fallback bên dưới sẽ được dùng.
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "PASS")
DB_NAME = os.getenv("DB_NAME", "BTL2")


def _mysql_error_message(error: Error) -> str:
    """Lấy thông báo lỗi MySQL gọn và dễ đọc."""
    return getattr(error, "msg", None) or str(error)


def _validate_sql_identifier(identifier: str) -> None:
    """
    Chặn tên procedure/function bất thường.
    Tên procedure/function chỉ lấy từ code nội bộ, nhưng vẫn kiểm tra để an toàn hơn.
    """
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", identifier):
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Tên procedure/function không hợp lệ: {identifier}",
        )


def serialize_value(value: Any) -> Any:
    """Chuyển dữ liệu MySQL sang dạng JSON-friendly."""
    if isinstance(value, Decimal):
        # Dùng float để Swagger hiển thị gọn. Nếu cần chính xác tuyệt đối tiền tệ, có thể đổi sang str.
        return float(value)
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    return value


def serialize_rows(rows: Iterable[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Chuyển list row từ MySQL sang list dict JSON-friendly."""
    return [
        {key: serialize_value(value) for key, value in row.items()}
        for row in rows
    ]


def get_db_connection():
    """Tạo kết nối MySQL. Trả về connection hoặc None nếu lỗi."""
    try:
        connection = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            charset="utf8mb4",
            use_unicode=True,
        )
        if connection.is_connected():
            return connection
        return None
    except Error as error:
        print(f"Lỗi không kết nối được MySQL: {_mysql_error_message(error)}")
        return None


def get_db():
    """
    Dependency cho FastAPI nếu các thành viên khác muốn dùng Depends(get_db).
    Gói 3 hiện dùng call_procedure/call_function trực tiếp để code ngắn hơn.
    """
    db_conn = get_db_connection()

    if db_conn is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Không thể kết nối đến cơ sở dữ liệu. Kiểm tra DB_HOST, DB_USER, DB_PASSWORD, DB_NAME.",
        )

    try:
        yield db_conn
    finally:
        if db_conn.is_connected():
            db_conn.close()


def test_connection() -> bool:
    """Kiểm tra API có kết nối được MySQL không."""
    connection = get_db_connection()
    if connection is None:
        return False

    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT 1 AS ok")
        row = cursor.fetchone()
        cursor.close()
        return bool(row and row.get("ok") == 1)
    except Error:
        return False
    finally:
        if connection.is_connected():
            connection.close()


def call_procedure(procedure_name: str, params: Sequence[Any]) -> List[Dict[str, Any]]:
    """
    Gọi stored procedure MySQL và trả về list[dict].

    Ví dụ:
        call_procedure("sp_StatisticRevenueByCity", ["Amsterdam", 0])
    """
    _validate_sql_identifier(procedure_name)

    connection = get_db_connection()
    if connection is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Không thể kết nối đến cơ sở dữ liệu.",
        )

    cursor = None
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.callproc(procedure_name, list(params))

        rows: List[Dict[str, Any]] = []
        # mysql.connector trả kết quả procedure qua stored_results()
        for result in cursor.stored_results():
            rows.extend(result.fetchall())

        return serialize_rows(rows)
    except Error as error:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi khi gọi procedure {procedure_name}: {_mysql_error_message(error)}",
        ) from error
    finally:
        if cursor is not None:
            cursor.close()
        if connection.is_connected():
            connection.close()


def call_function(function_name: str, params: Sequence[Any], result_alias: str = "result") -> Any:
    """
    Gọi MySQL function dạng SELECT fn_name(%s, ...) AS result_alias.

    Ví dụ:
        call_function("fn_TinhDiemTichLuy", ["CUS001"], "DiemTichLuy")
    """
    _validate_sql_identifier(function_name)
    _validate_sql_identifier(result_alias)

    connection = get_db_connection()
    if connection is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Không thể kết nối đến cơ sở dữ liệu.",
        )

    placeholders = ", ".join(["%s"] * len(params))
    sql = f"SELECT {function_name}({placeholders}) AS {result_alias}"

    cursor = None
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute(sql, tuple(params))
        row = cursor.fetchone()
        if row is None:
            return None
        return serialize_value(row.get(result_alias))
    except Error as error:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi khi gọi function {function_name}: {_mysql_error_message(error)}",
        ) from error
    finally:
        if cursor is not None:
            cursor.close()
        if connection.is_connected():
            connection.close()
