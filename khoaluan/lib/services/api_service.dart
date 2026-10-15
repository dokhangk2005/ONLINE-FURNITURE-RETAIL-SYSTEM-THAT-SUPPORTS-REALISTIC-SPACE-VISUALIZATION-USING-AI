import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../model/product.dart';
import '../model/category.dart';
import '../model/review.dart';
import '../model/order.dart';
import '../model/user_account.dart';
import '../model/voucher.dart';
import '../model/support_question.dart';
import '../model/support_conversation.dart';
import '../model/room_design.dart';
import '../model/room_analysis.dart';
import '../model/scene_harmonization.dart';
import '../model/recommendation_admin.dart';
import '../model/revenue_report.dart';
import 'auth_service.dart';

class ApiService {
  // URL API (localhost cho Web/Windows, 10.0.2.2 cho Android Emulator)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5024',
  );
  static const String apiUrl = '$apiBaseUrl/api';
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (AuthService.token != null)
      'Authorization': 'Bearer ${AuthService.token}',
  };

  Future<String> quickRegister(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/quick-register'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
      final data = response.bodyBytes.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw CustomException(
          data['message'] as String? ??
              'Không thể gửi liên kết đăng ký (${response.statusCode}).',
        );
      }
      return data['message'] as String? ??
          'Hãy kiểm tra email để thiết lập mật khẩu.';
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> getRegistrationLinkInfo(String token) async {
    try {
      final uri = Uri.parse(
        '$apiUrl/auth/registration-link',
      ).replace(queryParameters: {'token': token});
      final response = await http.get(uri, headers: _headers);
      final data = response.bodyBytes.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw CustomException(
          data['message'] as String? ??
              'Liên kết thiết lập mật khẩu không hợp lệ hoặc đã hết hạn.',
        );
      }
      return data;
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> completeRegistration({
    required String token,
    required String fullName,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/complete-registration'),
        headers: _headers,
        body: jsonEncode({
          'token': token,
          'fullName': fullName,
          'newPassword': newPassword,
        }),
      );
      final data = response.bodyBytes.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw CustomException(
          data['message'] as String? ??
              'Không thể hoàn tất đăng ký (${response.statusCode}).',
        );
      }
      return data['message'] as String? ?? 'Thiết lập tài khoản thành công.';
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<Product>> fetchProducts({bool includeDeleted = false}) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/products?includeDeleted=$includeDeleted'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        String errorMessage =
            'Đăng nhập thất bại (Mã lỗi: ${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            if (errorData.containsKey('message')) {
              errorMessage = errorData['message'];
            }
          } catch (_) {}
        }
        throw CustomException(errorMessage);
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final user = Map<String, dynamic>.from(responseData['user'] ?? {});
      user['_token'] = responseData['token'];
      return user;
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        String errorMessage =
            'Yêu cầu khôi phục thất bại (${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            if (errorData.containsKey('message'))
              errorMessage = errorData['message'];
          } catch (_) {}
        }
        throw CustomException(errorMessage);
      }
      return jsonDecode(response.body);
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> verifyResetOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/verify-otp'),
        headers: _headers,
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode != 200) {
        String errorMessage = 'Xác thực OTP thất bại (${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            if (errorData.containsKey('message'))
              errorMessage = errorData['message'];
          } catch (_) {}
        }
        throw CustomException(errorMessage);
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/reset-password'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        String errorMessage =
            'Đặt lại mật khẩu thất bại (${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            if (errorData.containsKey('message'))
              errorMessage = errorData['message'];
          } catch (_) {}
        }
        throw CustomException(errorMessage);
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // --- CRUD Category ---
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/categories'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Category.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<void> createCategory(
    String name, {
    String imageUrl = '',
    String categoryCode = '',
    int? parentCategoryId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/categories'),
        headers: _headers,
        body: jsonEncode({
          'categoryName': name,
          'imageUrl': imageUrl,
          'categoryCode': categoryCode,
          'parentCategoryId': parentCategoryId,
        }),
      );
      if (response.statusCode != 200)
        throw CustomException('Lỗi Server: ${response.statusCode}');
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<void> updateCategory(
    int id,
    String name, {
    String imageUrl = '',
    String categoryCode = '',
    int? parentCategoryId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/categories/$id'),
        headers: _headers,
        body: jsonEncode({
          'categoryName': name,
          'imageUrl': imageUrl,
          'categoryCode': categoryCode,
          'parentCategoryId': parentCategoryId,
        }),
      );
      if (response.statusCode != 200)
        throw CustomException('Lỗi Server: ${response.statusCode}');
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/categories/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200)
        throw CustomException('Lỗi Server: ${response.statusCode}');
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  // --- CRUD Product (Thêm/Sửa/Xóa) ---
  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/products'),
        headers: _headers,
        body: jsonEncode(data),
      );
      if (response.statusCode != 200)
        throw CustomException('Lỗi Server: ${response.statusCode}');
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/products/$id'),
        headers: _headers,
        body: jsonEncode(data),
      );
      if (response.statusCode != 200)
        throw CustomException('Lỗi Server: ${response.statusCode}');
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/products/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200)
        throw CustomException('Lỗi Server: ${response.statusCode}');
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<String> uploadImage(List<int> bytes, String fileName) async {
    if (AuthService.token == null || AuthService.token!.isEmpty) {
      throw CustomException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại trước khi tải ảnh.',
      );
    }
    if (bytes.length > 10 * 1024 * 1024) {
      throw CustomException('Ảnh sản phẩm không được vượt quá 10 MB.');
    }
    final imageFormat = _detectImageFormat(bytes);
    if (imageFormat == null) {
      throw CustomException(
        'Nội dung file không phải ảnh JPG, PNG hoặc WEBP hợp lệ.',
      );
    }
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/upload/image'),
      );
      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '$baseName.${imageFormat.$1}',
          contentType: MediaType('image', imageFormat.$2),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = _decodeMap(response);
        final imageUrl = data['imageUrl']?.toString() ?? '';
        if (imageUrl.isEmpty) {
          throw CustomException('Server không trả về đường dẫn ảnh đã tải.');
        }
        return imageUrl;
      } else {
        _throwIfUnauthorized(response);
        throw CustomException(
          _responseMessage(
            _decodeMap(response),
            'Không thể tải ảnh sản phẩm (mã ${response.statusCode}).',
          ),
        );
      }
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException('Lỗi upload: $e');
    }
  }

  // --- Product Reviews ---
  Future<List<Review>> fetchReviews(int productId, {int? rating}) async {
    try {
      final ratingQuery = rating != null ? '?rating=$rating' : '';
      final response = await http.get(
        Uri.parse('$apiUrl/reviews/product/$productId$ratingQuery'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Review.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<Map<String, dynamic>> fetchReviewStats(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/reviews/product/$productId/stats'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<Map<String, dynamic>> submitReview(
    int orderDetailId,
    int productId,
    int rating,
    String? comment,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/reviews'),
        headers: _headers,
        body: jsonEncode({
          'orderDetailId': orderDetailId,
          'productId': productId,
          'rating': rating,
          'comment': comment,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw CustomException(data['message'] ?? 'Lỗi gửi đánh giá');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // --- Admin Review Moderation ---
  Future<List<AdminPendingReview>> fetchPendingReviewsAdmin() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/reviews/admin/pending'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => AdminPendingReview.fromJson(json))
            .toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<void> approveReviewAdmin(int reviewId) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/reviews/admin/$reviewId/approve'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi duyệt đánh giá');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> rejectReviewAdmin(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/reviews/admin/$reviewId'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi từ chối đánh giá');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<AdminProductReviewSummary>>
  fetchAdminProductsReviewsSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/reviews/admin/products'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => AdminProductReviewSummary.fromJson(json))
            .toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<List<Review>> fetchAdminProductReviews(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/reviews/admin/products/$productId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Review.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<String> submitAdminReply(int reviewId, String reply) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/reviews/admin/$reviewId/reply'),
        headers: _headers,
        body: jsonEncode({'reply': reply}),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi gửi phản hồi');
      }
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['message']?.toString() ?? 'Đã lưu phản hồi.';
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // --- Orders & VNPay Checkout & Delivery ---
  Future<Map<String, dynamic>> createOrder(
    int userId,
    String address,
    List<Map<String, dynamic>> items, {
    String paymentMethod = 'VNPay',
    double shippingFee = 0.0,
    double assemblyFee = 0.0,
    bool includesAssembly = false,
    double? deliveryDistanceKm,
    String? deliveryTimeSlot,
    String? estimatedDeliveryDate,
    String? voucherCode,
    double discountAmount = 0.0,
    required String recipientName,
    required String recipientPhone,
    String? recipientEmail,
    String? customerNote,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/orders'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'shippingAddress': address,
          'items': items,
          'paymentMethod': paymentMethod,
          'shippingFee': shippingFee,
          'assemblyFee': assemblyFee,
          'includesAssembly': includesAssembly,
          'deliveryDistanceKm': deliveryDistanceKm,
          'deliveryTimeSlot': deliveryTimeSlot,
          'estimatedDeliveryDate': estimatedDeliveryDate,
          'voucherCode': voucherCode,
          'discountAmount': discountAmount,
          'recipientName': recipientName,
          'recipientPhone': recipientPhone,
          'recipientEmail': recipientEmail,
          'customerNote': customerNote,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw CustomException(data['message'] ?? 'Lỗi đặt hàng');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> fetchPaymentStatus(int orderId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/orders/$orderId/payment-status'),
      headers: _headers,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200)
      throw CustomException(data['message'] ?? 'Không thể xác minh thanh toán');
    return data;
  }

  Future<Product> fetchProduct(int productId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/products/$productId'),
      headers: _headers,
    );
    if (response.statusCode != 200)
      throw CustomException('Không tìm thấy sản phẩm');
    return Product.fromJson(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> suggestAddresses(
    String query,
    String sessionToken,
  ) async {
    final uri = Uri.parse(
      '$apiUrl/location/suggest',
    ).replace(queryParameters: {'q': query, 'sessionToken': sessionToken});
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200)
      throw CustomException('Không thể tải gợi ý địa chỉ');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['suggestions'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> retrieveAddress(
    String mapboxId,
    String sessionToken,
  ) async {
    final uri = Uri.parse(
      '$apiUrl/location/retrieve/${Uri.encodeComponent(mapboxId)}',
    ).replace(queryParameters: {'sessionToken': sessionToken});
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200)
      throw CustomException('Không thể lấy chi tiết địa chỉ');
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> fetchAddresses() async {
    final response = await http.get(
      Uri.parse('$apiUrl/addresses'),
      headers: _headers,
    );
    if (response.statusCode != 200)
      throw CustomException('Không thể tải địa chỉ');
    return (jsonDecode(response.body) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> saveAddress(
    Map<String, dynamic> address, {
    int? id,
  }) async {
    final uri = Uri.parse('$apiUrl/addresses${id == null ? '' : '/$id'}');
    final response = id == null
        ? await http.post(uri, headers: _headers, body: jsonEncode(address))
        : await http.put(uri, headers: _headers, body: jsonEncode(address));
    if (response.statusCode != 200)
      throw CustomException('Không thể lưu địa chỉ');
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<void> deleteAddress(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/addresses/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204)
      throw CustomException('Không thể xóa địa chỉ');
  }

  Future<List<OrderModel>> fetchMyOrders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/orders/my-orders/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<List<OrderModel>> fetchAdminOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/orders/admin/all'),
        headers: _headers,
      );
      _throwIfUnauthorized(response);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<void> updateOrderStatusAdmin(int orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/orders/admin/$orderId/status'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi cập nhật trạng thái');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<ShipperModel>> fetchShippers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/orders/shippers'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => ShipperModel.fromJson(json)).toList();
      } else {
        throw CustomException(
          'Lỗi lấy danh sách Shipper: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<void> assignShipperAdmin(int orderId, int shipperId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/orders/admin/$orderId/assign-shipper'),
        headers: _headers,
        body: jsonEncode({'shipperId': shipperId}),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi phân công Shipper');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<OrderModel>> fetchShipperOrders(int shipperId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/orders/shipper/$shipperId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối: $e');
    }
  }

  Future<Map<String, dynamic>> fetchShipperAvailability() async {
    final response = await http.get(
      Uri.parse('$apiUrl/delivery/shipper/availability'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw CustomException('Không thể tải trạng thái làm việc');
    }
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> updateShipperAvailability(
    bool isAvailable,
  ) async {
    final response = await http.put(
      Uri.parse('$apiUrl/delivery/shipper/availability'),
      headers: _headers,
      body: jsonEncode({'isAvailable': isAvailable}),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw CustomException(
        data['message'] ?? 'Không thể cập nhật trạng thái làm việc',
      );
    }
    return data;
  }

  Future<void> completeDeliveryShipper(
    int orderId, {
    String? proofImage,
    String? recipientName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/orders/shipper/$orderId/complete'),
        headers: _headers,
        body: jsonEncode({
          'deliveryProofImage': proofImage ?? '',
          'recipientName': recipientName ?? '',
        }),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(
          data['message'] ?? 'Lỗi xác nhận hoàn tất giao hàng',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> fetchShipperProfile() async {
    final response = await http.get(
      Uri.parse('$apiUrl/delivery/shipper/profile'),
      headers: _headers,
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể tải hồ sơ shipper.'),
      );
    }
    return data;
  }

  Future<void> updateShipperProfile(Map<String, dynamic> profile) async {
    final response = await http.put(
      Uri.parse('$apiUrl/delivery/shipper/profile'),
      headers: _headers,
      body: jsonEncode(profile),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể cập nhật hồ sơ shipper.'),
      );
    }
  }

  Future<Map<String, dynamic>> updateShipperShift(
    String status, {
    String? breakUntil,
  }) async {
    final response = await http.put(
      Uri.parse('$apiUrl/delivery/shipper/shift'),
      headers: _headers,
      body: jsonEncode({'status': status, 'breakUntil': breakUntil}),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể cập nhật ca làm việc.'),
      );
    }
    return data;
  }

  Future<void> acceptDeliveryAssignment(int orderId) =>
      _postDeliveryAction(orderId, 'accept');

  Future<void> rejectDeliveryAssignment(int orderId, String reason) =>
      _postDeliveryAction(orderId, 'reject', body: {'reason': reason});

  Future<void> updateDeliveryProgress(int orderId, String status) async {
    final response = await http.put(
      Uri.parse('$apiUrl/delivery/shipper/$orderId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể cập nhật giao hàng.'),
      );
    }
  }

  Future<void> requestDeliveryOtp(int orderId) =>
      _postDeliveryAction(orderId, 'otp/request');

  Future<void> verifyDeliveryOtp(int orderId, String otp) =>
      _postDeliveryAction(orderId, 'otp/verify', body: {'otp': otp});

  Future<Map<String, dynamic>> confirmDeliveryPaymentCollection(
    int orderId, {
    String? proofImage,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/delivery/shipper/$orderId/payment/collect'),
      headers: _headers,
      body: jsonEncode({'proofImage': proofImage, 'note': note}),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể xác nhận thu tiền.'),
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> fetchShipperReconciliation({
    String period = 'day',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl/delivery/shipper/reconciliation',
      ).replace(queryParameters: {'period': period}),
      headers: _headers,
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(_responseMessage(data, 'Không thể tải đối soát.'));
    }
    return data;
  }

  Future<void> submitShipperReconciliation({
    List<int> paymentIds = const [],
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/delivery/shipper/reconciliation/submit'),
      headers: _headers,
      body: jsonEncode({'paymentIds': paymentIds, 'note': note}),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(_responseMessage(data, 'Không thể gửi đối soát.'));
    }
  }

  Future<Map<String, dynamic>> fetchShipperPerformance({
    String period = 'day',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl/delivery/shipper/performance',
      ).replace(queryParameters: {'period': period}),
      headers: _headers,
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(_responseMessage(data, 'Không thể tải hiệu suất.'));
    }
    return data;
  }

  Future<List<dynamic>> fetchAdminReconciliations({String? status}) async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl/delivery/admin/reconciliations',
      ).replace(queryParameters: status == null ? null : {'status': status}),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      final data = _decodeMap(response);
      throw CustomException(_responseMessage(data, 'Không thể tải đối soát.'));
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<void> decideAdminReconciliation(
    int paymentId, {
    required bool confirm,
    String? note,
  }) async {
    final action = confirm ? 'confirm' : 'reject';
    final response = await http.post(
      Uri.parse('$apiUrl/delivery/admin/reconciliation/$paymentId/$action'),
      headers: _headers,
      body: jsonEncode({'note': note}),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể xử lý đối soát.'),
      );
    }
  }

  Future<List<dynamic>> fetchAdminShipperPerformance({
    String period = 'week',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl/delivery/admin/shipper-performance',
      ).replace(queryParameters: {'period': period}),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      final data = _decodeMap(response);
      throw CustomException(
        _responseMessage(data, 'Không thể tải hiệu suất shipper.'),
      );
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<void> _postDeliveryAction(
    int orderId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/delivery/shipper/$orderId/$action'),
      headers: _headers,
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể cập nhật giao hàng.'),
      );
    }
  }

  Future<List<UserAccount>> fetchAdminUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/users/admin/all'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => UserAccount.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi lấy danh sách tài khoản');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> updateUserRoleAdmin(int userId, int roleId) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/users/admin/update-role/$userId'),
        headers: _headers,
        body: jsonEncode({'roleId': roleId}),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi cập nhật vai trò');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> toggleUserStatusAdmin(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/users/admin/toggle-status/$userId'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi thay đổi trạng thái');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> resetUserPasswordAdmin(int userId, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/users/admin/reset-password/$userId'),
        headers: _headers,
        body: jsonEncode({'newPassword': newPassword}),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi đặt lại mật khẩu');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    int userId,
    String fullName,
    String gender,
    String? dateOfBirth,
    String phone,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/users/update-profile/$userId'),
        headers: _headers,
        body: jsonEncode({
          'fullName': fullName,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'phone': phone,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['user'] ?? {};
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(data['message'] ?? 'Lỗi cập nhật thông tin');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // --- Vouchers API ---
  Future<List<VoucherModel>> fetchAdminVouchers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/vouchers/admin'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => VoucherModel.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<VoucherModel>> fetchActiveVouchers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/vouchers/active'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => VoucherModel.fromJson(json)).toList();
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<VoucherValidationResult> validateVoucher(
    String code,
    double subtotal,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/vouchers/validate'),
        headers: _headers,
        body: jsonEncode({'voucherCode': code, 'orderSubtotal': subtotal}),
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return VoucherValidationResult.fromJson(data);
      } else {
        throw CustomException(
          data['message'] ?? data['Message'] ?? 'Mã khuyến mãi không hợp lệ',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<VoucherModel> createVoucherAdmin(VoucherModel voucher) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/vouchers/admin'),
        headers: _headers,
        body: jsonEncode(voucher.toJson()),
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return VoucherModel.fromJson(data);
      } else {
        throw CustomException(
          data['message'] ?? data['Message'] ?? 'Lỗi tạo mã khuyến mãi',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<VoucherModel> updateVoucherAdmin(
    int voucherId,
    VoucherModel voucher,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/vouchers/admin/$voucherId'),
        headers: _headers,
        body: jsonEncode(voucher.toJson()),
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return VoucherModel.fromJson(data);
      } else {
        throw CustomException(
          data['message'] ?? data['Message'] ?? 'Lỗi cập nhật mã',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteVoucherAdmin(int voucherId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/vouchers/admin/$voucherId'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(
          data['message'] ?? data['Message'] ?? 'Lỗi xóa mã khuyến mãi',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // --- Delivery Management Level 2 APIs ---
  Future<Map<String, dynamic>> fetchDeliveryAdminOverview() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/delivery/admin-overview'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw CustomException('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      throw CustomException('Lỗi kết nối Delivery Overview: $e');
    }
  }

  Future<void> reportDeliveryIssue(
    int orderId,
    String reason,
    String? note, {
    String? proofImage,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/delivery/shipper/$orderId/report-issue'),
        headers: _headers,
        body: jsonEncode({
          'reason': reason,
          'note': note ?? '',
          'proofImage': proofImage ?? '',
        }),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(
          data['message'] ?? data['Message'] ?? 'Lỗi báo cáo sự cố',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> cancelDeliveryOrder(
    int orderId, {
    required String reason,
    String? note,
    String? proofImage,
  }) async {
    final response = await http.put(
      Uri.parse('$apiUrl/delivery/shipper/$orderId/cancel'),
      headers: _headers,
      body: jsonEncode({
        'reason': reason,
        'note': note ?? '',
        'proofImage': proofImage ?? '',
      }),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(_responseMessage(data, 'Không thể hủy đơn hàng.'));
    }
  }

  Future<void> rescheduleDeliveryOrder(
    int orderId, {
    int? shipperId,
    String? estimatedDeliveryDate,
    String? deliveryTimeSlot,
    String? adminNote,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/delivery/admin/$orderId/reschedule'),
        headers: _headers,
        body: jsonEncode({
          'shipperId': shipperId,
          'estimatedDeliveryDate': estimatedDeliveryDate,
          'deliveryTimeSlot': deliveryTimeSlot,
          'adminNote': adminNote,
        }),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(
          data['message'] ?? data['Message'] ?? 'Lỗi điều phối đơn hàng',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // --- SUPPORT QUESTIONS Q&A ---
  Future<void> createSupportQuestion({
    required int userId,
    required String topic,
    required String questionText,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/questions/create'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'topic': topic,
          'questionText': questionText,
        }),
      );
      if (response.statusCode != 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        throw CustomException(
          data['message'] ?? data['Message'] ?? 'Lỗi gửi câu hỏi hỗ trợ',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<SupportQuestionModel>> fetchMyQuestions(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/questions/user/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((j) => SupportQuestionModel.fromJson(j)).toList();
      } else {
        throw CustomException(
          'Lỗi lấy danh sách câu hỏi: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<SupportQuestionModel>> fetchAdminQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/questions/admin'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((j) => SupportQuestionModel.fromJson(j)).toList();
      } else {
        throw CustomException(
          'Lỗi tải danh sách Q&A Admin: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> answerSupportQuestion(
    int questionId,
    String answerText,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/questions/admin/$questionId/answer'),
        headers: _headers,
        body: jsonEncode({'answerText': answerText}),
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return (data['message'] ?? data['Message'] ?? 'Đã lưu lời giải đáp')
            .toString();
      } else {
        throw CustomException(
          data['message'] ?? data['Message'] ?? 'Lỗi gửi lời trả lời',
        );
      }
    } catch (e) {
      throw CustomException(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<SupportConversationModel>> fetchMySupportConversations() async {
    final response = await http.get(
      Uri.parse('$apiUrl/support-conversations/mine'),
      headers: _headers,
    );
    _throwIfUnauthorized(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(
          _decodeMap(response),
          'Không thể tải các cuộc trò chuyện hỗ trợ.',
        ),
      );
    }
    return (jsonDecode(response.body) as List)
        .map(
          (item) => SupportConversationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<SupportConversationModel>> fetchAdminSupportConversations({
    String? status,
  }) async {
    final uri = Uri.parse('$apiUrl/support-conversations/admin').replace(
      queryParameters: status == null || status.trim().isEmpty
          ? null
          : {'status': status.trim()},
    );
    final response = await http.get(uri, headers: _headers);
    _throwIfUnauthorized(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(
          _decodeMap(response),
          'Không thể tải danh sách trò chuyện hỗ trợ.',
        ),
      );
    }
    return (jsonDecode(response.body) as List)
        .map(
          (item) => SupportConversationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<SupportConversationModel> fetchSupportConversation(int id) async {
    final response = await http.get(
      Uri.parse('$apiUrl/support-conversations/$id'),
      headers: _headers,
    );
    _throwIfUnauthorized(response);
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể tải cuộc trò chuyện hỗ trợ.'),
      );
    }
    return SupportConversationModel.fromJson(data);
  }

  Future<SupportConversationModel> createSupportConversation({
    required String topic,
    required String messageText,
    String? clientMessageId,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/support-conversations'),
      headers: _headers,
      body: jsonEncode({
        'topic': topic.trim(),
        'messageText': messageText.trim(),
        if (clientMessageId != null) 'clientMessageId': clientMessageId,
      }),
    );
    _throwIfUnauthorized(response);
    final data = _decodeMap(response);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể tạo cuộc trò chuyện hỗ trợ.'),
      );
    }
    return SupportConversationModel.fromJson(data);
  }

  Future<SupportMessageModel> sendSupportMessage(
    int conversationId,
    String messageText, {
    String? clientMessageId,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/support-conversations/$conversationId/messages'),
      headers: _headers,
      body: jsonEncode({
        'messageText': messageText.trim(),
        if (clientMessageId != null) 'clientMessageId': clientMessageId,
      }),
    );
    _throwIfUnauthorized(response);
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể gửi tin nhắn hỗ trợ.'),
      );
    }
    return SupportMessageModel.fromJson(data);
  }

  Future<void> markSupportConversationRead(int conversationId) async {
    final response = await http.put(
      Uri.parse('$apiUrl/support-conversations/$conversationId/read'),
      headers: _headers,
    );
    _throwIfUnauthorized(response);
    if (response.statusCode != 204) {
      throw CustomException(
        _responseMessage(
          _decodeMap(response),
          'Không thể cập nhật trạng thái đã đọc.',
        ),
      );
    }
  }

  Future<void> updateSupportConversationStatus(
    int conversationId,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$apiUrl/support-conversations/$conversationId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    _throwIfUnauthorized(response);
    if (response.statusCode != 204) {
      throw CustomException(
        _responseMessage(
          _decodeMap(response),
          'Không thể cập nhật trạng thái cuộc trò chuyện.',
        ),
      );
    }
  }

  Future<void> assignSupportConversation(int conversationId) async {
    final response = await http.put(
      Uri.parse('$apiUrl/support-conversations/$conversationId/assign'),
      headers: _headers,
    );
    _throwIfUnauthorized(response);
    if (response.statusCode != 204) {
      throw CustomException(
        _responseMessage(
          _decodeMap(response),
          'Không thể nhận xử lý cuộc trò chuyện.',
        ),
      );
    }
  }

  Future<ChatbotReply> askGeminiChatbot(String question) async {
    final response = await http.post(
      Uri.parse('$apiUrl/chatbot/ask'),
      headers: _headers,
      body: jsonEncode({'question': question}),
    );
    _throwIfUnauthorized(response);
    final data = _decodeMap(response);
    if (response.statusCode == 200) {
      return ChatbotReply.fromJson(data);
    }
    if (data['retryable'] == true || data['code'] == 'GEMINI_BUSY') {
      throw ChatbotBusyException();
    }
    throw CustomException(
      _responseMessage(data, 'Không thể kết nối đến Trợ lý AI.'),
    );
  }

  // --- Recommendations ---
  Future<RecommendationDashboardModel>
  fetchRecommendationAdminDashboard() async {
    final response = await http.get(
      Uri.parse('$apiUrl/recommendations/admin/dashboard'),
      headers: _headers,
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể tải dữ liệu quản lý gợi ý.'),
      );
    }
    return RecommendationDashboardModel.fromJson(data);
  }

  Future<String> updateRecommendationSettings({
    required bool aprioriEnabled,
    required bool contentBasedEnabled,
    required bool autoRebuildEnabled,
    required double minSupport,
    required double minConfidence,
    required int maxResults,
  }) async {
    final response = await http.put(
      Uri.parse('$apiUrl/recommendations/admin/settings'),
      headers: _headers,
      body: jsonEncode({
        'aprioriEnabled': aprioriEnabled,
        'contentBasedEnabled': contentBasedEnabled,
        'autoRebuildEnabled': autoRebuildEnabled,
        'minSupport': minSupport,
        'minConfidence': minConfidence,
        'maxResults': maxResults,
      }),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(_responseMessage(data, 'Không thể lưu cấu hình.'));
    }
    return _responseMessage(data, 'Đã lưu cấu hình thuật toán gợi ý.');
  }

  Future<Map<String, dynamic>> rebuildRecommendations() async {
    final response = await http.post(
      Uri.parse('$apiUrl/recommendations/admin/rebuild'),
      headers: _headers,
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể xây dựng lại dữ liệu gợi ý.'),
      );
    }
    return data;
  }

  Future<String> clearRecommendationRules() async {
    final response = await http.delete(
      Uri.parse('$apiUrl/recommendations/admin/rules'),
      headers: _headers,
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể xóa luật gợi ý.'),
      );
    }
    return _responseMessage(data, 'Đã xóa luật gợi ý.');
  }

  Future<List<Product>> fetchFrequentlyBoughtTogether(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/recommendations/frequently-bought/$productId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching frequently bought: $e');
      return [];
    }
  }

  Future<List<Product>> fetchSimilarProducts(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/recommendations/similar/$productId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching similar products: $e');
      return [];
    }
  }

  // --- Room visualizer ---
  static String absoluteUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '$apiBaseUrl${value.startsWith('/') ? value : '/$value'}';
  }

  Future<RoomDesignRecord> createRoomDesign(
    List<int> imageBytes,
    String fileName, {
    String title = 'Không gian của tôi',
  }) async {
    final imageFormat = _detectImageFormat(imageBytes);
    if (imageFormat == null) {
      throw CustomException(
        'Nội dung file không phải ảnh JPG, PNG hoặc WEBP hợp lệ.',
      );
    }
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/room-designs'),
    );
    if (AuthService.token != null) {
      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
    }
    request.fields['title'] = title;
    final contentType = MediaType('image', imageFormat.$2);
    final baseName = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    request.files.add(
      http.MultipartFile.fromBytes(
        'roomImage',
        imageBytes,
        filename: '$baseName.${imageFormat.$1}',
        contentType: contentType,
      ),
    );
    final response = await http.Response.fromStream(await request.send());
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(_responseMessage(data, 'Không thể tải ảnh phòng.'));
    }
    return RoomDesignRecord.fromJson(data);
  }

  static (String, String)? _detectImageFormat(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return ('jpg', 'jpeg');
    }
    const pngSignature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
    if (bytes.length >= pngSignature.length) {
      var isPng = true;
      for (var index = 0; index < pngSignature.length; index++) {
        if (bytes[index] != pngSignature[index]) {
          isPng = false;
          break;
        }
      }
      if (isPng) return ('png', 'png');
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return ('webp', 'webp');
    }
    return null;
  }

  Future<RoomDesignRecord> saveRoomDesign(
    String designId,
    String? accessToken,
    String title,
    List<RoomDesignItem> items,
    List<RoomOcclusionEdit> occlusionEdits,
  ) async {
    final query = accessToken == null || accessToken.isEmpty
        ? ''
        : '?accessToken=${Uri.encodeQueryComponent(accessToken)}';
    final response = await http.put(
      Uri.parse('$apiUrl/room-designs/$designId$query'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'items': items.map((item) => item.toJson()).toList(),
        'occlusionEdits': occlusionEdits.map((edit) => edit.toJson()).toList(),
      }),
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(_responseMessage(data, 'Không thể lưu phối cảnh.'));
    }
    return RoomDesignRecord.fromJson(data);
  }

  Future<void> saveRoomDesignPreview(
    String designId,
    String? accessToken,
    List<int> imageBytes,
  ) async {
    final query = accessToken == null || accessToken.isEmpty
        ? ''
        : '?accessToken=${Uri.encodeQueryComponent(accessToken)}';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/room-designs/$designId/preview$query'),
    );
    if (AuthService.token != null) {
      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        'previewImage',
        imageBytes,
        filename: 'room-design.png',
      ),
    );
    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(_decodeMap(response), 'Không thể lưu ảnh xem trước.'),
      );
    }
  }

  Future<List<RoomDesignRecord>> fetchMyRoomDesigns() async {
    final response = await http.get(
      Uri.parse('$apiUrl/room-designs/mine'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw CustomException('Không thể tải danh sách phối cảnh đã lưu.');
    }
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return list
        .map(
          (item) => RoomDesignRecord.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<RoomAnalysisResult> analyzeRoomDesign(
    String designId,
    String? accessToken, {
    bool force = false,
  }) async {
    final query = <String, String>{
      if (accessToken != null && accessToken.isNotEmpty)
        'accessToken': accessToken,
      if (force) 'force': 'true',
    };
    final uri = Uri.parse(
      '$apiUrl/room-designs/$designId/analyze',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final response = await http.post(uri, headers: _headers);
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể phân tích sàn, tường và chiều sâu.'),
      );
    }
    return RoomAnalysisResult.fromJson(data);
  }

  Future<RoomAnalysisResult?> fetchRoomAnalysis(
    String designId,
    String? accessToken,
  ) async {
    final query = accessToken == null || accessToken.isEmpty
        ? null
        : <String, String>{'accessToken': accessToken};
    final uri = Uri.parse(
      '$apiUrl/room-designs/$designId/analysis',
    ).replace(queryParameters: query);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 404) return null;
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể tải kết quả phân tích phòng.'),
      );
    }
    return RoomAnalysisResult.fromJson(data);
  }

  Future<SceneHarmonizationStatus> fetchSceneHarmonizationStatus() async {
    final response = await http.get(
      Uri.parse('$apiUrl/room-designs/harmonization/status'),
      headers: _headers,
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(
          data,
          'Không thể kiểm tra trạng thái AI tạo phối cảnh.',
        ),
      );
    }
    return SceneHarmonizationStatus.fromJson(data);
  }

  Future<SceneHarmonizationResult> generateRoomPreview(
    String designId,
    String? accessToken,
    List<int> productImageIds,
    List<String> productNames,
    List<String> variantLabels, {
    String placementPrompt = '',
  }) async {
    final query = accessToken == null || accessToken.isEmpty
        ? null
        : <String, String>{'accessToken': accessToken};
    final uri = Uri.parse(
      '$apiUrl/room-designs/$designId/generate-preview',
    ).replace(queryParameters: query);
    final request = http.MultipartRequest('POST', uri);
    if (AuthService.token != null) {
      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
    }
    request.fields['productImageIdsJson'] = jsonEncode(productImageIds);
    request.fields['productNamesJson'] = jsonEncode(productNames);
    request.fields['variantLabelsJson'] = jsonEncode(variantLabels);
    request.fields['placementPrompt'] = placementPrompt.trim();

    final response = await http.Response.fromStream(await request.send());
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'AI chưa thể tạo ảnh phối cảnh.'),
      );
    }
    final result = SceneHarmonizationResult.fromJson(data);
    if (result.imageUrl.isEmpty) {
      throw CustomException('AI không trả về đường dẫn ảnh kết quả.');
    }
    return SceneHarmonizationResult(
      imageUrl: absoluteUrl(result.imageUrl),
      fromCache: result.fromCache,
      provider: result.provider,
      model: result.model,
      quality: result.quality,
    );
  }

  Future<Map<String, dynamic>> removeProductImageBackground(int imageId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/visualization/products/$imageId/remove-background'),
      headers: _headers,
    );
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'AI chưa thể xóa nền ảnh sản phẩm.'),
      );
    }
    return data;
  }

  Future<RevenueReport> fetchAdminRevenueReport({
    required DateTime from,
    required DateTime to,
    required String groupBy,
  }) async {
    String dateValue(DateTime value) {
      return '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';
    }

    final uri = Uri.parse('$apiUrl/revenue/admin/report').replace(
      queryParameters: {
        'from': dateValue(from),
        'to': dateValue(to),
        'groupBy': groupBy,
      },
    );
    final response = await http.get(uri, headers: _headers);
    final data = _decodeMap(response);
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(data, 'Không thể tải báo cáo doanh thu.'),
      );
    }
    return RevenueReport.fromJson(data);
  }

  Future<void> deleteRoomDesign(String designId, String? accessToken) async {
    final query = accessToken == null || accessToken.isEmpty
        ? ''
        : '?accessToken=${Uri.encodeQueryComponent(accessToken)}';
    final response = await http.delete(
      Uri.parse('$apiUrl/room-designs/$designId$query'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw CustomException(
        _responseMessage(_decodeMap(response), 'Không thể xóa phối cảnh.'),
      );
    }
  }

  static Map<String, dynamic> _decodeMap(http.Response response) {
    _throwIfUnauthorized(response);
    if (response.bodyBytes.isEmpty) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static String _responseMessage(Map<String, dynamic> data, String fallback) =>
      (data['message'] ?? data['Message'] ?? data['detail'] ?? fallback)
          .toString();

  static void _throwIfUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      AuthService.logout();
      throw CustomException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    if (response.statusCode == 403) {
      throw CustomException('Tài khoản không có quyền thực hiện thao tác này.');
    }
  }
}

class CustomException implements Exception {
  final String message;
  CustomException(this.message);

  @override
  String toString() => message;
}

class ChatbotBusyException implements Exception {}

class ChatbotProductLink {
  final int productId;
  final String productName;

  const ChatbotProductLink({
    required this.productId,
    required this.productName,
  });

  factory ChatbotProductLink.fromJson(Map<String, dynamic> json) {
    return ChatbotProductLink(
      productId: (json['productId'] as num? ?? 0).toInt(),
      productName: json['productName']?.toString() ?? '',
    );
  }
}

class ChatbotReply {
  final String text;
  final List<ChatbotProductLink> productLinks;

  const ChatbotReply({required this.text, required this.productLinks});

  factory ChatbotReply.fromJson(Map<String, dynamic> json) {
    final rawLinks = json['productLinks'];
    return ChatbotReply(
      text: json['reply']?.toString() ?? '',
      productLinks: rawLinks is List
          ? rawLinks
                .whereType<Map>()
                .map(
                  (item) => ChatbotProductLink.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where(
                  (item) =>
                      item.productId > 0 && item.productName.trim().isNotEmpty,
                )
                .toList(growable: false)
          : const [],
    );
  }
}
