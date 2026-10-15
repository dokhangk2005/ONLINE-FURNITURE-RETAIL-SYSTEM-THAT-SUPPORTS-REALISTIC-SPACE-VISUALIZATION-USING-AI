import 'package:flutter/foundation.dart';
import 'dart:async';
import '../model/cart_item.dart';
import '../model/product.dart';
import 'auth_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const _legacyStorageKey = 'shopping_cart';
  static const _userStorageKeyPrefix = 'shopping_cart_user_';
  static final ValueNotifier<List<CartItem>> cartItems = ValueNotifier([]);
  static bool _initialized = false;
  static String? _activeStorageKey;
  static int _loadGeneration = 0;

  static Future<void> initialize() async {
    if (!_initialized) {
      AuthService.currentUser.addListener(_handleAuthChanged);
      _initialized = true;
    }

    await _switchToCurrentUser(force: true);
  }

  static String? _storageKeyForCurrentUser() {
    final user = AuthService.currentUser.value;
    if (user == null) return null;

    final userId = user['userId'] ?? user['UserId'];
    if (userId == null || userId.toString().trim().isEmpty) return null;
    return '$_userStorageKeyPrefix$userId';
  }

  static void _handleAuthChanged() {
    unawaited(_switchToCurrentUser());
  }

  static Future<void> _switchToCurrentUser({bool force = false}) async {
    final nextStorageKey = _storageKeyForCurrentUser();
    if (!force && nextStorageKey == _activeStorageKey) return;

    _activeStorageKey = nextStorageKey;
    final generation = ++_loadGeneration;
    cartItems.value = [];

    final preferences = await SharedPreferences.getInstance();
    if (nextStorageKey == null) {
      // Không để giỏ hàng cũ dùng chung trên trình duyệt xuất hiện khi đã đăng xuất.
      await preferences.remove(_legacyStorageKey);
      return;
    }

    var raw = preferences.getString(nextStorageKey);
    final legacyCart = preferences.getString(_legacyStorageKey);
    if (raw == null && legacyCart != null) {
      // Chỉ chuyển giỏ cũ cho tài khoản đang đăng nhập trong lần nâng cấp đầu tiên.
      raw = legacyCart;
      await preferences.setString(nextStorageKey, legacyCart);
    }
    await preferences.remove(_legacyStorageKey);

    if (generation != _loadGeneration ||
        nextStorageKey != _activeStorageKey ||
        raw == null) {
      return;
    }

    try {
      final list = jsonDecode(raw) as List;
      cartItems.value = list
          .map(
            (e) => CartItem(
              product: Product.fromJson(
                Map<String, dynamic>.from(e['product']),
              ),
              variant: e['variant'] == null
                  ? null
                  : ProductVariant.fromJson(
                      Map<String, dynamic>.from(e['variant']),
                    ),
              quantity: e['quantity'] as int,
            ),
          )
          .toList();
    } catch (_) {
      cartItems.value = [];
      await preferences.remove(nextStorageKey);
    }
  }

  static void _persist() {
    final storageKey = _activeStorageKey;
    if (storageKey == null) return;

    final value = cartItems.value
        .map(
          (e) => {
            'product': e.product.toJson(),
            'variant': e.variant?.toJson(),
            'quantity': e.quantity,
          },
        )
        .toList();
    SharedPreferences.getInstance().then(
      (p) => p.setString(storageKey, jsonEncode(value)),
    );
  }

  static String? addItem(
    Product product,
    ProductVariant? variant, {
    int quantity = 1,
  }) {
    if (!AuthService.isLoggedIn || _activeStorageKey == null) {
      return 'Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.';
    }

    final currentItems = List<CartItem>.from(cartItems.value);

    // Check if item already exists
    int existingIndex = currentItems.indexWhere(
      (item) =>
          item.product.productId == product.productId &&
          item.variant?.variantId == variant?.variantId,
    );

    int newQuantity = quantity;
    if (existingIndex >= 0) {
      newQuantity += currentItems[existingIndex].quantity;
    }

    if (variant != null && newQuantity > variant.stockQuantity) {
      return 'Vượt quá số lượng tồn kho của sản phẩm (${variant.stockQuantity} sản phẩm)';
    }

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity = newQuantity;
    } else {
      currentItems.add(
        CartItem(product: product, variant: variant, quantity: quantity),
      );
    }

    cartItems.value = currentItems;
    _persist();
    return null;
  }

  static String? updateQuantity(CartItem item, int newQuantity) {
    if (!AuthService.isLoggedIn || _activeStorageKey == null) {
      return 'Vui lòng đăng nhập để thay đổi giỏ hàng.';
    }

    if (newQuantity <= 0) {
      removeItem(item);
      return null;
    }

    if (item.variant != null && newQuantity > item.variant!.stockQuantity) {
      return 'Vượt quá số lượng tồn kho của sản phẩm (${item.variant!.stockQuantity} sản phẩm)';
    }

    final currentItems = List<CartItem>.from(cartItems.value);
    int existingIndex = currentItems.indexWhere((i) => i == item);

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity = newQuantity;
      cartItems.value = currentItems;
      _persist();
    }
    return null;
  }

  static void removeItem(CartItem item) {
    if (!AuthService.isLoggedIn || _activeStorageKey == null) return;

    final currentItems = List<CartItem>.from(cartItems.value);
    currentItems.removeWhere((i) => i == item);
    cartItems.value = currentItems;
    _persist();
  }

  static void clearCart() {
    cartItems.value = [];
    if (AuthService.isLoggedIn && _activeStorageKey != null) {
      _persist();
    }
  }

  static double get totalAmount {
    return cartItems.value.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  static int get totalQuantity {
    return cartItems.value.fold(0, (sum, item) => sum + item.quantity);
  }
}
