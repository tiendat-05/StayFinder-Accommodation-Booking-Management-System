import axios from 'axios';

// Vite proxy sẽ forward /api -> http://localhost:8000 trong development
// Khi deploy lên Vercel, cần cấu hình rewrites trong vercel.json
const api = axios.create({
  baseURL: '',
  headers: {
    'Content-Type': 'application/json',
  },
});

// ==============================
// Chỗ Ở - Search / CRUD
// ==============================

/**
 * Tìm kiếm chỗ ở theo thành phố và/hoặc tên
 * @param {string} thanhPho - Từ khóa thành phố
 * @param {string} tenChoO - Từ khóa tên chỗ ở
 */
export async function searchChoO(thanhPho = '', tenChoO = '') {
  const params = {};
  if (thanhPho.trim()) params.thanh_pho = thanhPho.trim();
  if (tenChoO.trim()) params.ten_cho_o = tenChoO.trim();

  const { data } = await api.get('/api/cho-o/search', { params });
  return data;
}

/**
 * Lấy tất cả chỗ ở (bao gồm chỗ ở chưa có chủ sở hữu)
 * Dùng cho Admin page
 */
export async function getAllChoO() {
  const { data } = await api.get('/api/cho-o/all');
  return data;
}

/**
 * Thêm mới chỗ ở
 * @param {Object} choO - Dữ liệu chỗ ở theo schema ChoOCreate
 */
export async function createChoO(choO) {
  const { data } = await api.post('/api/cho-o/', choO);
  return data;
}

/**
 * Cập nhật chỗ ở
 * @param {Object} choO - Dữ liệu chỗ ở theo schema ChoOUpdate (gồm TrangThai)
 */
export async function updateChoO(choO) {
  const { data } = await api.put('/api/cho-o/', choO);
  return data;
}

/**
 * Xóa chỗ ở theo mã
 * @param {string} maChoO - Mã chỗ ở cần xóa
 */
export async function deleteChoO(maChoO) {
  const { data } = await api.delete(`/api/cho-o/${encodeURIComponent(maChoO)}`);
  return data;
}

// ==============================
// Thống kê doanh thu
// ==============================

/**
 * Lấy thống kê doanh thu theo thành phố
 * @param {string} thanhPho - Tên thành phố
 * @param {number} doanhThuToiThieu - Lọc doanh thu tối thiểu
 */
export async function getRevenueStats(thanhPho, doanhThuToiThieu = 0) {
  const { data } = await api.get('/api/thong-ke/doanh-thu', {
    params: {
      ThanhPho: thanhPho,
      DoanhThuToiThieu: doanhThuToiThieu,
    },
  });
  return data;
}

// ==============================
// Khách hàng - Điểm tích lũy
// ==============================

/**
 * Lấy điểm tích lũy của khách hàng
 * @param {string} maNguoiDung - Mã người dùng (VD: CUS001)
 */
export async function getMemberPoints(maNguoiDung) {
  const { data } = await api.get(`/api/khach-hang/${encodeURIComponent(maNguoiDung)}/diem-tich-luy`);
  return data;
}

// ==============================
// Health check
// ==============================

export async function healthCheck() {
  const { data } = await api.get('/health');
  return data;
}

/**
 * Extract error message from API response or generic error
 */
export function getErrorMessage(error) {
  if (error.response?.data?.detail) {
    return error.response.data.detail;
  }
  if (error.response?.data?.message) {
    return error.response.data.message;
  }
  if (error.message) {
    return error.message;
  }
  return 'Đã xảy ra lỗi không xác định.';
}

export default api;
