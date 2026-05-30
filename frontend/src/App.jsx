import { Routes, Route, Navigate } from 'react-router-dom'
import Navbar from './components/Navbar'
import { ToastProvider } from './components/Toast'
import { AuthProvider, useAuth } from './components/AuthContext'
import LoginPage from './pages/LoginPage'
import SearchPage from './pages/SearchPage'
import AdminPage from './pages/AdminPage'
import StatsPage from './pages/StatsPage'

function AppRoutes() {
  const { role, isAdmin } = useAuth()

  // Chưa chọn role → hiển thị trang đăng nhập
  if (!role) {
    return <LoginPage />
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <Navbar />
      <main style={{ flex: 1 }}>
        <Routes>
          {/* Trang tìm kiếm — cả User và Admin đều thấy */}
          <Route path="/" element={<SearchPage />} />

          {/* Trang quản lý — chỉ Admin */}
          <Route
            path="/admin"
            element={isAdmin ? <AdminPage /> : <Navigate to="/" replace />}
          />

          {/* Trang thống kê — chỉ Admin */}
          <Route
            path="/stats"
            element={isAdmin ? <StatsPage /> : <Navigate to="/" replace />}
          />

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
      <footer style={{
        textAlign: 'center',
        padding: '1.5rem',
        color: 'var(--color-text-secondary)',
        fontSize: '0.8125rem',
        borderTop: '1px solid var(--color-border)',
        background: 'white',
      }}>
        © 2026 StayFinder — Bài tập lớn 2 · Hệ Cơ sở Dữ liệu · HK252
      </footer>
    </div>
  )
}

function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <AppRoutes />
      </ToastProvider>
    </AuthProvider>
  )
}

export default App
