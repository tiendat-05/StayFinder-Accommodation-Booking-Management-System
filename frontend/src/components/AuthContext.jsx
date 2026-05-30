import { createContext, useContext, useState, useCallback } from 'react'

const AuthContext = createContext(null)

/**
 * Role-based auth context (frontend-only, no real authentication).
 * Roles: 'user' (Người dùng / Chủ sở hữu) | 'admin' (Quản trị viên) | null (chưa chọn)
 */
export function AuthProvider({ children }) {
  const [role, setRole] = useState(() => {
    return localStorage.getItem('stayfinder_role') || null
  })

  const login = useCallback((selectedRole) => {
    setRole(selectedRole)
    localStorage.setItem('stayfinder_role', selectedRole)
  }, [])

  const logout = useCallback(() => {
    setRole(null)
    localStorage.removeItem('stayfinder_role')
  }, [])

  return (
    <AuthContext.Provider value={{ role, login, logout, isAdmin: role === 'admin', isUser: role === 'user' }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within <AuthProvider>')
  return ctx
}
