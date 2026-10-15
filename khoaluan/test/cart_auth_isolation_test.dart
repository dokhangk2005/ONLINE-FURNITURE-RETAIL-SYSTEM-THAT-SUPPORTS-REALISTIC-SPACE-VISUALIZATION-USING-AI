import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/product.dart';
import 'package:khoaluan/services/auth_service.dart';
import 'package:khoaluan/services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('không hiển thị hoặc cho thêm hàng khi chưa đăng nhập', () async {
    final product = _product();
    final legacyCart = jsonEncode([
      {'product': product.toJson(), 'variant': null, 'quantity': 2},
    ]);
    SharedPreferences.setMockInitialValues({'shopping_cart': legacyCart});

    await CartService.initialize();

    expect(AuthService.isLoggedIn, isFalse);
    expect(CartService.cartItems.value, isEmpty);
    expect(CartService.totalQuantity, 0);
    expect(CartService.addItem(product, null), contains('đăng nhập'));
    expect(CartService.cartItems.value, isEmpty);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('shopping_cart'), isFalse);
  });
}

Product _product() {
  return Product(
    productId: 1,
    categoryId: 1,
    categoryName: 'Bàn',
    productName: 'Bàn thử nghiệm',
    productCode: 'TEST-001',
    basePrice: 1000000,
    description: '',
    isDeleted: false,
    averageRating: 0,
    reviewCount: 0,
    productVariants: const [],
    soldCount: 0,
  );
}
