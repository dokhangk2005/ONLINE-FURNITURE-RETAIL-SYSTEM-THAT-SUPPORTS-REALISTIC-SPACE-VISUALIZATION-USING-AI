import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/order.dart';

void main() {
  test('đọc quyền đánh giá từ sản phẩm trong lịch sử đơn hàng', () {
    final item = OrderItem.fromJson({
      'orderDetailId': 41,
      'productVariantId': 12,
      'productId': 7,
      'quantity': 1,
      'price': 1500000,
      'productName': 'Ghế thư giãn',
      'color': 'Nâu',
      'size': 'L',
      'imageUrl': '/uploads/products/chair.jpg',
      'canReview': true,
      'hasReviewed': false,
    });

    expect(item.orderDetailId, 41);
    expect(item.productId, 7);
    expect(item.canReview, isTrue);
    expect(item.hasReviewed, isFalse);
  });

  test('chỉ cho đánh giá khi đơn đã thanh toán và đã giao', () {
    OrderModel order({
      required String orderStatus,
      required String paymentStatus,
    }) {
      return OrderModel(
        orderId: 1,
        orderCode: 'DH-1',
        orderDate: '2026-08-23',
        shippingAddress: 'TP.HCM',
        totalAmount: 1500000,
        orderStatus: orderStatus,
        orderDetails: const [],
        paymentMethod: 'COD',
        paymentStatus: paymentStatus,
        userFullName: 'Khách hàng',
        userEmail: 'customer@example.com',
      );
    }

    expect(
      order(orderStatus: 'Delivered', paymentStatus: 'Success').canReviewItems,
      isTrue,
    );
    expect(
      order(orderStatus: 'Delivered', paymentStatus: 'Pending').canReviewItems,
      isFalse,
    );
    expect(
      order(orderStatus: 'Shipping', paymentStatus: 'Success').canReviewItems,
      isFalse,
    );
  });
}
