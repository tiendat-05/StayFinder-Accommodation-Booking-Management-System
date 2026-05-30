import { useAuth } from '../components/AuthContext'

function LoginPage() {
  const { login } = useAuth()

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'linear-gradient(135deg, #00224f 0%, #003580 40%, #0071c2 100%)',
      position: 'relative',
      overflow: 'hidden',
    }}>
      {/* Background decoration */}
      <div style={{
        position: 'absolute',
        inset: 0,
        background: `
          radial-gradient(circle at 20% 80%, rgba(254, 187, 2, 0.08) 0%, transparent 40%),
          radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.05) 0%, transparent 50%)
        `,
        pointerEvents: 'none',
      }} />

      <div className="animate-scale-in" style={{
        position: 'relative',
        zIndex: 1,
        textAlign: 'center',
        maxWidth: '600px',
        width: '90%',
      }}>
        {/* Logo */}
        <div style={{ marginBottom: '2rem' }}>
          <span style={{ fontSize: '3.5rem' }}>🏨</span>
          <h1 style={{
            color: 'white',
            fontSize: '2.5rem',
            fontWeight: 800,
            letterSpacing: '-1px',
            marginTop: '0.5rem',
          }}>
            StayFinder
          </h1>
          <p style={{
            color: 'rgba(255, 255, 255, 0.7)',
            fontSize: '1rem',
            marginTop: '0.5rem',
          }}>
            Hệ thống Quản lý Đặt phòng — BTL2 · Hệ CSDL
          </p>
        </div>

        {/* Role selection */}
        <p style={{
          color: 'rgba(255, 255, 255, 0.85)',
          fontSize: '1.125rem',
          fontWeight: 500,
          marginBottom: '1.5rem',
        }}>
          Chọn vai trò để đăng nhập
        </p>

        <div style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: '1.25rem',
        }}>
          {/* User / Owner card */}
          <button
            onClick={() => login('user')}
            id="btn-login-user"
            style={{
              background: 'rgba(255, 255, 255, 0.1)',
              backdropFilter: 'blur(12px)',
              border: '1.5px solid rgba(255, 255, 255, 0.2)',
              borderRadius: 'var(--radius-lg)',
              padding: '2rem 1.5rem',
              cursor: 'pointer',
              transition: 'all 0.25s ease',
              color: 'white',
              textAlign: 'center',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = 'rgba(255, 255, 255, 0.18)'
              e.currentTarget.style.transform = 'translateY(-4px)'
              e.currentTarget.style.boxShadow = '0 12px 32px rgba(0, 0, 0, 0.3)'
              e.currentTarget.style.borderColor = 'var(--color-accent)'
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'rgba(255, 255, 255, 0.1)'
              e.currentTarget.style.transform = 'translateY(0)'
              e.currentTarget.style.boxShadow = 'none'
              e.currentTarget.style.borderColor = 'rgba(255, 255, 255, 0.2)'
            }}
          >
            <div style={{ fontSize: '3rem', marginBottom: '0.75rem' }}>👤</div>
            <h2 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '0.5rem' }}>
              Người dùng
            </h2>
            <p style={{ fontSize: '0.8125rem', opacity: 0.75, lineHeight: 1.5 }}>
              Tìm kiếm chỗ ở<br />Đăng ký chỗ ở mới
            </p>
          </button>

          {/* Admin card */}
          <button
            onClick={() => login('admin')}
            id="btn-login-admin"
            style={{
              background: 'rgba(255, 255, 255, 0.1)',
              backdropFilter: 'blur(12px)',
              border: '1.5px solid rgba(255, 255, 255, 0.2)',
              borderRadius: 'var(--radius-lg)',
              padding: '2rem 1.5rem',
              cursor: 'pointer',
              transition: 'all 0.25s ease',
              color: 'white',
              textAlign: 'center',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = 'rgba(255, 255, 255, 0.18)'
              e.currentTarget.style.transform = 'translateY(-4px)'
              e.currentTarget.style.boxShadow = '0 12px 32px rgba(0, 0, 0, 0.3)'
              e.currentTarget.style.borderColor = 'var(--color-accent)'
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'rgba(255, 255, 255, 0.1)'
              e.currentTarget.style.transform = 'translateY(0)'
              e.currentTarget.style.boxShadow = 'none'
              e.currentTarget.style.borderColor = 'rgba(255, 255, 255, 0.2)'
            }}
          >
            <div style={{ fontSize: '3rem', marginBottom: '0.75rem' }}>🛡️</div>
            <h2 style={{ fontSize: '1.25rem', fontWeight: 700, marginBottom: '0.5rem' }}>
              Quản trị viên
            </h2>
            <p style={{ fontSize: '0.8125rem', opacity: 0.75, lineHeight: 1.5 }}>
              Duyệt chỗ ở · Quản lý<br />Thống kê doanh thu
            </p>
          </button>
        </div>
      </div>
    </div>
  )
}

export default LoginPage
