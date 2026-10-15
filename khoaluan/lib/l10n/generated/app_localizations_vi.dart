// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'My Furniture Store';

  @override
  String get navProducts => 'SẢN PHẨM';

  @override
  String get navRoomDesign => 'PHỐI CẢNH';

  @override
  String get navAbout => 'GIỚI THIỆU';

  @override
  String get navContact => 'LIÊN HỆ';

  @override
  String get accountInfo => 'THÔNG TIN TÀI KHOẢN';

  @override
  String get yourAccount => 'Tài khoản của bạn';

  @override
  String get profileMenuTitle => 'Tài khoản';

  @override
  String get addressList => 'Danh sách địa chỉ';

  @override
  String get deliveryHistory => 'Lịch sử giao hàng';

  @override
  String get adminPage => 'Quay về trang admin';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get loggedOut => 'Đã đăng xuất';

  @override
  String get accountOf => 'Tài khoản của';

  @override
  String get loginRegister => 'Đăng nhập / Đăng ký';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get cart => 'Giỏ hàng';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String helloUser(String name) {
    return 'Xin chào, $name';
  }

  @override
  String get footerDescription =>
      'Từ thiết kế, sản xuất đến vận chuyển và hậu mãi, chúng tôi cung cấp giải pháp nội thất trọn gói tại Việt Nam.';

  @override
  String get exploreMore => 'KHÁM PHÁ THÊM';

  @override
  String get home => 'TRANG CHỦ';

  @override
  String get contactUs => 'LIÊN HỆ VỚI CHÚNG TÔI';

  @override
  String get companyAddress =>
      'Đường P, Tổ 4, xã Sông Vĩnh\nPhường Tân Phước, thị xã Phú Mỹ, Bà Rịa\nTỉnh Vũng Tàu';

  @override
  String homeLoadError(Object error) {
    return 'Lỗi: $error';
  }

  @override
  String get noProducts => 'Không có sản phẩm nào.';

  @override
  String get categories => 'Danh mục';

  @override
  String get bestSellingProducts => 'Sản phẩm bán chạy';

  @override
  String get viewMore => 'Xem thêm';

  @override
  String soldCount(int count) {
    return 'Đã bán $count';
  }

  @override
  String get loginTitle => 'Đăng nhập hoặc đăng ký';

  @override
  String get loginIntro =>
      'Nhập email để đăng nhập bằng mật khẩu hoặc đăng ký nhanh. Khi đăng ký, hệ thống sẽ gửi liên kết để bạn tự thiết lập mật khẩu.';

  @override
  String get emailAddress => 'ĐỊA CHỈ EMAIL';

  @override
  String get emailField => 'Địa chỉ email';

  @override
  String get loginWithPassword => 'ĐĂNG NHẬP BẰNG MẬT KHẨU';

  @override
  String get quickRegister => 'ĐĂNG KÝ NHANH';

  @override
  String get secureLinkHint =>
      'Không có mật khẩu được gửi qua email. Bạn tự đặt mật khẩu qua liên kết bảo mật.';

  @override
  String get backHome => 'Quay về trang chủ';

  @override
  String get invalidEmail => 'Vui lòng nhập một địa chỉ email hợp lệ.';

  @override
  String get checkEmailTitle => 'Kiểm tra email của bạn';

  @override
  String get quickRegisterDialogBody =>
      'Hệ thống đã gửi liên kết thiết lập mật khẩu đến email của bạn.\n\nLiên kết chỉ dùng được một lần và hết hạn sau 30 phút. Nếu chưa thấy email, hãy kiểm tra cả thư mục Spam/Rác.';

  @override
  String get understood => 'ĐÃ HIỂU';

  @override
  String get passwordLoginTitle => 'Đăng nhập bằng mật khẩu';

  @override
  String get passwordLoginWelcome =>
      'Chào mừng bạn trở lại My Furniture Store. Vui lòng nhập email hoặc tên đăng nhập và mật khẩu để truy cập tài khoản.';

  @override
  String get emailOrUsername => 'EMAIL HOẶC TÊN ĐĂNG NHẬP';

  @override
  String get emailOrUsernameField => 'Email hoặc tên đăng nhập';

  @override
  String get emailOrUsernameHint => 'Nhập email hoặc tên tài khoản...';

  @override
  String get password => 'MẬT KHẨU';

  @override
  String get passwordField => 'Mật khẩu';

  @override
  String get passwordHint => 'Nhập mật khẩu của bạn...';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get login => 'ĐĂNG NHẬP';

  @override
  String loginSuccess(String name) {
    return 'Đăng nhập thành công! Xin chào $name';
  }

  @override
  String get incompleteLogin =>
      'Vui lòng kiểm tra và điền đầy đủ thông tin đăng nhập!';

  @override
  String requiredField(String field) {
    return 'Vui lòng nhập $field!';
  }

  @override
  String minLengthField(String field, int count) {
    return '$field phải có ít nhất $count ký tự!';
  }

  @override
  String get backToLoginOptions => 'Quay lại lựa chọn đăng nhập';

  @override
  String get allProductsTitle => 'Tất cả sản phẩm My Furniture Home';

  @override
  String get sortFeatured => 'Sản phẩm nổi bật';

  @override
  String get sortNewest => 'Mới nhất';

  @override
  String get sortPriceLowHigh => 'Giá: Thấp đến Cao';

  @override
  String get sortPriceHighLow => 'Giá: Cao đến Thấp';

  @override
  String get category => 'Danh mục';

  @override
  String get colors => 'Màu sắc';

  @override
  String get sizes => 'Kích thước';

  @override
  String get filters => 'BỘ LỌC';

  @override
  String filtersActive(int count) {
    return 'BỘ LỌC ($count)';
  }

  @override
  String get detailedFilters => 'Bộ lọc chi tiết';

  @override
  String get closeFilters => 'Đóng bộ lọc';

  @override
  String get priceRange => 'Khoảng giá';

  @override
  String get clearFilters => 'XÓA BỘ LỌC';

  @override
  String get productPrice => 'GIÁ SẢN PHẨM';

  @override
  String abovePrice(String price) {
    return 'Trên $price';
  }

  @override
  String belowPrice(String price) {
    return 'Dưới $price';
  }

  @override
  String get allSubcategories => 'Tất cả danh mục con';

  @override
  String get allCategories => 'Tất cả danh mục';

  @override
  String get allPriceRanges => 'Tất cả mức giá';

  @override
  String get allColors => 'Tất cả màu sắc';

  @override
  String get allSizes => 'Tất cả kích thước';

  @override
  String get noMatchingProducts => 'Không tìm thấy sản phẩm phù hợp.';

  @override
  String get productNotFound => 'Không tìm thấy sản phẩm!';

  @override
  String inStock(int count) {
    return 'Còn hàng: $count sản phẩm';
  }

  @override
  String get temporarilyOutOfStock => 'Hết hàng (Tạm thời hết)';

  @override
  String get productDescription => 'Mô tả sản phẩm';

  @override
  String get noProductDescription => 'Chưa có mô tả cho sản phẩm này.';

  @override
  String get dimensionsLabel => 'Kích thước:';

  @override
  String get materialLabel => 'Chất liệu:';

  @override
  String get outOfStock => 'HẾT HÀNG';

  @override
  String get addToCart => 'THÊM VÀO GIỎ HÀNG';

  @override
  String get buyNow => 'MUA NGAY';

  @override
  String get tryInYourRoom => 'THỬ TRONG KHÔNG GIAN CỦA BẠN';

  @override
  String get frequentlyBoughtTogether => 'THƯỜNG ĐƯỢC MUA CÙNG';

  @override
  String get relatedProducts => 'SẢN PHẨM LIÊN QUAN';

  @override
  String get productReviews => 'ĐÁNH GIÁ SẢN PHẨM';

  @override
  String averageRating(int count) {
    return 'ĐÁNH GIÁ TRUNG BÌNH\n($count đánh giá)';
  }

  @override
  String reviewDistribution(String percent, int count) {
    return '$percent% | $count đánh giá';
  }

  @override
  String get reviewDeliveredOnly =>
      'Bạn chỉ có thể đánh giá sản phẩm trong đơn hàng đã thanh toán và đã giao.';

  @override
  String get viewOrderHistory => 'XEM LỊCH SỬ ĐƠN HÀNG';

  @override
  String get all => 'Tất cả';

  @override
  String get noMatchingReviews => 'Chưa có đánh giá nào phù hợp với bộ lọc.';

  @override
  String get noWrittenReview => 'Không có ý kiến viết bằng chữ.';

  @override
  String get storeReply => 'Phản hồi từ cửa hàng';

  @override
  String cartItemCount(int count) {
    return 'Giỏ hàng ($count)';
  }

  @override
  String get yourCart => 'Giỏ hàng của bạn';

  @override
  String get remove => 'Xóa';

  @override
  String get emptyCart => 'Giỏ hàng của bạn đang trống';

  @override
  String get continueShopping => 'TIẾP TỤC MUA SẮM';

  @override
  String get orderInformation => 'Thông tin đơn hàng';

  @override
  String get total => 'Tổng tiền:';

  @override
  String get checkout => 'THANH TOÁN';

  @override
  String get continueBuying => 'Tiếp tục mua hàng';

  @override
  String get voucherWallet => 'Kho Voucher Ưu Đãi';

  @override
  String currentOrder(String amount) {
    return 'Đơn hàng hiện tại: $amount';
  }

  @override
  String get noAvailableVouchers =>
      'Hiện không có mã ưu đãi nào khả dụng trong kho của bạn.';

  @override
  String discountPercent(String value) {
    return 'GIẢM $value%';
  }

  @override
  String discountAmount(String amount) {
    return 'GIẢM $amount';
  }

  @override
  String expiresOn(String date) {
    return 'HSD: $date';
  }

  @override
  String voucherUsage(int used, int limit) {
    return 'Đã dùng: $used/$limit';
  }

  @override
  String spendMoreToUse(String amount) {
    return 'Mua thêm $amount để dùng';
  }

  @override
  String get apply => 'ÁP DỤNG';

  @override
  String get morningSlot => 'Sáng (08:00 - 12:00)';

  @override
  String get afternoonSlot => 'Chiều (13:00 - 17:00)';

  @override
  String get eveningSlot => 'Tối (18:00 - 20:00)';

  @override
  String get enterOrSelectVoucher => 'Vui lòng nhập hoặc chọn mã khuyến mãi.';

  @override
  String get loginBeforeOrdering => 'Vui lòng đăng nhập trước khi đặt hàng.';

  @override
  String get checkCheckoutInformation =>
      'Vui lòng kiểm tra lại họ tên, số điện thoại hoặc email hợp lệ trước khi đặt hàng!';

  @override
  String get cartIsEmpty => 'Giỏ hàng của bạn đang trống!';

  @override
  String get paymentMaintenance =>
      'MoMo và QR đang được bảo trì. Vui lòng chọn chuyển khoản, POS hoặc VNPay.';

  @override
  String get missingVnPayUrl =>
      'Backend không trả về đường dẫn thanh toán VNPay.';

  @override
  String get cannotOpenVnPay => 'Không thể mở cổng thanh toán VNPay.';

  @override
  String createOrderError(Object error) {
    return 'Lỗi tạo đơn hàng: $error';
  }

  @override
  String get vnPaySuccess => 'Thanh toán VNPay thành công';

  @override
  String get vnPayFailed => 'Thanh toán VNPay thất bại';

  @override
  String paidOrderMessage(String orderId) {
    return 'Đơn hàng #$orderId đã được thanh toán và đang chờ cửa hàng xác nhận.';
  }

  @override
  String failedOrderMessage(String orderId) {
    return 'Giao dịch không thành công hoặc đã bị hủy. Đơn hàng #$orderId đã được hủy và tồn kho được hoàn lại.';
  }

  @override
  String get orderRecorded => 'Đã ghi nhận đơn hàng!';

  @override
  String get orderSuccess => 'Đặt hàng thành công!';

  @override
  String get bankTransferInstructions =>
      'Đơn hàng của bạn đã được ghi nhận thành công.\nVui lòng thực hiện chuyển khoản ngân hàng theo thông tin hiển thị để đơn hàng được duyệt giao sớm nhất.';

  @override
  String orderThankYou(String name) {
    return 'Cảm ơn bạn $name đã đặt hàng.\nĐơn hàng của bạn đã hoàn tất thanh toán (POS) và đang được xử lý.';
  }

  @override
  String get loginBenefit =>
      'Đăng nhập để mua hàng tiện lợi và nhận nhiều ưu đãi hơn nữa';

  @override
  String get loginAction => 'Đăng nhập';

  @override
  String get shippingInformation => 'Thông tin giao hàng';

  @override
  String get enterFullName => 'Nhập họ và tên (*)';

  @override
  String get fullName => 'Họ tên';

  @override
  String get enterPhone => 'Nhập số điện thoại (*)';

  @override
  String get phoneNumber => 'Số điện thoại';

  @override
  String get invalidPhone =>
      'Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0!';

  @override
  String get enterOrderEmail => 'Nhập email (* để nhận thông báo đặt hàng)';

  @override
  String get country => 'Quốc gia';

  @override
  String get vietnam => 'Việt Nam';

  @override
  String get streetAddress => 'Địa chỉ, tên đường (*)';

  @override
  String get address => 'Địa chỉ';

  @override
  String get regionAutoFill => 'Tỉnh/TP, Quận/Huyện, Phường/Xã (Tự động điền)';

  @override
  String get selectDeliveryArea => 'Vui lòng chọn khu vực giao hàng';

  @override
  String get deliveryAssemblyService => 'Dịch vụ Giao hàng & Lắp đặt tại nhà';

  @override
  String deliveryEstimate(String distance, String fee) {
    return 'Ước tính khoảng cách giao hàng: $distance km\nPhí vận chuyển theo số km: $fee';
  }

  @override
  String get selectDeliveryTime => 'Chọn khung giờ nhận hàng trong ngày:';

  @override
  String get assemblySupport => 'Yêu cầu thợ hỗ trợ lắp đặt nội thất tận nhà';

  @override
  String fixedAssemblyFee(String fee) {
    return 'Phí lắp đặt dịch vụ cố định: +$fee';
  }

  @override
  String get paymentMethod => 'Phương thức thanh toán';

  @override
  String get bankTransferPayment => 'Thanh toán chuyển khoản qua ngân hàng';

  @override
  String get accountName =>
      'Tên tài khoản: Công ty Cổ phần Hợp Tác Kinh Tế Và Xuất Nhập Khẩu Savimex';

  @override
  String get accountNumber => 'Số tài khoản: 0071001303667';

  @override
  String get bankName => 'Ngân hàng: Vietcombank - CN HCM';

  @override
  String get transferContent => 'Nội dung chuyển khoản: Tên + SĐT đặt hàng';

  @override
  String get posPayment => 'Thanh toán quẹt thẻ khi giao hàng (POS)';

  @override
  String get vnPayPayment =>
      'Thanh toán online qua cổng VNPay (ATM/Visa/MasterCard/JCB/QR Pay trên Internet Banking)';

  @override
  String get momoPayment => 'Thanh toán online qua ví MoMo';

  @override
  String get qrTransfer => 'Chuyển khoản qua QR - VCB';

  @override
  String get orderNote => 'Ghi chú đơn hàng';

  @override
  String get orderNoteHint => 'Nhập ghi chú cho đơn hàng của bạn...';

  @override
  String get emptyCartShort => 'Giỏ hàng trống';

  @override
  String get promotionApplied => 'Khuyến mãi áp dụng:';

  @override
  String get promotionCode => 'Mã khuyến mãi';

  @override
  String get openVoucherWallet => 'Mở Kho Voucher & Chọn Mã Ưu Đãi';

  @override
  String get enterPromotionCode => 'Nhập mã khuyến mãi';

  @override
  String get orderSummary => 'Tóm tắt đơn hàng';

  @override
  String get subtotal => 'Tổng tiền hàng';

  @override
  String shippingFeeDistance(String distance) {
    return 'Phí vận chuyển$distance:';
  }

  @override
  String get assemblyServiceFee => 'Phí dịch vụ lắp đặt:';

  @override
  String get discount => 'Giảm giá';

  @override
  String get totalPayment => 'Tổng thanh toán';

  @override
  String get placeOrder => 'Đặt hàng';

  @override
  String get account => 'TÀI KHOẢN';

  @override
  String get accountDetails => 'THÔNG TIN TÀI KHOẢN';

  @override
  String get profileInformation => 'Thông tin tài khoản';

  @override
  String get myVouchers => 'Voucher của tôi (Kho ưu đãi)';

  @override
  String get helpCenter => 'Trung tâm Hỏi đáp & Trợ giúp';

  @override
  String get lastName => 'Họ và tên đệm';

  @override
  String get firstName => 'Tên';

  @override
  String get gender => 'Giới tính';

  @override
  String get female => 'Nữ';

  @override
  String get male => 'Nam';

  @override
  String get dateOfBirth => 'Ngày sinh';

  @override
  String get update => 'CẬP NHẬT';

  @override
  String get profileUpdated => 'Cập nhật thông tin thành công!';

  @override
  String get loginAgain => 'Vui lòng đăng nhập lại.';

  @override
  String get addressBook => 'DANH SÁCH ĐỊA CHỈ';

  @override
  String get addAddress => 'Thêm địa chỉ';

  @override
  String get editAddress => 'Sửa địa chỉ';

  @override
  String get cannotLoadAddresses => 'Không thể tải danh sách địa chỉ.';

  @override
  String get noAddresses => 'Hiện tại chưa có địa chỉ nào được thêm.';

  @override
  String get defaultAddress => 'Mặc định';

  @override
  String get recipient => 'Người nhận';

  @override
  String get fullAddress => 'Địa chỉ đầy đủ';

  @override
  String get addressLabel => 'Nhãn địa chỉ';

  @override
  String get addressLabelHome => 'Nhà';

  @override
  String get addressLabelCompany => 'Công ty';

  @override
  String get addressLabelOther => 'Khác';

  @override
  String get addressSearchHint => 'Nhập ít nhất 3 ký tự để tìm địa chỉ';

  @override
  String get makeDefault => 'Đặt làm mặc định';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get loginToViewOrders =>
      'Vui lòng đăng nhập để xem lịch sử giao hàng.';

  @override
  String get deliveryHistoryTitle => 'LỊCH SỬ GIAO HÀNG';

  @override
  String get awaitingPayment => 'Chờ thanh toán';

  @override
  String get awaitingConfirmation => 'Chờ xác nhận';

  @override
  String get awaitingDelivery => 'Chờ giao hàng';

  @override
  String get shipping => 'Đang giao hàng';

  @override
  String get delivered => 'Đã giao';

  @override
  String get cancelled => 'Đã hủy';

  @override
  String get returnedRefunded => 'Trả hàng/Hoàn tiền';

  @override
  String get returned => 'Trả hàng';

  @override
  String get paid => 'Đã thanh toán';

  @override
  String get noOrdersForStatus =>
      'Không tìm thấy đơn hàng nào ở trạng thái này.';

  @override
  String loadOrdersError(Object error) {
    return 'Lỗi tải đơn hàng: $error';
  }

  @override
  String orderCode(String code) {
    return 'Mã đơn hàng: $code';
  }

  @override
  String orderDate(String date) {
    return 'Ngày đặt: $date';
  }

  @override
  String variantDetails(String color, String size) {
    return 'Biến thể: $color / $size';
  }

  @override
  String quantity(int count) {
    return 'Số lượng: $count';
  }

  @override
  String get reviewed => 'Đã đánh giá';

  @override
  String get review => 'Đánh giá';

  @override
  String paymentLabel(String method) {
    return 'Thanh toán: $method';
  }

  @override
  String get totalAmount => 'Tổng tiền:';

  @override
  String reviewProductTitle(String product) {
    return 'Đánh giá: $product';
  }

  @override
  String get verifiedPurchaseDelivered =>
      'Sản phẩm đã được xác nhận thanh toán và giao thành công.';

  @override
  String get satisfactionLevel => 'Mức độ hài lòng';

  @override
  String get optionalComment => 'Nhận xét (không bắt buộc)';

  @override
  String get reviewHint => 'Chia sẻ trải nghiệm của bạn về sản phẩm...';

  @override
  String get reviewSuccess => 'Đánh giá thành công.';

  @override
  String get submitReview => 'Gửi đánh giá';

  @override
  String voucherCopiedMessage(String code) {
    return 'Đã sao chép mã ưu đãi [$code] và lưu vào bộ nhớ!';
  }

  @override
  String get allAvailableVouchers => '🌟 Tất cả khả dụng';

  @override
  String get expiringSoonVouchers => '🔥 Sắp hết hạn (< 7 ngày)';

  @override
  String get newVouchers => '✨ Mới phát hành';

  @override
  String get myVoucherWalletTitle => 'VOUCHER CỦA TÔI / KHO ƯU ĐÃI';

  @override
  String get voucherWalletDescription =>
      'Quản lý, sưu tầm và sử dụng các mã khuyến mãi dành riêng cho đơn hàng nội thất của bạn.';

  @override
  String get noExpiringVouchers =>
      'Bạn không có mã giảm giá nào sắp hết hạn trong 7 ngày tới.';

  @override
  String get noNewVouchers =>
      'Hiện không có mã giảm giá nào mới phát hành trong tuần này.';

  @override
  String get discountBadge => 'GIẢM GIÁ';

  @override
  String expiryDate(String date) {
    return 'HSD: $date';
  }

  @override
  String voucherDescriptionMinOrder(String description, String amount) {
    return '$description - Đơn tối thiểu $amount';
  }

  @override
  String orderFrom(String amount) {
    return 'Đơn từ $amount';
  }

  @override
  String maxDiscount(String amount) {
    return 'Giảm tối đa $amount';
  }

  @override
  String voucherUsedPercent(String percent) {
    return '🔥 Đã dùng: $percent%';
  }

  @override
  String remainingUses(int count) {
    return 'Còn $count lượt';
  }

  @override
  String get copied => 'Đã sao chép';

  @override
  String get copyCode => 'Sao chép mã';

  @override
  String get useNow => 'Dùng ngay';

  @override
  String get loginToAsk => 'Vui lòng đăng nhập để gửi thắc mắc!';

  @override
  String get questionSubmitted =>
      '🎉 Đã gửi thắc mắc thành công! Bạn sẽ nhận được thông báo qua email ngay khi Admin giải đáp.';

  @override
  String genericError(Object error) {
    return 'Lỗi: $error';
  }

  @override
  String get qaCenterTitle => 'TRUNG TÂM HỎI ĐÁP & TRỢ GIÚP (Q&A)';

  @override
  String get qaCenterDescription =>
      'Gửi câu hỏi hoặc thắc mắc của bạn cho ban quản trị. Ngay sau khi Admin phản hồi, hệ thống sẽ gửi Email chi tiết về hòm thư của bạn.';

  @override
  String get newQuestionTab => '❓ Đặt Câu Hỏi Mới';

  @override
  String questionHistoryTab(int count) {
    return '📜 Lịch Sử Thắc Mắc ($count)';
  }

  @override
  String get chooseSupportTopic => '1. Chọn Chủ Đề Hỗ Trợ';

  @override
  String get questionContent => '2. Nội Dung Thắc Mắc';

  @override
  String get questionContentField => 'Nội dung thắc mắc';

  @override
  String get questionHint =>
      'VD: Tôi muốn mua bộ sofa nhưng cần điều chỉnh kích thước, cửa hàng có nhận gia công theo yêu cầu và chi phí thế nào?';

  @override
  String get sending => 'Đang gửi...';

  @override
  String get sendQuestionToAdmin => 'Gửi Thắc Mắc Cho Admin';

  @override
  String get noQuestions => 'Bạn chưa có câu hỏi hay yêu cầu trợ giúp nào.';

  @override
  String get answeredEmailed => '✅ Đã giải đáp (Đã gửi mail)';

  @override
  String get awaitingReply => '⏳ Chờ phản hồi';

  @override
  String sentAt(String time) {
    return 'Gửi lúc: $time';
  }

  @override
  String get yourQuestion => '❓ Nội dung câu hỏi của bạn:';

  @override
  String get officialAdminReply => '💡 Phản hồi chính thức từ Admin:';

  @override
  String answeredAt(String time) {
    return 'Lúc: $time';
  }

  @override
  String get topicProductAdvice => 'Tư vấn kỹ thuật sản phẩm & chất liệu';

  @override
  String get topicPolicies => 'Chính sách bảo hành, đổi trả & vận chuyển';

  @override
  String get topicCustomDesign =>
      'Tư vấn thiết kế & đặt đóng nội thất theo yêu cầu';

  @override
  String get topicFeedback => 'Góp ý & phản hồi về dịch vụ';

  @override
  String get mySpace => 'Không gian của tôi';

  @override
  String get waitForAiGeneration => 'Hãy chờ AI tạo ảnh hiện tại xong.';

  @override
  String get roomImageTooLarge => 'Ảnh căn phòng không được vượt quá 10 MB.';

  @override
  String get roomUploaded =>
      'Đã tải ảnh phòng. Bạn có thể chỉnh tay hoặc dùng AI.';

  @override
  String get defaultVariant => 'Mặc định';

  @override
  String chooseProductVariant(String product) {
    return 'Chọn biến thể $product';
  }

  @override
  String stockRemaining(int count) {
    return 'Còn $count sản phẩm';
  }

  @override
  String get uploadRoomFirst => 'Hãy tải ảnh phòng trước.';

  @override
  String get backgroundRemovedAdded => 'Đã xóa nền và thêm sản phẩm vào phòng.';

  @override
  String get chooseProduct => 'Chọn sản phẩm';

  @override
  String get chooseRoomAndProductImages =>
      'Hãy chọn đủ ảnh phòng và ảnh sản phẩm.';

  @override
  String get aiServiceNotReady => 'Dịch vụ AI chưa sẵn sàng.';

  @override
  String get generateNewAiImageTitle => 'Tạo ảnh mới bằng AI?';

  @override
  String get aiGenerateConfirmAuto =>
      'AI sẽ nhận đúng 2 ảnh: ảnh phòng và ảnh biến thể sản phẩm. AI sẽ tự chọn vị trí phù hợp. Mỗi lần tạo mới có thể phát sinh chi phí API.';

  @override
  String get aiGenerateConfirmPrompt =>
      'AI sẽ nhận đúng 2 ảnh: ảnh phòng và ảnh biến thể sản phẩm. AI sẽ ưu tiên vị trí bạn đã mô tả. Mỗi lần tạo mới có thể phát sinh chi phí API.';

  @override
  String get generateImage => 'Tạo ảnh';

  @override
  String get aiImageLoadedFromCache => 'Đã tải ảnh AI từ bộ nhớ đệm.';

  @override
  String get aiImageGenerated => 'AI đã tạo ảnh mới từ 2 hình.';

  @override
  String get designSaved => 'Đã lưu thiết kế.';

  @override
  String get cannotCreateResultImage => 'Không thể tạo ảnh kết quả.';

  @override
  String get visualizationDownloaded => 'Đã tải ảnh phối cảnh.';

  @override
  String get roomVisualizerTitle => 'Phối cảnh không gian';

  @override
  String get uploadRoomImage => 'Tải ảnh phòng';

  @override
  String get changeRoomImage => 'Đổi ảnh phòng';

  @override
  String get saveDesign => 'Lưu thiết kế';

  @override
  String get exportImage => 'Xuất ảnh';

  @override
  String get uploadYourRoom => 'Tải ảnh căn phòng của bạn';

  @override
  String get roomImageRequirements => 'Hỗ trợ JPG, PNG, WEBP; tối đa 10 MB.';

  @override
  String get uploadingImage => 'Đang tải ảnh…';

  @override
  String get chooseRoomImage => 'Chọn ảnh căn phòng';

  @override
  String get manualAdjustment => 'Tự điều chỉnh';

  @override
  String get aiGenerateImage => 'AI tạo ảnh';

  @override
  String get chooseProductManualHint => 'Chọn sản phẩm để bắt đầu chỉnh tay';

  @override
  String get chooseProductAiHint => 'Chọn sản phẩm rồi yêu cầu AI tạo ảnh mới';

  @override
  String get aiGeneratingNewImage => 'AI đang tạo ảnh mới…';

  @override
  String get analyzingSpace => 'Đang phân tích không gian…';

  @override
  String get designLayer => 'Thiết kế';

  @override
  String get floorWallLayer => 'Sàn / tường';

  @override
  String get depthLayer => 'Chiều sâu';

  @override
  String get floorMaskLayer => 'Mask sàn';

  @override
  String get wallMaskLayer => 'Mask tường';

  @override
  String get productsTab => 'Sản phẩm';

  @override
  String get adjustmentsTab => 'Điều chỉnh';

  @override
  String get selectProductOnCanvas => 'Chọn một sản phẩm trong khung ảnh.';

  @override
  String get placementSurface => 'Bề mặt đặt đồ';

  @override
  String get freePlacement => 'Tự do';

  @override
  String get floorSurface => 'Sàn';

  @override
  String get leftWall => 'Tường trái';

  @override
  String get rightWall => 'Tường phải';

  @override
  String get sizeControl => 'Kích thước';

  @override
  String get flatRotation => 'Xoay phẳng';

  @override
  String get perspectiveRotation => 'Xoay phối cảnh trái / phải';

  @override
  String get brightness => 'Độ sáng';

  @override
  String get shadowIntensity => 'Độ đậm bóng';

  @override
  String get flipProduct => 'Lật ngang sản phẩm';

  @override
  String get duplicate => 'Nhân bản';

  @override
  String get delete => 'Xóa';

  @override
  String get aiFromTwoImages => 'AI tạo ảnh từ 2 hình';

  @override
  String get aiFromTwoImagesDescription =>
      'AI nhận trực tiếp ảnh phòng và ảnh biến thể sản phẩm, rồi sinh một ảnh phối cảnh mới.';

  @override
  String get roomImage => 'Ảnh căn phòng';

  @override
  String get uploadedImage => 'Ảnh bạn đã tải lên';

  @override
  String get noProductSelected => 'Chưa chọn sản phẩm';

  @override
  String get chooseVariantBelow => 'Chọn một biến thể bên dưới';

  @override
  String get chooseProductColor => 'Chọn sản phẩm và màu';

  @override
  String get changeProductColor => 'Đổi sản phẩm / màu';

  @override
  String get desiredPlacementOptional => 'Vị trí mong muốn (không bắt buộc)';

  @override
  String get placementPromptHint =>
      'Ví dụ: Đặt bàn sát cửa sổ bên trái, xoay mặt bàn hướng vào giữa phòng.';

  @override
  String get placementPromptHelp =>
      'Chỉ mô tả vị trí, hướng xoay hoặc khu vực đặt sản phẩm. Nếu để trống, AI sẽ tự bố trí.';

  @override
  String get aiServiceUnavailable => 'Không kết nối được dịch vụ AI.';

  @override
  String get aiGenerating => 'AI đang tạo ảnh…';

  @override
  String get generateNewImageWithAi => 'Tạo ảnh mới bằng AI';

  @override
  String get regenerateImage => 'Tạo lại ảnh mới';

  @override
  String get downloadCurrentAiImage => 'Tải ảnh AI đang xem';

  @override
  String get aiImageDisclaimer =>
      'Ảnh AI chỉ mang tính tham khảo. Mỗi lần tạo có thể phát sinh phí API; hãy đối chiếu màu và kích thước thật trước khi mua.';

  @override
  String get chatPromptSofa => '💡 Tìm mẫu sofa phòng khách giá tốt';

  @override
  String get chatPromptDining => '💡 Gợi ý bộ bàn ăn cho gia đình 4 người';

  @override
  String get chatPromptDesk => '💡 Có bàn làm việc gỗ nào nhỏ gọn không?';

  @override
  String get chatPromptVoucher => '💡 Hướng dẫn áp dụng mã giảm giá voucher';

  @override
  String get chatPromptCustom =>
      '💡 Shop có nhận đặt gia công kích thước riêng?';

  @override
  String get chatWelcome =>
      'Xin chào! 🤖 Mình là Trợ lý AI Thông Minh của My Furniture Store. Mình đã nắm rõ thông tin giá cả và chi tiết của toàn bộ danh mục hàng hóa!\n\nBạn cần tìm món nội thất nào hoặc cần tư vấn cách thiết kế không gian hãy hỏi mình nhé! ✨';

  @override
  String get chatConnectionError =>
      '✨ Trợ lý AI đang trục trặc tín hiệu đường truyền. Bạn hãy thử lại sau nhé!';

  @override
  String get geminiAssistant => 'Trợ lý AI Gemini';

  @override
  String get furnitureAiAssistant => '✨ Trợ Lý AI Nội Thất';

  @override
  String get chatOnlineStatus => 'Online - Đang đọc dữ liệu kho';

  @override
  String get chatInputHint => 'Hỏi AI về sofa, bàn trà, giá ưu đãi...';

  @override
  String get chatThinking => 'AI đang suy nghĩ & tra cứu sản phẩm...';

  @override
  String viewMoreProducts(int count) {
    return 'Xem thêm $count sản phẩm';
  }

  @override
  String get cartTitle => 'GIỎ HÀNG';

  @override
  String get cartEmptyShort => 'Hiện chưa có sản phẩm';

  @override
  String get loginToViewCart => 'Vui lòng đăng nhập để xem giỏ hàng.';

  @override
  String get viewCart => 'XEM GIỎ HÀNG';

  @override
  String get checkoutAction => 'THANH TOÁN';

  @override
  String get aboutTitle => 'Về My Furniture Store';

  @override
  String get contactTitle => 'Liên hệ';

  @override
  String get aboutDescription =>
      'My Furniture Store cung cấp các sản phẩm nội thất cho không gian sống hiện đại, với dịch vụ giao hàng và lắp đặt tận nhà.';

  @override
  String get contactDescription =>
      'Email: support@myfurniture.local\nĐiện thoại: 1900 0000\nThời gian hỗ trợ: 08:00–20:00 mỗi ngày.';

  @override
  String get adminManageCategories => 'Quản lý danh mục';

  @override
  String get adminManageProducts => 'Quản lý sản phẩm';

  @override
  String get adminManageReviews => 'Quản lý đánh giá';

  @override
  String get adminManageOrders => 'Quản lý đơn hàng';

  @override
  String get adminManageAccounts => 'Quản lý tài khoản';

  @override
  String get adminManagePromotions => 'Quản lý khuyến mãi';

  @override
  String get adminManageDelivery => 'Quản lý vận chuyển';

  @override
  String get adminQaSupport => 'Hỏi đáp & Trợ giúp (Q&A)';

  @override
  String get adminManageRecommendations => 'Quản lý gợi ý';

  @override
  String get adminManageRevenue => 'Quản lý doanh thu';

  @override
  String get backToHome => 'Quay về trang chủ';

  @override
  String get refreshData => 'Làm mới dữ liệu';

  @override
  String get categoriesMetric => 'DANH MỤC';

  @override
  String get productsMetric => 'SẢN PHẨM';

  @override
  String get collectedRevenue => 'DOANH THU ĐÃ THU';

  @override
  String get outOfStockVariants => 'BIẾN THỂ HẾT HÀNG';

  @override
  String get recentOrders => 'ĐƠN HÀNG GẦN ĐÂY';

  @override
  String get noOrdersYet => 'Chưa có đơn hàng.';

  @override
  String loadDataError(Object error) {
    return 'Lỗi tải dữ liệu: $error';
  }

  @override
  String get productListTitle => 'Danh sách sản phẩm';

  @override
  String get searchProductHint => 'Tìm theo mã hoặc tên sản phẩm...';

  @override
  String get mainCategory => 'Danh mục chính';

  @override
  String get subCategory => 'Danh mục con';

  @override
  String get allChildren => 'Tất cả con';

  @override
  String get addProduct => 'Thêm Sản phẩm';

  @override
  String get productCode => 'Mã sản phẩm';

  @override
  String get productName => 'Tên Sản phẩm';

  @override
  String get price => 'Giá';

  @override
  String get status => 'Trạng thái';

  @override
  String get actions => 'Hành động';

  @override
  String categoryNumber(int id) {
    return 'Danh mục #$id';
  }

  @override
  String get discontinued => 'Ngừng bán';

  @override
  String get onSale => 'Đang bán';

  @override
  String loadProductsError(Object error) {
    return 'Lỗi tải sản phẩm: $error';
  }

  @override
  String get confirmDeleteProduct => 'Xác nhận xóa sản phẩm';

  @override
  String get confirmDeleteProductBody =>
      'Bạn có chắc chắn muốn xóa sản phẩm này không? Hành động này không thể hoàn tác.';

  @override
  String get categoryListTitle => 'Danh sách danh mục sản phẩm';

  @override
  String get addCategory => 'Thêm Danh mục';

  @override
  String get noCategories => 'Chưa có danh mục nào.';

  @override
  String get noSubcategories => 'Không có danh mục con';

  @override
  String loadCategoriesError(Object error) {
    return 'Lỗi tải danh mục: $error';
  }

  @override
  String get confirmDeleteCategory => 'Xác nhận xóa danh mục';

  @override
  String get confirmDeleteCategoryBody =>
      'Bạn có chắc chắn muốn xóa danh mục này không? Hành động này không thể hoàn tác.';

  @override
  String get addNewCategory => 'Thêm Danh Mục Mới';

  @override
  String get editCategory => 'Sửa Danh Mục';

  @override
  String get categoryInformation => 'Thông tin danh mục';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get categoryNameRequired => 'Tên danh mục (*)';

  @override
  String get categoryCode => 'Mã danh mục';

  @override
  String invalidCode(String field) {
    return '$field chỉ được chứa chữ cái, chữ số, gạch ngang (-) hoặc gạch dưới (_)!';
  }

  @override
  String get categoryCodeAuto => 'Mã danh mục (Để trống để tự sinh)';

  @override
  String get parentCategoryOptional => 'Danh mục cha (nếu có)';

  @override
  String get rootCategoryOption => 'Không có (Đây là danh mục gốc)';

  @override
  String get categoryImage => 'Hình ảnh danh mục';

  @override
  String get uploadFromDevice => 'Tải ảnh từ máy...';

  @override
  String selectedFile(String name) {
    return 'Đã chọn: $name';
  }

  @override
  String get useCurrentImage => 'Sử dụng ảnh hiện tại';

  @override
  String get noImageSelected => 'Chưa chọn hình ảnh nào';

  @override
  String get invalidCategoryName =>
      'Vui lòng kiểm tra và nhập hợp lệ tên danh mục!';

  @override
  String saveCategoryError(Object error) {
    return 'Lỗi lưu danh mục: $error';
  }

  @override
  String get addNewVariant => 'Thêm Biến thể mới';

  @override
  String get editVariant => 'Sửa Biến thể';

  @override
  String get color => 'Màu sắc';

  @override
  String get stockQuantity => 'Số lượng tồn kho';

  @override
  String get additionalPrice => 'Giá phát sinh (đ)';

  @override
  String get variantImages => 'Hình ảnh biến thể';

  @override
  String get cannotReadImage =>
      'Không đọc được dữ liệu ảnh. Vui lòng chọn lại file.';

  @override
  String imageUploadError(Object error) {
    return 'Lỗi tải ảnh: $error';
  }

  @override
  String get invalidProductFields =>
      'Vui lòng kiểm tra và nhập chính xác các trường thông tin sản phẩm!';

  @override
  String get selectFullCategoryPath =>
      'Vui lòng chọn đầy đủ danh mục chính và danh mục con';

  @override
  String saveProductError(Object error) {
    return 'Lỗi lưu sản phẩm: $error';
  }

  @override
  String get addNewProduct => 'Thêm Sản Phẩm Mới';

  @override
  String get editProductInformation => 'Sửa Thông Tin Sản Phẩm';

  @override
  String get productNameRequired => 'Tên sản phẩm (*)';

  @override
  String get productCodeAuto => 'Mã sản phẩm (Để trống để tự sinh)';

  @override
  String get basePrice => 'Giá cơ bản';

  @override
  String get basePriceRequired => 'Giá cơ bản (đ) (*)';

  @override
  String get detailedDescription => 'Mô tả chi tiết';

  @override
  String get detailedDescriptionRequired => 'Mô tả chi tiết (*)';

  @override
  String get productVariantsHeading =>
      'Biến thể sản phẩm (Màu sắc, Size, Tồn kho, Giá phát sinh)';

  @override
  String get addVariant => 'Thêm biến thể';

  @override
  String get noVariants =>
      'Chưa có biến thể nào. Bấm \"Thêm biến thể\" ở trên.';

  @override
  String variantColorSize(String color, String size) {
    return '$color | Kích thước: $size';
  }

  @override
  String variantStockPrice(Object stock, String price) {
    return 'Tồn kho: $stock | Chênh lệch: +$price';
  }

  @override
  String get temporarilyHideProduct => 'Ẩn tạm thời (ngừng kinh doanh)';

  @override
  String get hiddenProductDescription =>
      'Sản phẩm sẽ không hiển thị trên trang chủ';

  @override
  String get productPreview => 'XEM TRƯỚC SẢN PHẨM';

  @override
  String get productDiscountTitle => 'Giảm giá sản phẩm';

  @override
  String get productDiscountHint =>
      'Giảm trên toàn bộ biến thể của sản phẩm trong thời gian đã chọn.';

  @override
  String get discountStartDate => 'Ngày bắt đầu';

  @override
  String get discountEndDate => 'Ngày kết thúc';

  @override
  String get noDateLimit => 'Không giới hạn';

  @override
  String get discountPercentRangeError =>
      'Mức giảm phải lớn hơn 0 và không vượt quá 90%.';

  @override
  String get activeDiscountRequiredError =>
      'Hãy nhập phần trăm giảm giá trước khi bật chương trình.';

  @override
  String get discountDateRangeError => 'Ngày kết thúc phải sau ngày bắt đầu.';

  @override
  String get productNamePlaceholder => 'Tên Sản Phẩm';

  @override
  String get oakColor => 'Gỗ sồi (Oak)';

  @override
  String get walnutColor => 'Gỗ óc chó (Walnut)';

  @override
  String get naturalWoodColor => 'Gỗ tự nhiên';

  @override
  String get brownWoodColor => 'Nâu gỗ (Brown)';

  @override
  String get whiteColor => 'Trắng (White)';

  @override
  String get blackColor => 'Đen (Black)';

  @override
  String get greyColor => 'Xám (Grey)';

  @override
  String get beigeColor => 'Kem (Beige)';

  @override
  String get tanColor => 'Nâu da bò (Tan)';

  @override
  String get standardSize => 'Tiêu chuẩn';

  @override
  String get smallSize => 'S (Nhỏ)';

  @override
  String get mediumSize => 'M (Vừa)';

  @override
  String get largeSize => 'L (Lớn)';

  @override
  String invalidNumber(String field) {
    return '$field phải là số hợp lệ!';
  }

  @override
  String integerRequired(String field) {
    return '$field phải là số nguyên!';
  }

  @override
  String minimumValue(String field, num min) {
    return '$field phải lớn hơn hoặc bằng $min!';
  }

  @override
  String loadOrderListError(Object error) {
    return 'Lỗi tải danh sách đơn hàng: $error';
  }

  @override
  String get rescheduledDelivery => 'Hẹn giao lại';

  @override
  String get paymentFailed => 'Thất bại';

  @override
  String get confirmCancelOrder => 'Xác nhận hủy đơn hàng';

  @override
  String get confirmCancelOrderBody =>
      'Bạn có chắc muốn hủy đơn hàng này? Tồn kho và lượt sử dụng voucher sẽ được hoàn lại.';

  @override
  String get no => 'Không';

  @override
  String get cancelOrder => 'Hủy đơn';

  @override
  String get orderStatusUpdated => 'Cập nhật trạng thái đơn hàng thành công!';

  @override
  String updateError(Object error) {
    return 'Lỗi cập nhật: $error';
  }

  @override
  String get adminOrderManagement => 'Quản lý Đơn hàng';

  @override
  String get searchOrdersHint => 'Tìm kiếm tên, email, ID...';

  @override
  String get noOrdersFound => 'Không tìm thấy đơn hàng nào.';

  @override
  String orderNumber(int id) {
    return 'Đơn hàng #$id';
  }

  @override
  String customerSummary(String name, String email) {
    return 'Khách: $name ($email)';
  }

  @override
  String orderDetailsCode(String code) {
    return 'Chi tiết $code';
  }

  @override
  String orderDetailsNumber(int id) {
    return 'Chi tiết Đơn hàng #$id';
  }

  @override
  String get orderStatusLabel => 'Trạng thái đơn hàng:';

  @override
  String get shipperOwnsDeliveryConfirmation =>
      'Đơn đang do shipper phụ trách. Chỉ shipper được xác nhận “Đã giao”.';

  @override
  String get confirmOrder => 'Xác nhận đơn hàng';

  @override
  String get cancelOrderFull => 'Hủy đơn hàng';

  @override
  String get completedOrderLocked =>
      'Đơn hàng đã hoàn tất hoặc bị hủy. Không thể thay đổi trạng thái.';

  @override
  String get customerDeliveryInformation => 'Thông tin khách hàng & Giao hàng';

  @override
  String get assignedShipper => 'Shipper phụ trách:';

  @override
  String get customerNameLabel => 'Tên khách hàng:';

  @override
  String get deliveryAddressLabel => 'Địa chỉ nhận hàng:';

  @override
  String get appointmentSlot => 'Khung giờ hẹn:';

  @override
  String get assemblyServiceLabel => 'Dịch vụ lắp đặt:';

  @override
  String assemblyRequested(String fee) {
    return 'Có Yêu Cầu (+$fee)';
  }

  @override
  String get none => 'Không có';

  @override
  String get paymentSection => 'Thanh toán';

  @override
  String get methodLabel => 'Phương thức:';

  @override
  String get paymentStatusLabel => 'Trạng thái thanh toán:';

  @override
  String get orderedProducts => 'Sản phẩm đã đặt';

  @override
  String classification(String color, String size) {
    return 'Phân loại: $color - $size';
  }

  @override
  String get totalPaymentLabel => 'Tổng thanh toán:';

  @override
  String loadAccountsError(Object error) {
    return 'Lỗi tải danh sách tài khoản: $error';
  }

  @override
  String get accountUnlocked => 'Mở khóa tài khoản thành công!';

  @override
  String get accountLocked => 'Khóa tài khoản thành công!';

  @override
  String changeStatusError(Object error) {
    return 'Lỗi thay đổi trạng thái: $error';
  }

  @override
  String get roleUpdated => 'Cập nhật vai trò thành công!';

  @override
  String updateRoleError(Object error) {
    return 'Lỗi cập nhật vai trò: $error';
  }

  @override
  String resetPasswordFor(Object name) {
    return 'Đặt lại mật khẩu cho $name';
  }

  @override
  String get newPasswordLabel => 'Mật khẩu mới:';

  @override
  String passwordResetSuccess(Object password) {
    return 'Đặt lại mật khẩu thành công! Mật khẩu mới: $password';
  }

  @override
  String resetPasswordError(Object error) {
    return 'Lỗi đặt lại mật khẩu: $error';
  }

  @override
  String get confirm => 'Xác nhận';

  @override
  String get accountManagementTitle => 'Quản lý tài khoản';

  @override
  String get refresh => 'Làm mới';

  @override
  String get systemAccountList => 'Danh sách tài khoản hệ thống';

  @override
  String get searchAccountsHint => 'Tìm kiếm họ tên, email, sđt...';

  @override
  String get noAccountsFound => 'Không tìm thấy tài khoản nào.';

  @override
  String get customerId => 'Mã KH';

  @override
  String get role => 'Vai trò';

  @override
  String get operations => 'Thao tác';

  @override
  String get customerRole => 'Khách hàng';

  @override
  String get locked => 'Đã khóa';

  @override
  String get active => 'Đang hoạt động';

  @override
  String get unlock => 'Mở khóa';

  @override
  String get lock => 'Khóa';

  @override
  String get resetPassword => 'Đặt lại MK';

  @override
  String deliveryDispatchLoadError(Object error) {
    return 'Lỗi tải dữ liệu điều phối: $error';
  }

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get deliveryControlCenter =>
      '🚚 Trung Tâm Điều Phối & Quản Lý Giao Hàng';

  @override
  String get deliveryControlDescription =>
      'Giám sát hoạt động vận chuyển, thi công lắp đặt nội thất và xử lý sự cố real-time.';

  @override
  String get refreshMetrics => 'Làm mới số liệu';

  @override
  String get activeDispatchOrders => 'ĐƠN ĐANG ĐIỀU PHỐI';

  @override
  String orderCount(Object count) {
    return '$count đơn';
  }

  @override
  String get totalDistance => 'TỔNG QUÃNG ĐƯỜNG';

  @override
  String get collectedShippingFees => 'PHÍ VẬN CHUYỂN THU ĐƯỢC';

  @override
  String get earnedAssemblyFees => 'PHÍ LẮP ĐẶT THỢ KIẾM ĐƯỢC';

  @override
  String get teamWorkloadMonitoring =>
      'Giám Sát Tải Trọng Đội Ngũ Shipper & Thợ Thi Công';

  @override
  String get teamWorkloadDescription =>
      'Giúp Admin đưa ra quyết định phân ca và điều chỉnh đơn cho thợ hợp lý, tránh quá tải.';

  @override
  String get noShippers => 'Chưa có nhân viên Shipper nào trong hệ thống.';

  @override
  String get unavailable => 'Không sẵn sàng';

  @override
  String get unknown => 'Chưa rõ';

  @override
  String phoneSummary(Object phone) {
    return 'SĐT: $phone';
  }

  @override
  String activeDeliverySummary(Object count) {
    return 'Đang giao: $count đơn';
  }

  @override
  String completedDeliverySummary(Object count) {
    return 'Đã xong: $count đơn';
  }

  @override
  String get deliveryScheduleTitle =>
      '📅 Lịch Biểu Khung Giờ & Xử Lý Sự Cố Giao Hàng';

  @override
  String get deliveryScheduleDescription =>
      'Phân chia ca thi công và can thiệp kịp thời các đơn hàng gặp trở ngại do Shipper gửi lên.';

  @override
  String morningShift(Object count) {
    return '☀️ Ca Sáng ($count)';
  }

  @override
  String afternoonShift(Object count) {
    return '🌞 Ca Chiều ($count)';
  }

  @override
  String eveningShift(Object count) {
    return '🌙 Ca Tối ($count)';
  }

  @override
  String issuesReschedule(Object count) {
    return 'Sự cố / Hẹn lại ($count)';
  }

  @override
  String get noDeliveryIssues =>
      'Tối ưu! Hiện không có đơn hàng nào gặp sự cố hay cần hẹn lại.';

  @override
  String get noShiftOrders => 'Không có đơn hàng thuộc ca thi công này.';

  @override
  String assemblyIncludedBadge(Object fee) {
    return '🛠️ CÓ LẮP ĐẶT (+$fee)';
  }

  @override
  String get acceptanceImage => 'Ảnh nghiệm thu';

  @override
  String get dispatchChangeShift => 'Điều phối & Đổi ca';

  @override
  String customerContactSummary(Object name, Object phone) {
    return '👤 Khách hàng: $name ($phone)';
  }

  @override
  String addressSummary(Object address) {
    return '📍 Địa chỉ: $address';
  }

  @override
  String get responsibleShipper => '👷 Shipper phụ trách:';

  @override
  String get unassigned => 'Chưa phân công';

  @override
  String distanceSummary(Object distance) {
    return '📏 Khoảng cách: $distance km';
  }

  @override
  String issueHistoryNotes(Object notes) {
    return '⚠️ Lịch sử & Ghi chú sự cố:\n$notes';
  }

  @override
  String get rescheduledSecondTime => '⚠️ Hẹn lại (Lần 2)';

  @override
  String get completedStatus => '✅ Đã hoàn thành';

  @override
  String get outForDelivery => '🚚 Đang đi giao';

  @override
  String get awaitingDispatch => 'Chờ điều phối';

  @override
  String get acceptanceImageTitle => '🖼️ Ảnh Nghiệm Thu Lắp Đặt / Giao Hàng';

  @override
  String get cannotLoadImage => 'Không thể tải hình ảnh.';

  @override
  String dispatchDialogTitle(Object code) {
    return 'Điều Phối & Sắp Xếp Lại - Đơn #$code';
  }

  @override
  String get assignShipperRequired => 'Phân công Shipper thi công (*):';

  @override
  String get chooseResponsibleShipper => '-- Chọn Shipper phụ trách --';

  @override
  String get available => 'Sẵn sàng';

  @override
  String get newTimeSlot => 'Khung giờ thi công mới:';

  @override
  String get adminDispatchNote => 'Ghi chú điều phối từ Admin (tùy chọn):';

  @override
  String get adminDispatchNoteHint =>
      'VD: Khách vừa gọi chốt đổi sang ca Chiều, các bạn để ý lắp đặt cẩn thận...';

  @override
  String get mustChooseShipper =>
      '⚠️ Vui lòng bắt buộc chọn một Shipper trước khi phân công / điều phối!';

  @override
  String get dispatchSaved => '🎉 Đã lưu cấu hình điều phối thành công!';

  @override
  String get saveDispatch => 'Lưu thay đổi & Điều phối';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String confirmDeleteVoucher(Object code) {
    return 'Bạn có chắc chắn muốn xóa mã khuyến mãi \"$code\" khỏi hệ thống?';
  }

  @override
  String get voucherDeleted => 'Xóa mã giảm giá thành công';

  @override
  String deleteVoucherError(Object error) {
    return 'Lỗi xóa voucher: $error';
  }

  @override
  String get voucherManagementTitle => 'Quản lý Khuyến mãi (Vouchers)';

  @override
  String get createVoucher => 'Tạo Voucher Mới';

  @override
  String get voucherListTitle => 'Danh sách Mã Khuyến Mãi';

  @override
  String get searchVoucherHint => 'Tìm theo mã, tên chương trình...';

  @override
  String get noSystemVouchers => 'Chưa có mã khuyến mãi nào trong hệ thống.';

  @override
  String get code => 'Mã Code';

  @override
  String get campaignName => 'Tên chương trình';

  @override
  String get offer => 'Ưu đãi';

  @override
  String get minimumOrder => 'Đơn từ';

  @override
  String get usedSupported => 'Đã dùng / Hỗ trợ';

  @override
  String get expiry => 'Hết hạn';

  @override
  String percentageDiscount(Object value) {
    return 'Giảm $value%';
  }

  @override
  String maximumAmountSuffix(Object amount) {
    return 'Tối đa $amount';
  }

  @override
  String cashDiscount(Object amount) {
    return 'Giảm $amount';
  }

  @override
  String get operating => 'Đang HĐ';

  @override
  String get expired => 'Hết hạn';

  @override
  String get usageExhausted => 'Hết lượt';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get createNewVoucher => 'Tạo Mã Khuyến Mãi Mới';

  @override
  String updateVoucher(Object code) {
    return 'Cập Nhật Voucher (#$code)';
  }

  @override
  String get voucherCodeHint => 'Mã Code (VD: SUMMER2026)*';

  @override
  String get campaignNameRequired => 'Tên chương trình*';

  @override
  String get conditionDescription => 'Mô tả chi tiết điều kiện áp dụng';

  @override
  String get discountType => 'Loại giảm giá';

  @override
  String get percentageType => 'Theo Phần Trăm (%)';

  @override
  String get cashType => 'Giảm Tiền Mặt (VNĐ)';

  @override
  String get discountPercentField => 'Mức giảm (%)';

  @override
  String get discountCashField => 'Số tiền giảm (VNĐ)';

  @override
  String get discountAmountField => 'Số tiền giảm';

  @override
  String get maximumDiscountVnd => 'Giảm tối đa (VNĐ)';

  @override
  String get minimumOrderVnd => 'Đơn hàng tối thiểu (VNĐ)*';

  @override
  String get totalIssueLimit => 'Tổng số lượt phát hành*';

  @override
  String get activateImmediately => 'Kích hoạt ngay';

  @override
  String get startDate => 'Ngày bắt đầu';

  @override
  String get endDate => 'Ngày hết hạn';

  @override
  String get saveVoucher => 'Lưu Voucher';

  @override
  String maximumValue(Object field, Object max) {
    return '$field không được vượt quá $max!';
  }

  @override
  String get editReply => 'Chỉnh Sửa Phản Hồi';

  @override
  String get answerAndEmail => 'Giải Đáp Thắc Mắc & Gửi Mail';

  @override
  String get anonymous => 'Ẩn danh';

  @override
  String get noEmail => 'Không có email';

  @override
  String customerWithEmail(Object email, Object name) {
    return 'Khách hàng: $name ($email)';
  }

  @override
  String topicLabel(Object topic) {
    return 'Chủ đề: [$topic]';
  }

  @override
  String get adminReplyContent => 'Nội Dung Phản Hồi Của Ban Quản Trị:';

  @override
  String get adminReplyHint =>
      'Nhập câu trả lời chính thức... Nội dung này sẽ được gửi đến email của khách hàng.';

  @override
  String get replyContentField => 'Nội dung phản hồi';

  @override
  String get processing => 'Đang Xử Lý...';

  @override
  String get saveReplyEmail => 'Lưu Phản Hồi & Gửi Email';

  @override
  String get adminQaCenterTitle => 'TRUNG TÂM QUẢN LÝ HỎI ĐÁP & TRỢ GIÚP (Q&A)';

  @override
  String get adminQaCenterDescription =>
      'Giải đáp thắc mắc khách hàng - Tự động thông báo trực tiếp qua Email SMTP';

  @override
  String needsAnswer(Object count) {
    return '⏳ Cần giải đáp ngay ($count)';
  }

  @override
  String answeredCount(Object count) {
    return '✅ Đã giải đáp ($count)';
  }

  @override
  String allQuestionCount(Object count) {
    return '🌟 Tất cả câu hỏi ($count)';
  }

  @override
  String get noUrgentQuestions =>
      'Tuyệt vời! Hiện không có câu hỏi nào cần trả lời gấp.';

  @override
  String get noQuestionsInSection =>
      'Không tìm thấy câu hỏi nào trong mục này.';

  @override
  String fromCustomer(Object email, Object name) {
    return 'Từ: $name ($email)';
  }

  @override
  String get answered => '✅ Đã trả lời';

  @override
  String get urgentHandling => '⏳ Cần xử lý gấp';

  @override
  String get questionLabel => '❓ Câu hỏi:';

  @override
  String get repliedEmailed => '💡 Đã phản hồi (Đã gửi mail):';

  @override
  String get replyEmailCustomer => '💬 Trả Lời & Gửi Mail Cho Khách';

  @override
  String minimumCharacters(Object count) {
    return 'Nội dung phải có ít nhất $count ký tự.';
  }

  @override
  String get customerLabel => 'Khách';

  @override
  String atTime(Object time) {
    return 'Lúc: $time';
  }

  @override
  String recommendationLoadError(Object error) {
    return 'Không thể tải trang quản lý gợi ý: $error';
  }

  @override
  String get supportRangeError =>
      'Min Support phải lớn hơn 0% và không vượt quá 100%.';

  @override
  String get confidenceRangeError =>
      'Min Confidence phải lớn hơn 0% và không vượt quá 100%.';

  @override
  String get recommendationResultRangeError =>
      'Số kết quả gợi ý phải từ 1 đến 20.';

  @override
  String get recommendationRebuilt => 'Đã xây dựng lại dữ liệu gợi ý.';

  @override
  String recommendationBuildSummary(
    Object baskets,
    Object message,
    Object rules,
  ) {
    return '$message Giỏ hàng: $baskets · Luật: $rules';
  }

  @override
  String get deleteAllAprioriRules => 'Xóa toàn bộ luật Apriori?';

  @override
  String get deleteAprioriWarning =>
      'Phần “Thường mua cùng” sẽ không còn dữ liệu cho tới khi bạn xây dựng lại.';

  @override
  String get deleteRules => 'Xóa luật';

  @override
  String get recommendationManagementTitle => 'Quản lý thuật toán gợi ý';

  @override
  String get recommendationManagementDescription =>
      'Theo dõi và điều chỉnh Apriori cùng Content-Based.';

  @override
  String get eligibleBaskets => 'GIỎ HÀNG HỢP LỆ';

  @override
  String get aprioriRules => 'LUẬT APRIORI';

  @override
  String get coveredProducts => 'SẢN PHẨM ĐƯỢC PHỦ';

  @override
  String get coverage => 'ĐỘ PHỦ';

  @override
  String get operationSettings => 'Cấu hình vận hành';

  @override
  String get aprioriFrequentlyBoughtTogether => 'Apriori – Thường mua cùng';

  @override
  String get aprioriHistoryDescription =>
      'Dùng lịch sử đơn đã thanh toán hoặc đã giao.';

  @override
  String get contentBasedSimilarProducts => 'Content-Based – Sản phẩm tương tự';

  @override
  String get contentBasedDescription =>
      'So khớp danh mục, chất liệu, màu sắc và giá.';

  @override
  String get autoRebuildApriori => 'Tự động xây dựng lại Apriori';

  @override
  String get autoRebuildDescription =>
      'Chạy sau khi shipper xác nhận giao hàng.';

  @override
  String get maximumRecommendationResults => 'Số kết quả tối đa';

  @override
  String get saveSettings => 'Lưu cấu hình';

  @override
  String get rebuildApriori => 'Xây dựng lại Apriori';

  @override
  String get parameterMeaning => 'Ý nghĩa tham số';

  @override
  String get supportExplanation =>
      'Tỷ lệ số đơn chứa đồng thời hai sản phẩm trên tổng đơn hợp lệ.';

  @override
  String get confidenceExplanation =>
      'Xác suất khách mua sản phẩm B khi đơn đã có sản phẩm A.';

  @override
  String get coverageExplanation =>
      'Tỷ lệ sản phẩm đang có ít nhất một luật “thường mua cùng”.';

  @override
  String get thresholdExplanation =>
      'Ngưỡng càng cao thì luật càng đáng tin nhưng số sản phẩm được phủ có thể giảm.';

  @override
  String get contentBasedPreview => 'Xem thử Content-Based';

  @override
  String get sourceProduct => 'Sản phẩm nguồn';

  @override
  String get runTest => 'Chạy thử';

  @override
  String currentAprioriRules(Object count) {
    return 'Luật Apriori hiện tại ($count)';
  }

  @override
  String get deleteAll => 'Xóa toàn bộ';

  @override
  String get noAprioriRules => 'Chưa có luật. Hãy chạy “Xây dựng lại Apriori”.';

  @override
  String get accompanyingRecommendation => 'Gợi ý đi kèm';

  @override
  String get updatedAt => 'Cập nhật';

  @override
  String productListLoadError(Object error) {
    return 'Lỗi tải danh sách sản phẩm: $error';
  }

  @override
  String productReviewsLoadError(Object error) {
    return 'Lỗi tải đánh giá sản phẩm: $error';
  }

  @override
  String get reviewApprovedSuccess => 'Đã phê duyệt đánh giá thành công!';

  @override
  String reviewApprovalError(Object error) {
    return 'Lỗi phê duyệt: $error';
  }

  @override
  String get confirmReject => 'Xác nhận từ chối';

  @override
  String get confirmRejectReview =>
      'Bạn có chắc chắn muốn xóa/từ chối đánh giá này không?';

  @override
  String get reject => 'Từ chối';

  @override
  String get reviewRejectedSuccess => 'Đã xóa/từ chối đánh giá thành công!';

  @override
  String reviewRejectError(Object error) {
    return 'Lỗi từ chối: $error';
  }

  @override
  String get replyToReview => 'Phản hồi đánh giá';

  @override
  String reviewCustomerNameLabel(Object name) {
    return 'Khách hàng: $name';
  }

  @override
  String commentQuoted(Object comment) {
    return 'Bình luận: “$comment”';
  }

  @override
  String get replyContent => 'Nội dung phản hồi:';

  @override
  String get storeReplyHint => 'Nhập nội dung trả lời từ cửa hàng...';

  @override
  String get replyRequired => 'Nội dung phản hồi không được để trống.';

  @override
  String sendReplyError(Object error) {
    return 'Lỗi gửi phản hồi: $error';
  }

  @override
  String get sendReply => 'Gửi phản hồi';

  @override
  String get reviewManagementByProduct => 'Quản lý đánh giá theo sản phẩm';

  @override
  String get aiReviewModerationDescription =>
      'AI kiểm duyệt khi khách gửi đánh giá: nội dung phù hợp được đăng tự động, nội dung tục tĩu bị chặn, trường hợp chưa chắc chắn sẽ chuyển sang chờ admin duyệt.';

  @override
  String get businessProducts => 'Sản phẩm kinh doanh';

  @override
  String get parentCategory => 'Danh mục cha';

  @override
  String get allParentCategories => 'Tất cả danh mục cha';

  @override
  String get chooseSubcategory => 'Chọn danh mục con';

  @override
  String get subcategory => 'Danh mục con';

  @override
  String get noProductsMatchFilter =>
      'Không có dữ liệu sản phẩm nào phù hợp bộ lọc.';

  @override
  String get averageStars => 'Số sao trung bình';

  @override
  String get totalReviews => 'Tổng số đánh giá';

  @override
  String get pendingApproval => 'Chờ duyệt';

  @override
  String reviewCountText(Object count) {
    return '$count đánh giá';
  }

  @override
  String pendingReviewCount(Object count) {
    return '$count chờ duyệt';
  }

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String productReviewHeading(Object product) {
    return 'Đánh giá sản phẩm: $product';
  }

  @override
  String get detailedReviewList => 'Danh sách đánh giá chi tiết';

  @override
  String ratingReviewSummary(Object count, Object rating) {
    return '$rating ($count đánh giá)';
  }

  @override
  String get productHasNoReviews => 'Sản phẩm này chưa nhận được đánh giá nào.';

  @override
  String get sender => 'Người gửi';

  @override
  String get starCount => 'Số sao';

  @override
  String get customerOpinion => 'Ý kiến khách hàng';

  @override
  String get time => 'Thời gian';

  @override
  String get noComment => 'Không có chữ';

  @override
  String get approved => 'Đã duyệt';

  @override
  String get notReplied => 'Chưa phản hồi';

  @override
  String get approve => 'Phê duyệt';

  @override
  String get reply => 'Phản hồi';

  @override
  String get deleteReview => 'Xóa đánh giá';

  @override
  String get chooseRevenueRange => 'CHỌN KHOẢNG THỐNG KÊ DOANH THU';

  @override
  String get dateRangeTooLong =>
      'Khoảng thời gian quá dài. Hãy chọn mức tổng hợp lớn hơn hoặc rút ngắn khoảng ngày.';

  @override
  String get revenueManagement => 'Quản lý doanh thu';

  @override
  String get revenueManagementDescription =>
      'Phân tích doanh thu từ các đơn hàng đã giao thành công';

  @override
  String get reloadReport => 'Tải lại báo cáo';

  @override
  String get today => 'Hôm nay';

  @override
  String get last7Days => '7 ngày gần nhất';

  @override
  String get last30Days => '30 ngày gần nhất';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get thisYear => 'Năm nay';

  @override
  String get allTime => 'Toàn bộ thời gian';

  @override
  String get custom => 'Tùy chỉnh';

  @override
  String get byDay => 'Theo ngày';

  @override
  String get byMonth => 'Theo tháng';

  @override
  String get byYear => 'Theo năm';

  @override
  String get dateRange => 'Khoảng thời gian';

  @override
  String get aggregationLevel => 'Mức tổng hợp';

  @override
  String get viewReport => 'XEM BÁO CÁO';

  @override
  String get totalRevenue => 'Tổng doanh thu';

  @override
  String get afterFeesAndOffers => 'Sau phí và ưu đãi';

  @override
  String get deliveredOrders => 'Đơn đã giao';

  @override
  String get deliveredOrdersOnly => 'Chỉ tính đơn Delivered';

  @override
  String get productsSold => 'Sản phẩm đã bán';

  @override
  String get totalItemsInOrders => 'Tổng số lượng trong đơn';

  @override
  String get averageOrderValue => 'Giá trị đơn trung bình';

  @override
  String customerCountText(Object count) {
    return '$count khách hàng';
  }

  @override
  String get comparePreviousPeriod => 'So sánh với kỳ liền trước';

  @override
  String get ordersLabel => 'Số đơn';

  @override
  String previousPeriodRange(Object from, Object to) {
    return 'Kỳ trước: $from – $to';
  }

  @override
  String previousPeriodValue(Object value) {
    return 'Kỳ trước: $value';
  }

  @override
  String get revenueComposition => 'Cơ cấu doanh thu';

  @override
  String get merchandiseBeforeOffers => 'Tiền hàng trước ưu đãi';

  @override
  String get shippingFee => 'Phí vận chuyển';

  @override
  String get assemblyFee => 'Phí lắp đặt';

  @override
  String get estimatedDiscount => 'Giảm giá ước tính';

  @override
  String get recognizedRevenue => 'Doanh thu ghi nhận';

  @override
  String voucherOrderCountText(Object count) {
    return '$count đơn có sử dụng mã ưu đãi';
  }

  @override
  String get revenueOrderTrend => 'Xu hướng doanh thu và số đơn';

  @override
  String get revenue => 'Doanh thu';

  @override
  String get noTimelineData => 'Chưa có dữ liệu theo thời gian.';

  @override
  String get revenueByCategory => 'Doanh thu theo danh mục';

  @override
  String revenueCategoryCount(Object count) {
    return '$count danh mục phát sinh doanh thu';
  }

  @override
  String get noCategoryRevenue => 'Chưa có doanh thu theo danh mục.';

  @override
  String get sold => 'Đã bán';

  @override
  String get share => 'Tỷ trọng';

  @override
  String get revenueByProduct => 'Doanh thu theo sản phẩm';

  @override
  String revenueProductCount(Object count) {
    return '$count sản phẩm phát sinh doanh thu';
  }

  @override
  String get searchRevenueProductHint => 'Tìm tên, mã hoặc danh mục...';

  @override
  String get noMatchingRevenueProducts => 'Không tìm thấy sản phẩm phù hợp.';

  @override
  String get averageSellingPrice => 'Giá bán TB';

  @override
  String detailByGroup(Object group) {
    return 'Chi tiết theo $group';
  }

  @override
  String periodCountText(Object count) {
    return '$count kỳ dữ liệu trong khoảng đã chọn';
  }

  @override
  String get reportingPeriod => 'Kỳ thống kê';

  @override
  String get revenueMethodology =>
      'Cách tính: chỉ ghi nhận đơn đã giao (Delivered), theo thời điểm hoàn tất đơn. Doanh thu sản phẩm và danh mục là tiền hàng trước khi phân bổ mã giảm giá; tổng doanh thu là số tiền cuối cùng của đơn, đã bao gồm phí và ưu đãi. Vì dữ liệu hiện tại chưa lưu riêng số tiền giảm trên từng sản phẩm, phần giảm giá được ước tính ở cấp đơn hàng.';

  @override
  String monthYear(Object month, Object year) {
    return 'Tháng $month/$year';
  }

  @override
  String yearValue(Object year) {
    return 'Năm $year';
  }

  @override
  String get sessionExpired =>
      'Bạn chưa đăng nhập hoặc phiên làm việc đã hết hạn.';

  @override
  String deliveryListLoadError(Object error) {
    return 'Lỗi tải danh sách vận đơn: $error';
  }

  @override
  String get availableForOrders => 'Bạn đang sẵn sàng nhận đơn.';

  @override
  String get unavailableForOrders => 'Bạn đã chuyển sang không sẵn sàng.';

  @override
  String get shipperPortalTitle => 'Cổng Giao nhận & Lắp đặt';

  @override
  String employeeName(Object name) {
    return 'Nhân viên: $name';
  }

  @override
  String get refreshList => 'Làm mới danh sách';

  @override
  String activeDeliveriesCount(Object count) {
    return 'Đang Giao ($count)';
  }

  @override
  String completedDeliveriesCount(Object count) {
    return 'Đã Hoàn Thành ($count)';
  }

  @override
  String get noPendingDeliveries => 'Hiện không có đơn hàng nào đang chờ giao.';

  @override
  String get noCompletedDeliveries => 'Bạn chưa hoàn thành đơn hàng nào.';

  @override
  String deliveryNoteCode(Object code) {
    return 'Vận đơn #$code';
  }

  @override
  String rescheduledAttempt(Object count) {
    return '⚠️ HẸN LẠI (LẦN $count)';
  }

  @override
  String get deliveringStatus => 'ĐANG GIAO';

  @override
  String get successfulStatus => 'THÀNH CÔNG';

  @override
  String noteText(Object note) {
    return '📝 Ghi chú: $note';
  }

  @override
  String get includesAssemblyBadge => '🛠️ CÓ LẮP ĐẶT';

  @override
  String totalCollection(Object amount) {
    return 'Tổng thu: $amount';
  }

  @override
  String cannotCallNumber(Object phone) {
    return 'Không thể gọi đến số: $phone';
  }

  @override
  String get cannotOpenGoogleMaps => 'Không thể mở bản đồ Google Maps.';

  @override
  String get confirmDeliveryCompletion => 'Xác nhận hoàn tất đơn hàng';

  @override
  String get confirmDeliveryCompletionMessage =>
      'Bạn đã giao nội thất và hoàn thành việc lắp đặt (nếu có) thành công cho khách hàng?';

  @override
  String get confirmComplete => 'Xác nhận hoàn tất';

  @override
  String get deliveryCompletedSuccess =>
      '🎉 Xác nhận giao hàng & lắp đặt thành công!';

  @override
  String get customerAbsentReason => 'Khách vắng nhà (Xin hẹn lại)';

  @override
  String get customerRescheduleReason => 'Khách xin đổi lịch / giờ giao';

  @override
  String get incorrectContactReason => 'Sai thông tin địa chỉ hoặc SĐT';

  @override
  String get technicalIssueReason => 'Sự cố kỹ thuật lắp đặt / hàng hóa';

  @override
  String get weatherTrafficReason => 'Lý do thời tiết / giao thông';

  @override
  String get reportIssue => 'Báo cáo sự cố';

  @override
  String get chooseIncompleteReason => 'Chọn nguyên nhân chưa hoàn thành đơn:';

  @override
  String get issueDetailNote => 'Ghi chú chi tiết / Mong muốn của khách:';

  @override
  String get issueNoteHint =>
      'VD: Khách đi làm về trễ, hẹn giao sáng mai lúc 9h...';

  @override
  String get sendReport => 'Gửi báo cáo';

  @override
  String get issueReportedSuccess =>
      '⚠️ Đã ghi nhận sự cố và chuyển đơn sang trạng thái Hẹn giao lại!';

  @override
  String deliveryDetailTitle(Object code) {
    return 'Chi tiết vận đơn #$code';
  }

  @override
  String get deliveryAssemblySuccessful => 'Giao hàng & Lắp đặt thành công';

  @override
  String get deliveryInProgress => 'Đang thực hiện giao hàng...';

  @override
  String shipperAppointmentSlot(Object slot) {
    return '⏰ Khung giờ hẹn: $slot';
  }

  @override
  String homeAssemblyRequired(Object amount) {
    return '🛠️ CÓ YÊU CẦU LẮP ĐẶT TẠI NHÀ (+$amount)';
  }

  @override
  String incidentHistory(Object notes) {
    return '📝 Lịch sử / Ghi chú sự cố:\n$notes';
  }

  @override
  String get recipientInformation => 'Thông tin người nhận';

  @override
  String get phoneNotUpdated => 'Chưa cập nhật số ĐT';

  @override
  String get callNow => 'Gọi ngay';

  @override
  String get openGoogleMapsDirections => 'Mở Google Maps Chỉ Đường';

  @override
  String deliveryItemsCount(Object count) {
    return 'Danh sách món đồ cần giao ($count sản phẩm)';
  }

  @override
  String colorSizeSummary(Object color, Object size) {
    return 'Màu: $color | Kích thước: $size';
  }

  @override
  String get orderInvoiceSummary => 'Tổng kết đơn & Hóa đơn';

  @override
  String get merchandiseAmount => 'Tiền hàng:';

  @override
  String get grandTotal => 'TỔNG TIỀN:';

  @override
  String paidNoCashCollection(Object method) {
    return 'Đơn hàng ĐÃ THANH TOÁN ($method). Không thu tiền mặt.';
  }

  @override
  String collectCashCod(Object amount) {
    return 'Chưa thanh toán. Vui lòng THU TIỀN MẶT (COD): $amount';
  }

  @override
  String get confirmDeliveryAssemblySuccess =>
      'XÁC NHẬN GIAO HÀNG & LẮP ĐẶT THÀNH CÔNG';

  @override
  String get reportIssueReschedule => 'BÁO CÁO SỰ CỐ / XIN HẸN GIAO LẠI';

  @override
  String get registrationLinkMissingToken =>
      'Liên kết không chứa mã thiết lập mật khẩu.';

  @override
  String get registrationSuccess => 'Đăng ký thành công';

  @override
  String get accountSetup => 'Thiết lập tài khoản';

  @override
  String get invalidRegistrationLink => 'Liên kết không còn hiệu lực';

  @override
  String get requestNewLink => 'YÊU CẦU LIÊN KẾT MỚI';

  @override
  String get createYourPassword => 'Tạo mật khẩu của bạn';

  @override
  String get newPasswordField => 'Mật khẩu mới';

  @override
  String get minimumEightCharacters => 'Tối thiểu 8 ký tự';

  @override
  String get confirmPasswordField => 'Nhập lại mật khẩu';

  @override
  String get passwordMismatch =>
      'Mật khẩu xác nhận không trùng khớp với mật khẩu mới!';

  @override
  String get completeRegistration => 'HOÀN TẤT ĐĂNG KÝ';

  @override
  String get verificationCodeSent => 'Đã gửi mã xác thực về Email của bạn!';

  @override
  String get otpResent => '🔄 Đã tạo và gửi lại mã OTP mới về Email!';

  @override
  String get otpVerifiedSetPassword =>
      '✅ Xác thực OTP thành công! Vui lòng đặt mật khẩu mới.';

  @override
  String get otpRequired => 'Vui lòng nhập mã OTP!';

  @override
  String otpDigitsRequired(Object count) {
    return 'Mã OTP phải gồm đúng $count chữ số!';
  }

  @override
  String get passwordRecoverySuccess =>
      '🎉 Khôi phục mật khẩu thành công! Hãy đăng nhập lại.';

  @override
  String get backPreviousStep => 'Quay lại bước trước';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get otpStep => '2. Mã OTP';

  @override
  String get newPasswordStep => '3. Mật khẩu mới';

  @override
  String get passwordRecoveryTitle => 'Khôi Phục Mật Khẩu';

  @override
  String get passwordRecoveryDescription =>
      'Nhập Email gắn liền với tài khoản của bạn. Hệ thống sẽ gửi một mã xác thực (OTP) để bạn đặt lại mật khẩu mới.';

  @override
  String get yourEmailRequired => 'EMAIL CỦA BẠN (*)';

  @override
  String get emailExample => 'VD: user@example.com';

  @override
  String get sendOtp => 'GỬI MÃ XÁC THỰC OTP';

  @override
  String get verifyOtpTitle => 'Xác Thực Mã OTP';

  @override
  String otpEmailInstruction(Object email) {
    return 'Vui lòng kiểm tra Email “$email” (cả hộp thư Rác/Spam) và nhập mã 6 số vừa nhận được vào bên dưới.';
  }

  @override
  String get sixDigitVerificationCode => 'MÃ XÁC THỰC 6 SỐ';

  @override
  String resendAfterSeconds(Object seconds) {
    return 'Gửi lại mã sau (${seconds}s)';
  }

  @override
  String get emailNotReceived => 'Chưa nhận được email?';

  @override
  String get resendNewCode => '🔄 Gửi Lại Mã Mới';

  @override
  String get confirmOtp => 'XÁC NHẬN MÃ OTP';

  @override
  String get notEntered => 'Chưa nhập';

  @override
  String get weak => 'Yếu';

  @override
  String get medium => 'Trung bình';

  @override
  String get strong => 'Mạnh';

  @override
  String get createNewPassword => 'Tạo Mật Khẩu Mới';

  @override
  String verifiedPasswordInstruction(Object email) {
    return 'Mã xác thực thành công. Vui lòng thiết lập mật khẩu mới cho tài khoản “$email”.';
  }

  @override
  String get newPasswordRequired => 'MẬT KHẨU MỚI (*)';

  @override
  String get minimumSixCharactersHint => 'Ít nhất 6 ký tự...';

  @override
  String passwordStrength(Object strength) {
    return 'Độ mạnh: $strength';
  }

  @override
  String get confirmPasswordRequired => 'XÁC NHẬN MẬT KHẨU (*)';

  @override
  String get confirmNewPasswordHint => 'Nhập lại mật khẩu mới...';

  @override
  String get savePasswordComplete => 'LƯU MẬT KHẨU & HOÀN TẤT';

  @override
  String get aiFromRoomAndProducts => 'AI tạo phối cảnh từ phòng và sản phẩm';

  @override
  String get aiFromRoomAndProductsDescription =>
      'Thêm các sản phẩm muốn phối vào phòng. AI sẽ tạo một ảnh mới, tự cân chỉnh vị trí, góc nhìn và ánh sáng.';

  @override
  String get addProductToAiScene => 'Thêm sản phẩm vào phối cảnh';

  @override
  String get selectedProducts => 'Sản phẩm đã thêm';

  @override
  String get removeProductFromScene => 'Bỏ sản phẩm khỏi phối cảnh';

  @override
  String get chooseAtLeastOneProduct =>
      'Vui lòng chọn ảnh phòng và ít nhất một sản phẩm.';

  @override
  String get chatServiceBusy =>
      'Trợ lý AI đang bận. Hệ thống sẽ tự thử lại; bạn cũng có thể gửi lại sau ít phút.';

  @override
  String get retryMessage => 'Gửi lại';

  @override
  String get chatReadyStatus => 'Sẵn sàng tư vấn nội thất';

  @override
  String get addressSaved => 'Đã lưu địa chỉ thành công.';

  @override
  String get addressDeleted => 'Đã xóa địa chỉ.';

  @override
  String get confirmDeleteAddress => 'Bạn có chắc muốn xóa địa chỉ này?';

  @override
  String get addressRequiredFields =>
      'Vui lòng nhập đầy đủ người nhận, số điện thoại và địa chỉ.';

  @override
  String get chooseSavedAddress => 'Chọn địa chỉ đã lưu';

  @override
  String get savedAddresses => 'Địa chỉ đã lưu';

  @override
  String get useThisAddress => 'Sử dụng địa chỉ này';

  @override
  String get revenueByMonthDashboard => 'Doanh thu theo tháng';

  @override
  String get ordersByMonthDashboard => 'Tỷ lệ đơn giao thành công theo tháng';

  @override
  String get noDashboardChartData => 'Chưa có dữ liệu để hiển thị biểu đồ.';

  @override
  String get supportChatTitle => 'TRÒ CHUYỆN HỖ TRỢ';

  @override
  String get supportChatDescription =>
      'Trao đổi trực tiếp với bộ phận chăm sóc khách hàng.';

  @override
  String get newSupportConversation => 'Cuộc trò chuyện mới';

  @override
  String get createSupportConversation => 'Bắt đầu trò chuyện';

  @override
  String get supportTopic => 'Chủ đề hỗ trợ';

  @override
  String get supportFirstMessageHint => 'Mô tả vấn đề bạn cần hỗ trợ...';

  @override
  String get supportFirstMessageValidation =>
      'Nội dung mở đầu cần có ít nhất 10 ký tự.';

  @override
  String get supportMessageTooLong =>
      'Tin nhắn không được vượt quá 4.000 ký tự.';

  @override
  String get noSupportConversations =>
      'Bạn chưa có cuộc trò chuyện hỗ trợ nào.';

  @override
  String get noConversationSelected => 'Chưa chọn cuộc trò chuyện';

  @override
  String get chooseConversationHint =>
      'Chọn một cuộc trò chuyện bên trái hoặc tạo cuộc trò chuyện mới.';

  @override
  String get noMessagesYet => 'Chưa có tin nhắn';

  @override
  String get supportMessageHint => 'Nhập tin nhắn...';

  @override
  String get sendSupportMessage => 'Gửi tin nhắn';

  @override
  String get adminSupport => 'Bộ phận hỗ trợ';

  @override
  String get supportOnline => 'Trực tuyến';

  @override
  String get supportConnecting => 'Đang kết nối';

  @override
  String get supportReconnecting => 'Đang kết nối lại';

  @override
  String get supportOffline => 'Ngoại tuyến';

  @override
  String get waitingForAdmin => 'Đang chờ bộ phận hỗ trợ';

  @override
  String get waitingForCustomer => 'Đang chờ phản hồi của bạn';

  @override
  String get supportClosed => 'Đã đóng';

  @override
  String get supportActive => 'Đang hỗ trợ';

  @override
  String get supportConversationClosed =>
      'Cuộc trò chuyện này đã đóng. Hãy tạo cuộc trò chuyện mới nếu bạn cần thêm hỗ trợ.';

  @override
  String get backToConversations => 'Quay lại danh sách trò chuyện';

  @override
  String get adminSupportInboxTitle => 'HỘP THƯ HỖ TRỢ REALTIME';

  @override
  String get adminSupportInboxDescription =>
      'Theo dõi và phản hồi hội thoại của khách hàng theo thời gian thực.';

  @override
  String get needsAdminReply => 'Cần phản hồi';

  @override
  String get awaitingCustomer => 'Chờ khách hàng';

  @override
  String get allSupportConversations => 'Tất cả';

  @override
  String get searchSupportConversation => 'Tìm khách hàng, email...';

  @override
  String get noAdminSupportConversations => 'Không có hội thoại phù hợp.';

  @override
  String get adminChooseConversation =>
      'Chọn một hội thoại để bắt đầu hỗ trợ khách hàng.';

  @override
  String get assignToMe => 'Nhận xử lý';

  @override
  String assignedAdmin(String name) {
    return 'Phụ trách: $name';
  }

  @override
  String get reopenConversation => 'Mở lại hội thoại';

  @override
  String get closeConversation => 'Đóng hội thoại';

  @override
  String get adminClosedConversationHint =>
      'Hội thoại đã đóng. Mở lại nếu cần tiếp tục trao đổi.';

  @override
  String get adminSupportReplyHint =>
      'Nhập nội dung phản hồi cho khách hàng...';

  @override
  String get adminReplyEmailNotice =>
      'Khách hàng sẽ nhận tin nhắn realtime và email thông báo phản hồi.';

  @override
  String get supportIsTyping => 'Bộ phận hỗ trợ đang nhập...';

  @override
  String get customerIsTyping => 'Khách hàng đang nhập...';

  @override
  String get shipperProfileTitle => 'Hồ sơ giao hàng';

  @override
  String get vehicleType => 'Loại phương tiện';

  @override
  String get vehiclePlate => 'Biển số xe';

  @override
  String get serviceArea => 'Khu vực hoạt động';

  @override
  String get maxConcurrentDeliveries => 'Số đơn tối đa cùng lúc';

  @override
  String get canHandleBulkyItems => 'Có thể chở hàng cồng kềnh';

  @override
  String get canProvideAssembly => 'Có thể hỗ trợ lắp đặt';

  @override
  String get shiftEnd => 'Kết thúc ca';

  @override
  String get shiftAvailable => 'Sẵn sàng';

  @override
  String get shiftDelivering => 'Đang giao';

  @override
  String get shiftBreak => 'Tạm nghỉ';

  @override
  String get deliveryDirections => 'Chỉ đường';

  @override
  String get callCustomer => 'Gọi khách';

  @override
  String get acceptDelivery => 'Chấp nhận đơn';

  @override
  String get rejectDelivery => 'Từ chối đơn';

  @override
  String get rejectDeliveryTitle => 'Từ chối đơn giao hàng';

  @override
  String get rejectReason => 'Lý do từ chối';

  @override
  String get assignmentAccepted => 'Đã chấp nhận đơn giao hàng.';

  @override
  String get assignmentRejected => 'Đã chuyển đơn về Admin để phân công lại.';

  @override
  String get pickedUpFromWarehouse => 'Đã nhận hàng từ kho';

  @override
  String get pickedUpConfirmed => 'Đã xác nhận nhận hàng từ kho.';

  @override
  String get startDelivery => 'Bắt đầu giao hàng';

  @override
  String get deliveryOnTheWay => 'Đơn hàng đang trên đường giao.';

  @override
  String get arrivedDestination => 'Đã đến nơi';

  @override
  String get arrivedNotification => 'Đã thông báo shipper đến nơi.';

  @override
  String get verifyRecipient => 'Xác minh người nhận';

  @override
  String get sendOtpByEmail => 'Gửi OTP qua email';

  @override
  String get deliveryOtpLabel => 'Mã OTP 6 số';

  @override
  String get verifyOtp => 'Xác minh';

  @override
  String get otpVerified => 'OTP đã xác minh';

  @override
  String get otpSent => 'Đã gửi OTP đến email của khách hàng.';

  @override
  String get otpMustBeSixDigits => 'OTP phải gồm đúng 6 chữ số.';

  @override
  String get otpVerifiedSuccess => 'Xác minh OTP thành công.';

  @override
  String get actualRecipientName => 'Tên người thực tế nhận hàng';

  @override
  String get chooseDeliveryProof => 'Chụp/chọn ảnh bằng chứng';

  @override
  String get changeDeliveryProof => 'Đổi ảnh bằng chứng';

  @override
  String get confirmDelivered => 'Xác nhận giao thành công';

  @override
  String get deliveryStatusAssigned => 'Chờ shipper nhận';

  @override
  String get deliveryStatusAccepted => 'Đã nhận đơn';

  @override
  String get deliveryStatusPickedUp => 'Đã lấy hàng';

  @override
  String get deliveryStatusShipping => 'Đang giao hàng';

  @override
  String get deliveryStatusArrived => 'Đã đến nơi';

  @override
  String get deliveryOtpRequired => 'Vui lòng xác minh OTP của người nhận.';

  @override
  String get deliveryProofRequired => 'Vui lòng tải ảnh bằng chứng giao hàng.';

  @override
  String get deliveryRecipientRequired =>
      'Vui lòng nhập tên người thực tế nhận hàng.';

  @override
  String get attachIssueProof => 'Đính kèm ảnh sự cố';

  @override
  String get confirmCollectedPayment => 'Xác nhận đã thu tiền';

  @override
  String confirmCollectedPaymentMessage(String amount) {
    return 'Bạn xác nhận đã thu đúng $amount từ khách hàng?';
  }

  @override
  String get paymentCollectedSuccess => 'Đã ghi nhận thu tiền thành công.';

  @override
  String get collectPaymentBeforeComplete =>
      'Vui lòng xác nhận đã thu tiền COD/POS trước khi hoàn tất.';

  @override
  String amountToCollect(String amount) {
    return 'Số tiền cần thu: $amount';
  }

  @override
  String paymentMethodSummary(String method) {
    return 'Phương thức: $method';
  }

  @override
  String get paymentCollected => 'Đã xác nhận thu đủ tiền';

  @override
  String get paymentCollectionNote => 'Ghi chú thu tiền (không bắt buộc)';

  @override
  String get addPaymentProof => 'Thêm ảnh bằng chứng thanh toán';

  @override
  String get changePaymentProof => 'Đổi ảnh bằng chứng thanh toán';

  @override
  String get confirmPaymentCollected => 'Xác nhận đã thu tiền';

  @override
  String get handoverPending => 'Chờ shipper bàn giao';

  @override
  String get handoverSubmitted => 'Chờ Admin xác nhận';

  @override
  String get handoverConfirmed => 'Đã đối soát';

  @override
  String get handoverRejected => 'Cần kiểm tra lại';

  @override
  String handoverStatusSummary(String status) {
    return 'Đối soát: $status';
  }

  @override
  String get reconciliationTab => 'Đối soát';

  @override
  String get performanceTab => 'Hiệu suất';

  @override
  String get byWeek => 'Theo tuần';

  @override
  String get collectionReconciliationTitle => 'Thu tiền và đối soát';

  @override
  String get totalCollected => 'Đã thu';

  @override
  String get pendingHandover => 'Chờ bàn giao';

  @override
  String get confirmedHandover => 'Đã xác nhận';

  @override
  String submitMoneyHandover(int count) {
    return 'Gửi bàn giao $count khoản';
  }

  @override
  String get reconciliationSubmittedSuccess =>
      'Đã gửi yêu cầu bàn giao tiền cho Admin.';

  @override
  String get noCollectedPayments => 'Chưa có khoản thu nào trong kỳ này.';

  @override
  String get personalPerformanceTitle => 'Hiệu suất cá nhân';

  @override
  String get activeOrdersMetric => 'Đơn đang giao';

  @override
  String get completedOrdersMetric => 'Đơn hoàn thành';

  @override
  String get failedDeliveriesMetric => 'Lần giao thất bại';

  @override
  String get totalDistanceMetric => 'Tổng quãng đường';

  @override
  String get onTimeRateMetric => 'Tỷ lệ đúng hẹn';

  @override
  String get rescheduleCountMetric => 'Số lần hẹn lại';

  @override
  String get averageDeliveryTimeMetric => 'Thời gian giao trung bình';

  @override
  String minuteCount(int count) {
    return '$count phút';
  }

  @override
  String get performanceTrend => 'Chi tiết theo ngày';

  @override
  String get noPerformanceData => 'Chưa có dữ liệu hiệu suất.';

  @override
  String performanceTrendSummary(int completed, int failed, double distance) {
    return 'Hoàn thành $completed · Thất bại $failed · $distance km';
  }

  @override
  String adminOnTimeRate(double rate) {
    return 'Đúng hẹn $rate%';
  }

  @override
  String adminFailedAttempts(int count) {
    return 'Thất bại $count';
  }

  @override
  String get adminReconciliationTitle => 'Đối soát tiền thu hộ';

  @override
  String get adminReconciliationDescription =>
      'Xác nhận các khoản COD/POS shipper đã thu và bàn giao.';

  @override
  String waitingHandoverSummary(int count, String amount) {
    return 'Chờ xác nhận: $count khoản · $amount';
  }

  @override
  String get noReconciliationEntries => 'Chưa có dữ liệu đối soát.';

  @override
  String get paymentProof => 'Bằng chứng thanh toán';

  @override
  String get confirmHandover => 'Xác nhận bàn giao';

  @override
  String get confirmMoneyHandoverTitle => 'Xác nhận đã nhận tiền bàn giao';

  @override
  String get rejectReconciliationTitle => 'Trả lại đối soát';

  @override
  String get reconciliationNoteOptional => 'Ghi chú (không bắt buộc)';

  @override
  String get rejectionReasonRequired => 'Lý do yêu cầu kiểm tra lại';

  @override
  String get handoverConfirmedSuccess => 'Đã xác nhận shipper bàn giao tiền.';

  @override
  String get reconciliationRejectedSuccess =>
      'Đã yêu cầu shipper kiểm tra lại khoản đối soát.';

  @override
  String get shipperCancelOrder => 'Hủy đơn hàng';

  @override
  String get shipperCancelWarning =>
      'Thao tác này sẽ hủy đơn, hoàn lại tồn kho và không thể hoàn tác. Admin và khách hàng sẽ được thông báo.';

  @override
  String get cancellationReason => 'Lý do hủy đơn';

  @override
  String get cancellationNote => 'Ghi chú chi tiết';

  @override
  String get cancellationNoteHint =>
      'Mô tả thêm tình trạng đơn hàng (không bắt buộc)';

  @override
  String get shipperCancelCustomerRefused => 'Khách hàng từ chối nhận hàng';

  @override
  String get shipperCancelDamagedGoods =>
      'Hàng hóa hư hỏng hoặc không an toàn để giao';

  @override
  String get shipperCancelIncorrectOrder =>
      'Sai sản phẩm hoặc sai thông tin đơn hàng';

  @override
  String get shipperCancelUnsafeDelivery => 'Không thể giao hàng an toàn';

  @override
  String get otherReason => 'Lý do khác';

  @override
  String get optionalCancellationProof => 'Ảnh bằng chứng hủy (không bắt buộc)';

  @override
  String get cancellationProof => 'Bằng chứng hủy';

  @override
  String get shipperCancelSuccess => 'Đã hủy đơn hàng và thông báo cho admin.';

  @override
  String get paidOrderCancellationRequiresAdmin =>
      'Đơn đã thanh toán hoặc đã thu tiền; cần admin xử lý hoàn tiền trước khi hủy.';

  @override
  String deliveryHistoryCount(int count) {
    return 'Lịch sử ($count)';
  }

  @override
  String showMoreColors(int count) {
    return 'Xem thêm $count màu';
  }

  @override
  String get showFewerColors => 'Thu gọn';
}
