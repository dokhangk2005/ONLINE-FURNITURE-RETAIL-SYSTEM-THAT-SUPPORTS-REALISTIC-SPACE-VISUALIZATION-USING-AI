class VoucherModel {
  final int voucherId;
  final String voucherCode;
  final String voucherName;
  final String? description;
  final int discountType; // 1: %, 2: Fixed amount
  final double discountValue;
  final double? maxDiscountAmount;
  final double minOrderAmount;
  final int usageLimit;
  final int usedCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  VoucherModel({
    required this.voucherId,
    required this.voucherCode,
    required this.voucherName,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    required this.minOrderAmount,
    required this.usageLimit,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      voucherId: (json['voucherId'] ?? json['VoucherId'] ?? 0) as int,
      voucherCode: (json['voucherCode'] ?? json['VoucherCode'] ?? '')
          .toString(),
      voucherName: (json['voucherName'] ?? json['VoucherName'] ?? '')
          .toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
      discountType: (json['discountType'] ?? json['DiscountType'] ?? 1) as int,
      discountValue: (json['discountValue'] ?? json['DiscountValue'] ?? 0)
          .toDouble(),
      maxDiscountAmount: json['maxDiscountAmount'] != null
          ? (json['maxDiscountAmount'] as num).toDouble()
          : (json['MaxDiscountAmount'] != null
                ? (json['MaxDiscountAmount'] as num).toDouble()
                : null),
      minOrderAmount: (json['minOrderAmount'] ?? json['MinOrderAmount'] ?? 0)
          .toDouble(),
      usageLimit: (json['usageLimit'] ?? json['UsageLimit'] ?? 100) as int,
      usedCount: (json['usedCount'] ?? json['UsedCount'] ?? 0) as int,
      startDate:
          DateTime.tryParse(
            (json['startDate'] ?? json['StartDate'] ?? '').toString(),
          ) ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(
            (json['endDate'] ?? json['EndDate'] ?? '').toString(),
          ) ??
          DateTime.now().add(const Duration(days: 30)),
      isActive: (json['isActive'] ?? json['IsActive'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucherCode': voucherCode,
      'voucherName': voucherName,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'maxDiscountAmount': maxDiscountAmount,
      'minOrderAmount': minOrderAmount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class VoucherValidationResult {
  final int voucherId;
  final String voucherCode;
  final String voucherName;
  final int discountType;
  final double discountAmount;
  final String message;

  VoucherValidationResult({
    required this.voucherId,
    required this.voucherCode,
    required this.voucherName,
    required this.discountType,
    required this.discountAmount,
    required this.message,
  });

  factory VoucherValidationResult.fromJson(Map<String, dynamic> json) {
    return VoucherValidationResult(
      voucherId: (json['voucherId'] ?? json['VoucherId'] ?? 0) as int,
      voucherCode: (json['voucherCode'] ?? json['VoucherCode'] ?? '')
          .toString(),
      voucherName: (json['voucherName'] ?? json['VoucherName'] ?? '')
          .toString(),
      discountType: (json['discountType'] ?? json['DiscountType'] ?? 1) as int,
      discountAmount: (json['discountAmount'] ?? json['DiscountAmount'] ?? 0)
          .toDouble(),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
    );
  }
}
