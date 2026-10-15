class AppValidator {
  // Validate Email
  static String? validateEmail(String? value, {String fieldName = 'Email'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName!';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return '$fieldName không đúng định dạng!';
    }
    return null;
  }

  // Validate Số điện thoại (10 chữ số đầu 0 của Việt Nam)
  static String? validatePhone(
    String? value, {
    String fieldName = 'Số điện thoại',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName!';
    }
    final cleanPhone = value.trim().replaceAll(' ', '').replaceAll('-', '');
    final phoneRegExp = RegExp(r'^0\d{9}$');
    if (!phoneRegExp.hasMatch(cleanPhone)) {
      return '$fieldName phải gồm 10 chữ số và bắt đầu bằng số 0!';
    }
    return null;
  }

  // Validate Email hoặc Số điện thoại (Cho các ô đăng nhập chung nếu có)
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập Email hoặc Số điện thoại!';
    }
    final cleanValue = value.trim();
    final isNumeric = RegExp(r'^[0-9+ \-]+$').hasMatch(cleanValue);
    if (isNumeric && cleanValue.startsWith('0') && cleanValue.length >= 9) {
      return validatePhone(cleanValue);
    }
    return validateEmail(cleanValue, fieldName: 'Email / Tài khoản');
  }

  // Validate Mật khẩu
  static String? validatePassword(
    String? value, {
    int minLength = 6,
    String fieldName = 'Mật khẩu',
  }) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName!';
    }
    if (value.length < minLength) {
      return '$fieldName phải có ít nhất $minLength ký tự!';
    }
    return null;
  }

  // Validate Xác nhận Mật khẩu
  static String? validateConfirmPassword(
    String? value,
    String originalPassword, {
    String fieldName = 'Mật khẩu xác nhận',
  }) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName!';
    }
    if (value != originalPassword) {
      return '$fieldName không trùng khớp với mật khẩu mới!';
    }
    return null;
  }

  // Validate Mã OTP
  static String? validateOTP(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mã OTP!';
    }
    final cleanValue = value.trim().replaceAll(' ', '');
    final otpRegExp = RegExp(
      r'^\d+'
      r'$',
    );
    if (!otpRegExp.hasMatch(cleanValue) || cleanValue.length != length) {
      return 'Mã OTP phải gồm đúng $length chữ số!';
    }
    return null;
  }

  // Validate Họ và tên / Tên riêng
  static String? validateName(
    String? value, {
    String label = 'Họ và tên',
    int minLength = 2,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $label!';
    }
    if (value.trim().length < minLength) {
      return '$label phải có ít nhất $minLength ký tự!';
    }
    return null;
  }

  // Validate Trường thông tin chung không để trống
  static String? validateRequired(
    String? value, {
    String fieldName = 'Thông tin này',
    int minLength = 1,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName!';
    }
    if (value.trim().length < minLength) {
      return '$fieldName phải có từ $minLength ký tự trở lên!';
    }
    return null;
  }

  // Validate Số (Giá tiền, Số lượng, Đơn hàng...)
  static String? validateNumber(
    String? value, {
    String label = 'Giá trị',
    bool isInteger = false,
    double? min = 0,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $label!';
    }
    final cleanValue = value.trim().replaceAll(',', '').replaceAll('.', '');
    final number = double.tryParse(cleanValue);
    if (number == null) {
      return '$label phải là định dạng số hợp lệ!';
    }
    if (isInteger && number != number.toInt().toDouble()) {
      return '$label phải là số nguyên!';
    }
    if (min != null && number < min) {
      return '$label phải lớn hơn hoặc bằng ${min == min.toInt() ? min.toInt() : min}!';
    }
    if (max != null && number > max) {
      return '$label không được vượt quá ${max == max.toInt() ? max.toInt() : max}!';
    }
    return null;
  }

  // Validate Mã Code (Voucher, Mã sản phẩm, Mã danh mục)
  static String? validateCode(String? value, {String label = 'Mã'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $label!';
    }
    final codeRegExp = RegExp(r'^[A-Za-z0-9\-_]+$');
    if (!codeRegExp.hasMatch(value.trim())) {
      return '$label chỉ được chứa chữ cái, chữ số, gạch ngang (-) hoặc gạch dưới (_) !';
    }
    return null;
  }
}
