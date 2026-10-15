class OrderItem {
  final int orderDetailId;
  final int productVariantId;
  final int productId;
  final int quantity;
  final double price;
  final String productName;
  final String color;
  final String size;
  final String imageUrl;
  final bool canReview;
  final bool hasReviewed;

  OrderItem({
    required this.orderDetailId,
    required this.productVariantId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.productName,
    required this.color,
    required this.size,
    required this.imageUrl,
    this.canReview = false,
    this.hasReviewed = false,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderDetailId: json['orderDetailId'] ?? 0,
      productVariantId: json['productVariantId'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      productName: json['productName'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      canReview: json['canReview'] ?? false,
      hasReviewed: json['hasReviewed'] ?? false,
    );
  }
}

class OrderModel {
  final int orderId;
  final String orderCode;
  final String orderDate;
  final String shippingAddress;
  final double totalAmount;
  final String orderStatus;
  final List<OrderItem> orderDetails;
  final String paymentMethod;
  final String paymentStatus;
  final double? paymentAmount;
  final String userFullName;
  final String userEmail;
  final String userPhone;
  final double shippingFee;
  final double assemblyFee;
  final bool includesAssembly;
  final double? deliveryDistanceKm;
  final String? estimatedDeliveryDate;
  final String? deliveryTimeSlot;
  final int? shipperId;
  final String? shipperName;
  final String? deliveryProofImage;
  final String? deliveryNotes;
  final int deliveryAttemptCount;
  final String? deliveryAssignedAt;
  final String? deliveryAssignmentExpiresAt;
  final String? deliveryAcceptedAt;
  final String? deliveryPickedUpAt;
  final String? deliveryArrivedAt;
  final String? deliveredAt;
  final String? deliveryRecipientName;
  final String? deliveryIssueProofImage;
  final bool otpVerified;
  final String? paymentCollectedAt;
  final String? paymentCollectionProofImage;
  final String paymentHandoverStatus;
  final String? deliveryCancelledAt;
  final int? deliveryCancelledByShipperId;
  final String? deliveryCancellationReason;
  final String? deliveryCancellationNote;
  final String? deliveryCancellationProofImage;

  OrderModel({
    required this.orderId,
    required this.orderCode,
    required this.orderDate,
    required this.shippingAddress,
    required this.totalAmount,
    required this.orderStatus,
    required this.orderDetails,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentAmount,
    required this.userFullName,
    required this.userEmail,
    this.userPhone = '',
    this.shippingFee = 0.0,
    this.assemblyFee = 0.0,
    this.includesAssembly = false,
    this.deliveryDistanceKm,
    this.estimatedDeliveryDate,
    this.deliveryTimeSlot,
    this.shipperId,
    this.shipperName,
    this.deliveryProofImage,
    this.deliveryNotes,
    this.deliveryAttemptCount = 0,
    this.deliveryAssignedAt,
    this.deliveryAssignmentExpiresAt,
    this.deliveryAcceptedAt,
    this.deliveryPickedUpAt,
    this.deliveryArrivedAt,
    this.deliveredAt,
    this.deliveryRecipientName,
    this.deliveryIssueProofImage,
    this.otpVerified = false,
    this.paymentCollectedAt,
    this.paymentCollectionProofImage,
    this.paymentHandoverStatus = 'NotRequired',
    this.deliveryCancelledAt,
    this.deliveryCancelledByShipperId,
    this.deliveryCancellationReason,
    this.deliveryCancellationNote,
    this.deliveryCancellationProofImage,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var detailsList = json['orderDetails'] as List? ?? [];
    return OrderModel(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderDate: json['orderDate'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      orderStatus: json['orderStatus'] ?? '',
      orderDetails: detailsList.map((d) => OrderItem.fromJson(d)).toList(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentAmount: json['paymentAmount'] == null
          ? null
          : (json['paymentAmount'] as num).toDouble(),
      userFullName: json['userFullName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'] ?? '',
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      assemblyFee: (json['assemblyFee'] ?? 0).toDouble(),
      includesAssembly: json['includesAssembly'] ?? false,
      deliveryDistanceKm: json['deliveryDistanceKm'] != null
          ? (json['deliveryDistanceKm']).toDouble()
          : null,
      estimatedDeliveryDate: json['estimatedDeliveryDate']?.toString(),
      deliveryTimeSlot: json['deliveryTimeSlot']?.toString(),
      shipperId: json['shipperId'],
      shipperName: json['shipperName']?.toString(),
      deliveryProofImage: json['deliveryProofImage']?.toString(),
      deliveryNotes: json['deliveryNotes']?.toString(),
      deliveryAttemptCount: json['deliveryAttemptCount'] != null
          ? (json['deliveryAttemptCount'] as num).toInt()
          : 0,
      deliveryAssignedAt: json['deliveryAssignedAt']?.toString(),
      deliveryAssignmentExpiresAt: json['deliveryAssignmentExpiresAt']
          ?.toString(),
      deliveryAcceptedAt: json['deliveryAcceptedAt']?.toString(),
      deliveryPickedUpAt: json['deliveryPickedUpAt']?.toString(),
      deliveryArrivedAt: json['deliveryArrivedAt']?.toString(),
      deliveredAt: json['deliveredAt']?.toString(),
      deliveryRecipientName: json['deliveryRecipientName']?.toString(),
      deliveryIssueProofImage: json['deliveryIssueProofImage']?.toString(),
      otpVerified: json['otpVerified'] == true,
      paymentCollectedAt: json['paymentCollectedAt']?.toString(),
      paymentCollectionProofImage: json['paymentCollectionProofImage']
          ?.toString(),
      paymentHandoverStatus:
          json['paymentHandoverStatus']?.toString() ?? 'NotRequired',
      deliveryCancelledAt: json['deliveryCancelledAt']?.toString(),
      deliveryCancelledByShipperId:
          (json['deliveryCancelledByShipperId'] as num?)?.toInt(),
      deliveryCancellationReason: json['deliveryCancellationReason']
          ?.toString(),
      deliveryCancellationNote: json['deliveryCancellationNote']?.toString(),
      deliveryCancellationProofImage: json['deliveryCancellationProofImage']
          ?.toString(),
    );
  }

  double get amountToCollect => paymentAmount ?? totalAmount;

  bool get isDelivered => orderStatus.trim().toLowerCase() == 'delivered';

  bool get isPaid {
    final normalized = paymentStatus.trim().toLowerCase();
    return normalized == 'success' ||
        normalized == 'paid' ||
        normalized == 'đã thanh toán';
  }

  bool get canReviewItems => isDelivered && isPaid;
}

class ShipperModel {
  final int userId;
  final String fullName;
  final String email;
  final String phone;
  final bool isAvailableForDelivery;
  final String? availabilityUpdatedAt;

  ShipperModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.isAvailableForDelivery = false,
    this.availabilityUpdatedAt,
  });

  factory ShipperModel.fromJson(Map<String, dynamic> json) {
    return ShipperModel(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isAvailableForDelivery: json['isAvailableForDelivery'] ?? false,
      availabilityUpdatedAt: json['availabilityUpdatedAt']?.toString(),
    );
  }
}
