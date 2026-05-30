import { useState, useEffect } from 'react'
import { getAllChoO, createChoO, updateChoO, deleteChoO, getErrorMessage } from '../api'
import { useToast } from '../components/Toast'
import Modal from '../components/Modal'
import LoadingSpinner from '../components/LoadingSpinner'

const EMPTY_FORM = {
  MaChoO: '',
  TenChoO: '',
  SoNha: '',
  TenDuong: '',
  MaBuuDien: '',
  ThanhPho: '',
  QuocGia: '',
  MoTa: '',
  MaQTV: '',
  TrangThai: 'Cho xac nhan',
}

function AdminPage() {
  const [allItems, setAllItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState('pending') // 'pending' | 'approved'
  const [modalOpen, setModalOpen] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [formData, setFormData] = useState({ ...EMPTY_FORM })
  const [submitting, setSubmitting] = useState(false)
  const [confirmDelete, setConfirmDelete] = useState(null)
  const [confirmApprove, setConfirmApprove] = useState(null)
  const [confirmReject, setConfirmReject] = useState(null)
  const [adminIdInput, setAdminIdInput] = useState('') // item to approve
  const toast = useToast()

  // Derived data
  const pendingItems = allItems.filter((item) => item.TrangThaiXacNhan === 'Cho xac nhan')
  const approvedItems = allItems.filter((item) => item.TrangThaiXacNhan === 'Da xac nhan')

  const loadData = async () => {
    setLoading(true)
    try {
      const data = await getAllChoO()
      setAllItems(data)
    } catch (error) {
      toast.error('Lỗi tải dữ liệu', getErrorMessage(error))
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadData()
  }, [])

  // Approve accommodation: update TrangThai from 'Cho xac nhan' → 'Da xac nhan'
  const handleApprove = async (item) => {
    if (!adminIdInput.trim()) {
      toast.warning('Thiếu thông tin', 'Vui lòng nhập Mã Quản Trị Viên (VD: ADM003).')
      return
    }
    setSubmitting(true)
    try {
      await updateChoO({
        MaChoO: item.MaChoO,
        TenChoO: item.TenChoO,
        SoNha: item.SoNha || '',
        TenDuong: item.TenDuong || '',
        MaBuuDien: item.MaBuuDien || '',
        ThanhPho: item.ThanhPho,
        QuocGia: item.QuocGia,
        MoTa: item.MoTa || '',
        MaQTV: adminIdInput.trim(),
        TrangThai: 'Da xac nhan',
      })
      toast.success('Duyệt thành công!', `"${item.TenChoO}" đã được xác nhận và hiển thị cho người dùng.`)
      setConfirmApprove(null)
      setAdminIdInput('')
      await loadData()
    } catch (error) {
      toast.error('Lỗi duyệt', getErrorMessage(error))
    } finally {
      setSubmitting(false)
    }
  }

  // Reject accommodation: update TrangThai → 'Tu choi'
  const handleReject = async (item) => {
    if (!adminIdInput.trim()) {
      toast.warning('Thiếu thông tin', 'Vui lòng nhập Mã Quản Trị Viên (VD: ADM003).')
      return
    }
    setSubmitting(true)
    try {
      await updateChoO({
        MaChoO: item.MaChoO,
        TenChoO: item.TenChoO,
        SoNha: item.SoNha || '',
        TenDuong: item.TenDuong || '',
        MaBuuDien: item.MaBuuDien || '',
        ThanhPho: item.ThanhPho,
        QuocGia: item.QuocGia,
        MoTa: item.MoTa || '',
        MaQTV: adminIdInput.trim(),
        TrangThai: 'Tu choi',
      })
      toast.success('Đã từ chối', `"${item.TenChoO}" đã bị từ chối.`)
      setConfirmReject(null)
      setAdminIdInput('')
      await loadData()
    } catch (error) {
      toast.error('Lỗi', getErrorMessage(error))
    } finally {
      setSubmitting(false)
    }
  }

  // Open modal for creating
  const handleOpenCreate = () => {
    setFormData({ ...EMPTY_FORM })
    setIsEditing(false)
    setModalOpen(true)
  }

  // Open modal for editing
  const handleOpenEdit = (item) => {
    setFormData({
      MaChoO: item.MaChoO || '',
      TenChoO: item.TenChoO || '',
      SoNha: item.SoNha || '',
      TenDuong: item.TenDuong || '',
      MaBuuDien: item.MaBuuDien || '',
      ThanhPho: item.ThanhPho || '',
      QuocGia: item.QuocGia || '',
      MoTa: item.MoTa || '',
      MaQTV: item.MaQTV || '',
      TrangThai: item.TrangThaiXacNhan || 'Da xac nhan',
    })
    setIsEditing(true)
    setModalOpen(true)
  }

  const handleChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!formData.MaChoO.trim() || !formData.TenChoO.trim()) {
      toast.warning('Thiếu thông tin', 'Mã chỗ ở và Tên chỗ ở là bắt buộc.')
      return
    }

    setSubmitting(true)
    try {
      if (isEditing) {
        await updateChoO(formData)
        toast.success('Cập nhật thành công!', `Đã cập nhật chỗ ở "${formData.TenChoO}".`)
      } else {
        const { TrangThai, ...createData } = formData
        await createChoO(createData)
        toast.success('Thêm mới thành công!', `Đã thêm chỗ ở "${formData.TenChoO}".`)
      }
      setModalOpen(false)
      await loadData()
    } catch (error) {
      toast.error('Lỗi từ Database', getErrorMessage(error))
    } finally {
      setSubmitting(false)
    }
  }

  const handleDelete = async () => {
    if (!confirmDelete) return
    setSubmitting(true)
    try {
      await deleteChoO(confirmDelete.MaChoO)
      toast.success('Xóa thành công!', `Đã xóa chỗ ở "${confirmDelete.TenChoO}".`)
      setConfirmDelete(null)
      await loadData()
    } catch (error) {
      toast.error('Không thể xóa', getErrorMessage(error))
      setConfirmDelete(null)
    } finally {
      setSubmitting(false)
    }
  }

  const getStatusBadge = (status) => {
    switch (status) {
      case 'Da xac nhan':
        return <span className="badge badge-success">✓ Đã xác nhận</span>
      case 'Cho xac nhan':
        return <span className="badge badge-warning">⏳ Chờ xác nhận</span>
      case 'Tu choi':
        return <span className="badge badge-error">✗ Từ chối</span>
      default:
        return <span className="badge badge-info">{status}</span>
    }
  }

  const tabStyle = (tab) => ({
    padding: '0.75rem 1.5rem',
    border: 'none',
    background: activeTab === tab ? 'var(--color-primary)' : 'transparent',
    color: activeTab === tab ? 'white' : 'var(--color-text-secondary)',
    fontWeight: 600,
    fontSize: '0.9375rem',
    cursor: 'pointer',
    borderRadius: 'var(--radius-sm)',
    transition: 'all 0.2s ease',
    display: 'flex',
    alignItems: 'center',
    gap: '0.5rem',
  })

  return (
    <div className="page-container">
      {/* Page Header */}
      <div className="page-header animate-fade-in-up" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem' }}>
        <div>
          <h1>⚙️ Quản lý Chỗ ở</h1>
          <p>Duyệt, chỉnh sửa và quản lý thông tin chỗ ở trong hệ thống</p>
        </div>
        <div style={{ display: 'flex', gap: '0.75rem' }}>
          <button className="btn btn-primary" onClick={handleOpenCreate} id="btn-add-new">
            ➕ Thêm mới
          </button>
          <button className="btn btn-outline" onClick={loadData} disabled={loading} id="btn-refresh">
            🔄 Làm mới
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div style={{
        display: 'flex',
        gap: '0.5rem',
        marginBottom: '1.5rem',
        background: 'white',
        padding: '0.375rem',
        borderRadius: 'var(--radius-md)',
        boxShadow: 'var(--shadow-card)',
        width: 'fit-content',
      }}>
        <button style={tabStyle('pending')} onClick={() => setActiveTab('pending')} id="tab-pending">
          📋 Chờ duyệt
          {pendingItems.length > 0 && (
            <span style={{
              background: activeTab === 'pending' ? 'var(--color-accent)' : 'var(--color-error)',
              color: activeTab === 'pending' ? 'var(--color-primary-dark)' : 'white',
              padding: '0.125rem 0.5rem',
              borderRadius: '999px',
              fontSize: '0.75rem',
              fontWeight: 700,
              minWidth: '20px',
              textAlign: 'center',
            }}>
              {pendingItems.length}
            </span>
          )}
        </button>
        <button style={tabStyle('approved')} onClick={() => setActiveTab('approved')} id="tab-approved">
          ✅ Đã duyệt
          <span style={{
            background: activeTab === 'approved' ? 'rgba(255,255,255,0.2)' : '#e5e7eb',
            padding: '0.125rem 0.5rem',
            borderRadius: '999px',
            fontSize: '0.75rem',
            fontWeight: 700,
          }}>
            {approvedItems.length}
          </span>
        </button>
      </div>

      {loading ? (
        <LoadingSpinner text="Đang tải danh sách chỗ ở..." />
      ) : (
        <>
          {/* ====== TAB: CHỜ DUYỆT ====== */}
          {activeTab === 'pending' && (
            <div className="animate-fade-in">
              {pendingItems.length === 0 ? (
                <div className="empty-state">
                  <div className="empty-icon">✅</div>
                  <h3>Không có chỗ ở nào chờ duyệt</h3>
                  <p>Tất cả chỗ ở đã được xử lý. Khi người dùng đăng ký chỗ ở mới, chúng sẽ xuất hiện tại đây.</p>
                </div>
              ) : (
                <div className="stagger-children" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(380px, 1fr))', gap: '1rem' }}>
                  {pendingItems.map((item) => (
                    <div className="card" key={item.MaChoO} style={{ border: '2px solid #fbbf24' }}>
                      <div style={{
                        background: 'linear-gradient(135deg, #f59e0b, #d97706)',
                        padding: '1rem 1.25rem',
                        color: 'white',
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                      }}>
                        <div>
                          <h3 style={{ fontSize: '1rem', fontWeight: 700 }}>{item.TenChoO}</h3>
                          <p style={{ fontSize: '0.8125rem', opacity: 0.9 }}>📍 {item.ThanhPho}, {item.QuocGia}</p>
                        </div>
                        <code style={{
                          background: 'rgba(255,255,255,0.2)',
                          padding: '0.125rem 0.5rem',
                          borderRadius: '4px',
                          fontSize: '0.75rem',
                        }}>
                          {item.MaChoO}
                        </code>
                      </div>
                      <div style={{ padding: '1rem 1.25rem' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.75rem' }}>
                          <span className="badge badge-warning">⏳ Chờ xác nhận</span>
                          <span className="rating">⭐ {Number(item.DiemDanhGiaTrungBinh).toFixed(1)}</span>
                        </div>
                        <p style={{ fontSize: '0.8125rem', color: 'var(--color-text-secondary)', marginBottom: '1rem' }}>
                          👤 {item.TenChuSoHuu} · ✉️ {item.EmailChuSoHuu}
                        </p>
                        <div style={{ display: 'flex', gap: '0.5rem' }}>
                          <button
                            className="btn btn-primary"
                            style={{ flex: 1 }}
                            onClick={() => { setConfirmApprove(item); setAdminIdInput(''); }}
                            disabled={submitting}
                          >
                            ✅ Duyệt
                          </button>
                          <button
                            className="btn btn-danger"
                            style={{ flex: 1 }}
                            onClick={() => { setConfirmReject(item); setAdminIdInput(''); }}
                            disabled={submitting}
                          >
                            ✗ Từ chối
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* ====== TAB: ĐÃ DUYỆT ====== */}
          {activeTab === 'approved' && (
            <div className="animate-fade-in">
              {approvedItems.length === 0 ? (
                <div className="empty-state">
                  <div className="empty-icon">📋</div>
                  <h3>Chưa có chỗ ở nào được duyệt</h3>
                  <p>Duyệt các chỗ ở ở tab "Chờ duyệt" để chúng hiển thị tại đây.</p>
                </div>
              ) : (
                <div className="card" style={{ overflow: 'auto' }}>
                  <table className="data-table" id="admin-table">
                    <thead>
                      <tr>
                        <th>Mã</th>
                        <th>Tên chỗ ở</th>
                        <th>Thành phố</th>
                        <th>Quốc gia</th>
                        <th>Điểm TB</th>
                        <th>Trạng thái</th>
                        <th>Chủ sở hữu</th>
                        <th style={{ textAlign: 'center' }}>Hành động</th>
                      </tr>
                    </thead>
                    <tbody>
                      {approvedItems.map((item) => (
                        <tr key={item.MaChoO}>
                          <td>
                            <code style={{ background: '#f0f7ff', padding: '0.125rem 0.375rem', borderRadius: '4px', fontSize: '0.8125rem', fontWeight: 600 }}>
                              {item.MaChoO}
                            </code>
                          </td>
                          <td style={{ fontWeight: 600, maxWidth: '200px' }}>{item.TenChoO}</td>
                          <td>{item.ThanhPho}</td>
                          <td>{item.QuocGia}</td>
                          <td>
                            <span className="rating">⭐ {Number(item.DiemDanhGiaTrungBinh).toFixed(1)}</span>
                          </td>
                          <td>{getStatusBadge(item.TrangThaiXacNhan)}</td>
                          <td style={{ fontSize: '0.8125rem', color: 'var(--color-text-secondary)' }}>
                            {item.TenChuSoHuu}
                          </td>
                          <td>
                            <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center' }}>
                              <button
                                className="btn btn-outline btn-sm"
                                onClick={() => handleOpenEdit(item)}
                                title="Chỉnh sửa"
                              >
                                ✏️ Sửa
                              </button>
                              <button
                                className="btn btn-danger btn-sm"
                                onClick={() => setConfirmDelete(item)}
                                title="Xóa"
                              >
                                🗑️ Xóa
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}
        </>
      )}

      {/* Create / Edit Modal */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={isEditing ? '✏️ Chỉnh sửa Chỗ ở' : '➕ Thêm mới Chỗ ở'}
        footer={
          <>
            <button className="btn btn-ghost" onClick={() => setModalOpen(false)} disabled={submitting}>
              Hủy
            </button>
            <button className="btn btn-primary" onClick={handleSubmit} disabled={submitting} id="btn-modal-submit">
              {submitting ? 'Đang xử lý...' : isEditing ? 'Cập nhật' : 'Thêm mới'}
            </button>
          </>
        }
      >
        <form onSubmit={handleSubmit} id="form-cho-o">
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
            <div className="form-group">
              <label className="form-label">Mã chỗ ở *</label>
              <input
                className="form-input"
                value={formData.MaChoO}
                onChange={(e) => handleChange('MaChoO', e.target.value)}
                placeholder="VD: ACC001"
                disabled={isEditing}
                required
                id="field-ma-cho-o"
                style={isEditing ? { background: '#f3f4f6', cursor: 'not-allowed' } : {}}
              />
            </div>
            <div className="form-group">
              <label className="form-label">Tên chỗ ở *</label>
              <input
                className="form-input"
                value={formData.TenChoO}
                onChange={(e) => handleChange('TenChoO', e.target.value)}
                placeholder="VD: Grand Hotel Amsterdam"
                required
                id="field-ten-cho-o"
              />
            </div>
            <div className="form-group">
              <label className="form-label">Số nhà</label>
              <input
                className="form-input"
                value={formData.SoNha}
                onChange={(e) => handleChange('SoNha', e.target.value)}
                placeholder="VD: 123"
                id="field-so-nha"
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
                id="field-ten-duong"
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
                id="field-ma-buu-dien"
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
                id="field-thanh-pho"
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
                id="field-quoc-gia"
              />
            </div>
            <div className="form-group">
              <label className="form-label">Mã QTV</label>
              <input
                className="form-input"
                value={formData.MaQTV}
                onChange={(e) => handleChange('MaQTV', e.target.value)}
                placeholder="VD: ADM001"
                id="field-ma-qtv"
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
              id="field-mo-ta"
            />
          </div>

          {isEditing && (
            <div className="form-group" style={{ marginTop: '1rem' }}>
              <label className="form-label">Trạng thái xác nhận</label>
              <select
                className="form-input"
                value={formData.TrangThai}
                onChange={(e) => handleChange('TrangThai', e.target.value)}
                id="field-trang-thai"
              >
                <option value="Cho xac nhan">Chờ xác nhận</option>
                <option value="Da xac nhan">Đã xác nhận</option>
                <option value="Tu choi">Từ chối</option>
              </select>
            </div>
          )}
        </form>
      </Modal>

      {/* Confirm Approve Dialog */}
      {confirmApprove && (
        <div className="confirm-overlay" id="confirm-approve-overlay">
          <div className="confirm-dialog">
            <div className="confirm-icon">✅</div>
            <h3>Xác nhận duyệt chỗ ở?</h3>
            <p>
              Bạn có chắc chắn muốn duyệt <strong>"{confirmApprove.TenChoO}"</strong>?
              <br />
              <span style={{ color: 'var(--color-success)', fontWeight: 600 }}>
                Chỗ ở sẽ hiển thị cho tất cả người dùng sau khi duyệt.
              </span>
            </p>
            <div className="form-group" style={{ textAlign: 'left', marginTop: '1rem', marginBottom: '1.5rem' }}>
              <label className="form-label">Mã Quản Trị Viên của bạn *</label>
              <input 
                className="form-input" 
                placeholder="VD: ADM003" 
                value={adminIdInput}
                onChange={(e) => setAdminIdInput(e.target.value)}
                required
              />
            </div>
            <div className="confirm-actions">
              <button
                className="btn btn-ghost"
                onClick={() => setConfirmApprove(null)}
                disabled={submitting}
              >
                Hủy bỏ
              </button>
              <button
                className="btn btn-primary"
                onClick={() => handleApprove(confirmApprove)}
                disabled={submitting}
                id="btn-confirm-approve"
              >
                {submitting ? 'Đang duyệt...' : '✅ Duyệt'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Confirm Reject Dialog */}
      {confirmReject && (
        <div className="confirm-overlay" id="confirm-reject-overlay">
          <div className="confirm-dialog">
            <div className="confirm-icon" style={{ background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444' }}>✗</div>
            <h3>Từ chối chỗ ở?</h3>
            <p>
              Bạn đang từ chối <strong>"{confirmReject.TenChoO}"</strong>.
            </p>
            <div className="form-group" style={{ textAlign: 'left', marginTop: '1rem', marginBottom: '1.5rem' }}>
              <label className="form-label">Mã Quản Trị Viên của bạn *</label>
              <input 
                className="form-input" 
                placeholder="VD: ADM003" 
                value={adminIdInput}
                onChange={(e) => setAdminIdInput(e.target.value)}
                required
              />
            </div>
            <div className="confirm-actions">
              <button
                className="btn btn-ghost"
                onClick={() => setConfirmReject(null)}
                disabled={submitting}
              >
                Hủy bỏ
              </button>
              <button
                className="btn btn-danger"
                onClick={() => handleReject(confirmReject)}
                disabled={submitting}
              >
                {submitting ? 'Đang xử lý...' : 'Từ chối'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Confirm Delete Dialog */}
      {confirmDelete && (
        <div className="confirm-overlay" id="confirm-delete-overlay">
          <div className="confirm-dialog">
            <div className="confirm-icon">⚠️</div>
            <h3>Xác nhận xóa chỗ ở?</h3>
            <p>
              Bạn có chắc chắn muốn xóa <strong>"{confirmDelete.TenChoO}"</strong> (Mã: {confirmDelete.MaChoO})?
              <br />
              <span style={{ color: 'var(--color-error)', fontWeight: 600 }}>
                Hành động này không thể hoàn tác.
              </span>
            </p>
            <div className="confirm-actions">
              <button
                className="btn btn-ghost"
                onClick={() => setConfirmDelete(null)}
                disabled={submitting}
              >
                Hủy bỏ
              </button>
              <button
                className="btn btn-danger"
                onClick={handleDelete}
                disabled={submitting}
                id="btn-confirm-delete"
              >
                {submitting ? 'Đang xóa...' : '🗑️ Xóa'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default AdminPage
