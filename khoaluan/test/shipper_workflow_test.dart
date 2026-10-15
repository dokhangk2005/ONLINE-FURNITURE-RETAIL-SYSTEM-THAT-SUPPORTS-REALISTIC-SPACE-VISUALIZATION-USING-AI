import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/order.dart';
import 'package:khoaluan/services/delivery_realtime_service.dart';

void main() {
  group('Shipper workflow A-H', () {
    test('đọc đầy đủ trạng thái và bằng chứng giao hàng', () {
      final order = OrderModel.fromJson({
        'orderId': 42,
        'orderCode': 'DH-0042',
        'orderStatus': 'Arrived',
        'orderDate': '2026-08-16T10:00:00Z',
        'shippingAddress': '1 Nguyễn Huệ, TP.HCM',
        'totalAmount': 1250000,
        'orderDetails': <dynamic>[],
        'paymentMethod': 'COD',
        'paymentStatus': 'Pending',
        'paymentAmount': 1200000,
        'paymentCollectedAt': '2026-08-16T10:41:00Z',
        'paymentCollectionProofImage': '/uploads/delivery/payment.jpg',
        'paymentHandoverStatus': 'Pending',
        'userFullName': 'Khách hàng',
        'userEmail': 'customer@example.com',
        'deliveryAssignedAt': '2026-08-16T10:01:00Z',
        'deliveryAcceptedAt': '2026-08-16T10:02:00Z',
        'deliveryPickedUpAt': '2026-08-16T10:10:00Z',
        'deliveryArrivedAt': '2026-08-16T10:40:00Z',
        'deliveryRecipientName': 'Nguyễn Văn A',
        'deliveryIssueProofImage': '/uploads/delivery/issue.jpg',
        'otpVerified': true,
      });

      expect(order.orderId, 42);
      expect(order.orderStatus, 'Arrived');
      expect(order.deliveryAcceptedAt, isNotNull);
      expect(order.deliveryPickedUpAt, isNotNull);
      expect(order.deliveryArrivedAt, isNotNull);
      expect(order.deliveryRecipientName, 'Nguyễn Văn A');
      expect(order.deliveryIssueProofImage, contains('issue.jpg'));
      expect(order.otpVerified, isTrue);
      expect(order.paymentCollectedAt, isNotNull);
      expect(order.paymentCollectionProofImage, contains('payment.jpg'));
      expect(order.paymentHandoverStatus, 'Pending');
      expect(order.amountToCollect, 1200000);
    });

    test('đọc được lịch sử shipper hủy đơn', () {
      final order = OrderModel.fromJson({
        'orderId': 43,
        'orderCode': 'DH-0043',
        'orderStatus': 'Cancelled',
        'orderDate': '2026-08-16T10:00:00Z',
        'shippingAddress': 'TP.HCM',
        'totalAmount': 1250000,
        'orderDetails': <dynamic>[],
        'paymentMethod': 'COD',
        'paymentStatus': 'Cancelled',
        'deliveryCancelledAt': '2026-08-16T11:00:00Z',
        'deliveryCancelledByShipperId': 7,
        'deliveryCancellationReason': 'Khách hàng từ chối nhận hàng',
        'deliveryCancellationNote': 'Khách xác nhận tại cửa.',
        'deliveryCancellationProofImage': '/uploads/delivery/cancel.jpg',
      });

      expect(order.orderStatus, 'Cancelled');
      expect(order.deliveryCancelledByShipperId, 7);
      expect(order.deliveryCancellationReason, contains('từ chối'));
      expect(order.deliveryCancellationProofImage, contains('cancel.jpg'));
    });

    test('đọc sự kiện giao hàng realtime với camelCase', () {
      final event = DeliveryRealtimeEvent.fromJson({
        'orderId': 42,
        'orderCode': 'DH-0042',
        'orderStatus': 'Assigned',
        'message': 'Bạn có đơn giao hàng mới.',
      });

      expect(event.orderId, 42);
      expect(event.orderCode, 'DH-0042');
      expect(event.orderStatus, 'Assigned');
      expect(event.message, 'Bạn có đơn giao hàng mới.');
    });

    test('đọc sự kiện giao hàng realtime với PascalCase và id dạng chuỗi', () {
      final event = DeliveryRealtimeEvent.fromJson({
        'OrderId': '77',
        'OrderCode': 'DH-0077',
        'OrderStatus': 'Delivered',
        'Message': 'Đơn hàng đã giao thành công.',
      });

      expect(event.orderId, 77);
      expect(event.orderStatus, 'Delivered');
    });
  });
}
