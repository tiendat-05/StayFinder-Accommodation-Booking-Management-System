import { useState } from 'react'
import { getRevenueStats, getMemberPoints, getErrorMessage } from '../api'
import { useToast } from '../components/Toast'
import LoadingSpinner from '../components/LoadingSpinner'

function StatsPage() {
  // Revenue stats state
  const [thanhPho, setThanhPho] = useState('')
  const [doanhThuMin, setDoanhThuMin] = useState('0')
  const [revenueData, setRevenueData] = useState(null)
  const [loadingRevenue, setLoadingRevenue] = useState(false)

  // Member points state
  const [maNguoiDung, setMaNguoiDung] = useState('')
  const [memberData, setMemberData] = useState(null)
  const [loadingMember, setLoadingMember] = useState(false)

  const toast = useToast()

  // Fetch revenue statistics
  const handleRevenueSearch = async (e) => {
    e.preventDefault()
    if (!thanhPho.trim()) {
      toast.warning('Thiếu thông tin', 'Vui lòng nhập tên thành phố để thống kê.')
      return
    }

    setLoadingRevenue(true)
    try {
      const data = await getRevenueStats(thanhPho.trim(), Number(doanhThuMin) || 0)
      setRevenueData(data)
      if (data.data.length === 0) {
        toast.warning('Không có dữ liệu', `Không tìm thấy doanh thu nào tại "${thanhPho}".`)
      }
    } catch (error) {
      toast.error('Lỗi thống kê', getErrorMessage(error))
    } finally {
      setLoadingRevenue(false)
    }
  }

  // Fetch member points
  const handleMemberSearch = async (e) => {
    e.preventDefault()
    if (!maNguoiDung.trim()) {
      toast.warning('Thiếu thông tin', 'Vui lòng nhập mã người dùng.')
      return
    }

    setLoadingMember(true)
    try {
      const data = await getMemberPoints(maNguoiDung.trim())
      setMemberData(data)
      toast.success('Thành công', `Đã lấy điểm tích lũy của ${maNguoiDung.trim()}.`)
    } catch (error) {
      toast.error('Lỗi', getErrorMessage(error))
      setMemberData(null)
    } finally {
      setLoadingMember(false)
    }
  }

  // Format currency
  const formatCurrency = (value) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
      maximumFractionDigits: 0,
    }).format(value).replace('₫', '$')
  }

  const formatNumber = (value) => {
    return new Intl.NumberFormat('vi-VN').format(value)
  }

  return (
    <div className="page-container">
      {/* Page Header */}
      <div className="page-header animate-fade-in-up">
        <h1>📊 Thống kê Doanh thu</h1>
        <p>Báo cáo doanh thu theo thành phố và quản lý điểm tích lũy khách hàng</p>
      </div>

      {/* Two-column layout */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem', alignItems: 'start' }}>
        {/* Revenue Search Form */}
        <div className="card animate-fade-in-up" style={{ padding: '1.5rem' }}>
          <h2 style={{ fontSize: '1.125rem', fontWeight: 700, marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            💰 Doanh thu theo Thành phố
          </h2>
          <form onSubmit={handleRevenueSearch} id="form-revenue">
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div className="form-group">
                <label className="form-label">Thành phố *</label>
                <input
                  className="form-input"
                  value={thanhPho}
                  onChange={(e) => setThanhPho(e.target.value)}
                  placeholder="VD: Amsterdam, London, Paris..."
                  required
                  id="stats-thanh-pho"
                />
              </div>
              <div className="form-group">
                <label className="form-label">Doanh thu tối thiểu ($)</label>
                <input
                  className="form-input"
                  type="number"
                  min="0"
                  value={doanhThuMin}
                  onChange={(e) => setDoanhThuMin(e.target.value)}
                  placeholder="0"
                  id="stats-doanh-thu-min"
                />
              </div>
              <button type="submit" className="btn btn-primary btn-lg" disabled={loadingRevenue} id="btn-stats-search">
                {loadingRevenue ? 'Đang tải...' : '📊 Xem thống kê'}
              </button>
            </div>
          </form>
        </div>

        {/* Member Points Form */}
        <div className="card animate-fade-in-up" style={{ padding: '1.5rem', animationDelay: '100ms' }}>
          <h2 style={{ fontSize: '1.125rem', fontWeight: 700, marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            🏅 Điểm tích lũy Khách hàng
          </h2>
          <form onSubmit={handleMemberSearch} id="form-member">
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <div className="form-group">
                <label className="form-label">Mã người dùng *</label>
                <input
                  className="form-input"
                  value={maNguoiDung}
                  onChange={(e) => setMaNguoiDung(e.target.value)}
                  placeholder="VD: CUS001, CUS003..."
                  required
                  id="stats-ma-nguoi-dung"
                />
              </div>
              <button type="submit" className="btn btn-accent btn-lg" disabled={loadingMember} id="btn-member-search">
                {loadingMember ? 'Đang tải...' : '🔍 Tra cứu điểm'}
              </button>
            </div>
          </form>

          {/* Member Points Result */}
          {loadingMember && <LoadingSpinner text="Đang tính điểm..." />}
          {!loadingMember && memberData && (
            <div style={{ marginTop: '1.5rem', animation: 'fadeInUp 0.4s ease both' }}>
              <div
                style={{
                  background: 'linear-gradient(135deg, #003580, #0071c2)',
                  borderRadius: 'var(--radius-md)',
                  padding: '1.5rem',
                  color: 'white',
                  textAlign: 'center',
                }}
              >
                <p style={{ fontSize: '0.875rem', opacity: 0.85, marginBottom: '0.25rem' }}>
                  {memberData.data.MaNguoiDung}
                </p>
                <p style={{ fontSize: '2.5rem', fontWeight: 800, lineHeight: 1 }}>
                  {formatNumber(memberData.data.DiemTichLuy)}
                </p>
                <p style={{ fontSize: '0.875rem', opacity: 0.85, marginTop: '0.25rem' }}>điểm tích lũy</p>
                {memberData.data.GhiChu && (
                  <p style={{ fontSize: '0.75rem', opacity: 0.7, marginTop: '0.75rem', fontStyle: 'italic' }}>
                    {memberData.data.GhiChu}
                  </p>
                )}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Revenue Results */}
      {loadingRevenue && <LoadingSpinner text="Đang tải thống kê doanh thu..." />}

      {!loadingRevenue && revenueData && (
        <div style={{ marginTop: '2rem' }} className="animate-fade-in-up">
          {/* Summary Cards */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1rem', marginBottom: '1.5rem' }}>
            <div className="stat-card">
              <div className="stat-icon">🏨</div>
              <div className="stat-value">{revenueData.summary.SoChoOThoaDieuKien}</div>
              <div className="stat-label">Chỗ ở thỏa điều kiện</div>
            </div>
            <div className="stat-card">
              <div className="stat-icon">📦</div>
              <div className="stat-value">{formatNumber(revenueData.summary.TongSoDonHang)}</div>
              <div className="stat-label">Tổng số đơn hàng</div>
            </div>
            <div className="stat-card">
              <div className="stat-icon">💰</div>
              <div className="stat-value" style={{ fontSize: '1.5rem' }}>
                {formatCurrency(revenueData.summary.TongDoanhThuToanBo)}
              </div>
              <div className="stat-label">Tổng doanh thu</div>
            </div>
          </div>

          {/* Filter info */}
          <div style={{
            display: 'flex',
            gap: '0.75rem',
            marginBottom: '1rem',
            flexWrap: 'wrap',
          }}>
            <span className="badge badge-info" style={{ fontSize: '0.8125rem', padding: '0.375rem 0.75rem' }}>
              🏙️ {revenueData.filters.ThanhPho}
            </span>
            <span className="badge badge-info" style={{ fontSize: '0.8125rem', padding: '0.375rem 0.75rem' }}>
              💵 Doanh thu ≥ {formatCurrency(revenueData.filters.DoanhThuToiThieu)}
            </span>
          </div>

          {/* Revenue Table */}
          {revenueData.data.length > 0 ? (
            <div className="card" style={{ overflow: 'auto' }}>
              <table className="data-table" id="revenue-table">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Mã chỗ ở</th>
                    <th>Tên chỗ ở</th>
                    <th>Thành phố</th>
                    <th style={{ textAlign: 'right' }}>Số đơn hàng</th>
                    <th style={{ textAlign: 'right' }}>Tổng doanh thu</th>
                  </tr>
                </thead>
                <tbody>
                  {revenueData.data.map((item, idx) => (
                    <tr key={item.MaChoO}>
                      <td style={{ color: 'var(--color-text-secondary)' }}>{idx + 1}</td>
                      <td>
                        <code style={{ background: '#f0f7ff', padding: '0.125rem 0.375rem', borderRadius: '4px', fontSize: '0.8125rem', fontWeight: 600 }}>
                          {item.MaChoO}
                        </code>
                      </td>
                      <td style={{ fontWeight: 600 }}>{item.TenChoO}</td>
                      <td>{item.ThanhPho}</td>
                      <td style={{ textAlign: 'right', fontWeight: 600 }}>{formatNumber(item.SoLuongDonHang)}</td>
                      <td style={{ textAlign: 'right', fontWeight: 700, color: 'var(--color-success)' }}>
                        {formatCurrency(item.TongDoanhThu)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="empty-state">
              <div className="empty-icon">📭</div>
              <h3>Không có dữ liệu doanh thu</h3>
              <p>Không tìm thấy chỗ ở nào thỏa điều kiện thống kê.</p>
            </div>
          )}
        </div>
      )}

      {/* Initial state */}
      {!loadingRevenue && !revenueData && (
        <div className="empty-state animate-fade-in" style={{ marginTop: '2rem' }}>
          <div className="empty-icon">📈</div>
          <h3>Chọn thành phố để xem thống kê</h3>
          <p>Nhập tên thành phố ở form bên trên và nhấn "Xem thống kê" để hiển thị báo cáo doanh thu.</p>
        </div>
      )}
    </div>
  )
}

export default StatsPage
