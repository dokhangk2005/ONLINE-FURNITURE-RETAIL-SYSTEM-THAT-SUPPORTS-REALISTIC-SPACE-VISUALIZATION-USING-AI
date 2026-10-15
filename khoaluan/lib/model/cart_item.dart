import 'product.dart';

class CartItem {
  final Product product;
  final ProductVariant? variant;
  int quantity;

  CartItem({required this.product, this.variant, required this.quantity});

  double get unitPrice {
    return product.effectivePrice(variant?.additionalPrice ?? 0);
  }

  double get originalUnitPrice =>
      product.basePrice + (variant?.additionalPrice ?? 0);

  double get totalPrice {
    return unitPrice * quantity;
  }
}
