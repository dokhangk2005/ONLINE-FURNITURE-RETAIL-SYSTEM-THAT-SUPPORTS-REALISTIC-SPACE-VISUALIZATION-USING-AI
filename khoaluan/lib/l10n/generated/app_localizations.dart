import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'My Furniture Store'**
  String get appTitle;

  /// No description provided for @navProducts.
  ///
  /// In vi, this message translates to:
  /// **'SẢN PHẨM'**
  String get navProducts;

  /// No description provided for @navRoomDesign.
  ///
  /// In vi, this message translates to:
  /// **'PHỐI CẢNH'**
  String get navRoomDesign;

  /// No description provided for @navAbout.
  ///
  /// In vi, this message translates to:
  /// **'GIỚI THIỆU'**
  String get navAbout;

  /// No description provided for @navContact.
  ///
  /// In vi, this message translates to:
  /// **'LIÊN HỆ'**
  String get navContact;

  /// No description provided for @accountInfo.
  ///
  /// In vi, this message translates to:
  /// **'THÔNG TIN TÀI KHOẢN'**
  String get accountInfo;

  /// No description provided for @yourAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản của bạn'**
  String get yourAccount;

  /// No description provided for @profileMenuTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get profileMenuTitle;

  /// No description provided for @addressList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách địa chỉ'**
  String get addressList;

  /// No description provided for @deliveryHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử giao hàng'**
  String get deliveryHistory;

  /// No description provided for @adminPage.
  ///
  /// In vi, this message translates to:
  /// **'Quay về trang admin'**
  String get adminPage;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @loggedOut.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng xuất'**
  String get loggedOut;

  /// No description provided for @accountOf.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản của'**
  String get accountOf;

  /// No description provided for @loginRegister.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập / Đăng ký'**
  String get loginRegister;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @cart.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng'**
  String get cart;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @helloUser.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào, {name}'**
  String helloUser(String name);

  /// No description provided for @footerDescription.
  ///
  /// In vi, this message translates to:
  /// **'Từ thiết kế, sản xuất đến vận chuyển và hậu mãi, chúng tôi cung cấp giải pháp nội thất trọn gói tại Việt Nam.'**
  String get footerDescription;

  /// No description provided for @exploreMore.
  ///
  /// In vi, this message translates to:
  /// **'KHÁM PHÁ THÊM'**
  String get exploreMore;

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'TRANG CHỦ'**
  String get home;

  /// No description provided for @contactUs.
  ///
  /// In vi, this message translates to:
  /// **'LIÊN HỆ VỚI CHÚNG TÔI'**
  String get contactUs;

  /// No description provided for @companyAddress.
  ///
  /// In vi, this message translates to:
  /// **'Đường P, Tổ 4, xã Sông Vĩnh\nPhường Tân Phước, thị xã Phú Mỹ, Bà Rịa\nTỉnh Vũng Tàu'**
  String get companyAddress;

  /// No description provided for @homeLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String homeLoadError(Object error);

  /// No description provided for @noProducts.
  ///
  /// In vi, this message translates to:
  /// **'Không có sản phẩm nào.'**
  String get noProducts;

  /// No description provided for @categories.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get categories;

  /// No description provided for @bestSellingProducts.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm bán chạy'**
  String get bestSellingProducts;

  /// No description provided for @viewMore.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm'**
  String get viewMore;

  /// No description provided for @soldCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã bán {count}'**
  String soldCount(int count);

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập hoặc đăng ký'**
  String get loginTitle;

  /// No description provided for @loginIntro.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email để đăng nhập bằng mật khẩu hoặc đăng ký nhanh. Khi đăng ký, hệ thống sẽ gửi liên kết để bạn tự thiết lập mật khẩu.'**
  String get loginIntro;

  /// No description provided for @emailAddress.
  ///
  /// In vi, this message translates to:
  /// **'ĐỊA CHỈ EMAIL'**
  String get emailAddress;

  /// No description provided for @emailField.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ email'**
  String get emailField;

  /// No description provided for @loginWithPassword.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG NHẬP BẰNG MẬT KHẨU'**
  String get loginWithPassword;

  /// No description provided for @quickRegister.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG KÝ NHANH'**
  String get quickRegister;

  /// No description provided for @secureLinkHint.
  ///
  /// In vi, this message translates to:
  /// **'Không có mật khẩu được gửi qua email. Bạn tự đặt mật khẩu qua liên kết bảo mật.'**
  String get secureLinkHint;

  /// No description provided for @backHome.
  ///
  /// In vi, this message translates to:
  /// **'Quay về trang chủ'**
  String get backHome;

  /// No description provided for @invalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập một địa chỉ email hợp lệ.'**
  String get invalidEmail;

  /// No description provided for @checkEmailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra email của bạn'**
  String get checkEmailTitle;

  /// No description provided for @quickRegisterDialogBody.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống đã gửi liên kết thiết lập mật khẩu đến email của bạn.\n\nLiên kết chỉ dùng được một lần và hết hạn sau 30 phút. Nếu chưa thấy email, hãy kiểm tra cả thư mục Spam/Rác.'**
  String get quickRegisterDialogBody;

  /// No description provided for @understood.
  ///
  /// In vi, this message translates to:
  /// **'ĐÃ HIỂU'**
  String get understood;

  /// No description provided for @passwordLoginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập bằng mật khẩu'**
  String get passwordLoginTitle;

  /// No description provided for @passwordLoginWelcome.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn trở lại My Furniture Store. Vui lòng nhập email hoặc tên đăng nhập và mật khẩu để truy cập tài khoản.'**
  String get passwordLoginWelcome;

  /// No description provided for @emailOrUsername.
  ///
  /// In vi, this message translates to:
  /// **'EMAIL HOẶC TÊN ĐĂNG NHẬP'**
  String get emailOrUsername;

  /// No description provided for @emailOrUsernameField.
  ///
  /// In vi, this message translates to:
  /// **'Email hoặc tên đăng nhập'**
  String get emailOrUsernameField;

  /// No description provided for @emailOrUsernameHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email hoặc tên tài khoản...'**
  String get emailOrUsernameHint;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'MẬT KHẨU'**
  String get password;

  /// No description provided for @passwordField.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordField;

  /// No description provided for @passwordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu của bạn...'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG NHẬP'**
  String get login;

  /// No description provided for @loginSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thành công! Xin chào {name}'**
  String loginSuccess(String name);

  /// No description provided for @incompleteLogin.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng kiểm tra và điền đầy đủ thông tin đăng nhập!'**
  String get incompleteLogin;

  /// No description provided for @requiredField.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập {field}!'**
  String requiredField(String field);

  /// No description provided for @minLengthField.
  ///
  /// In vi, this message translates to:
  /// **'{field} phải có ít nhất {count} ký tự!'**
  String minLengthField(String field, int count);

  /// No description provided for @backToLoginOptions.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại lựa chọn đăng nhập'**
  String get backToLoginOptions;

  /// No description provided for @allProductsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả sản phẩm My Furniture Home'**
  String get allProductsTitle;

  /// No description provided for @sortFeatured.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm nổi bật'**
  String get sortFeatured;

  /// No description provided for @sortNewest.
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get sortNewest;

  /// No description provided for @sortPriceLowHigh.
  ///
  /// In vi, this message translates to:
  /// **'Giá: Thấp đến Cao'**
  String get sortPriceLowHigh;

  /// No description provided for @sortPriceHighLow.
  ///
  /// In vi, this message translates to:
  /// **'Giá: Cao đến Thấp'**
  String get sortPriceHighLow;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @colors.
  ///
  /// In vi, this message translates to:
  /// **'Màu sắc'**
  String get colors;

  /// No description provided for @sizes.
  ///
  /// In vi, this message translates to:
  /// **'Kích thước'**
  String get sizes;

  /// No description provided for @filters.
  ///
  /// In vi, this message translates to:
  /// **'BỘ LỌC'**
  String get filters;

  /// No description provided for @filtersActive.
  ///
  /// In vi, this message translates to:
  /// **'BỘ LỌC ({count})'**
  String filtersActive(int count);

  /// No description provided for @detailedFilters.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc chi tiết'**
  String get detailedFilters;

  /// No description provided for @closeFilters.
  ///
  /// In vi, this message translates to:
  /// **'Đóng bộ lọc'**
  String get closeFilters;

  /// No description provided for @priceRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng giá'**
  String get priceRange;

  /// No description provided for @clearFilters.
  ///
  /// In vi, this message translates to:
  /// **'XÓA BỘ LỌC'**
  String get clearFilters;

  /// No description provided for @productPrice.
  ///
  /// In vi, this message translates to:
  /// **'GIÁ SẢN PHẨM'**
  String get productPrice;

  /// No description provided for @abovePrice.
  ///
  /// In vi, this message translates to:
  /// **'Trên {price}'**
  String abovePrice(String price);

  /// No description provided for @belowPrice.
  ///
  /// In vi, this message translates to:
  /// **'Dưới {price}'**
  String belowPrice(String price);

  /// No description provided for @allSubcategories.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả danh mục con'**
  String get allSubcategories;

  /// No description provided for @allCategories.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả danh mục'**
  String get allCategories;

  /// No description provided for @allPriceRanges.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả mức giá'**
  String get allPriceRanges;

  /// No description provided for @allColors.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả màu sắc'**
  String get allColors;

  /// No description provided for @allSizes.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả kích thước'**
  String get allSizes;

  /// No description provided for @noMatchingProducts.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sản phẩm phù hợp.'**
  String get noMatchingProducts;

  /// No description provided for @productNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sản phẩm!'**
  String get productNotFound;

  /// No description provided for @inStock.
  ///
  /// In vi, this message translates to:
  /// **'Còn hàng: {count} sản phẩm'**
  String inStock(int count);

  /// No description provided for @temporarilyOutOfStock.
  ///
  /// In vi, this message translates to:
  /// **'Hết hàng (Tạm thời hết)'**
  String get temporarilyOutOfStock;

  /// No description provided for @productDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả sản phẩm'**
  String get productDescription;

  /// No description provided for @noProductDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mô tả cho sản phẩm này.'**
  String get noProductDescription;

  /// No description provided for @dimensionsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Kích thước:'**
  String get dimensionsLabel;

  /// No description provided for @materialLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chất liệu:'**
  String get materialLabel;

  /// No description provided for @outOfStock.
  ///
  /// In vi, this message translates to:
  /// **'HẾT HÀNG'**
  String get outOfStock;

  /// No description provided for @addToCart.
  ///
  /// In vi, this message translates to:
  /// **'THÊM VÀO GIỎ HÀNG'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In vi, this message translates to:
  /// **'MUA NGAY'**
  String get buyNow;

  /// No description provided for @tryInYourRoom.
  ///
  /// In vi, this message translates to:
  /// **'THỬ TRONG KHÔNG GIAN CỦA BẠN'**
  String get tryInYourRoom;

  /// No description provided for @frequentlyBoughtTogether.
  ///
  /// In vi, this message translates to:
  /// **'THƯỜNG ĐƯỢC MUA CÙNG'**
  String get frequentlyBoughtTogether;

  /// No description provided for @relatedProducts.
  ///
  /// In vi, this message translates to:
  /// **'SẢN PHẨM LIÊN QUAN'**
  String get relatedProducts;

  /// No description provided for @productReviews.
  ///
  /// In vi, this message translates to:
  /// **'ĐÁNH GIÁ SẢN PHẨM'**
  String get productReviews;

  /// No description provided for @averageRating.
  ///
  /// In vi, this message translates to:
  /// **'ĐÁNH GIÁ TRUNG BÌNH\n({count} đánh giá)'**
  String averageRating(int count);

  /// No description provided for @reviewDistribution.
  ///
  /// In vi, this message translates to:
  /// **'{percent}% | {count} đánh giá'**
  String reviewDistribution(String percent, int count);

  /// No description provided for @reviewDeliveredOnly.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chỉ có thể đánh giá sản phẩm trong đơn hàng đã giao.'**
  String get reviewDeliveredOnly;

  /// No description provided for @viewOrderHistory.
  ///
  /// In vi, this message translates to:
  /// **'XEM LỊCH SỬ ĐƠN HÀNG'**
  String get viewOrderHistory;

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @noMatchingReviews.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá nào phù hợp với bộ lọc.'**
  String get noMatchingReviews;

  /// No description provided for @noWrittenReview.
  ///
  /// In vi, this message translates to:
  /// **'Không có ý kiến viết bằng chữ.'**
  String get noWrittenReview;

  /// No description provided for @storeReply.
  ///
  /// In vi, this message translates to:
  /// **'Phản hồi từ cửa hàng'**
  String get storeReply;

  /// No description provided for @cartItemCount.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng ({count})'**
  String cartItemCount(int count);

  /// No description provided for @yourCart.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng của bạn'**
  String get yourCart;

  /// No description provided for @remove.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get remove;

  /// No description provided for @emptyCart.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng của bạn đang trống'**
  String get emptyCart;

  /// No description provided for @continueShopping.
  ///
  /// In vi, this message translates to:
  /// **'TIẾP TỤC MUA SẮM'**
  String get continueShopping;

  /// No description provided for @orderInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin đơn hàng'**
  String get orderInformation;

  /// No description provided for @total.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền:'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In vi, this message translates to:
  /// **'THANH TOÁN'**
  String get checkout;

  /// No description provided for @continueBuying.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục mua hàng'**
  String get continueBuying;

  /// No description provided for @voucherWallet.
  ///
  /// In vi, this message translates to:
  /// **'Kho Voucher Ưu Đãi'**
  String get voucherWallet;

  /// No description provided for @currentOrder.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng hiện tại: {amount}'**
  String currentOrder(String amount);

  /// No description provided for @noAvailableVouchers.
  ///
  /// In vi, this message translates to:
  /// **'Hiện không có mã ưu đãi nào khả dụng trong kho của bạn.'**
  String get noAvailableVouchers;

  /// No description provided for @discountPercent.
  ///
  /// In vi, this message translates to:
  /// **'GIẢM {value}%'**
  String discountPercent(String value);

  /// No description provided for @discountAmount.
  ///
  /// In vi, this message translates to:
  /// **'GIẢM {amount}'**
  String discountAmount(String amount);

  /// No description provided for @expiresOn.
  ///
  /// In vi, this message translates to:
  /// **'HSD: {date}'**
  String expiresOn(String date);

  /// No description provided for @voucherUsage.
  ///
  /// In vi, this message translates to:
  /// **'Đã dùng: {used}/{limit}'**
  String voucherUsage(int used, int limit);

  /// No description provided for @spendMoreToUse.
  ///
  /// In vi, this message translates to:
  /// **'Mua thêm {amount} để dùng'**
  String spendMoreToUse(String amount);

  /// No description provided for @apply.
  ///
  /// In vi, this message translates to:
  /// **'ÁP DỤNG'**
  String get apply;

  /// No description provided for @morningSlot.
  ///
  /// In vi, this message translates to:
  /// **'Sáng (08:00 - 12:00)'**
  String get morningSlot;

  /// No description provided for @afternoonSlot.
  ///
  /// In vi, this message translates to:
  /// **'Chiều (13:00 - 17:00)'**
  String get afternoonSlot;

  /// No description provided for @eveningSlot.
  ///
  /// In vi, this message translates to:
  /// **'Tối (18:00 - 20:00)'**
  String get eveningSlot;

  /// No description provided for @enterOrSelectVoucher.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập hoặc chọn mã khuyến mãi.'**
  String get enterOrSelectVoucher;

  /// No description provided for @loginBeforeOrdering.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập trước khi đặt hàng.'**
  String get loginBeforeOrdering;

  /// No description provided for @checkCheckoutInformation.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng kiểm tra lại họ tên, số điện thoại hoặc email hợp lệ trước khi đặt hàng!'**
  String get checkCheckoutInformation;

  /// No description provided for @cartIsEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng của bạn đang trống!'**
  String get cartIsEmpty;

  /// No description provided for @paymentMaintenance.
  ///
  /// In vi, this message translates to:
  /// **'MoMo và QR đang được bảo trì. Vui lòng chọn chuyển khoản, POS hoặc VNPay.'**
  String get paymentMaintenance;

  /// No description provided for @missingVnPayUrl.
  ///
  /// In vi, this message translates to:
  /// **'Backend không trả về đường dẫn thanh toán VNPay.'**
  String get missingVnPayUrl;

  /// No description provided for @cannotOpenVnPay.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở cổng thanh toán VNPay.'**
  String get cannotOpenVnPay;

  /// No description provided for @createOrderError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tạo đơn hàng: {error}'**
  String createOrderError(Object error);

  /// No description provided for @vnPaySuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán VNPay thành công'**
  String get vnPaySuccess;

  /// No description provided for @vnPayFailed.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán VNPay thất bại'**
  String get vnPayFailed;

  /// No description provided for @paidOrderMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng #{orderId} đã được thanh toán và đang chờ cửa hàng xác nhận.'**
  String paidOrderMessage(String orderId);

  /// No description provided for @failedOrderMessage.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch không thành công hoặc đã bị hủy. Đơn hàng #{orderId} đã được hủy và tồn kho được hoàn lại.'**
  String failedOrderMessage(String orderId);

  /// No description provided for @orderRecorded.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi nhận đơn hàng!'**
  String get orderRecorded;

  /// No description provided for @orderSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đặt hàng thành công!'**
  String get orderSuccess;

  /// No description provided for @bankTransferInstructions.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng của bạn đã được ghi nhận thành công.\nVui lòng thực hiện chuyển khoản ngân hàng theo thông tin hiển thị để đơn hàng được duyệt giao sớm nhất.'**
  String get bankTransferInstructions;

  /// No description provided for @orderThankYou.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn {name} đã đặt hàng.\nĐơn hàng của bạn đã hoàn tất thanh toán (POS) và đang được xử lý.'**
  String orderThankYou(String name);

  /// No description provided for @loginBenefit.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để mua hàng tiện lợi và nhận nhiều ưu đãi hơn nữa'**
  String get loginBenefit;

  /// No description provided for @loginAction.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginAction;

  /// No description provided for @shippingInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin giao hàng'**
  String get shippingInformation;

  /// No description provided for @enterFullName.
  ///
  /// In vi, this message translates to:
  /// **'Nhập họ và tên (*)'**
  String get enterFullName;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên'**
  String get fullName;

  /// No description provided for @enterPhone.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số điện thoại (*)'**
  String get enterPhone;

  /// No description provided for @phoneNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phoneNumber;

  /// No description provided for @invalidPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0!'**
  String get invalidPhone;

  /// No description provided for @enterOrderEmail.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email (* để nhận thông báo đặt hàng)'**
  String get enterOrderEmail;

  /// No description provided for @country.
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia'**
  String get country;

  /// No description provided for @vietnam.
  ///
  /// In vi, this message translates to:
  /// **'Việt Nam'**
  String get vietnam;

  /// No description provided for @streetAddress.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ, tên đường (*)'**
  String get streetAddress;

  /// No description provided for @address.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ'**
  String get address;

  /// No description provided for @regionAutoFill.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh/TP, Quận/Huyện, Phường/Xã (Tự động điền)'**
  String get regionAutoFill;

  /// No description provided for @selectDeliveryArea.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn khu vực giao hàng'**
  String get selectDeliveryArea;

  /// No description provided for @deliveryAssemblyService.
  ///
  /// In vi, this message translates to:
  /// **'Dịch vụ Giao hàng & Lắp đặt tại nhà'**
  String get deliveryAssemblyService;

  /// No description provided for @deliveryEstimate.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính khoảng cách giao hàng: {distance} km\nPhí vận chuyển theo số km: {fee}'**
  String deliveryEstimate(String distance, String fee);

  /// No description provided for @selectDeliveryTime.
  ///
  /// In vi, this message translates to:
  /// **'Chọn khung giờ nhận hàng trong ngày:'**
  String get selectDeliveryTime;

  /// No description provided for @assemblySupport.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu thợ hỗ trợ lắp đặt nội thất tận nhà'**
  String get assemblySupport;

  /// No description provided for @fixedAssemblyFee.
  ///
  /// In vi, this message translates to:
  /// **'Phí lắp đặt dịch vụ cố định: +{fee}'**
  String fixedAssemblyFee(String fee);

  /// No description provided for @paymentMethod.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức thanh toán'**
  String get paymentMethod;

  /// No description provided for @bankTransferPayment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán chuyển khoản qua ngân hàng'**
  String get bankTransferPayment;

  /// No description provided for @accountName.
  ///
  /// In vi, this message translates to:
  /// **'Tên tài khoản: Công ty Cổ phần Hợp Tác Kinh Tế Và Xuất Nhập Khẩu Savimex'**
  String get accountName;

  /// No description provided for @accountNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số tài khoản: 0071001303667'**
  String get accountNumber;

  /// No description provided for @bankName.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng: Vietcombank - CN HCM'**
  String get bankName;

  /// No description provided for @transferContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung chuyển khoản: Tên + SĐT đặt hàng'**
  String get transferContent;

  /// No description provided for @posPayment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán quẹt thẻ khi giao hàng (POS)'**
  String get posPayment;

  /// No description provided for @vnPayPayment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán online qua cổng VNPay (ATM/Visa/MasterCard/JCB/QR Pay trên Internet Banking)'**
  String get vnPayPayment;

  /// No description provided for @momoPayment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán online qua ví MoMo'**
  String get momoPayment;

  /// No description provided for @qrTransfer.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển khoản qua QR - VCB'**
  String get qrTransfer;

  /// No description provided for @orderNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú đơn hàng'**
  String get orderNote;

  /// No description provided for @orderNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú cho đơn hàng của bạn...'**
  String get orderNoteHint;

  /// No description provided for @emptyCartShort.
  ///
  /// In vi, this message translates to:
  /// **'Giỏ hàng trống'**
  String get emptyCartShort;

  /// No description provided for @promotionApplied.
  ///
  /// In vi, this message translates to:
  /// **'Khuyến mãi áp dụng:'**
  String get promotionApplied;

  /// No description provided for @promotionCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi'**
  String get promotionCode;

  /// No description provided for @openVoucherWallet.
  ///
  /// In vi, this message translates to:
  /// **'Mở Kho Voucher & Chọn Mã Ưu Đãi'**
  String get openVoucherWallet;

  /// No description provided for @enterPromotionCode.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã khuyến mãi'**
  String get enterPromotionCode;

  /// No description provided for @orderSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tóm tắt đơn hàng'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền hàng'**
  String get subtotal;

  /// No description provided for @shippingFeeDistance.
  ///
  /// In vi, this message translates to:
  /// **'Phí vận chuyển{distance}:'**
  String shippingFeeDistance(String distance);

  /// No description provided for @assemblyServiceFee.
  ///
  /// In vi, this message translates to:
  /// **'Phí dịch vụ lắp đặt:'**
  String get assemblyServiceFee;

  /// No description provided for @discount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá'**
  String get discount;

  /// No description provided for @totalPayment.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thanh toán'**
  String get totalPayment;

  /// No description provided for @placeOrder.
  ///
  /// In vi, this message translates to:
  /// **'Đặt hàng'**
  String get placeOrder;

  /// No description provided for @account.
  ///
  /// In vi, this message translates to:
  /// **'TÀI KHOẢN'**
  String get account;

  /// No description provided for @accountDetails.
  ///
  /// In vi, this message translates to:
  /// **'THÔNG TIN TÀI KHOẢN'**
  String get accountDetails;

  /// No description provided for @profileInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin tài khoản'**
  String get profileInformation;

  /// No description provided for @myVouchers.
  ///
  /// In vi, this message translates to:
  /// **'Voucher của tôi (Kho ưu đãi)'**
  String get myVouchers;

  /// No description provided for @helpCenter.
  ///
  /// In vi, this message translates to:
  /// **'Trung tâm Hỏi đáp & Trợ giúp'**
  String get helpCenter;

  /// No description provided for @lastName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên đệm'**
  String get lastName;

  /// No description provided for @firstName.
  ///
  /// In vi, this message translates to:
  /// **'Tên'**
  String get firstName;

  /// No description provided for @gender.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get gender;

  /// No description provided for @female.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get female;

  /// No description provided for @male.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get male;

  /// No description provided for @dateOfBirth.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh'**
  String get dateOfBirth;

  /// No description provided for @update.
  ///
  /// In vi, this message translates to:
  /// **'CẬP NHẬT'**
  String get update;

  /// No description provided for @profileUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật thông tin thành công!'**
  String get profileUpdated;

  /// No description provided for @loginAgain.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập lại.'**
  String get loginAgain;

  /// No description provided for @addressBook.
  ///
  /// In vi, this message translates to:
  /// **'DANH SÁCH ĐỊA CHỈ'**
  String get addressBook;

  /// No description provided for @addAddress.
  ///
  /// In vi, this message translates to:
  /// **'Thêm địa chỉ'**
  String get addAddress;

  /// No description provided for @editAddress.
  ///
  /// In vi, this message translates to:
  /// **'Sửa địa chỉ'**
  String get editAddress;

  /// No description provided for @cannotLoadAddresses.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải danh sách địa chỉ.'**
  String get cannotLoadAddresses;

  /// No description provided for @noAddresses.
  ///
  /// In vi, this message translates to:
  /// **'Hiện tại chưa có địa chỉ nào được thêm.'**
  String get noAddresses;

  /// No description provided for @defaultAddress.
  ///
  /// In vi, this message translates to:
  /// **'Mặc định'**
  String get defaultAddress;

  /// No description provided for @recipient.
  ///
  /// In vi, this message translates to:
  /// **'Người nhận'**
  String get recipient;

  /// No description provided for @fullAddress.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ đầy đủ'**
  String get fullAddress;

  /// No description provided for @addressLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nhãn địa chỉ'**
  String get addressLabel;

  /// No description provided for @addressLabelHome.
  ///
  /// In vi, this message translates to:
  /// **'Nhà'**
  String get addressLabelHome;

  /// No description provided for @addressLabelCompany.
  ///
  /// In vi, this message translates to:
  /// **'Công ty'**
  String get addressLabelCompany;

  /// No description provided for @addressLabelOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get addressLabelOther;

  /// No description provided for @addressSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ít nhất 3 ký tự để tìm địa chỉ'**
  String get addressSearchHint;

  /// No description provided for @makeDefault.
  ///
  /// In vi, this message translates to:
  /// **'Đặt làm mặc định'**
  String get makeDefault;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @loginToViewOrders.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để xem lịch sử giao hàng.'**
  String get loginToViewOrders;

  /// No description provided for @deliveryHistoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'LỊCH SỬ GIAO HÀNG'**
  String get deliveryHistoryTitle;

  /// No description provided for @awaitingPayment.
  ///
  /// In vi, this message translates to:
  /// **'Chờ thanh toán'**
  String get awaitingPayment;

  /// No description provided for @awaitingConfirmation.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xác nhận'**
  String get awaitingConfirmation;

  /// No description provided for @awaitingDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Chờ giao hàng'**
  String get awaitingDelivery;

  /// No description provided for @shipping.
  ///
  /// In vi, this message translates to:
  /// **'Đang giao hàng'**
  String get shipping;

  /// No description provided for @delivered.
  ///
  /// In vi, this message translates to:
  /// **'Đã giao'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get cancelled;

  /// No description provided for @returnedRefunded.
  ///
  /// In vi, this message translates to:
  /// **'Trả hàng/Hoàn tiền'**
  String get returnedRefunded;

  /// No description provided for @returned.
  ///
  /// In vi, this message translates to:
  /// **'Trả hàng'**
  String get returned;

  /// No description provided for @paid.
  ///
  /// In vi, this message translates to:
  /// **'Đã thanh toán'**
  String get paid;

  /// No description provided for @noOrdersForStatus.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy đơn hàng nào ở trạng thái này.'**
  String get noOrdersForStatus;

  /// No description provided for @loadOrdersError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải đơn hàng: {error}'**
  String loadOrdersError(Object error);

  /// No description provided for @orderCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã đơn hàng: {code}'**
  String orderCode(String code);

  /// No description provided for @orderDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đặt: {date}'**
  String orderDate(String date);

  /// No description provided for @variantDetails.
  ///
  /// In vi, this message translates to:
  /// **'Biến thể: {color} / {size}'**
  String variantDetails(String color, String size);

  /// No description provided for @quantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng: {count}'**
  String quantity(int count);

  /// No description provided for @reviewed.
  ///
  /// In vi, this message translates to:
  /// **'Đã đánh giá'**
  String get reviewed;

  /// No description provided for @review.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá'**
  String get review;

  /// No description provided for @paymentLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán: {method}'**
  String paymentLabel(String method);

  /// No description provided for @totalAmount.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền:'**
  String get totalAmount;

  /// No description provided for @reviewProductTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá: {product}'**
  String reviewProductTitle(String product);

  /// No description provided for @verifiedPurchaseDelivered.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm đã được xác nhận mua và giao thành công.'**
  String get verifiedPurchaseDelivered;

  /// No description provided for @satisfactionLevel.
  ///
  /// In vi, this message translates to:
  /// **'Mức độ hài lòng'**
  String get satisfactionLevel;

  /// No description provided for @optionalComment.
  ///
  /// In vi, this message translates to:
  /// **'Nhận xét (không bắt buộc)'**
  String get optionalComment;

  /// No description provided for @reviewHint.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ trải nghiệm của bạn về sản phẩm...'**
  String get reviewHint;

  /// No description provided for @reviewSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá thành công.'**
  String get reviewSuccess;

  /// No description provided for @submitReview.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đánh giá'**
  String get submitReview;

  /// No description provided for @voucherCopiedMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép mã ưu đãi [{code}] và lưu vào bộ nhớ!'**
  String voucherCopiedMessage(String code);

  /// No description provided for @allAvailableVouchers.
  ///
  /// In vi, this message translates to:
  /// **'🌟 Tất cả khả dụng'**
  String get allAvailableVouchers;

  /// No description provided for @expiringSoonVouchers.
  ///
  /// In vi, this message translates to:
  /// **'🔥 Sắp hết hạn (< 7 ngày)'**
  String get expiringSoonVouchers;

  /// No description provided for @newVouchers.
  ///
  /// In vi, this message translates to:
  /// **'✨ Mới phát hành'**
  String get newVouchers;

  /// No description provided for @myVoucherWalletTitle.
  ///
  /// In vi, this message translates to:
  /// **'VOUCHER CỦA TÔI / KHO ƯU ĐÃI'**
  String get myVoucherWalletTitle;

  /// No description provided for @voucherWalletDescription.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý, sưu tầm và sử dụng các mã khuyến mãi dành riêng cho đơn hàng nội thất của bạn.'**
  String get voucherWalletDescription;

  /// No description provided for @noExpiringVouchers.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không có mã giảm giá nào sắp hết hạn trong 7 ngày tới.'**
  String get noExpiringVouchers;

  /// No description provided for @noNewVouchers.
  ///
  /// In vi, this message translates to:
  /// **'Hiện không có mã giảm giá nào mới phát hành trong tuần này.'**
  String get noNewVouchers;

  /// No description provided for @discountBadge.
  ///
  /// In vi, this message translates to:
  /// **'GIẢM GIÁ'**
  String get discountBadge;

  /// No description provided for @expiryDate.
  ///
  /// In vi, this message translates to:
  /// **'HSD: {date}'**
  String expiryDate(String date);

  /// No description provided for @voucherDescriptionMinOrder.
  ///
  /// In vi, this message translates to:
  /// **'{description} - Đơn tối thiểu {amount}'**
  String voucherDescriptionMinOrder(String description, String amount);

  /// No description provided for @orderFrom.
  ///
  /// In vi, this message translates to:
  /// **'Đơn từ {amount}'**
  String orderFrom(String amount);

  /// No description provided for @maxDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm tối đa {amount}'**
  String maxDiscount(String amount);

  /// No description provided for @voucherUsedPercent.
  ///
  /// In vi, this message translates to:
  /// **'🔥 Đã dùng: {percent}%'**
  String voucherUsedPercent(String percent);

  /// No description provided for @remainingUses.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} lượt'**
  String remainingUses(int count);

  /// No description provided for @copied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép'**
  String get copied;

  /// No description provided for @copyCode.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép mã'**
  String get copyCode;

  /// No description provided for @useNow.
  ///
  /// In vi, this message translates to:
  /// **'Dùng ngay'**
  String get useNow;

  /// No description provided for @loginToAsk.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để gửi thắc mắc!'**
  String get loginToAsk;

  /// No description provided for @questionSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'🎉 Đã gửi thắc mắc thành công! Bạn sẽ nhận được thông báo qua email ngay khi Admin giải đáp.'**
  String get questionSubmitted;

  /// No description provided for @genericError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String genericError(Object error);

  /// No description provided for @qaCenterTitle.
  ///
  /// In vi, this message translates to:
  /// **'TRUNG TÂM HỎI ĐÁP & TRỢ GIÚP (Q&A)'**
  String get qaCenterTitle;

  /// No description provided for @qaCenterDescription.
  ///
  /// In vi, this message translates to:
  /// **'Gửi câu hỏi hoặc thắc mắc của bạn cho ban quản trị. Ngay sau khi Admin phản hồi, hệ thống sẽ gửi Email chi tiết về hòm thư của bạn.'**
  String get qaCenterDescription;

  /// No description provided for @newQuestionTab.
  ///
  /// In vi, this message translates to:
  /// **'❓ Đặt Câu Hỏi Mới'**
  String get newQuestionTab;

  /// No description provided for @questionHistoryTab.
  ///
  /// In vi, this message translates to:
  /// **'📜 Lịch Sử Thắc Mắc ({count})'**
  String questionHistoryTab(int count);

  /// No description provided for @chooseSupportTopic.
  ///
  /// In vi, this message translates to:
  /// **'1. Chọn Chủ Đề Hỗ Trợ'**
  String get chooseSupportTopic;

  /// No description provided for @questionContent.
  ///
  /// In vi, this message translates to:
  /// **'2. Nội Dung Thắc Mắc'**
  String get questionContent;

  /// No description provided for @questionContentField.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung thắc mắc'**
  String get questionContentField;

  /// No description provided for @questionHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Tôi muốn mua bộ sofa nhưng cần điều chỉnh kích thước, cửa hàng có nhận gia công theo yêu cầu và chi phí thế nào?'**
  String get questionHint;

  /// No description provided for @sending.
  ///
  /// In vi, this message translates to:
  /// **'Đang gửi...'**
  String get sending;

  /// No description provided for @sendQuestionToAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Gửi Thắc Mắc Cho Admin'**
  String get sendQuestionToAdmin;

  /// No description provided for @noQuestions.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có câu hỏi hay yêu cầu trợ giúp nào.'**
  String get noQuestions;

  /// No description provided for @answeredEmailed.
  ///
  /// In vi, this message translates to:
  /// **'✅ Đã giải đáp (Đã gửi mail)'**
  String get answeredEmailed;

  /// No description provided for @awaitingReply.
  ///
  /// In vi, this message translates to:
  /// **'⏳ Chờ phản hồi'**
  String get awaitingReply;

  /// No description provided for @sentAt.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lúc: {time}'**
  String sentAt(String time);

  /// No description provided for @yourQuestion.
  ///
  /// In vi, this message translates to:
  /// **'❓ Nội dung câu hỏi của bạn:'**
  String get yourQuestion;

  /// No description provided for @officialAdminReply.
  ///
  /// In vi, this message translates to:
  /// **'💡 Phản hồi chính thức từ Admin:'**
  String get officialAdminReply;

  /// No description provided for @answeredAt.
  ///
  /// In vi, this message translates to:
  /// **'Lúc: {time}'**
  String answeredAt(String time);

  /// No description provided for @topicProductAdvice.
  ///
  /// In vi, this message translates to:
  /// **'Tư vấn kỹ thuật sản phẩm & chất liệu'**
  String get topicProductAdvice;

  /// No description provided for @topicPolicies.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo hành, đổi trả & vận chuyển'**
  String get topicPolicies;

  /// No description provided for @topicCustomDesign.
  ///
  /// In vi, this message translates to:
  /// **'Tư vấn thiết kế & đặt đóng nội thất theo yêu cầu'**
  String get topicCustomDesign;

  /// No description provided for @topicFeedback.
  ///
  /// In vi, this message translates to:
  /// **'Góp ý & phản hồi về dịch vụ'**
  String get topicFeedback;

  /// No description provided for @mySpace.
  ///
  /// In vi, this message translates to:
  /// **'Không gian của tôi'**
  String get mySpace;

  /// No description provided for @waitForAiGeneration.
  ///
  /// In vi, this message translates to:
  /// **'Hãy chờ AI tạo ảnh hiện tại xong.'**
  String get waitForAiGeneration;

  /// No description provided for @roomImageTooLarge.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh căn phòng không được vượt quá 10 MB.'**
  String get roomImageTooLarge;

  /// No description provided for @roomUploaded.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải ảnh phòng. Bạn có thể chỉnh tay hoặc dùng AI.'**
  String get roomUploaded;

  /// No description provided for @defaultVariant.
  ///
  /// In vi, this message translates to:
  /// **'Mặc định'**
  String get defaultVariant;

  /// No description provided for @chooseProductVariant.
  ///
  /// In vi, this message translates to:
  /// **'Chọn biến thể {product}'**
  String chooseProductVariant(String product);

  /// No description provided for @stockRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} sản phẩm'**
  String stockRemaining(int count);

  /// No description provided for @uploadRoomFirst.
  ///
  /// In vi, this message translates to:
  /// **'Hãy tải ảnh phòng trước.'**
  String get uploadRoomFirst;

  /// No description provided for @backgroundRemovedAdded.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa nền và thêm sản phẩm vào phòng.'**
  String get backgroundRemovedAdded;

  /// No description provided for @chooseProduct.
  ///
  /// In vi, this message translates to:
  /// **'Chọn sản phẩm'**
  String get chooseProduct;

  /// No description provided for @chooseRoomAndProductImages.
  ///
  /// In vi, this message translates to:
  /// **'Hãy chọn đủ ảnh phòng và ảnh sản phẩm.'**
  String get chooseRoomAndProductImages;

  /// No description provided for @aiServiceNotReady.
  ///
  /// In vi, this message translates to:
  /// **'Dịch vụ AI chưa sẵn sàng.'**
  String get aiServiceNotReady;

  /// No description provided for @generateNewAiImageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ảnh mới bằng AI?'**
  String get generateNewAiImageTitle;

  /// No description provided for @aiGenerateConfirmAuto.
  ///
  /// In vi, this message translates to:
  /// **'AI sẽ nhận đúng 2 ảnh: ảnh phòng và ảnh biến thể sản phẩm. AI sẽ tự chọn vị trí phù hợp. Mỗi lần tạo mới có thể phát sinh chi phí API.'**
  String get aiGenerateConfirmAuto;

  /// No description provided for @aiGenerateConfirmPrompt.
  ///
  /// In vi, this message translates to:
  /// **'AI sẽ nhận đúng 2 ảnh: ảnh phòng và ảnh biến thể sản phẩm. AI sẽ ưu tiên vị trí bạn đã mô tả. Mỗi lần tạo mới có thể phát sinh chi phí API.'**
  String get aiGenerateConfirmPrompt;

  /// No description provided for @generateImage.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ảnh'**
  String get generateImage;

  /// No description provided for @aiImageLoadedFromCache.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải ảnh AI từ bộ nhớ đệm.'**
  String get aiImageLoadedFromCache;

  /// No description provided for @aiImageGenerated.
  ///
  /// In vi, this message translates to:
  /// **'AI đã tạo ảnh mới từ 2 hình.'**
  String get aiImageGenerated;

  /// No description provided for @designSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu thiết kế.'**
  String get designSaved;

  /// No description provided for @cannotCreateResultImage.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tạo ảnh kết quả.'**
  String get cannotCreateResultImage;

  /// No description provided for @visualizationDownloaded.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải ảnh phối cảnh.'**
  String get visualizationDownloaded;

  /// No description provided for @roomVisualizerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phối cảnh không gian'**
  String get roomVisualizerTitle;

  /// No description provided for @uploadRoomImage.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh phòng'**
  String get uploadRoomImage;

  /// No description provided for @changeRoomImage.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh phòng'**
  String get changeRoomImage;

  /// No description provided for @saveDesign.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thiết kế'**
  String get saveDesign;

  /// No description provided for @exportImage.
  ///
  /// In vi, this message translates to:
  /// **'Xuất ảnh'**
  String get exportImage;

  /// No description provided for @uploadYourRoom.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh căn phòng của bạn'**
  String get uploadYourRoom;

  /// No description provided for @roomImageRequirements.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ JPG, PNG, WEBP; tối đa 10 MB.'**
  String get roomImageRequirements;

  /// No description provided for @uploadingImage.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải ảnh…'**
  String get uploadingImage;

  /// No description provided for @chooseRoomImage.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh căn phòng'**
  String get chooseRoomImage;

  /// No description provided for @manualAdjustment.
  ///
  /// In vi, this message translates to:
  /// **'Tự điều chỉnh'**
  String get manualAdjustment;

  /// No description provided for @aiGenerateImage.
  ///
  /// In vi, this message translates to:
  /// **'AI tạo ảnh'**
  String get aiGenerateImage;

  /// No description provided for @chooseProductManualHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn sản phẩm để bắt đầu chỉnh tay'**
  String get chooseProductManualHint;

  /// No description provided for @chooseProductAiHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn sản phẩm rồi yêu cầu AI tạo ảnh mới'**
  String get chooseProductAiHint;

  /// No description provided for @aiGeneratingNewImage.
  ///
  /// In vi, this message translates to:
  /// **'AI đang tạo ảnh mới…'**
  String get aiGeneratingNewImage;

  /// No description provided for @analyzingSpace.
  ///
  /// In vi, this message translates to:
  /// **'Đang phân tích không gian…'**
  String get analyzingSpace;

  /// No description provided for @designLayer.
  ///
  /// In vi, this message translates to:
  /// **'Thiết kế'**
  String get designLayer;

  /// No description provided for @floorWallLayer.
  ///
  /// In vi, this message translates to:
  /// **'Sàn / tường'**
  String get floorWallLayer;

  /// No description provided for @depthLayer.
  ///
  /// In vi, this message translates to:
  /// **'Chiều sâu'**
  String get depthLayer;

  /// No description provided for @floorMaskLayer.
  ///
  /// In vi, this message translates to:
  /// **'Mask sàn'**
  String get floorMaskLayer;

  /// No description provided for @wallMaskLayer.
  ///
  /// In vi, this message translates to:
  /// **'Mask tường'**
  String get wallMaskLayer;

  /// No description provided for @productsTab.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm'**
  String get productsTab;

  /// No description provided for @adjustmentsTab.
  ///
  /// In vi, this message translates to:
  /// **'Điều chỉnh'**
  String get adjustmentsTab;

  /// No description provided for @selectProductOnCanvas.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một sản phẩm trong khung ảnh.'**
  String get selectProductOnCanvas;

  /// No description provided for @placementSurface.
  ///
  /// In vi, this message translates to:
  /// **'Bề mặt đặt đồ'**
  String get placementSurface;

  /// No description provided for @freePlacement.
  ///
  /// In vi, this message translates to:
  /// **'Tự do'**
  String get freePlacement;

  /// No description provided for @floorSurface.
  ///
  /// In vi, this message translates to:
  /// **'Sàn'**
  String get floorSurface;

  /// No description provided for @leftWall.
  ///
  /// In vi, this message translates to:
  /// **'Tường trái'**
  String get leftWall;

  /// No description provided for @rightWall.
  ///
  /// In vi, this message translates to:
  /// **'Tường phải'**
  String get rightWall;

  /// No description provided for @sizeControl.
  ///
  /// In vi, this message translates to:
  /// **'Kích thước'**
  String get sizeControl;

  /// No description provided for @flatRotation.
  ///
  /// In vi, this message translates to:
  /// **'Xoay phẳng'**
  String get flatRotation;

  /// No description provided for @perspectiveRotation.
  ///
  /// In vi, this message translates to:
  /// **'Xoay phối cảnh trái / phải'**
  String get perspectiveRotation;

  /// No description provided for @brightness.
  ///
  /// In vi, this message translates to:
  /// **'Độ sáng'**
  String get brightness;

  /// No description provided for @shadowIntensity.
  ///
  /// In vi, this message translates to:
  /// **'Độ đậm bóng'**
  String get shadowIntensity;

  /// No description provided for @flipProduct.
  ///
  /// In vi, this message translates to:
  /// **'Lật ngang sản phẩm'**
  String get flipProduct;

  /// No description provided for @duplicate.
  ///
  /// In vi, this message translates to:
  /// **'Nhân bản'**
  String get duplicate;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @aiFromTwoImages.
  ///
  /// In vi, this message translates to:
  /// **'AI tạo ảnh từ 2 hình'**
  String get aiFromTwoImages;

  /// No description provided for @aiFromTwoImagesDescription.
  ///
  /// In vi, this message translates to:
  /// **'AI nhận trực tiếp ảnh phòng và ảnh biến thể sản phẩm, rồi sinh một ảnh phối cảnh mới.'**
  String get aiFromTwoImagesDescription;

  /// No description provided for @roomImage.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh căn phòng'**
  String get roomImage;

  /// No description provided for @uploadedImage.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh bạn đã tải lên'**
  String get uploadedImage;

  /// No description provided for @noProductSelected.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn sản phẩm'**
  String get noProductSelected;

  /// No description provided for @chooseVariantBelow.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một biến thể bên dưới'**
  String get chooseVariantBelow;

  /// No description provided for @chooseProductColor.
  ///
  /// In vi, this message translates to:
  /// **'Chọn sản phẩm và màu'**
  String get chooseProductColor;

  /// No description provided for @changeProductColor.
  ///
  /// In vi, this message translates to:
  /// **'Đổi sản phẩm / màu'**
  String get changeProductColor;

  /// No description provided for @desiredPlacementOptional.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí mong muốn (không bắt buộc)'**
  String get desiredPlacementOptional;

  /// No description provided for @placementPromptHint.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Đặt bàn sát cửa sổ bên trái, xoay mặt bàn hướng vào giữa phòng.'**
  String get placementPromptHint;

  /// No description provided for @placementPromptHelp.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ mô tả vị trí, hướng xoay hoặc khu vực đặt sản phẩm. Nếu để trống, AI sẽ tự bố trí.'**
  String get placementPromptHelp;

  /// No description provided for @aiServiceUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Không kết nối được dịch vụ AI.'**
  String get aiServiceUnavailable;

  /// No description provided for @aiGenerating.
  ///
  /// In vi, this message translates to:
  /// **'AI đang tạo ảnh…'**
  String get aiGenerating;

  /// No description provided for @generateNewImageWithAi.
  ///
  /// In vi, this message translates to:
  /// **'Tạo ảnh mới bằng AI'**
  String get generateNewImageWithAi;

  /// No description provided for @regenerateImage.
  ///
  /// In vi, this message translates to:
  /// **'Tạo lại ảnh mới'**
  String get regenerateImage;

  /// No description provided for @downloadCurrentAiImage.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh AI đang xem'**
  String get downloadCurrentAiImage;

  /// No description provided for @aiImageDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh AI chỉ mang tính tham khảo. Mỗi lần tạo có thể phát sinh phí API; hãy đối chiếu màu và kích thước thật trước khi mua.'**
  String get aiImageDisclaimer;

  /// No description provided for @chatPromptSofa.
  ///
  /// In vi, this message translates to:
  /// **'💡 Tìm mẫu sofa phòng khách giá tốt'**
  String get chatPromptSofa;

  /// No description provided for @chatPromptDining.
  ///
  /// In vi, this message translates to:
  /// **'💡 Gợi ý bộ bàn ăn cho gia đình 4 người'**
  String get chatPromptDining;

  /// No description provided for @chatPromptDesk.
  ///
  /// In vi, this message translates to:
  /// **'💡 Có bàn làm việc gỗ nào nhỏ gọn không?'**
  String get chatPromptDesk;

  /// No description provided for @chatPromptVoucher.
  ///
  /// In vi, this message translates to:
  /// **'💡 Hướng dẫn áp dụng mã giảm giá voucher'**
  String get chatPromptVoucher;

  /// No description provided for @chatPromptCustom.
  ///
  /// In vi, this message translates to:
  /// **'💡 Shop có nhận đặt gia công kích thước riêng?'**
  String get chatPromptCustom;

  /// No description provided for @chatWelcome.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào! 🤖 Mình là Trợ lý AI Thông Minh của My Furniture Store. Mình đã nắm rõ thông tin giá cả và chi tiết của toàn bộ danh mục hàng hóa!\n\nBạn cần tìm món nội thất nào hoặc cần tư vấn cách thiết kế không gian hãy hỏi mình nhé! ✨'**
  String get chatWelcome;

  /// No description provided for @chatConnectionError.
  ///
  /// In vi, this message translates to:
  /// **'✨ Trợ lý AI đang trục trặc tín hiệu đường truyền. Bạn hãy thử lại sau nhé!'**
  String get chatConnectionError;

  /// No description provided for @geminiAssistant.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý AI Gemini'**
  String get geminiAssistant;

  /// No description provided for @furnitureAiAssistant.
  ///
  /// In vi, this message translates to:
  /// **'✨ Trợ Lý AI Nội Thất'**
  String get furnitureAiAssistant;

  /// No description provided for @chatOnlineStatus.
  ///
  /// In vi, this message translates to:
  /// **'Online - Đang đọc dữ liệu kho'**
  String get chatOnlineStatus;

  /// No description provided for @chatInputHint.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi AI về sofa, bàn trà, giá ưu đãi...'**
  String get chatInputHint;

  /// No description provided for @chatThinking.
  ///
  /// In vi, this message translates to:
  /// **'AI đang suy nghĩ & tra cứu sản phẩm...'**
  String get chatThinking;

  /// No description provided for @viewMoreProducts.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm {count} sản phẩm'**
  String viewMoreProducts(int count);

  /// No description provided for @cartTitle.
  ///
  /// In vi, this message translates to:
  /// **'GIỎ HÀNG'**
  String get cartTitle;

  /// No description provided for @cartEmptyShort.
  ///
  /// In vi, this message translates to:
  /// **'Hiện chưa có sản phẩm'**
  String get cartEmptyShort;

  /// No description provided for @loginToViewCart.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để xem giỏ hàng.'**
  String get loginToViewCart;

  /// No description provided for @viewCart.
  ///
  /// In vi, this message translates to:
  /// **'XEM GIỎ HÀNG'**
  String get viewCart;

  /// No description provided for @checkoutAction.
  ///
  /// In vi, this message translates to:
  /// **'THANH TOÁN'**
  String get checkoutAction;

  /// No description provided for @aboutTitle.
  ///
  /// In vi, this message translates to:
  /// **'Về My Furniture Store'**
  String get aboutTitle;

  /// No description provided for @contactTitle.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get contactTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In vi, this message translates to:
  /// **'My Furniture Store cung cấp các sản phẩm nội thất cho không gian sống hiện đại, với dịch vụ giao hàng và lắp đặt tận nhà.'**
  String get aboutDescription;

  /// No description provided for @contactDescription.
  ///
  /// In vi, this message translates to:
  /// **'Email: support@myfurniture.local\nĐiện thoại: 1900 0000\nThời gian hỗ trợ: 08:00–20:00 mỗi ngày.'**
  String get contactDescription;

  /// No description provided for @adminManageCategories.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý danh mục'**
  String get adminManageCategories;

  /// No description provided for @adminManageProducts.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý sản phẩm'**
  String get adminManageProducts;

  /// No description provided for @adminManageReviews.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý đánh giá'**
  String get adminManageReviews;

  /// No description provided for @adminManageOrders.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý đơn hàng'**
  String get adminManageOrders;

  /// No description provided for @adminManageAccounts.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý tài khoản'**
  String get adminManageAccounts;

  /// No description provided for @adminManagePromotions.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý khuyến mãi'**
  String get adminManagePromotions;

  /// No description provided for @adminManageDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý vận chuyển'**
  String get adminManageDelivery;

  /// No description provided for @adminQaSupport.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi đáp & Trợ giúp (Q&A)'**
  String get adminQaSupport;

  /// No description provided for @adminManageRecommendations.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý gợi ý'**
  String get adminManageRecommendations;

  /// No description provided for @adminManageRevenue.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý doanh thu'**
  String get adminManageRevenue;

  /// No description provided for @backToHome.
  ///
  /// In vi, this message translates to:
  /// **'Quay về trang chủ'**
  String get backToHome;

  /// No description provided for @refreshData.
  ///
  /// In vi, this message translates to:
  /// **'Làm mới dữ liệu'**
  String get refreshData;

  /// No description provided for @categoriesMetric.
  ///
  /// In vi, this message translates to:
  /// **'DANH MỤC'**
  String get categoriesMetric;

  /// No description provided for @productsMetric.
  ///
  /// In vi, this message translates to:
  /// **'SẢN PHẨM'**
  String get productsMetric;

  /// No description provided for @collectedRevenue.
  ///
  /// In vi, this message translates to:
  /// **'DOANH THU ĐÃ THU'**
  String get collectedRevenue;

  /// No description provided for @outOfStockVariants.
  ///
  /// In vi, this message translates to:
  /// **'BIẾN THỂ HẾT HÀNG'**
  String get outOfStockVariants;

  /// No description provided for @recentOrders.
  ///
  /// In vi, this message translates to:
  /// **'ĐƠN HÀNG GẦN ĐÂY'**
  String get recentOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đơn hàng.'**
  String get noOrdersYet;

  /// No description provided for @loadDataError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải dữ liệu: {error}'**
  String loadDataError(Object error);

  /// No description provided for @productListTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách sản phẩm'**
  String get productListTitle;

  /// No description provided for @searchProductHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo mã hoặc tên sản phẩm...'**
  String get searchProductHint;

  /// No description provided for @mainCategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục chính'**
  String get mainCategory;

  /// No description provided for @subCategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục con'**
  String get subCategory;

  /// No description provided for @allChildren.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả con'**
  String get allChildren;

  /// No description provided for @addProduct.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Sản phẩm'**
  String get addProduct;

  /// No description provided for @productCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã sản phẩm'**
  String get productCode;

  /// No description provided for @productName.
  ///
  /// In vi, this message translates to:
  /// **'Tên Sản phẩm'**
  String get productName;

  /// No description provided for @price.
  ///
  /// In vi, this message translates to:
  /// **'Giá'**
  String get price;

  /// No description provided for @status.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get status;

  /// No description provided for @actions.
  ///
  /// In vi, this message translates to:
  /// **'Hành động'**
  String get actions;

  /// No description provided for @categoryNumber.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục #{id}'**
  String categoryNumber(int id);

  /// No description provided for @discontinued.
  ///
  /// In vi, this message translates to:
  /// **'Ngừng bán'**
  String get discontinued;

  /// No description provided for @onSale.
  ///
  /// In vi, this message translates to:
  /// **'Đang bán'**
  String get onSale;

  /// No description provided for @loadProductsError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải sản phẩm: {error}'**
  String loadProductsError(Object error);

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa sản phẩm'**
  String get confirmDeleteProduct;

  /// No description provided for @confirmDeleteProductBody.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa sản phẩm này không? Hành động này không thể hoàn tác.'**
  String get confirmDeleteProductBody;

  /// No description provided for @categoryListTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách danh mục sản phẩm'**
  String get categoryListTitle;

  /// No description provided for @addCategory.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Danh mục'**
  String get addCategory;

  /// No description provided for @noCategories.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có danh mục nào.'**
  String get noCategories;

  /// No description provided for @noSubcategories.
  ///
  /// In vi, this message translates to:
  /// **'Không có danh mục con'**
  String get noSubcategories;

  /// No description provided for @loadCategoriesError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải danh mục: {error}'**
  String loadCategoriesError(Object error);

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa danh mục'**
  String get confirmDeleteCategory;

  /// No description provided for @confirmDeleteCategoryBody.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa danh mục này không? Hành động này không thể hoàn tác.'**
  String get confirmDeleteCategoryBody;

  /// No description provided for @addNewCategory.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Danh Mục Mới'**
  String get addNewCategory;

  /// No description provided for @editCategory.
  ///
  /// In vi, this message translates to:
  /// **'Sửa Danh Mục'**
  String get editCategory;

  /// No description provided for @categoryInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin danh mục'**
  String get categoryInformation;

  /// No description provided for @categoryName.
  ///
  /// In vi, this message translates to:
  /// **'Tên danh mục'**
  String get categoryName;

  /// No description provided for @categoryNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Tên danh mục (*)'**
  String get categoryNameRequired;

  /// No description provided for @categoryCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã danh mục'**
  String get categoryCode;

  /// No description provided for @invalidCode.
  ///
  /// In vi, this message translates to:
  /// **'{field} chỉ được chứa chữ cái, chữ số, gạch ngang (-) hoặc gạch dưới (_)!'**
  String invalidCode(String field);

  /// No description provided for @categoryCodeAuto.
  ///
  /// In vi, this message translates to:
  /// **'Mã danh mục (Để trống để tự sinh)'**
  String get categoryCodeAuto;

  /// No description provided for @parentCategoryOptional.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục cha (nếu có)'**
  String get parentCategoryOptional;

  /// No description provided for @rootCategoryOption.
  ///
  /// In vi, this message translates to:
  /// **'Không có (Đây là danh mục gốc)'**
  String get rootCategoryOption;

  /// No description provided for @categoryImage.
  ///
  /// In vi, this message translates to:
  /// **'Hình ảnh danh mục'**
  String get categoryImage;

  /// No description provided for @uploadFromDevice.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh từ máy...'**
  String get uploadFromDevice;

  /// No description provided for @selectedFile.
  ///
  /// In vi, this message translates to:
  /// **'Đã chọn: {name}'**
  String selectedFile(String name);

  /// No description provided for @useCurrentImage.
  ///
  /// In vi, this message translates to:
  /// **'Sử dụng ảnh hiện tại'**
  String get useCurrentImage;

  /// No description provided for @noImageSelected.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn hình ảnh nào'**
  String get noImageSelected;

  /// No description provided for @invalidCategoryName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng kiểm tra và nhập hợp lệ tên danh mục!'**
  String get invalidCategoryName;

  /// No description provided for @saveCategoryError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi lưu danh mục: {error}'**
  String saveCategoryError(Object error);

  /// No description provided for @addNewVariant.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Biến thể mới'**
  String get addNewVariant;

  /// No description provided for @editVariant.
  ///
  /// In vi, this message translates to:
  /// **'Sửa Biến thể'**
  String get editVariant;

  /// No description provided for @color.
  ///
  /// In vi, this message translates to:
  /// **'Màu sắc'**
  String get color;

  /// No description provided for @stockQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng tồn kho'**
  String get stockQuantity;

  /// No description provided for @additionalPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá phát sinh (đ)'**
  String get additionalPrice;

  /// No description provided for @variantImages.
  ///
  /// In vi, this message translates to:
  /// **'Hình ảnh biến thể'**
  String get variantImages;

  /// No description provided for @cannotReadImage.
  ///
  /// In vi, this message translates to:
  /// **'Không đọc được dữ liệu ảnh. Vui lòng chọn lại file.'**
  String get cannotReadImage;

  /// No description provided for @imageUploadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải ảnh: {error}'**
  String imageUploadError(Object error);

  /// No description provided for @invalidProductFields.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng kiểm tra và nhập chính xác các trường thông tin sản phẩm!'**
  String get invalidProductFields;

  /// No description provided for @selectFullCategoryPath.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn đầy đủ danh mục chính và danh mục con'**
  String get selectFullCategoryPath;

  /// No description provided for @saveProductError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi lưu sản phẩm: {error}'**
  String saveProductError(Object error);

  /// No description provided for @addNewProduct.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Sản Phẩm Mới'**
  String get addNewProduct;

  /// No description provided for @editProductInformation.
  ///
  /// In vi, this message translates to:
  /// **'Sửa Thông Tin Sản Phẩm'**
  String get editProductInformation;

  /// No description provided for @productNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Tên sản phẩm (*)'**
  String get productNameRequired;

  /// No description provided for @productCodeAuto.
  ///
  /// In vi, this message translates to:
  /// **'Mã sản phẩm (Để trống để tự sinh)'**
  String get productCodeAuto;

  /// No description provided for @basePrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá cơ bản'**
  String get basePrice;

  /// No description provided for @basePriceRequired.
  ///
  /// In vi, this message translates to:
  /// **'Giá cơ bản (đ) (*)'**
  String get basePriceRequired;

  /// No description provided for @detailedDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết'**
  String get detailedDescription;

  /// No description provided for @detailedDescriptionRequired.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết (*)'**
  String get detailedDescriptionRequired;

  /// No description provided for @productVariantsHeading.
  ///
  /// In vi, this message translates to:
  /// **'Biến thể sản phẩm (Màu sắc, Size, Tồn kho, Giá phát sinh)'**
  String get productVariantsHeading;

  /// No description provided for @addVariant.
  ///
  /// In vi, this message translates to:
  /// **'Thêm biến thể'**
  String get addVariant;

  /// No description provided for @noVariants.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có biến thể nào. Bấm \"Thêm biến thể\" ở trên.'**
  String get noVariants;

  /// No description provided for @variantColorSize.
  ///
  /// In vi, this message translates to:
  /// **'{color} | Kích thước: {size}'**
  String variantColorSize(String color, String size);

  /// No description provided for @variantStockPrice.
  ///
  /// In vi, this message translates to:
  /// **'Tồn kho: {stock} | Chênh lệch: +{price}'**
  String variantStockPrice(Object stock, String price);

  /// No description provided for @temporarilyHideProduct.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn tạm thời (ngừng kinh doanh)'**
  String get temporarilyHideProduct;

  /// No description provided for @hiddenProductDescription.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm sẽ không hiển thị trên trang chủ'**
  String get hiddenProductDescription;

  /// No description provided for @productPreview.
  ///
  /// In vi, this message translates to:
  /// **'XEM TRƯỚC SẢN PHẨM'**
  String get productPreview;

  /// No description provided for @productDiscountTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá sản phẩm'**
  String get productDiscountTitle;

  /// No description provided for @productDiscountHint.
  ///
  /// In vi, this message translates to:
  /// **'Giảm trên toàn bộ biến thể của sản phẩm trong thời gian đã chọn.'**
  String get productDiscountHint;

  /// No description provided for @discountStartDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu'**
  String get discountStartDate;

  /// No description provided for @discountEndDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc'**
  String get discountEndDate;

  /// No description provided for @noDateLimit.
  ///
  /// In vi, this message translates to:
  /// **'Không giới hạn'**
  String get noDateLimit;

  /// No description provided for @discountPercentRangeError.
  ///
  /// In vi, this message translates to:
  /// **'Mức giảm phải lớn hơn 0 và không vượt quá 90%.'**
  String get discountPercentRangeError;

  /// No description provided for @activeDiscountRequiredError.
  ///
  /// In vi, this message translates to:
  /// **'Hãy nhập phần trăm giảm giá trước khi bật chương trình.'**
  String get activeDiscountRequiredError;

  /// No description provided for @discountDateRangeError.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc phải sau ngày bắt đầu.'**
  String get discountDateRangeError;

  /// No description provided for @productNamePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tên Sản Phẩm'**
  String get productNamePlaceholder;

  /// No description provided for @oakColor.
  ///
  /// In vi, this message translates to:
  /// **'Gỗ sồi (Oak)'**
  String get oakColor;

  /// No description provided for @walnutColor.
  ///
  /// In vi, this message translates to:
  /// **'Gỗ óc chó (Walnut)'**
  String get walnutColor;

  /// No description provided for @naturalWoodColor.
  ///
  /// In vi, this message translates to:
  /// **'Gỗ tự nhiên'**
  String get naturalWoodColor;

  /// No description provided for @brownWoodColor.
  ///
  /// In vi, this message translates to:
  /// **'Nâu gỗ (Brown)'**
  String get brownWoodColor;

  /// No description provided for @whiteColor.
  ///
  /// In vi, this message translates to:
  /// **'Trắng (White)'**
  String get whiteColor;

  /// No description provided for @blackColor.
  ///
  /// In vi, this message translates to:
  /// **'Đen (Black)'**
  String get blackColor;

  /// No description provided for @greyColor.
  ///
  /// In vi, this message translates to:
  /// **'Xám (Grey)'**
  String get greyColor;

  /// No description provided for @beigeColor.
  ///
  /// In vi, this message translates to:
  /// **'Kem (Beige)'**
  String get beigeColor;

  /// No description provided for @tanColor.
  ///
  /// In vi, this message translates to:
  /// **'Nâu da bò (Tan)'**
  String get tanColor;

  /// No description provided for @standardSize.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu chuẩn'**
  String get standardSize;

  /// No description provided for @smallSize.
  ///
  /// In vi, this message translates to:
  /// **'S (Nhỏ)'**
  String get smallSize;

  /// No description provided for @mediumSize.
  ///
  /// In vi, this message translates to:
  /// **'M (Vừa)'**
  String get mediumSize;

  /// No description provided for @largeSize.
  ///
  /// In vi, this message translates to:
  /// **'L (Lớn)'**
  String get largeSize;

  /// No description provided for @invalidNumber.
  ///
  /// In vi, this message translates to:
  /// **'{field} phải là số hợp lệ!'**
  String invalidNumber(String field);

  /// No description provided for @integerRequired.
  ///
  /// In vi, this message translates to:
  /// **'{field} phải là số nguyên!'**
  String integerRequired(String field);

  /// No description provided for @minimumValue.
  ///
  /// In vi, this message translates to:
  /// **'{field} phải lớn hơn hoặc bằng {min}!'**
  String minimumValue(String field, num min);

  /// No description provided for @loadOrderListError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải danh sách đơn hàng: {error}'**
  String loadOrderListError(Object error);

  /// No description provided for @rescheduledDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Hẹn giao lại'**
  String get rescheduledDelivery;

  /// No description provided for @paymentFailed.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại'**
  String get paymentFailed;

  /// No description provided for @confirmCancelOrder.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận hủy đơn hàng'**
  String get confirmCancelOrder;

  /// No description provided for @confirmCancelOrderBody.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn hủy đơn hàng này? Tồn kho và lượt sử dụng voucher sẽ được hoàn lại.'**
  String get confirmCancelOrderBody;

  /// No description provided for @no.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get no;

  /// No description provided for @cancelOrder.
  ///
  /// In vi, this message translates to:
  /// **'Hủy đơn'**
  String get cancelOrder;

  /// No description provided for @orderStatusUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật trạng thái đơn hàng thành công!'**
  String get orderStatusUpdated;

  /// No description provided for @updateError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi cập nhật: {error}'**
  String updateError(Object error);

  /// No description provided for @adminOrderManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Đơn hàng'**
  String get adminOrderManagement;

  /// No description provided for @searchOrdersHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm tên, email, ID...'**
  String get searchOrdersHint;

  /// No description provided for @noOrdersFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy đơn hàng nào.'**
  String get noOrdersFound;

  /// No description provided for @orderNumber.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng #{id}'**
  String orderNumber(int id);

  /// No description provided for @customerSummary.
  ///
  /// In vi, this message translates to:
  /// **'Khách: {name} ({email})'**
  String customerSummary(String name, String email);

  /// No description provided for @orderDetailsCode.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết {code}'**
  String orderDetailsCode(String code);

  /// No description provided for @orderDetailsNumber.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết Đơn hàng #{id}'**
  String orderDetailsNumber(int id);

  /// No description provided for @orderStatusLabel.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái đơn hàng:'**
  String get orderStatusLabel;

  /// No description provided for @shipperOwnsDeliveryConfirmation.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đang do shipper phụ trách. Chỉ shipper được xác nhận “Đã giao”.'**
  String get shipperOwnsDeliveryConfirmation;

  /// No description provided for @confirmOrder.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đơn hàng'**
  String get confirmOrder;

  /// No description provided for @cancelOrderFull.
  ///
  /// In vi, this message translates to:
  /// **'Hủy đơn hàng'**
  String get cancelOrderFull;

  /// No description provided for @completedOrderLocked.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng đã hoàn tất hoặc bị hủy. Không thể thay đổi trạng thái.'**
  String get completedOrderLocked;

  /// No description provided for @customerDeliveryInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin khách hàng & Giao hàng'**
  String get customerDeliveryInformation;

  /// No description provided for @assignedShipper.
  ///
  /// In vi, this message translates to:
  /// **'Shipper phụ trách:'**
  String get assignedShipper;

  /// No description provided for @customerNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên khách hàng:'**
  String get customerNameLabel;

  /// No description provided for @deliveryAddressLabel.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ nhận hàng:'**
  String get deliveryAddressLabel;

  /// No description provided for @appointmentSlot.
  ///
  /// In vi, this message translates to:
  /// **'Khung giờ hẹn:'**
  String get appointmentSlot;

  /// No description provided for @assemblyServiceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Dịch vụ lắp đặt:'**
  String get assemblyServiceLabel;

  /// No description provided for @assemblyRequested.
  ///
  /// In vi, this message translates to:
  /// **'Có Yêu Cầu (+{fee})'**
  String assemblyRequested(String fee);

  /// No description provided for @none.
  ///
  /// In vi, this message translates to:
  /// **'Không có'**
  String get none;

  /// No description provided for @paymentSection.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get paymentSection;

  /// No description provided for @methodLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức:'**
  String get methodLabel;

  /// No description provided for @paymentStatusLabel.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái thanh toán:'**
  String get paymentStatusLabel;

  /// No description provided for @orderedProducts.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm đã đặt'**
  String get orderedProducts;

  /// No description provided for @classification.
  ///
  /// In vi, this message translates to:
  /// **'Phân loại: {color} - {size}'**
  String classification(String color, String size);

  /// No description provided for @totalPaymentLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thanh toán:'**
  String get totalPaymentLabel;

  /// No description provided for @loadAccountsError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải danh sách tài khoản: {error}'**
  String loadAccountsError(Object error);

  /// No description provided for @accountUnlocked.
  ///
  /// In vi, this message translates to:
  /// **'Mở khóa tài khoản thành công!'**
  String get accountUnlocked;

  /// No description provided for @accountLocked.
  ///
  /// In vi, this message translates to:
  /// **'Khóa tài khoản thành công!'**
  String get accountLocked;

  /// No description provided for @changeStatusError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi thay đổi trạng thái: {error}'**
  String changeStatusError(Object error);

  /// No description provided for @roleUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật vai trò thành công!'**
  String get roleUpdated;

  /// No description provided for @updateRoleError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi cập nhật vai trò: {error}'**
  String updateRoleError(Object error);

  /// No description provided for @resetPasswordFor.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu cho {name}'**
  String resetPasswordFor(Object name);

  /// No description provided for @newPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới:'**
  String get newPasswordLabel;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu thành công! Mật khẩu mới: {password}'**
  String passwordResetSuccess(Object password);

  /// No description provided for @resetPasswordError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi đặt lại mật khẩu: {error}'**
  String resetPasswordError(Object error);

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @accountManagementTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý tài khoản'**
  String get accountManagementTitle;

  /// No description provided for @refresh.
  ///
  /// In vi, this message translates to:
  /// **'Làm mới'**
  String get refresh;

  /// No description provided for @systemAccountList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách tài khoản hệ thống'**
  String get systemAccountList;

  /// No description provided for @searchAccountsHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm họ tên, email, sđt...'**
  String get searchAccountsHint;

  /// No description provided for @noAccountsFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy tài khoản nào.'**
  String get noAccountsFound;

  /// No description provided for @customerId.
  ///
  /// In vi, this message translates to:
  /// **'Mã KH'**
  String get customerId;

  /// No description provided for @role.
  ///
  /// In vi, this message translates to:
  /// **'Vai trò'**
  String get role;

  /// No description provided for @operations.
  ///
  /// In vi, this message translates to:
  /// **'Thao tác'**
  String get operations;

  /// No description provided for @customerRole.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get customerRole;

  /// No description provided for @locked.
  ///
  /// In vi, this message translates to:
  /// **'Đã khóa'**
  String get locked;

  /// No description provided for @active.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get active;

  /// No description provided for @unlock.
  ///
  /// In vi, this message translates to:
  /// **'Mở khóa'**
  String get unlock;

  /// No description provided for @lock.
  ///
  /// In vi, this message translates to:
  /// **'Khóa'**
  String get lock;

  /// No description provided for @resetPassword.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại MK'**
  String get resetPassword;

  /// No description provided for @deliveryDispatchLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải dữ liệu điều phối: {error}'**
  String deliveryDispatchLoadError(Object error);

  /// No description provided for @tryAgain.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get tryAgain;

  /// No description provided for @deliveryControlCenter.
  ///
  /// In vi, this message translates to:
  /// **'🚚 Trung Tâm Điều Phối & Quản Lý Giao Hàng'**
  String get deliveryControlCenter;

  /// No description provided for @deliveryControlDescription.
  ///
  /// In vi, this message translates to:
  /// **'Giám sát hoạt động vận chuyển, thi công lắp đặt nội thất và xử lý sự cố real-time.'**
  String get deliveryControlDescription;

  /// No description provided for @refreshMetrics.
  ///
  /// In vi, this message translates to:
  /// **'Làm mới số liệu'**
  String get refreshMetrics;

  /// No description provided for @activeDispatchOrders.
  ///
  /// In vi, this message translates to:
  /// **'ĐƠN ĐANG ĐIỀU PHỐI'**
  String get activeDispatchOrders;

  /// No description provided for @orderCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} đơn'**
  String orderCount(Object count);

  /// No description provided for @totalDistance.
  ///
  /// In vi, this message translates to:
  /// **'TỔNG QUÃNG ĐƯỜNG'**
  String get totalDistance;

  /// No description provided for @collectedShippingFees.
  ///
  /// In vi, this message translates to:
  /// **'PHÍ VẬN CHUYỂN THU ĐƯỢC'**
  String get collectedShippingFees;

  /// No description provided for @earnedAssemblyFees.
  ///
  /// In vi, this message translates to:
  /// **'PHÍ LẮP ĐẶT THỢ KIẾM ĐƯỢC'**
  String get earnedAssemblyFees;

  /// No description provided for @teamWorkloadMonitoring.
  ///
  /// In vi, this message translates to:
  /// **'Giám Sát Tải Trọng Đội Ngũ Shipper & Thợ Thi Công'**
  String get teamWorkloadMonitoring;

  /// No description provided for @teamWorkloadDescription.
  ///
  /// In vi, this message translates to:
  /// **'Giúp Admin đưa ra quyết định phân ca và điều chỉnh đơn cho thợ hợp lý, tránh quá tải.'**
  String get teamWorkloadDescription;

  /// No description provided for @noShippers.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nhân viên Shipper nào trong hệ thống.'**
  String get noShippers;

  /// No description provided for @unavailable.
  ///
  /// In vi, this message translates to:
  /// **'Không sẵn sàng'**
  String get unavailable;

  /// No description provided for @unknown.
  ///
  /// In vi, this message translates to:
  /// **'Chưa rõ'**
  String get unknown;

  /// No description provided for @phoneSummary.
  ///
  /// In vi, this message translates to:
  /// **'SĐT: {phone}'**
  String phoneSummary(Object phone);

  /// No description provided for @activeDeliverySummary.
  ///
  /// In vi, this message translates to:
  /// **'Đang giao: {count} đơn'**
  String activeDeliverySummary(Object count);

  /// No description provided for @completedDeliverySummary.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong: {count} đơn'**
  String completedDeliverySummary(Object count);

  /// No description provided for @deliveryScheduleTitle.
  ///
  /// In vi, this message translates to:
  /// **'📅 Lịch Biểu Khung Giờ & Xử Lý Sự Cố Giao Hàng'**
  String get deliveryScheduleTitle;

  /// No description provided for @deliveryScheduleDescription.
  ///
  /// In vi, this message translates to:
  /// **'Phân chia ca thi công và can thiệp kịp thời các đơn hàng gặp trở ngại do Shipper gửi lên.'**
  String get deliveryScheduleDescription;

  /// No description provided for @morningShift.
  ///
  /// In vi, this message translates to:
  /// **'☀️ Ca Sáng ({count})'**
  String morningShift(Object count);

  /// No description provided for @afternoonShift.
  ///
  /// In vi, this message translates to:
  /// **'🌞 Ca Chiều ({count})'**
  String afternoonShift(Object count);

  /// No description provided for @eveningShift.
  ///
  /// In vi, this message translates to:
  /// **'🌙 Ca Tối ({count})'**
  String eveningShift(Object count);

  /// No description provided for @issuesReschedule.
  ///
  /// In vi, this message translates to:
  /// **'Sự cố / Hẹn lại ({count})'**
  String issuesReschedule(Object count);

  /// No description provided for @noDeliveryIssues.
  ///
  /// In vi, this message translates to:
  /// **'Tối ưu! Hiện không có đơn hàng nào gặp sự cố hay cần hẹn lại.'**
  String get noDeliveryIssues;

  /// No description provided for @noShiftOrders.
  ///
  /// In vi, this message translates to:
  /// **'Không có đơn hàng thuộc ca thi công này.'**
  String get noShiftOrders;

  /// No description provided for @assemblyIncludedBadge.
  ///
  /// In vi, this message translates to:
  /// **'🛠️ CÓ LẮP ĐẶT (+{fee})'**
  String assemblyIncludedBadge(Object fee);

  /// No description provided for @acceptanceImage.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh nghiệm thu'**
  String get acceptanceImage;

  /// No description provided for @dispatchChangeShift.
  ///
  /// In vi, this message translates to:
  /// **'Điều phối & Đổi ca'**
  String get dispatchChangeShift;

  /// No description provided for @customerContactSummary.
  ///
  /// In vi, this message translates to:
  /// **'👤 Khách hàng: {name} ({phone})'**
  String customerContactSummary(Object name, Object phone);

  /// No description provided for @addressSummary.
  ///
  /// In vi, this message translates to:
  /// **'📍 Địa chỉ: {address}'**
  String addressSummary(Object address);

  /// No description provided for @responsibleShipper.
  ///
  /// In vi, this message translates to:
  /// **'👷 Shipper phụ trách:'**
  String get responsibleShipper;

  /// No description provided for @unassigned.
  ///
  /// In vi, this message translates to:
  /// **'Chưa phân công'**
  String get unassigned;

  /// No description provided for @distanceSummary.
  ///
  /// In vi, this message translates to:
  /// **'📏 Khoảng cách: {distance} km'**
  String distanceSummary(Object distance);

  /// No description provided for @issueHistoryNotes.
  ///
  /// In vi, this message translates to:
  /// **'⚠️ Lịch sử & Ghi chú sự cố:\n{notes}'**
  String issueHistoryNotes(Object notes);

  /// No description provided for @rescheduledSecondTime.
  ///
  /// In vi, this message translates to:
  /// **'⚠️ Hẹn lại (Lần 2)'**
  String get rescheduledSecondTime;

  /// No description provided for @completedStatus.
  ///
  /// In vi, this message translates to:
  /// **'✅ Đã hoàn thành'**
  String get completedStatus;

  /// No description provided for @outForDelivery.
  ///
  /// In vi, this message translates to:
  /// **'🚚 Đang đi giao'**
  String get outForDelivery;

  /// No description provided for @awaitingDispatch.
  ///
  /// In vi, this message translates to:
  /// **'Chờ điều phối'**
  String get awaitingDispatch;

  /// No description provided for @acceptanceImageTitle.
  ///
  /// In vi, this message translates to:
  /// **'🖼️ Ảnh Nghiệm Thu Lắp Đặt / Giao Hàng'**
  String get acceptanceImageTitle;

  /// No description provided for @cannotLoadImage.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải hình ảnh.'**
  String get cannotLoadImage;

  /// No description provided for @dispatchDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Điều Phối & Sắp Xếp Lại - Đơn #{code}'**
  String dispatchDialogTitle(Object code);

  /// No description provided for @assignShipperRequired.
  ///
  /// In vi, this message translates to:
  /// **'Phân công Shipper thi công (*):'**
  String get assignShipperRequired;

  /// No description provided for @chooseResponsibleShipper.
  ///
  /// In vi, this message translates to:
  /// **'-- Chọn Shipper phụ trách --'**
  String get chooseResponsibleShipper;

  /// No description provided for @available.
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng'**
  String get available;

  /// No description provided for @newTimeSlot.
  ///
  /// In vi, this message translates to:
  /// **'Khung giờ thi công mới:'**
  String get newTimeSlot;

  /// No description provided for @adminDispatchNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú điều phối từ Admin (tùy chọn):'**
  String get adminDispatchNote;

  /// No description provided for @adminDispatchNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Khách vừa gọi chốt đổi sang ca Chiều, các bạn để ý lắp đặt cẩn thận...'**
  String get adminDispatchNoteHint;

  /// No description provided for @mustChooseShipper.
  ///
  /// In vi, this message translates to:
  /// **'⚠️ Vui lòng bắt buộc chọn một Shipper trước khi phân công / điều phối!'**
  String get mustChooseShipper;

  /// No description provided for @dispatchSaved.
  ///
  /// In vi, this message translates to:
  /// **'🎉 Đã lưu cấu hình điều phối thành công!'**
  String get dispatchSaved;

  /// No description provided for @saveDispatch.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi & Điều phối'**
  String get saveDispatch;

  /// No description provided for @confirmDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteVoucher.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa mã khuyến mãi \"{code}\" khỏi hệ thống?'**
  String confirmDeleteVoucher(Object code);

  /// No description provided for @voucherDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Xóa mã giảm giá thành công'**
  String get voucherDeleted;

  /// No description provided for @deleteVoucherError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi xóa voucher: {error}'**
  String deleteVoucherError(Object error);

  /// No description provided for @voucherManagementTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Khuyến mãi (Vouchers)'**
  String get voucherManagementTitle;

  /// No description provided for @createVoucher.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Voucher Mới'**
  String get createVoucher;

  /// No description provided for @voucherListTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách Mã Khuyến Mãi'**
  String get voucherListTitle;

  /// No description provided for @searchVoucherHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo mã, tên chương trình...'**
  String get searchVoucherHint;

  /// No description provided for @noSystemVouchers.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mã khuyến mãi nào trong hệ thống.'**
  String get noSystemVouchers;

  /// No description provided for @code.
  ///
  /// In vi, this message translates to:
  /// **'Mã Code'**
  String get code;

  /// No description provided for @campaignName.
  ///
  /// In vi, this message translates to:
  /// **'Tên chương trình'**
  String get campaignName;

  /// No description provided for @offer.
  ///
  /// In vi, this message translates to:
  /// **'Ưu đãi'**
  String get offer;

  /// No description provided for @minimumOrder.
  ///
  /// In vi, this message translates to:
  /// **'Đơn từ'**
  String get minimumOrder;

  /// No description provided for @usedSupported.
  ///
  /// In vi, this message translates to:
  /// **'Đã dùng / Hỗ trợ'**
  String get usedSupported;

  /// No description provided for @expiry.
  ///
  /// In vi, this message translates to:
  /// **'Hết hạn'**
  String get expiry;

  /// No description provided for @percentageDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm {value}%'**
  String percentageDiscount(Object value);

  /// No description provided for @maximumAmountSuffix.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa {amount}'**
  String maximumAmountSuffix(Object amount);

  /// No description provided for @cashDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm {amount}'**
  String cashDiscount(Object amount);

  /// No description provided for @operating.
  ///
  /// In vi, this message translates to:
  /// **'Đang HĐ'**
  String get operating;

  /// No description provided for @expired.
  ///
  /// In vi, this message translates to:
  /// **'Hết hạn'**
  String get expired;

  /// No description provided for @usageExhausted.
  ///
  /// In vi, this message translates to:
  /// **'Hết lượt'**
  String get usageExhausted;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get edit;

  /// No description provided for @createNewVoucher.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Mã Khuyến Mãi Mới'**
  String get createNewVoucher;

  /// No description provided for @updateVoucher.
  ///
  /// In vi, this message translates to:
  /// **'Cập Nhật Voucher (#{code})'**
  String updateVoucher(Object code);

  /// No description provided for @voucherCodeHint.
  ///
  /// In vi, this message translates to:
  /// **'Mã Code (VD: SUMMER2026)*'**
  String get voucherCodeHint;

  /// No description provided for @campaignNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Tên chương trình*'**
  String get campaignNameRequired;

  /// No description provided for @conditionDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết điều kiện áp dụng'**
  String get conditionDescription;

  /// No description provided for @discountType.
  ///
  /// In vi, this message translates to:
  /// **'Loại giảm giá'**
  String get discountType;

  /// No description provided for @percentageType.
  ///
  /// In vi, this message translates to:
  /// **'Theo Phần Trăm (%)'**
  String get percentageType;

  /// No description provided for @cashType.
  ///
  /// In vi, this message translates to:
  /// **'Giảm Tiền Mặt (VNĐ)'**
  String get cashType;

  /// No description provided for @discountPercentField.
  ///
  /// In vi, this message translates to:
  /// **'Mức giảm (%)'**
  String get discountPercentField;

  /// No description provided for @discountCashField.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền giảm (VNĐ)'**
  String get discountCashField;

  /// No description provided for @discountAmountField.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền giảm'**
  String get discountAmountField;

  /// No description provided for @maximumDiscountVnd.
  ///
  /// In vi, this message translates to:
  /// **'Giảm tối đa (VNĐ)'**
  String get maximumDiscountVnd;

  /// No description provided for @minimumOrderVnd.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng tối thiểu (VNĐ)*'**
  String get minimumOrderVnd;

  /// No description provided for @totalIssueLimit.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số lượt phát hành*'**
  String get totalIssueLimit;

  /// No description provided for @activateImmediately.
  ///
  /// In vi, this message translates to:
  /// **'Kích hoạt ngay'**
  String get activateImmediately;

  /// No description provided for @startDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày hết hạn'**
  String get endDate;

  /// No description provided for @saveVoucher.
  ///
  /// In vi, this message translates to:
  /// **'Lưu Voucher'**
  String get saveVoucher;

  /// No description provided for @maximumValue.
  ///
  /// In vi, this message translates to:
  /// **'{field} không được vượt quá {max}!'**
  String maximumValue(Object field, Object max);

  /// No description provided for @editReply.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh Sửa Phản Hồi'**
  String get editReply;

  /// No description provided for @answerAndEmail.
  ///
  /// In vi, this message translates to:
  /// **'Giải Đáp Thắc Mắc & Gửi Mail'**
  String get answerAndEmail;

  /// No description provided for @anonymous.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn danh'**
  String get anonymous;

  /// No description provided for @noEmail.
  ///
  /// In vi, this message translates to:
  /// **'Không có email'**
  String get noEmail;

  /// No description provided for @customerWithEmail.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng: {name} ({email})'**
  String customerWithEmail(Object email, Object name);

  /// No description provided for @topicLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chủ đề: [{topic}]'**
  String topicLabel(Object topic);

  /// No description provided for @adminReplyContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội Dung Phản Hồi Của Ban Quản Trị:'**
  String get adminReplyContent;

  /// No description provided for @adminReplyHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập câu trả lời chính thức... Nội dung này sẽ được gửi đến email của khách hàng.'**
  String get adminReplyHint;

  /// No description provided for @replyContentField.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung phản hồi'**
  String get replyContentField;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Đang Xử Lý...'**
  String get processing;

  /// No description provided for @saveReplyEmail.
  ///
  /// In vi, this message translates to:
  /// **'Lưu Phản Hồi & Gửi Email'**
  String get saveReplyEmail;

  /// No description provided for @adminQaCenterTitle.
  ///
  /// In vi, this message translates to:
  /// **'TRUNG TÂM QUẢN LÝ HỎI ĐÁP & TRỢ GIÚP (Q&A)'**
  String get adminQaCenterTitle;

  /// No description provided for @adminQaCenterDescription.
  ///
  /// In vi, this message translates to:
  /// **'Giải đáp thắc mắc khách hàng - Tự động thông báo trực tiếp qua Email SMTP'**
  String get adminQaCenterDescription;

  /// No description provided for @needsAnswer.
  ///
  /// In vi, this message translates to:
  /// **'⏳ Cần giải đáp ngay ({count})'**
  String needsAnswer(Object count);

  /// No description provided for @answeredCount.
  ///
  /// In vi, this message translates to:
  /// **'✅ Đã giải đáp ({count})'**
  String answeredCount(Object count);

  /// No description provided for @allQuestionCount.
  ///
  /// In vi, this message translates to:
  /// **'🌟 Tất cả câu hỏi ({count})'**
  String allQuestionCount(Object count);

  /// No description provided for @noUrgentQuestions.
  ///
  /// In vi, this message translates to:
  /// **'Tuyệt vời! Hiện không có câu hỏi nào cần trả lời gấp.'**
  String get noUrgentQuestions;

  /// No description provided for @noQuestionsInSection.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy câu hỏi nào trong mục này.'**
  String get noQuestionsInSection;

  /// No description provided for @fromCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Từ: {name} ({email})'**
  String fromCustomer(Object email, Object name);

  /// No description provided for @answered.
  ///
  /// In vi, this message translates to:
  /// **'✅ Đã trả lời'**
  String get answered;

  /// No description provided for @urgentHandling.
  ///
  /// In vi, this message translates to:
  /// **'⏳ Cần xử lý gấp'**
  String get urgentHandling;

  /// No description provided for @questionLabel.
  ///
  /// In vi, this message translates to:
  /// **'❓ Câu hỏi:'**
  String get questionLabel;

  /// No description provided for @repliedEmailed.
  ///
  /// In vi, this message translates to:
  /// **'💡 Đã phản hồi (Đã gửi mail):'**
  String get repliedEmailed;

  /// No description provided for @replyEmailCustomer.
  ///
  /// In vi, this message translates to:
  /// **'💬 Trả Lời & Gửi Mail Cho Khách'**
  String get replyEmailCustomer;

  /// No description provided for @minimumCharacters.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung phải có ít nhất {count} ký tự.'**
  String minimumCharacters(Object count);

  /// No description provided for @customerLabel.
  ///
  /// In vi, this message translates to:
  /// **'Khách'**
  String get customerLabel;

  /// No description provided for @atTime.
  ///
  /// In vi, this message translates to:
  /// **'Lúc: {time}'**
  String atTime(Object time);

  /// No description provided for @recommendationLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải trang quản lý gợi ý: {error}'**
  String recommendationLoadError(Object error);

  /// No description provided for @supportRangeError.
  ///
  /// In vi, this message translates to:
  /// **'Min Support phải lớn hơn 0% và không vượt quá 100%.'**
  String get supportRangeError;

  /// No description provided for @confidenceRangeError.
  ///
  /// In vi, this message translates to:
  /// **'Min Confidence phải lớn hơn 0% và không vượt quá 100%.'**
  String get confidenceRangeError;

  /// No description provided for @recommendationResultRangeError.
  ///
  /// In vi, this message translates to:
  /// **'Số kết quả gợi ý phải từ 1 đến 20.'**
  String get recommendationResultRangeError;

  /// No description provided for @recommendationRebuilt.
  ///
  /// In vi, this message translates to:
  /// **'Đã xây dựng lại dữ liệu gợi ý.'**
  String get recommendationRebuilt;

  /// No description provided for @recommendationBuildSummary.
  ///
  /// In vi, this message translates to:
  /// **'{message} Giỏ hàng: {baskets} · Luật: {rules}'**
  String recommendationBuildSummary(
    Object baskets,
    Object message,
    Object rules,
  );

  /// No description provided for @deleteAllAprioriRules.
  ///
  /// In vi, this message translates to:
  /// **'Xóa toàn bộ luật Apriori?'**
  String get deleteAllAprioriRules;

  /// No description provided for @deleteAprioriWarning.
  ///
  /// In vi, this message translates to:
  /// **'Phần “Thường mua cùng” sẽ không còn dữ liệu cho tới khi bạn xây dựng lại.'**
  String get deleteAprioriWarning;

  /// No description provided for @deleteRules.
  ///
  /// In vi, this message translates to:
  /// **'Xóa luật'**
  String get deleteRules;

  /// No description provided for @recommendationManagementTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý thuật toán gợi ý'**
  String get recommendationManagementTitle;

  /// No description provided for @recommendationManagementDescription.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi và điều chỉnh Apriori cùng Content-Based.'**
  String get recommendationManagementDescription;

  /// No description provided for @eligibleBaskets.
  ///
  /// In vi, this message translates to:
  /// **'GIỎ HÀNG HỢP LỆ'**
  String get eligibleBaskets;

  /// No description provided for @aprioriRules.
  ///
  /// In vi, this message translates to:
  /// **'LUẬT APRIORI'**
  String get aprioriRules;

  /// No description provided for @coveredProducts.
  ///
  /// In vi, this message translates to:
  /// **'SẢN PHẨM ĐƯỢC PHỦ'**
  String get coveredProducts;

  /// No description provided for @coverage.
  ///
  /// In vi, this message translates to:
  /// **'ĐỘ PHỦ'**
  String get coverage;

  /// No description provided for @operationSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình vận hành'**
  String get operationSettings;

  /// No description provided for @aprioriFrequentlyBoughtTogether.
  ///
  /// In vi, this message translates to:
  /// **'Apriori – Thường mua cùng'**
  String get aprioriFrequentlyBoughtTogether;

  /// No description provided for @aprioriHistoryDescription.
  ///
  /// In vi, this message translates to:
  /// **'Dùng lịch sử đơn đã thanh toán hoặc đã giao.'**
  String get aprioriHistoryDescription;

  /// No description provided for @contentBasedSimilarProducts.
  ///
  /// In vi, this message translates to:
  /// **'Content-Based – Sản phẩm tương tự'**
  String get contentBasedSimilarProducts;

  /// No description provided for @contentBasedDescription.
  ///
  /// In vi, this message translates to:
  /// **'So khớp danh mục, chất liệu, màu sắc và giá.'**
  String get contentBasedDescription;

  /// No description provided for @autoRebuildApriori.
  ///
  /// In vi, this message translates to:
  /// **'Tự động xây dựng lại Apriori'**
  String get autoRebuildApriori;

  /// No description provided for @autoRebuildDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chạy sau khi shipper xác nhận giao hàng.'**
  String get autoRebuildDescription;

  /// No description provided for @maximumRecommendationResults.
  ///
  /// In vi, this message translates to:
  /// **'Số kết quả tối đa'**
  String get maximumRecommendationResults;

  /// No description provided for @saveSettings.
  ///
  /// In vi, this message translates to:
  /// **'Lưu cấu hình'**
  String get saveSettings;

  /// No description provided for @rebuildApriori.
  ///
  /// In vi, this message translates to:
  /// **'Xây dựng lại Apriori'**
  String get rebuildApriori;

  /// No description provided for @parameterMeaning.
  ///
  /// In vi, this message translates to:
  /// **'Ý nghĩa tham số'**
  String get parameterMeaning;

  /// No description provided for @supportExplanation.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ số đơn chứa đồng thời hai sản phẩm trên tổng đơn hợp lệ.'**
  String get supportExplanation;

  /// No description provided for @confidenceExplanation.
  ///
  /// In vi, this message translates to:
  /// **'Xác suất khách mua sản phẩm B khi đơn đã có sản phẩm A.'**
  String get confidenceExplanation;

  /// No description provided for @coverageExplanation.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ sản phẩm đang có ít nhất một luật “thường mua cùng”.'**
  String get coverageExplanation;

  /// No description provided for @thresholdExplanation.
  ///
  /// In vi, this message translates to:
  /// **'Ngưỡng càng cao thì luật càng đáng tin nhưng số sản phẩm được phủ có thể giảm.'**
  String get thresholdExplanation;

  /// No description provided for @contentBasedPreview.
  ///
  /// In vi, this message translates to:
  /// **'Xem thử Content-Based'**
  String get contentBasedPreview;

  /// No description provided for @sourceProduct.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm nguồn'**
  String get sourceProduct;

  /// No description provided for @runTest.
  ///
  /// In vi, this message translates to:
  /// **'Chạy thử'**
  String get runTest;

  /// No description provided for @currentAprioriRules.
  ///
  /// In vi, this message translates to:
  /// **'Luật Apriori hiện tại ({count})'**
  String currentAprioriRules(Object count);

  /// No description provided for @deleteAll.
  ///
  /// In vi, this message translates to:
  /// **'Xóa toàn bộ'**
  String get deleteAll;

  /// No description provided for @noAprioriRules.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có luật. Hãy chạy “Xây dựng lại Apriori”.'**
  String get noAprioriRules;

  /// No description provided for @accompanyingRecommendation.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý đi kèm'**
  String get accompanyingRecommendation;

  /// No description provided for @updatedAt.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get updatedAt;

  /// No description provided for @productListLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải danh sách sản phẩm: {error}'**
  String productListLoadError(Object error);

  /// No description provided for @productReviewsLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải đánh giá sản phẩm: {error}'**
  String productReviewsLoadError(Object error);

  /// No description provided for @reviewApprovedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã phê duyệt đánh giá thành công!'**
  String get reviewApprovedSuccess;

  /// No description provided for @reviewApprovalError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi phê duyệt: {error}'**
  String reviewApprovalError(Object error);

  /// No description provided for @confirmReject.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận từ chối'**
  String get confirmReject;

  /// No description provided for @confirmRejectReview.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa/từ chối đánh giá này không?'**
  String get confirmRejectReview;

  /// No description provided for @reject.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get reject;

  /// No description provided for @reviewRejectedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa/từ chối đánh giá thành công!'**
  String get reviewRejectedSuccess;

  /// No description provided for @reviewRejectError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi từ chối: {error}'**
  String reviewRejectError(Object error);

  /// No description provided for @replyToReview.
  ///
  /// In vi, this message translates to:
  /// **'Phản hồi đánh giá'**
  String get replyToReview;

  /// No description provided for @reviewCustomerNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng: {name}'**
  String reviewCustomerNameLabel(Object name);

  /// No description provided for @commentQuoted.
  ///
  /// In vi, this message translates to:
  /// **'Bình luận: “{comment}”'**
  String commentQuoted(Object comment);

  /// No description provided for @replyContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung phản hồi:'**
  String get replyContent;

  /// No description provided for @storeReplyHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập nội dung trả lời từ cửa hàng...'**
  String get storeReplyHint;

  /// No description provided for @replyRequired.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung phản hồi không được để trống.'**
  String get replyRequired;

  /// No description provided for @sendReplyError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi gửi phản hồi: {error}'**
  String sendReplyError(Object error);

  /// No description provided for @sendReply.
  ///
  /// In vi, this message translates to:
  /// **'Gửi phản hồi'**
  String get sendReply;

  /// No description provided for @reviewManagementByProduct.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý đánh giá theo sản phẩm'**
  String get reviewManagementByProduct;

  /// No description provided for @aiReviewModerationDescription.
  ///
  /// In vi, this message translates to:
  /// **'AI kiểm duyệt khi khách gửi đánh giá: nội dung phù hợp được đăng tự động, nội dung tục tĩu bị chặn, trường hợp chưa chắc chắn sẽ chuyển sang chờ admin duyệt.'**
  String get aiReviewModerationDescription;

  /// No description provided for @businessProducts.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm kinh doanh'**
  String get businessProducts;

  /// No description provided for @parentCategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục cha'**
  String get parentCategory;

  /// No description provided for @allParentCategories.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả danh mục cha'**
  String get allParentCategories;

  /// No description provided for @chooseSubcategory.
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục con'**
  String get chooseSubcategory;

  /// No description provided for @subcategory.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục con'**
  String get subcategory;

  /// No description provided for @noProductsMatchFilter.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu sản phẩm nào phù hợp bộ lọc.'**
  String get noProductsMatchFilter;

  /// No description provided for @averageStars.
  ///
  /// In vi, this message translates to:
  /// **'Số sao trung bình'**
  String get averageStars;

  /// No description provided for @totalReviews.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số đánh giá'**
  String get totalReviews;

  /// No description provided for @pendingApproval.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get pendingApproval;

  /// No description provided for @reviewCountText.
  ///
  /// In vi, this message translates to:
  /// **'{count} đánh giá'**
  String reviewCountText(Object count);

  /// No description provided for @pendingReviewCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} chờ duyệt'**
  String pendingReviewCount(Object count);

  /// No description provided for @viewDetails.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết'**
  String get viewDetails;

  /// No description provided for @productReviewHeading.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá sản phẩm: {product}'**
  String productReviewHeading(Object product);

  /// No description provided for @detailedReviewList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách đánh giá chi tiết'**
  String get detailedReviewList;

  /// No description provided for @ratingReviewSummary.
  ///
  /// In vi, this message translates to:
  /// **'{rating} ({count} đánh giá)'**
  String ratingReviewSummary(Object count, Object rating);

  /// No description provided for @productHasNoReviews.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm này chưa nhận được đánh giá nào.'**
  String get productHasNoReviews;

  /// No description provided for @sender.
  ///
  /// In vi, this message translates to:
  /// **'Người gửi'**
  String get sender;

  /// No description provided for @starCount.
  ///
  /// In vi, this message translates to:
  /// **'Số sao'**
  String get starCount;

  /// No description provided for @customerOpinion.
  ///
  /// In vi, this message translates to:
  /// **'Ý kiến khách hàng'**
  String get customerOpinion;

  /// No description provided for @time.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get time;

  /// No description provided for @noComment.
  ///
  /// In vi, this message translates to:
  /// **'Không có chữ'**
  String get noComment;

  /// No description provided for @approved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get approved;

  /// No description provided for @notReplied.
  ///
  /// In vi, this message translates to:
  /// **'Chưa phản hồi'**
  String get notReplied;

  /// No description provided for @approve.
  ///
  /// In vi, this message translates to:
  /// **'Phê duyệt'**
  String get approve;

  /// No description provided for @reply.
  ///
  /// In vi, this message translates to:
  /// **'Phản hồi'**
  String get reply;

  /// No description provided for @deleteReview.
  ///
  /// In vi, this message translates to:
  /// **'Xóa đánh giá'**
  String get deleteReview;

  /// No description provided for @chooseRevenueRange.
  ///
  /// In vi, this message translates to:
  /// **'CHỌN KHOẢNG THỐNG KÊ DOANH THU'**
  String get chooseRevenueRange;

  /// No description provided for @dateRangeTooLong.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng thời gian quá dài. Hãy chọn mức tổng hợp lớn hơn hoặc rút ngắn khoảng ngày.'**
  String get dateRangeTooLong;

  /// No description provided for @revenueManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý doanh thu'**
  String get revenueManagement;

  /// No description provided for @revenueManagementDescription.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích doanh thu từ các đơn hàng đã giao thành công'**
  String get revenueManagementDescription;

  /// No description provided for @reloadReport.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại báo cáo'**
  String get reloadReport;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @last7Days.
  ///
  /// In vi, this message translates to:
  /// **'7 ngày gần nhất'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In vi, this message translates to:
  /// **'30 ngày gần nhất'**
  String get last30Days;

  /// No description provided for @thisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm nay'**
  String get thisYear;

  /// No description provided for @allTime.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ thời gian'**
  String get allTime;

  /// No description provided for @custom.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh'**
  String get custom;

  /// No description provided for @byDay.
  ///
  /// In vi, this message translates to:
  /// **'Theo ngày'**
  String get byDay;

  /// No description provided for @byMonth.
  ///
  /// In vi, this message translates to:
  /// **'Theo tháng'**
  String get byMonth;

  /// No description provided for @byYear.
  ///
  /// In vi, this message translates to:
  /// **'Theo năm'**
  String get byYear;

  /// No description provided for @dateRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng thời gian'**
  String get dateRange;

  /// No description provided for @aggregationLevel.
  ///
  /// In vi, this message translates to:
  /// **'Mức tổng hợp'**
  String get aggregationLevel;

  /// No description provided for @viewReport.
  ///
  /// In vi, this message translates to:
  /// **'XEM BÁO CÁO'**
  String get viewReport;

  /// No description provided for @totalRevenue.
  ///
  /// In vi, this message translates to:
  /// **'Tổng doanh thu'**
  String get totalRevenue;

  /// No description provided for @afterFeesAndOffers.
  ///
  /// In vi, this message translates to:
  /// **'Sau phí và ưu đãi'**
  String get afterFeesAndOffers;

  /// No description provided for @deliveredOrders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đã giao'**
  String get deliveredOrders;

  /// No description provided for @deliveredOrdersOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ tính đơn Delivered'**
  String get deliveredOrdersOnly;

  /// No description provided for @productsSold.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm đã bán'**
  String get productsSold;

  /// No description provided for @totalItemsInOrders.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số lượng trong đơn'**
  String get totalItemsInOrders;

  /// No description provided for @averageOrderValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị đơn trung bình'**
  String get averageOrderValue;

  /// No description provided for @customerCountText.
  ///
  /// In vi, this message translates to:
  /// **'{count} khách hàng'**
  String customerCountText(Object count);

  /// No description provided for @comparePreviousPeriod.
  ///
  /// In vi, this message translates to:
  /// **'So sánh với kỳ liền trước'**
  String get comparePreviousPeriod;

  /// No description provided for @ordersLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số đơn'**
  String get ordersLabel;

  /// No description provided for @previousPeriodRange.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ trước: {from} – {to}'**
  String previousPeriodRange(Object from, Object to);

  /// No description provided for @previousPeriodValue.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ trước: {value}'**
  String previousPeriodValue(Object value);

  /// No description provided for @revenueComposition.
  ///
  /// In vi, this message translates to:
  /// **'Cơ cấu doanh thu'**
  String get revenueComposition;

  /// No description provided for @merchandiseBeforeOffers.
  ///
  /// In vi, this message translates to:
  /// **'Tiền hàng trước ưu đãi'**
  String get merchandiseBeforeOffers;

  /// No description provided for @shippingFee.
  ///
  /// In vi, this message translates to:
  /// **'Phí vận chuyển'**
  String get shippingFee;

  /// No description provided for @assemblyFee.
  ///
  /// In vi, this message translates to:
  /// **'Phí lắp đặt'**
  String get assemblyFee;

  /// No description provided for @estimatedDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá ước tính'**
  String get estimatedDiscount;

  /// No description provided for @recognizedRevenue.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu ghi nhận'**
  String get recognizedRevenue;

  /// No description provided for @voucherOrderCountText.
  ///
  /// In vi, this message translates to:
  /// **'{count} đơn có sử dụng mã ưu đãi'**
  String voucherOrderCountText(Object count);

  /// No description provided for @revenueOrderTrend.
  ///
  /// In vi, this message translates to:
  /// **'Xu hướng doanh thu và số đơn'**
  String get revenueOrderTrend;

  /// No description provided for @revenue.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu'**
  String get revenue;

  /// No description provided for @noTimelineData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu theo thời gian.'**
  String get noTimelineData;

  /// No description provided for @revenueByCategory.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu theo danh mục'**
  String get revenueByCategory;

  /// No description provided for @revenueCategoryCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} danh mục phát sinh doanh thu'**
  String revenueCategoryCount(Object count);

  /// No description provided for @noCategoryRevenue.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có doanh thu theo danh mục.'**
  String get noCategoryRevenue;

  /// No description provided for @sold.
  ///
  /// In vi, this message translates to:
  /// **'Đã bán'**
  String get sold;

  /// No description provided for @share.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ trọng'**
  String get share;

  /// No description provided for @revenueByProduct.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu theo sản phẩm'**
  String get revenueByProduct;

  /// No description provided for @revenueProductCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} sản phẩm phát sinh doanh thu'**
  String revenueProductCount(Object count);

  /// No description provided for @searchRevenueProductHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm tên, mã hoặc danh mục...'**
  String get searchRevenueProductHint;

  /// No description provided for @noMatchingRevenueProducts.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sản phẩm phù hợp.'**
  String get noMatchingRevenueProducts;

  /// No description provided for @averageSellingPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá bán TB'**
  String get averageSellingPrice;

  /// No description provided for @detailByGroup.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết theo {group}'**
  String detailByGroup(Object group);

  /// No description provided for @periodCountText.
  ///
  /// In vi, this message translates to:
  /// **'{count} kỳ dữ liệu trong khoảng đã chọn'**
  String periodCountText(Object count);

  /// No description provided for @reportingPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Kỳ thống kê'**
  String get reportingPeriod;

  /// No description provided for @revenueMethodology.
  ///
  /// In vi, this message translates to:
  /// **'Cách tính: chỉ ghi nhận đơn đã giao (Delivered), theo thời điểm hoàn tất đơn. Doanh thu sản phẩm và danh mục là tiền hàng trước khi phân bổ mã giảm giá; tổng doanh thu là số tiền cuối cùng của đơn, đã bao gồm phí và ưu đãi. Vì dữ liệu hiện tại chưa lưu riêng số tiền giảm trên từng sản phẩm, phần giảm giá được ước tính ở cấp đơn hàng.'**
  String get revenueMethodology;

  /// No description provided for @monthYear.
  ///
  /// In vi, this message translates to:
  /// **'Tháng {month}/{year}'**
  String monthYear(Object month, Object year);

  /// No description provided for @yearValue.
  ///
  /// In vi, this message translates to:
  /// **'Năm {year}'**
  String yearValue(Object year);

  /// No description provided for @sessionExpired.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa đăng nhập hoặc phiên làm việc đã hết hạn.'**
  String get sessionExpired;

  /// No description provided for @deliveryListLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải danh sách vận đơn: {error}'**
  String deliveryListLoadError(Object error);

  /// No description provided for @availableForOrders.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang sẵn sàng nhận đơn.'**
  String get availableForOrders;

  /// No description provided for @unavailableForOrders.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã chuyển sang không sẵn sàng.'**
  String get unavailableForOrders;

  /// No description provided for @shipperPortalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cổng Giao nhận & Lắp đặt'**
  String get shipperPortalTitle;

  /// No description provided for @employeeName.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên: {name}'**
  String employeeName(Object name);

  /// No description provided for @refreshList.
  ///
  /// In vi, this message translates to:
  /// **'Làm mới danh sách'**
  String get refreshList;

  /// No description provided for @activeDeliveriesCount.
  ///
  /// In vi, this message translates to:
  /// **'Đang Giao ({count})'**
  String activeDeliveriesCount(Object count);

  /// No description provided for @completedDeliveriesCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã Hoàn Thành ({count})'**
  String completedDeliveriesCount(Object count);

  /// No description provided for @noPendingDeliveries.
  ///
  /// In vi, this message translates to:
  /// **'Hiện không có đơn hàng nào đang chờ giao.'**
  String get noPendingDeliveries;

  /// No description provided for @noCompletedDeliveries.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa hoàn thành đơn hàng nào.'**
  String get noCompletedDeliveries;

  /// No description provided for @deliveryNoteCode.
  ///
  /// In vi, this message translates to:
  /// **'Vận đơn #{code}'**
  String deliveryNoteCode(Object code);

  /// No description provided for @rescheduledAttempt.
  ///
  /// In vi, this message translates to:
  /// **'⚠️ HẸN LẠI (LẦN {count})'**
  String rescheduledAttempt(Object count);

  /// No description provided for @deliveringStatus.
  ///
  /// In vi, this message translates to:
  /// **'ĐANG GIAO'**
  String get deliveringStatus;

  /// No description provided for @successfulStatus.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH CÔNG'**
  String get successfulStatus;

  /// No description provided for @noteText.
  ///
  /// In vi, this message translates to:
  /// **'📝 Ghi chú: {note}'**
  String noteText(Object note);

  /// No description provided for @includesAssemblyBadge.
  ///
  /// In vi, this message translates to:
  /// **'🛠️ CÓ LẮP ĐẶT'**
  String get includesAssemblyBadge;

  /// No description provided for @totalCollection.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thu: {amount}'**
  String totalCollection(Object amount);

  /// No description provided for @cannotCallNumber.
  ///
  /// In vi, this message translates to:
  /// **'Không thể gọi đến số: {phone}'**
  String cannotCallNumber(Object phone);

  /// No description provided for @cannotOpenGoogleMaps.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở bản đồ Google Maps.'**
  String get cannotOpenGoogleMaps;

  /// No description provided for @confirmDeliveryCompletion.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận hoàn tất đơn hàng'**
  String get confirmDeliveryCompletion;

  /// No description provided for @confirmDeliveryCompletionMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã giao nội thất và hoàn thành việc lắp đặt (nếu có) thành công cho khách hàng?'**
  String get confirmDeliveryCompletionMessage;

  /// No description provided for @confirmComplete.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận hoàn tất'**
  String get confirmComplete;

  /// No description provided for @deliveryCompletedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'🎉 Xác nhận giao hàng & lắp đặt thành công!'**
  String get deliveryCompletedSuccess;

  /// No description provided for @customerAbsentReason.
  ///
  /// In vi, this message translates to:
  /// **'Khách vắng nhà (Xin hẹn lại)'**
  String get customerAbsentReason;

  /// No description provided for @customerRescheduleReason.
  ///
  /// In vi, this message translates to:
  /// **'Khách xin đổi lịch / giờ giao'**
  String get customerRescheduleReason;

  /// No description provided for @incorrectContactReason.
  ///
  /// In vi, this message translates to:
  /// **'Sai thông tin địa chỉ hoặc SĐT'**
  String get incorrectContactReason;

  /// No description provided for @technicalIssueReason.
  ///
  /// In vi, this message translates to:
  /// **'Sự cố kỹ thuật lắp đặt / hàng hóa'**
  String get technicalIssueReason;

  /// No description provided for @weatherTrafficReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do thời tiết / giao thông'**
  String get weatherTrafficReason;

  /// No description provided for @reportIssue.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo sự cố'**
  String get reportIssue;

  /// No description provided for @chooseIncompleteReason.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nguyên nhân chưa hoàn thành đơn:'**
  String get chooseIncompleteReason;

  /// No description provided for @issueDetailNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú chi tiết / Mong muốn của khách:'**
  String get issueDetailNote;

  /// No description provided for @issueNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Khách đi làm về trễ, hẹn giao sáng mai lúc 9h...'**
  String get issueNoteHint;

  /// No description provided for @sendReport.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo'**
  String get sendReport;

  /// No description provided for @issueReportedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'⚠️ Đã ghi nhận sự cố và chuyển đơn sang trạng thái Hẹn giao lại!'**
  String get issueReportedSuccess;

  /// No description provided for @deliveryDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết vận đơn #{code}'**
  String deliveryDetailTitle(Object code);

  /// No description provided for @deliveryAssemblySuccessful.
  ///
  /// In vi, this message translates to:
  /// **'Giao hàng & Lắp đặt thành công'**
  String get deliveryAssemblySuccessful;

  /// No description provided for @deliveryInProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đang thực hiện giao hàng...'**
  String get deliveryInProgress;

  /// No description provided for @shipperAppointmentSlot.
  ///
  /// In vi, this message translates to:
  /// **'⏰ Khung giờ hẹn: {slot}'**
  String shipperAppointmentSlot(Object slot);

  /// No description provided for @homeAssemblyRequired.
  ///
  /// In vi, this message translates to:
  /// **'🛠️ CÓ YÊU CẦU LẮP ĐẶT TẠI NHÀ (+{amount})'**
  String homeAssemblyRequired(Object amount);

  /// No description provided for @incidentHistory.
  ///
  /// In vi, this message translates to:
  /// **'📝 Lịch sử / Ghi chú sự cố:\n{notes}'**
  String incidentHistory(Object notes);

  /// No description provided for @recipientInformation.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin người nhận'**
  String get recipientInformation;

  /// No description provided for @phoneNotUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật số ĐT'**
  String get phoneNotUpdated;

  /// No description provided for @callNow.
  ///
  /// In vi, this message translates to:
  /// **'Gọi ngay'**
  String get callNow;

  /// No description provided for @openGoogleMapsDirections.
  ///
  /// In vi, this message translates to:
  /// **'Mở Google Maps Chỉ Đường'**
  String get openGoogleMapsDirections;

  /// No description provided for @deliveryItemsCount.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách món đồ cần giao ({count} sản phẩm)'**
  String deliveryItemsCount(Object count);

  /// No description provided for @colorSizeSummary.
  ///
  /// In vi, this message translates to:
  /// **'Màu: {color} | Kích thước: {size}'**
  String colorSizeSummary(Object color, Object size);

  /// No description provided for @orderInvoiceSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tổng kết đơn & Hóa đơn'**
  String get orderInvoiceSummary;

  /// No description provided for @merchandiseAmount.
  ///
  /// In vi, this message translates to:
  /// **'Tiền hàng:'**
  String get merchandiseAmount;

  /// No description provided for @grandTotal.
  ///
  /// In vi, this message translates to:
  /// **'TỔNG TIỀN:'**
  String get grandTotal;

  /// No description provided for @paidNoCashCollection.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng ĐÃ THANH TOÁN ({method}). Không thu tiền mặt.'**
  String paidNoCashCollection(Object method);

  /// No description provided for @collectCashCod.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thanh toán. Vui lòng THU TIỀN MẶT (COD): {amount}'**
  String collectCashCod(Object amount);

  /// No description provided for @confirmDeliveryAssemblySuccess.
  ///
  /// In vi, this message translates to:
  /// **'XÁC NHẬN GIAO HÀNG & LẮP ĐẶT THÀNH CÔNG'**
  String get confirmDeliveryAssemblySuccess;

  /// No description provided for @reportIssueReschedule.
  ///
  /// In vi, this message translates to:
  /// **'BÁO CÁO SỰ CỐ / XIN HẸN GIAO LẠI'**
  String get reportIssueReschedule;

  /// No description provided for @registrationLinkMissingToken.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết không chứa mã thiết lập mật khẩu.'**
  String get registrationLinkMissingToken;

  /// No description provided for @registrationSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công'**
  String get registrationSuccess;

  /// No description provided for @accountSetup.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập tài khoản'**
  String get accountSetup;

  /// No description provided for @invalidRegistrationLink.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết không còn hiệu lực'**
  String get invalidRegistrationLink;

  /// No description provided for @requestNewLink.
  ///
  /// In vi, this message translates to:
  /// **'YÊU CẦU LIÊN KẾT MỚI'**
  String get requestNewLink;

  /// No description provided for @createYourPassword.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mật khẩu của bạn'**
  String get createYourPassword;

  /// No description provided for @newPasswordField.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get newPasswordField;

  /// No description provided for @minimumEightCharacters.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 8 ký tự'**
  String get minimumEightCharacters;

  /// No description provided for @confirmPasswordField.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get confirmPasswordField;

  /// No description provided for @passwordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không trùng khớp với mật khẩu mới!'**
  String get passwordMismatch;

  /// No description provided for @completeRegistration.
  ///
  /// In vi, this message translates to:
  /// **'HOÀN TẤT ĐĂNG KÝ'**
  String get completeRegistration;

  /// No description provided for @verificationCodeSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi mã xác thực về Email của bạn!'**
  String get verificationCodeSent;

  /// No description provided for @otpResent.
  ///
  /// In vi, this message translates to:
  /// **'🔄 Đã tạo và gửi lại mã OTP mới về Email!'**
  String get otpResent;

  /// No description provided for @otpVerifiedSetPassword.
  ///
  /// In vi, this message translates to:
  /// **'✅ Xác thực OTP thành công! Vui lòng đặt mật khẩu mới.'**
  String get otpVerifiedSetPassword;

  /// No description provided for @otpRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mã OTP!'**
  String get otpRequired;

  /// No description provided for @otpDigitsRequired.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP phải gồm đúng {count} chữ số!'**
  String otpDigitsRequired(Object count);

  /// No description provided for @passwordRecoverySuccess.
  ///
  /// In vi, this message translates to:
  /// **'🎉 Khôi phục mật khẩu thành công! Hãy đăng nhập lại.'**
  String get passwordRecoverySuccess;

  /// No description provided for @backPreviousStep.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại bước trước'**
  String get backPreviousStep;

  /// No description provided for @backToLogin.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại đăng nhập'**
  String get backToLogin;

  /// No description provided for @otpStep.
  ///
  /// In vi, this message translates to:
  /// **'2. Mã OTP'**
  String get otpStep;

  /// No description provided for @newPasswordStep.
  ///
  /// In vi, this message translates to:
  /// **'3. Mật khẩu mới'**
  String get newPasswordStep;

  /// No description provided for @passwordRecoveryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khôi Phục Mật Khẩu'**
  String get passwordRecoveryTitle;

  /// No description provided for @passwordRecoveryDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhập Email gắn liền với tài khoản của bạn. Hệ thống sẽ gửi một mã xác thực (OTP) để bạn đặt lại mật khẩu mới.'**
  String get passwordRecoveryDescription;

  /// No description provided for @yourEmailRequired.
  ///
  /// In vi, this message translates to:
  /// **'EMAIL CỦA BẠN (*)'**
  String get yourEmailRequired;

  /// No description provided for @emailExample.
  ///
  /// In vi, this message translates to:
  /// **'VD: user@example.com'**
  String get emailExample;

  /// No description provided for @sendOtp.
  ///
  /// In vi, this message translates to:
  /// **'GỬI MÃ XÁC THỰC OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác Thực Mã OTP'**
  String get verifyOtpTitle;

  /// No description provided for @otpEmailInstruction.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng kiểm tra Email “{email}” (cả hộp thư Rác/Spam) và nhập mã 6 số vừa nhận được vào bên dưới.'**
  String otpEmailInstruction(Object email);

  /// No description provided for @sixDigitVerificationCode.
  ///
  /// In vi, this message translates to:
  /// **'MÃ XÁC THỰC 6 SỐ'**
  String get sixDigitVerificationCode;

  /// No description provided for @resendAfterSeconds.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã sau ({seconds}s)'**
  String resendAfterSeconds(Object seconds);

  /// No description provided for @emailNotReceived.
  ///
  /// In vi, this message translates to:
  /// **'Chưa nhận được email?'**
  String get emailNotReceived;

  /// No description provided for @resendNewCode.
  ///
  /// In vi, this message translates to:
  /// **'🔄 Gửi Lại Mã Mới'**
  String get resendNewCode;

  /// No description provided for @confirmOtp.
  ///
  /// In vi, this message translates to:
  /// **'XÁC NHẬN MÃ OTP'**
  String get confirmOtp;

  /// No description provided for @notEntered.
  ///
  /// In vi, this message translates to:
  /// **'Chưa nhập'**
  String get notEntered;

  /// No description provided for @weak.
  ///
  /// In vi, this message translates to:
  /// **'Yếu'**
  String get weak;

  /// No description provided for @medium.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình'**
  String get medium;

  /// No description provided for @strong.
  ///
  /// In vi, this message translates to:
  /// **'Mạnh'**
  String get strong;

  /// No description provided for @createNewPassword.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Mật Khẩu Mới'**
  String get createNewPassword;

  /// No description provided for @verifiedPasswordInstruction.
  ///
  /// In vi, this message translates to:
  /// **'Mã xác thực thành công. Vui lòng thiết lập mật khẩu mới cho tài khoản “{email}”.'**
  String verifiedPasswordInstruction(Object email);

  /// No description provided for @newPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'MẬT KHẨU MỚI (*)'**
  String get newPasswordRequired;

  /// No description provided for @minimumSixCharactersHint.
  ///
  /// In vi, this message translates to:
  /// **'Ít nhất 6 ký tự...'**
  String get minimumSixCharactersHint;

  /// No description provided for @passwordStrength.
  ///
  /// In vi, this message translates to:
  /// **'Độ mạnh: {strength}'**
  String passwordStrength(Object strength);

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'XÁC NHẬN MẬT KHẨU (*)'**
  String get confirmPasswordRequired;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu mới...'**
  String get confirmNewPasswordHint;

  /// No description provided for @savePasswordComplete.
  ///
  /// In vi, this message translates to:
  /// **'LƯU MẬT KHẨU & HOÀN TẤT'**
  String get savePasswordComplete;

  /// No description provided for @aiFromRoomAndProducts.
  ///
  /// In vi, this message translates to:
  /// **'AI tạo phối cảnh từ phòng và sản phẩm'**
  String get aiFromRoomAndProducts;

  /// No description provided for @aiFromRoomAndProductsDescription.
  ///
  /// In vi, this message translates to:
  /// **'Thêm các sản phẩm muốn phối vào phòng. AI sẽ tạo một ảnh mới, tự cân chỉnh vị trí, góc nhìn và ánh sáng.'**
  String get aiFromRoomAndProductsDescription;

  /// No description provided for @addProductToAiScene.
  ///
  /// In vi, this message translates to:
  /// **'Thêm sản phẩm vào phối cảnh'**
  String get addProductToAiScene;

  /// No description provided for @selectedProducts.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm đã thêm'**
  String get selectedProducts;

  /// No description provided for @removeProductFromScene.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ sản phẩm khỏi phối cảnh'**
  String get removeProductFromScene;

  /// No description provided for @chooseAtLeastOneProduct.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn ảnh phòng và ít nhất một sản phẩm.'**
  String get chooseAtLeastOneProduct;

  /// No description provided for @chatServiceBusy.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý AI đang bận. Hệ thống sẽ tự thử lại; bạn cũng có thể gửi lại sau ít phút.'**
  String get chatServiceBusy;

  /// No description provided for @retryMessage.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại'**
  String get retryMessage;

  /// No description provided for @chatReadyStatus.
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng tư vấn nội thất'**
  String get chatReadyStatus;

  /// No description provided for @addressSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu địa chỉ thành công.'**
  String get addressSaved;

  /// No description provided for @addressDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa địa chỉ.'**
  String get addressDeleted;

  /// No description provided for @confirmDeleteAddress.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa địa chỉ này?'**
  String get confirmDeleteAddress;

  /// No description provided for @addressRequiredFields.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đầy đủ người nhận, số điện thoại và địa chỉ.'**
  String get addressRequiredFields;

  /// No description provided for @chooseSavedAddress.
  ///
  /// In vi, this message translates to:
  /// **'Chọn địa chỉ đã lưu'**
  String get chooseSavedAddress;

  /// No description provided for @savedAddresses.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ đã lưu'**
  String get savedAddresses;

  /// No description provided for @useThisAddress.
  ///
  /// In vi, this message translates to:
  /// **'Sử dụng địa chỉ này'**
  String get useThisAddress;

  /// No description provided for @revenueByMonthDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu theo tháng'**
  String get revenueByMonthDashboard;

  /// No description provided for @ordersByMonthDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ đơn giao thành công theo tháng'**
  String get ordersByMonthDashboard;

  /// No description provided for @noDashboardChartData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu để hiển thị biểu đồ.'**
  String get noDashboardChartData;

  /// No description provided for @supportChatTitle.
  ///
  /// In vi, this message translates to:
  /// **'TRÒ CHUYỆN HỖ TRỢ'**
  String get supportChatTitle;

  /// No description provided for @supportChatDescription.
  ///
  /// In vi, this message translates to:
  /// **'Trao đổi trực tiếp với bộ phận chăm sóc khách hàng.'**
  String get supportChatDescription;

  /// No description provided for @newSupportConversation.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc trò chuyện mới'**
  String get newSupportConversation;

  /// No description provided for @createSupportConversation.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu trò chuyện'**
  String get createSupportConversation;

  /// No description provided for @supportTopic.
  ///
  /// In vi, this message translates to:
  /// **'Chủ đề hỗ trợ'**
  String get supportTopic;

  /// No description provided for @supportFirstMessageHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả vấn đề bạn cần hỗ trợ...'**
  String get supportFirstMessageHint;

  /// No description provided for @supportFirstMessageValidation.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung mở đầu cần có ít nhất 10 ký tự.'**
  String get supportFirstMessageValidation;

  /// No description provided for @supportMessageTooLong.
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn không được vượt quá 4.000 ký tự.'**
  String get supportMessageTooLong;

  /// No description provided for @noSupportConversations.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có cuộc trò chuyện hỗ trợ nào.'**
  String get noSupportConversations;

  /// No description provided for @noConversationSelected.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn cuộc trò chuyện'**
  String get noConversationSelected;

  /// No description provided for @chooseConversationHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một cuộc trò chuyện bên trái hoặc tạo cuộc trò chuyện mới.'**
  String get chooseConversationHint;

  /// No description provided for @noMessagesYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin nhắn'**
  String get noMessagesYet;

  /// No description provided for @supportMessageHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tin nhắn...'**
  String get supportMessageHint;

  /// No description provided for @sendSupportMessage.
  ///
  /// In vi, this message translates to:
  /// **'Gửi tin nhắn'**
  String get sendSupportMessage;

  /// No description provided for @adminSupport.
  ///
  /// In vi, this message translates to:
  /// **'Bộ phận hỗ trợ'**
  String get adminSupport;

  /// No description provided for @supportOnline.
  ///
  /// In vi, this message translates to:
  /// **'Trực tuyến'**
  String get supportOnline;

  /// No description provided for @supportConnecting.
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối'**
  String get supportConnecting;

  /// No description provided for @supportReconnecting.
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối lại'**
  String get supportReconnecting;

  /// No description provided for @supportOffline.
  ///
  /// In vi, this message translates to:
  /// **'Ngoại tuyến'**
  String get supportOffline;

  /// No description provided for @waitingForAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ bộ phận hỗ trợ'**
  String get waitingForAdmin;

  /// No description provided for @waitingForCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ phản hồi của bạn'**
  String get waitingForCustomer;

  /// No description provided for @supportClosed.
  ///
  /// In vi, this message translates to:
  /// **'Đã đóng'**
  String get supportClosed;

  /// No description provided for @supportActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang hỗ trợ'**
  String get supportActive;

  /// No description provided for @supportConversationClosed.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc trò chuyện này đã đóng. Hãy tạo cuộc trò chuyện mới nếu bạn cần thêm hỗ trợ.'**
  String get supportConversationClosed;

  /// No description provided for @backToConversations.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại danh sách trò chuyện'**
  String get backToConversations;

  /// No description provided for @adminSupportInboxTitle.
  ///
  /// In vi, this message translates to:
  /// **'HỘP THƯ HỖ TRỢ REALTIME'**
  String get adminSupportInboxTitle;

  /// No description provided for @adminSupportInboxDescription.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi và phản hồi hội thoại của khách hàng theo thời gian thực.'**
  String get adminSupportInboxDescription;

  /// No description provided for @needsAdminReply.
  ///
  /// In vi, this message translates to:
  /// **'Cần phản hồi'**
  String get needsAdminReply;

  /// No description provided for @awaitingCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Chờ khách hàng'**
  String get awaitingCustomer;

  /// No description provided for @allSupportConversations.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get allSupportConversations;

  /// No description provided for @searchSupportConversation.
  ///
  /// In vi, this message translates to:
  /// **'Tìm khách hàng, email...'**
  String get searchSupportConversation;

  /// No description provided for @noAdminSupportConversations.
  ///
  /// In vi, this message translates to:
  /// **'Không có hội thoại phù hợp.'**
  String get noAdminSupportConversations;

  /// No description provided for @adminChooseConversation.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một hội thoại để bắt đầu hỗ trợ khách hàng.'**
  String get adminChooseConversation;

  /// No description provided for @assignToMe.
  ///
  /// In vi, this message translates to:
  /// **'Nhận xử lý'**
  String get assignToMe;

  /// No description provided for @assignedAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Phụ trách: {name}'**
  String assignedAdmin(String name);

  /// No description provided for @reopenConversation.
  ///
  /// In vi, this message translates to:
  /// **'Mở lại hội thoại'**
  String get reopenConversation;

  /// No description provided for @closeConversation.
  ///
  /// In vi, this message translates to:
  /// **'Đóng hội thoại'**
  String get closeConversation;

  /// No description provided for @adminClosedConversationHint.
  ///
  /// In vi, this message translates to:
  /// **'Hội thoại đã đóng. Mở lại nếu cần tiếp tục trao đổi.'**
  String get adminClosedConversationHint;

  /// No description provided for @adminSupportReplyHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập nội dung phản hồi cho khách hàng...'**
  String get adminSupportReplyHint;

  /// No description provided for @adminReplyEmailNotice.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng sẽ nhận tin nhắn realtime và email thông báo phản hồi.'**
  String get adminReplyEmailNotice;

  /// No description provided for @supportIsTyping.
  ///
  /// In vi, this message translates to:
  /// **'Bộ phận hỗ trợ đang nhập...'**
  String get supportIsTyping;

  /// No description provided for @customerIsTyping.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng đang nhập...'**
  String get customerIsTyping;

  /// No description provided for @shipperProfileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ giao hàng'**
  String get shipperProfileTitle;

  /// No description provided for @vehicleType.
  ///
  /// In vi, this message translates to:
  /// **'Loại phương tiện'**
  String get vehicleType;

  /// No description provided for @vehiclePlate.
  ///
  /// In vi, this message translates to:
  /// **'Biển số xe'**
  String get vehiclePlate;

  /// No description provided for @serviceArea.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực hoạt động'**
  String get serviceArea;

  /// No description provided for @maxConcurrentDeliveries.
  ///
  /// In vi, this message translates to:
  /// **'Số đơn tối đa cùng lúc'**
  String get maxConcurrentDeliveries;

  /// No description provided for @canHandleBulkyItems.
  ///
  /// In vi, this message translates to:
  /// **'Có thể chở hàng cồng kềnh'**
  String get canHandleBulkyItems;

  /// No description provided for @canProvideAssembly.
  ///
  /// In vi, this message translates to:
  /// **'Có thể hỗ trợ lắp đặt'**
  String get canProvideAssembly;

  /// No description provided for @shiftEnd.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc ca'**
  String get shiftEnd;

  /// No description provided for @shiftAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng'**
  String get shiftAvailable;

  /// No description provided for @shiftDelivering.
  ///
  /// In vi, this message translates to:
  /// **'Đang giao'**
  String get shiftDelivering;

  /// No description provided for @shiftBreak.
  ///
  /// In vi, this message translates to:
  /// **'Tạm nghỉ'**
  String get shiftBreak;

  /// No description provided for @deliveryDirections.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ đường'**
  String get deliveryDirections;

  /// No description provided for @callCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Gọi khách'**
  String get callCustomer;

  /// No description provided for @acceptDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Chấp nhận đơn'**
  String get acceptDelivery;

  /// No description provided for @rejectDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối đơn'**
  String get rejectDelivery;

  /// No description provided for @rejectDeliveryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối đơn giao hàng'**
  String get rejectDeliveryTitle;

  /// No description provided for @rejectReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do từ chối'**
  String get rejectReason;

  /// No description provided for @assignmentAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã chấp nhận đơn giao hàng.'**
  String get assignmentAccepted;

  /// No description provided for @assignmentRejected.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển đơn về Admin để phân công lại.'**
  String get assignmentRejected;

  /// No description provided for @pickedUpFromWarehouse.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận hàng từ kho'**
  String get pickedUpFromWarehouse;

  /// No description provided for @pickedUpConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận nhận hàng từ kho.'**
  String get pickedUpConfirmed;

  /// No description provided for @startDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu giao hàng'**
  String get startDelivery;

  /// No description provided for @deliveryOnTheWay.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng đang trên đường giao.'**
  String get deliveryOnTheWay;

  /// No description provided for @arrivedDestination.
  ///
  /// In vi, this message translates to:
  /// **'Đã đến nơi'**
  String get arrivedDestination;

  /// No description provided for @arrivedNotification.
  ///
  /// In vi, this message translates to:
  /// **'Đã thông báo shipper đến nơi.'**
  String get arrivedNotification;

  /// No description provided for @verifyRecipient.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh người nhận'**
  String get verifyRecipient;

  /// No description provided for @sendOtpByEmail.
  ///
  /// In vi, this message translates to:
  /// **'Gửi OTP qua email'**
  String get sendOtpByEmail;

  /// No description provided for @deliveryOtpLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP 6 số'**
  String get deliveryOtpLabel;

  /// No description provided for @verifyOtp.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh'**
  String get verifyOtp;

  /// No description provided for @otpVerified.
  ///
  /// In vi, this message translates to:
  /// **'OTP đã xác minh'**
  String get otpVerified;

  /// No description provided for @otpSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi OTP đến email của khách hàng.'**
  String get otpSent;

  /// No description provided for @otpMustBeSixDigits.
  ///
  /// In vi, this message translates to:
  /// **'OTP phải gồm đúng 6 chữ số.'**
  String get otpMustBeSixDigits;

  /// No description provided for @otpVerifiedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh OTP thành công.'**
  String get otpVerifiedSuccess;

  /// No description provided for @actualRecipientName.
  ///
  /// In vi, this message translates to:
  /// **'Tên người thực tế nhận hàng'**
  String get actualRecipientName;

  /// No description provided for @chooseDeliveryProof.
  ///
  /// In vi, this message translates to:
  /// **'Chụp/chọn ảnh bằng chứng'**
  String get chooseDeliveryProof;

  /// No description provided for @changeDeliveryProof.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh bằng chứng'**
  String get changeDeliveryProof;

  /// No description provided for @confirmDelivered.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận giao thành công'**
  String get confirmDelivered;

  /// No description provided for @deliveryStatusAssigned.
  ///
  /// In vi, this message translates to:
  /// **'Chờ shipper nhận'**
  String get deliveryStatusAssigned;

  /// No description provided for @deliveryStatusAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận đơn'**
  String get deliveryStatusAccepted;

  /// No description provided for @deliveryStatusPickedUp.
  ///
  /// In vi, this message translates to:
  /// **'Đã lấy hàng'**
  String get deliveryStatusPickedUp;

  /// No description provided for @deliveryStatusShipping.
  ///
  /// In vi, this message translates to:
  /// **'Đang giao hàng'**
  String get deliveryStatusShipping;

  /// No description provided for @deliveryStatusArrived.
  ///
  /// In vi, this message translates to:
  /// **'Đã đến nơi'**
  String get deliveryStatusArrived;

  /// No description provided for @deliveryOtpRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác minh OTP của người nhận.'**
  String get deliveryOtpRequired;

  /// No description provided for @deliveryProofRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng tải ảnh bằng chứng giao hàng.'**
  String get deliveryProofRequired;

  /// No description provided for @deliveryRecipientRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên người thực tế nhận hàng.'**
  String get deliveryRecipientRequired;

  /// No description provided for @attachIssueProof.
  ///
  /// In vi, this message translates to:
  /// **'Đính kèm ảnh sự cố'**
  String get attachIssueProof;

  /// No description provided for @confirmCollectedPayment.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đã thu tiền'**
  String get confirmCollectedPayment;

  /// No description provided for @confirmCollectedPaymentMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn xác nhận đã thu đúng {amount} từ khách hàng?'**
  String confirmCollectedPaymentMessage(String amount);

  /// No description provided for @paymentCollectedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi nhận thu tiền thành công.'**
  String get paymentCollectedSuccess;

  /// No description provided for @collectPaymentBeforeComplete.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác nhận đã thu tiền COD/POS trước khi hoàn tất.'**
  String get collectPaymentBeforeComplete;

  /// No description provided for @amountToCollect.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền cần thu: {amount}'**
  String amountToCollect(String amount);

  /// No description provided for @paymentMethodSummary.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức: {method}'**
  String paymentMethodSummary(String method);

  /// No description provided for @paymentCollected.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận thu đủ tiền'**
  String get paymentCollected;

  /// No description provided for @paymentCollectionNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú thu tiền (không bắt buộc)'**
  String get paymentCollectionNote;

  /// No description provided for @addPaymentProof.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh bằng chứng thanh toán'**
  String get addPaymentProof;

  /// No description provided for @changePaymentProof.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh bằng chứng thanh toán'**
  String get changePaymentProof;

  /// No description provided for @confirmPaymentCollected.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đã thu tiền'**
  String get confirmPaymentCollected;

  /// No description provided for @handoverPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ shipper bàn giao'**
  String get handoverPending;

  /// No description provided for @handoverSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Chờ Admin xác nhận'**
  String get handoverSubmitted;

  /// No description provided for @handoverConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Đã đối soát'**
  String get handoverConfirmed;

  /// No description provided for @handoverRejected.
  ///
  /// In vi, this message translates to:
  /// **'Cần kiểm tra lại'**
  String get handoverRejected;

  /// No description provided for @handoverStatusSummary.
  ///
  /// In vi, this message translates to:
  /// **'Đối soát: {status}'**
  String handoverStatusSummary(String status);

  /// No description provided for @reconciliationTab.
  ///
  /// In vi, this message translates to:
  /// **'Đối soát'**
  String get reconciliationTab;

  /// No description provided for @performanceTab.
  ///
  /// In vi, this message translates to:
  /// **'Hiệu suất'**
  String get performanceTab;

  /// No description provided for @byWeek.
  ///
  /// In vi, this message translates to:
  /// **'Theo tuần'**
  String get byWeek;

  /// No description provided for @collectionReconciliationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thu tiền và đối soát'**
  String get collectionReconciliationTitle;

  /// No description provided for @totalCollected.
  ///
  /// In vi, this message translates to:
  /// **'Đã thu'**
  String get totalCollected;

  /// No description provided for @pendingHandover.
  ///
  /// In vi, this message translates to:
  /// **'Chờ bàn giao'**
  String get pendingHandover;

  /// No description provided for @confirmedHandover.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận'**
  String get confirmedHandover;

  /// No description provided for @submitMoneyHandover.
  ///
  /// In vi, this message translates to:
  /// **'Gửi bàn giao {count} khoản'**
  String submitMoneyHandover(int count);

  /// No description provided for @reconciliationSubmittedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi yêu cầu bàn giao tiền cho Admin.'**
  String get reconciliationSubmittedSuccess;

  /// No description provided for @noCollectedPayments.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có khoản thu nào trong kỳ này.'**
  String get noCollectedPayments;

  /// No description provided for @personalPerformanceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hiệu suất cá nhân'**
  String get personalPerformanceTitle;

  /// No description provided for @activeOrdersMetric.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đang giao'**
  String get activeOrdersMetric;

  /// No description provided for @completedOrdersMetric.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hoàn thành'**
  String get completedOrdersMetric;

  /// No description provided for @failedDeliveriesMetric.
  ///
  /// In vi, this message translates to:
  /// **'Lần giao thất bại'**
  String get failedDeliveriesMetric;

  /// No description provided for @totalDistanceMetric.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quãng đường'**
  String get totalDistanceMetric;

  /// No description provided for @onTimeRateMetric.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ đúng hẹn'**
  String get onTimeRateMetric;

  /// No description provided for @rescheduleCountMetric.
  ///
  /// In vi, this message translates to:
  /// **'Số lần hẹn lại'**
  String get rescheduleCountMetric;

  /// No description provided for @averageDeliveryTimeMetric.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian giao trung bình'**
  String get averageDeliveryTimeMetric;

  /// No description provided for @minuteCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} phút'**
  String minuteCount(int count);

  /// No description provided for @performanceTrend.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết theo ngày'**
  String get performanceTrend;

  /// No description provided for @noPerformanceData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu hiệu suất.'**
  String get noPerformanceData;

  /// No description provided for @performanceTrendSummary.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành {completed} · Thất bại {failed} · {distance} km'**
  String performanceTrendSummary(int completed, int failed, double distance);

  /// No description provided for @adminOnTimeRate.
  ///
  /// In vi, this message translates to:
  /// **'Đúng hẹn {rate}%'**
  String adminOnTimeRate(double rate);

  /// No description provided for @adminFailedAttempts.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại {count}'**
  String adminFailedAttempts(int count);

  /// No description provided for @adminReconciliationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đối soát tiền thu hộ'**
  String get adminReconciliationTitle;

  /// No description provided for @adminReconciliationDescription.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận các khoản COD/POS shipper đã thu và bàn giao.'**
  String get adminReconciliationDescription;

  /// No description provided for @waitingHandoverSummary.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xác nhận: {count} khoản · {amount}'**
  String waitingHandoverSummary(int count, String amount);

  /// No description provided for @noReconciliationEntries.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu đối soát.'**
  String get noReconciliationEntries;

  /// No description provided for @paymentProof.
  ///
  /// In vi, this message translates to:
  /// **'Bằng chứng thanh toán'**
  String get paymentProof;

  /// No description provided for @confirmHandover.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận bàn giao'**
  String get confirmHandover;

  /// No description provided for @confirmMoneyHandoverTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đã nhận tiền bàn giao'**
  String get confirmMoneyHandoverTitle;

  /// No description provided for @rejectReconciliationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trả lại đối soát'**
  String get rejectReconciliationTitle;

  /// No description provided for @reconciliationNoteOptional.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú (không bắt buộc)'**
  String get reconciliationNoteOptional;

  /// No description provided for @rejectionReasonRequired.
  ///
  /// In vi, this message translates to:
  /// **'Lý do yêu cầu kiểm tra lại'**
  String get rejectionReasonRequired;

  /// No description provided for @handoverConfirmedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận shipper bàn giao tiền.'**
  String get handoverConfirmedSuccess;

  /// No description provided for @reconciliationRejectedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã yêu cầu shipper kiểm tra lại khoản đối soát.'**
  String get reconciliationRejectedSuccess;

  /// No description provided for @shipperCancelOrder.
  ///
  /// In vi, this message translates to:
  /// **'Hủy đơn hàng'**
  String get shipperCancelOrder;

  /// No description provided for @shipperCancelWarning.
  ///
  /// In vi, this message translates to:
  /// **'Thao tác này sẽ hủy đơn, hoàn lại tồn kho và không thể hoàn tác. Admin và khách hàng sẽ được thông báo.'**
  String get shipperCancelWarning;

  /// No description provided for @cancellationReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do hủy đơn'**
  String get cancellationReason;

  /// No description provided for @cancellationNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú chi tiết'**
  String get cancellationNote;

  /// No description provided for @cancellationNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả thêm tình trạng đơn hàng (không bắt buộc)'**
  String get cancellationNoteHint;

  /// No description provided for @shipperCancelCustomerRefused.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng từ chối nhận hàng'**
  String get shipperCancelCustomerRefused;

  /// No description provided for @shipperCancelDamagedGoods.
  ///
  /// In vi, this message translates to:
  /// **'Hàng hóa hư hỏng hoặc không an toàn để giao'**
  String get shipperCancelDamagedGoods;

  /// No description provided for @shipperCancelIncorrectOrder.
  ///
  /// In vi, this message translates to:
  /// **'Sai sản phẩm hoặc sai thông tin đơn hàng'**
  String get shipperCancelIncorrectOrder;

  /// No description provided for @shipperCancelUnsafeDelivery.
  ///
  /// In vi, this message translates to:
  /// **'Không thể giao hàng an toàn'**
  String get shipperCancelUnsafeDelivery;

  /// No description provided for @otherReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do khác'**
  String get otherReason;

  /// No description provided for @optionalCancellationProof.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh bằng chứng hủy (không bắt buộc)'**
  String get optionalCancellationProof;

  /// No description provided for @cancellationProof.
  ///
  /// In vi, this message translates to:
  /// **'Bằng chứng hủy'**
  String get cancellationProof;

  /// No description provided for @shipperCancelSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy đơn hàng và thông báo cho admin.'**
  String get shipperCancelSuccess;

  /// No description provided for @paidOrderCancellationRequiresAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đã thanh toán hoặc đã thu tiền; cần admin xử lý hoàn tiền trước khi hủy.'**
  String get paidOrderCancellationRequiresAdmin;

  /// No description provided for @deliveryHistoryCount.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử ({count})'**
  String deliveryHistoryCount(int count);

  /// No description provided for @showMoreColors.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm {count} màu'**
  String showMoreColors(int count);

  /// No description provided for @showFewerColors.
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn'**
  String get showFewerColors;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
