import { NavLink } from 'react-router-dom'
import { useAuth } from './AuthContext'

function Navbar() {
  const { role, isAdmin, logout } = useAuth()

  const roleLabel = isAdmin ? '🛡️ Quản trị viên' : '👤 Người dùng'

  return (
    <nav className="navbar" id="main-navbar">
      <NavLink to="/" className="navbar-brand">
        <span>🏨</span>
        <span>StayFinder</span>
      </NavLink>

      <div className="navbar-links">
        <NavLink
          to="/"
          end
          className={({ isActive }) => `navbar-link ${isActive ? 'active' : ''}`}
          id="nav-search"
        >
          🔍 Tìm kiếm
        </NavLink>

        {isAdmin && (
          <>
            <NavLink
              to="/admin"
              className={({ isActive }) => `navbar-link ${isActive ? 'active' : ''}`}
              id="nav-admin"
            >
              ⚙️ Quản lý
            </NavLink>
            <NavLink
              to="/stats"
              className={({ isActive }) => `navbar-link ${isActive ? 'active' : ''}`}
              id="nav-stats"
            >
              📊 Thống kê
            </NavLink>
          </>
        )}

        {/* Role indicator + logout */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.75rem',
          marginLeft: '0.75rem',
          paddingLeft: '0.75rem',
          borderLeft: '1px solid rgba(255,255,255,0.2)',
        }}>
          <span style={{
            color: 'rgba(255,255,255,0.7)',
            fontSize: '0.8125rem',
            fontWeight: 500,
          }}>
            {roleLabel}
          </span>
          <button
            onClick={logout}
            className="btn btn-sm"
            id="btn-logout"
            style={{
              background: 'rgba(255,255,255,0.1)',
              color: 'rgba(255,255,255,0.85)',
              border: '1px solid rgba(255,255,255,0.2)',
              fontSize: '0.75rem',
              padding: '0.25rem 0.625rem',
            }}
          >
            Đăng xuất
          </button>
        </div>
      </div>
    </nav>
  )
}

export default Navbar
