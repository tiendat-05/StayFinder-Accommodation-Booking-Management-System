import { useState } from 'react'
import { searchChoO, createChoO, getErrorMessage } from '../api'
import { useToast } from '../components/Toast'
import { useAuth } from '../components/AuthContext'
import Modal from '../components/Modal'
import LoadingSpinner from '../components/LoadingSpinner'

const EMPTY_FORM = {
  TenChoO: '',
  SoNha: '',
  TenDuong: '',
  MaBuuDien: '',
  ThanhPho: '',
  QuocGia: '',
  MoTa: '',
}

function SearchPage() {
  const [thanhPho, setThanhPho] = useState('')
  const [tenChoO, setTenChoO] = useState('')
  const [results, setResults] = useState(null)
  const [loading, setLoading] = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const [formData, setFormData] = useState({ ...EMPTY_FORM })
  const [submitting, setSubmitting] = useState(false)
  const toast = useToast()
  const { isUser, isAdmin } = useAuth()

  const handleSearch = async (e) => {
    e.preventDefault()
    if (!thanhPho.trim() && !tenChoO.trim()) {
      toast.warning('Thiếu thông tin', 'Vui lòng nhập thành phố hoặc tên chỗ ở để tìm kiếm.')
      return
    }

    setLoading(true)
    try {
      const data = await searchChoO(thanhPho, tenChoO)
      // User chỉ thấy chỗ ở đã xác nhận. Admin thấy tất cả.
      const filtered = isAdmin ? data : data.filter((item) => item.TrangThaiXacNhan === 'Da xac nhan')
      setResults(filtered)
      if (filtered.length === 0) {
        toast.warning('Không tìm thấy', 'Không có chỗ ở nào phù hợp với tiêu chí tìm kiếm.')
      }
    } catch (error) {
      toast.error('Lỗi tìm kiếm', getErrorMessage(error))
      setResults([])
    } finally {
      setLoading(false)
    }
  }

  // Handle form
  const handleChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  const handleSubmitAdd = async (e) => {
    e.preventDefault()
    if (!formData.TenChoO.trim()) {
      toast.warning('Thiếu thông tin', 'Tên chỗ ở là bắt buộc.')
      return
    }

    setSubmitting(true)
    try {
      await createChoO(formData)
      toast.success(
        'Đăng ký chỗ ở thành công!',
        `"${formData.TenChoO}" đã được gửi và đang chờ quản trị viên duyệt.`
      )
      setModalOpen(false)
      setFormData({ ...EMPTY_FORM })
    } catch (error) {
      toast.error('Lỗi từ Database', getErrorMessage(error))
    } finally {
      setSubmitting(false)
    }
  }

  const renderRating = (score) => {
    const rounded = Math.round(score * 10) / 10
    let label = 'Tốt'
    if (rounded >= 9) label = 'Xuất sắc'
    else if (rounded >= 8) label = 'Rất tốt'
    else if (rounded >= 7) label = 'Tốt'
    else if (rounded >= 6) label = 'Hài lòng'
    else label = 'Trung bình'

    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
        <span
          style={{
            background: 'var(--color-primary)',
            color: 'white',
            padding: '0.25rem 0.5rem',
            borderRadius: 'var(--radius-sm)',
            fontWeight: 700,
            fontSize: '0.875rem',
          }}
        >
          {rounded.toFixed(1)}
        </span>
        <span style={{ fontSize: '0.8125rem', color: 'var(--color-text-secondary)', fontWeight: 500 }}>
          {label}
        </span>
      </div>
    )
  }

  return (
    <div>
      {/* Hero Section */}
      <section className="hero" id="hero-section">
        <div className="hero-content animate-fade-in-up">
          <h1>Tìm chỗ ở lý tưởng của bạn</h1>
          <p>
            Khám phá hàng ngàn khách sạn, căn hộ, resort và villa trên khắp thế giới
          </p>

          <form className="search-bar" onSubmit={handleSearch} id="search-form">
            <input
              type="text"
              className="form-input"
              placeholder="🏙️ Thành phố (VD: Amsterdam, Paris...)"
              value={thanhPho}
              onChange={(e) => setThanhPho(e.target.value)}
              id="input-thanh-pho"
            />
            <input
              type="text"
              className="form-input"
              placeholder="🏨 Tên chỗ ở..."
              value={tenChoO}
              onChange={(e) => setTenChoO(e.target.value)}
              id="input-ten-cho-o"
            />
            <button type="submit" className="btn btn-accent btn-lg" disabled={loading} id="btn-search">
              {loading ? '...' : '🔍 Tìm kiếm'}
            </button>
          </form>

          {/* Nút thêm chỗ ở cho User */}
          {isUser && (
            <button
              className="btn btn-primary btn-lg"
              onClick={() => setModalOpen(true)}
              style={{ marginTop: '1.25rem' }}
              id="btn-user-add"
            >
              ➕ Đăng ký chỗ ở mới
            </button>
          )}
        </div>
      </section>

      {/* Results Section */}
      <div className="page-container">
        {loading && <LoadingSpinner text="Đang tìm kiếm chỗ ở..." />}

        {!loading && results === null && (
          <div className="empty-state animate-fade-in">
            <div className="empty-icon">🌍</div>
            <h3>Bắt đầu tìm kiếm</h3>
            <p>Nhập tên thành phố hoặc tên chỗ ở ở thanh tìm kiếm phía trên để bắt đầu.</p>
          </div>
        )}

        {!loading && results !== null && results.length === 0 && (
          <div className="empty-state animate-fade-in">
            <div className="empty-icon">😔</div>
            <h3>Không tìm thấy kết quả</h3>
            <p>Thử thay đổi từ khóa tìm kiếm hoặc kiểm tra lại chính tả.</p>
          </div>
        )}

        {!loading && results !== null && results.length > 0 && (
          <>
            <div className="page-header" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div>
                <h1>Kết quả tìm kiếm</h1>
                <p>Tìm thấy <strong>{results.length}</strong> chỗ ở phù hợp</p>
              </div>
            </div>

            <div
              className="stagger-children"
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))',
                gap: '1.25rem',
              }}
              id="search-results"
            >
              {results.map((item, index) => (
                <div className="card" key={item.MaChoO || index} style={{ display: 'flex', flexDirection: 'column' }}>
                  {/* Card header with gradient */}
                  <div
                    style={{
                      background: `linear-gradient(135deg, ${
                        ['#003580', '#0071c2', '#00224f', '#1a4d8f', '#2563eb'][index % 5]
                      }, ${
                        ['#0071c2', '#38bdf8', '#003580', '#3b82f6', '#6366f1'][index % 5]
                      })`,
                      padding: '1.25rem',
                      color: 'white',
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                      <div>
                        <h3 style={{ fontSize: '1.125rem', fontWeight: 700, marginBottom: '0.25rem', lineHeight: 1.3 }}>
                          {item.TenChoO}
                        </h3>
                        <p style={{ opacity: 0.85, fontSize: '0.875rem' }}>
                          📍 {item.ThanhPho}, {item.QuocGia}
                        </p>
                      </div>
                      <span
                        style={{
                          background: 'rgba(255,255,255,0.2)',
                          padding: '0.125rem 0.5rem',
                          borderRadius: 'var(--radius-sm)',
                          fontSize: '0.75rem',
                          fontWeight: 600,
                          backdropFilter: 'blur(4px)',
                        }}
                      >
                        {item.MaChoO}
                      </span>
                    </div>
                  </div>

                  {/* Card body */}
                  <div style={{ padding: '1rem 1.25rem', flex: 1, display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      {renderRating(item.DiemDanhGiaTrungBinh)}
                      <span className="badge badge-success">✓ Đã xác nhận</span>
                    </div>

                    <div
                      style={{
                        borderTop: '1px solid var(--color-border)',
                        paddingTop: '0.75rem',
                        marginTop: 'auto',
                      }}
                    >
                      <p style={{ fontSize: '0.8125rem', color: 'var(--color-text-secondary)' }}>
                        👤 {item.TenChuSoHuu}
                      </p>
                      <p style={{ fontSize: '0.8125rem', color: 'var(--color-text-secondary)' }}>
                        ✉️ {item.EmailChuSoHuu}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </div>

      {/* Modal thêm chỗ ở cho User */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title="➕ Đăng ký chỗ ở mới"
        footer={
          <>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)} disabled={submitting}>
              Hủy
            </button>
            <button className="btn btn-primary" onClick={handleSubmitAdd} disabled={submitting} id="btn-user-submit">
              {submitting ? 'Đang gửi...' : '📤 Gửi đăng ký'}
            </button>
          </>
        }
      >
        <div style={{
          background: '#eff6ff',
          border: '1px solid #bfdbfe',
          borderRadius: 'var(--radius-sm)',
          padding: '0.75rem 1rem',
          marginBottom: '1rem',
          fontSize: '0.8125rem',
          color: '#1e40af',
        }}>
          ℹ️ Chỗ ở sau khi đăng ký sẽ ở trạng thái <strong>"Chờ xác nhận"</strong> cho đến khi quản trị viên duyệt.
        </div>

        <form onSubmit={handleSubmitAdd} id="form-user-add">
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>

            <div className="form-group">
              <label className="form-label">Tên chỗ ở *</label>
              <input
                className="form-input"
                value={formData.TenChoO}
                onChange={(e) => handleChange('TenChoO', e.target.value)}
                placeholder="VD: Grand Hotel Amsterdam"
                required
                id="user-field-ten-cho-o"
              />
            </div>
            <div className="form-group">
              <label className="form-label">Số nhà</label>
              <input
                className="form-input"
                value={formData.SoNha}
                onChange={(e) => handleChange('SoNha', e.target.value)}
                placeholder="VD: 123"
              />
            </div>
            <div className="form-group">
              <label className="form-label">Tên đường *</label>
              <input
                className="form-input"
                value={formData.TenDuong}
                onChange={(e) => handleChange('TenDuong', e.target.value)}
                placeholder="VD: Damrak"
                required
              />
            </div>
            <div className="form-group">
              <label className="form-label">Mã bưu điện *</label>
              <input
                className="form-input"
                value={formData.MaBuuDien}
                onChange={(e) => handleChange('MaBuuDien', e.target.value)}
                placeholder="VD: 1012"
                required
              />
            </div>
            <div className="form-group">
              <label className="form-label">Thành phố *</label>
              <input
                className="form-input"
                value={formData.ThanhPho}
                onChange={(e) => handleChange('ThanhPho', e.target.value)}
                placeholder="VD: Amsterdam"
                required
              />
            </div>
            <div className="form-group">
              <label className="form-label">Quốc gia *</label>
              <input
                className="form-input"
                value={formData.QuocGia}
                onChange={(e) => handleChange('QuocGia', e.target.value)}
                placeholder="VD: Netherlands"
                required
              />
            </div>

          </div>
          <div className="form-group" style={{ marginTop: '1rem' }}>
            <label className="form-label">Mô tả</label>
            <textarea
              className="form-input"
              value={formData.MoTa}
              onChange={(e) => handleChange('MoTa', e.target.value)}
              placeholder="Mô tả ngắn về chỗ ở..."
              rows={3}
              style={{ resize: 'vertical' }}
            />
          </div>
        </form>
      </Modal>
    </div>
  )
}

export default SearchPage
