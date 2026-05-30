# Tài liệu Yêu cầu Sản phẩm (PRD) - Hệ thống Quản lý Đặt phòng

## 1. Mục đích dịch vụ (Why)
* **Về mặt thực tiễn:** Xây dựng một nền tảng thương mại điện tử làm cầu nối trung gian, kết nối đơn vị cung cấp chỗ nghỉ và khách hàng. Nền tảng cung cấp giải pháp tìm kiếm và quản lý thông tin các loại hình lưu trú đa dạng (khách sạn, căn hộ, resort, villa).
* **Về mặt học thuật:** Ứng dụng thành thạo và trực quan hóa các kiến thức Hệ cơ sở dữ liệu vào một hệ thống phần mềm thực tế. Đảm bảo luồng dữ liệu nhất quán, hiện thực hóa các ràng buộc ngữ nghĩa nghiệp vụ thông qua cơ chế của hệ quản trị CSDL (Stored Procedure, Trigger, Function) và xử lý lỗi thông minh từ Backend truyền lên giao diện.

## 2. Người dùng mục tiêu (Who)
Hệ thống được thiết kế tích hợp để phục vụ hai nhóm đối tượng chính trên cùng một nền tảng:
* **Khách hàng (Customer):** Người dùng có nhu cầu tìm kiếm, lọc và xem thông tin các chỗ ở phù hợp với tiêu chí cá nhân.
* **Quản trị viên / Chủ sở hữu (Admin/Owner):** Người dùng có quyền truy cập khu vực quản trị để kiểm duyệt, thêm mới, chỉnh sửa thông tin chỗ ở, và trích xuất các báo cáo doanh thu kinh doanh.

## 3. Tính năng cốt lõi (What)
Bám sát yêu cầu nghiệp vụ và tiêu chí bài tập lớn, hệ thống tập trung vào 3 nhóm tính năng:
* **Tìm kiếm & Lọc (Search):** Khách hàng có thể tìm kiếm nơi lưu trú theo thành phố và tên chỗ ở. Dữ liệu được gọi trực tiếp qua Procedure `sp_SearchChoO`.
* **Quản lý Chỗ Ở (CRUD):** Giao diện Admin cho phép Thêm mới, Cập nhật thông tin, và Xóa chỗ ở (kiểm tra điều kiện không có đơn đặt phòng đang xử lý).
* **Thống kê Báo cáo (Statistics):** Giao diện Dashboard cho Admin hiển thị báo cáo tổng doanh thu theo thành phố hoặc doanh thu từng chỗ ở, sử dụng Function/Group By từ CSDL.

## 4. Bố cục màn hình (Pages)
Hệ thống được chia thành 3 phân hệ màn hình chính:
1. **Trang chủ Tìm kiếm (Customer View):**
   * Thanh tìm kiếm nổi bật (Thành phố, Tên).
   * Danh sách kết quả trả về hiển thị dưới dạng thẻ (Card) trực quan.
2. **Trang Quản lý Chỗ ở (Admin View):**
   * Bảng (Data Table) hiển thị danh sách chỗ ở.
   * Các nút hành động (Action buttons): Thêm mới (mở Modal/Form), Chỉnh sửa, Xóa.
3. **Trang Báo cáo Thống kê (Admin View):**
   * Hiển thị bảng số liệu hoặc biểu đồ tóm tắt doanh thu theo khu vực.

## 5. Yêu cầu thiết kế (Design)
* **Phong cách (Vibe):** Hiện đại, tối giản, lấy cảm hứng từ Booking.com. Tone màu chủ đạo là xanh dương, ưu tiên trải nghiệm người dùng (UX) rõ ràng.
* **Thư viện UI/CSS:** Sử dụng **Tailwind CSS** để tối ưu hóa thời gian phát triển và đảm bảo tính nhất quán của giao diện.
* **Trải nghiệm:** Các thao tác xử lý dữ liệu (Thêm/Sửa/Xóa) phải có phản hồi trực quan (Toast notification hoặc Alert) thông báo thành công hoặc hiển thị chính xác lỗi trả về từ Database.

## 6. Tiêu chí thành công (Success Criteria)
* **Kết nối DB:** Ứng dụng Frontend kết nối mượt mà với MySQL thông qua Backend FastAPI.
* **Xử lý lỗi:** Bắt và hiển thị được các thông báo lỗi có ý nghĩa từ Database (nhờ cơ chế `SIGNAL SQLSTATE` trong Stored Procedure).
* **Tính toàn vẹn:** Hệ thống không vi phạm các ràng buộc ngữ nghĩa đã định nghĩa trong sơ đồ EERD.
* **Triển khai (Deployment):** Giao diện Frontend được deploy thành công và chạy ổn định trên nền tảng Vercel.

## 7. Yêu cầu kỹ thuật (Tech Specs)
* **Cơ sở dữ liệu:** MySQL Server (Sử dụng Stored Procedures, Triggers, Functions để xử lý logic).
* **Backend:** Python với framework FastAPI, giao tiếp CSDL qua thư viện `mysql-connector-python`.
* **Frontend:** ReactJS (khởi tạo bằng Vite) kết hợp Tailwind CSS.
* **Hosting/Deployment:** Deploy Frontend lên **Vercel** để vận hành web động. (Backend và DB linh hoạt chạy local để báo cáo hoặc host trên các nền tảng tương đương nếu cần).