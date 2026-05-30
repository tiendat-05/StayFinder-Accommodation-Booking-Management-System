function LoadingSpinner({ text = 'Đang tải dữ liệu...' }) {
  return (
    <div className="loading-container" id="loading-spinner">
      <div className="spinner"></div>
      <p style={{ fontWeight: 500 }}>{text}</p>
    </div>
  )
}

export default LoadingSpinner
