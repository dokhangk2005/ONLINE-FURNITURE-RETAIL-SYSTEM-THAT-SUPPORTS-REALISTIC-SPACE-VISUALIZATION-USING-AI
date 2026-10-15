DateTime? _parseServerDate(dynamic value) {
  final text = value?.toString() ?? '';
  if (text.isEmpty) return null;
  final hasTimeZone =
      text.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(text);
  final parsed = DateTime.tryParse(hasTimeZone ? text : '${text}Z');
  if (parsed == null) return null;
  return parsed.toLocal();
}

class ProductImage {
  final int imageId;
  final int productId;
  final String imageUrl;
  final String sourceImageUrl;
  final bool isThumbnail;
  final String createdAt;

  ProductImage({
    required this.imageId,
    required this.productId,
    required this.imageUrl,
    String? sourceImageUrl,
    required this.isThumbnail,
    required this.createdAt,
  }) : sourceImageUrl = sourceImageUrl ?? imageUrl;

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imageId: json['imageId'] ?? 0,
      productId: json['productId'] ?? json['variantId'] ?? 0,
      imageUrl: json['displayImageUrl'] ?? json['imageUrl'] ?? '',
      sourceImageUrl: json['imageUrl'] ?? '',
      isThumbnail: json['isThumbnail'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'imageId': imageId,
    'productId': productId,
    'variantId': productId,
    'imageUrl': sourceImageUrl,
    'isThumbnail': isThumbnail,
    'createdAt': createdAt,
  };
}

class ProductVariant {
  final int variantId;
  final int productId;
  final String material;
  final String color;
  final String size;
  final double additionalPrice;
  final int stockQuantity;
  final List<ProductImage> productImages;

  ProductVariant({
    required this.variantId,
    required this.productId,
    required this.material,
    required this.color,
    required this.size,
    required this.additionalPrice,
    required this.stockQuantity,
    required this.productImages,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    var imagesList = json['productImages'] as List? ?? [];
    return ProductVariant(
      variantId: json['variantId'] ?? 0,
      productId: json['productId'] ?? 0,
      material: json['material'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      additionalPrice: (json['additionalPrice'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      productImages: imagesList.map((i) => ProductImage.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'variantId': variantId,
    'productId': productId,
    'material': material,
    'color': color,
    'size': size,
    'additionalPrice': additionalPrice,
    'stockQuantity': stockQuantity,
    'productImages': productImages.map((e) => e.toJson()).toList(),
  };
}

class Product {
  final int productId;
  final int categoryId;
  final String categoryName;
  final String productName;
  final String productCode;
  final double basePrice;
  final double discountPercent;
  final bool isDiscountActive;
  final DateTime? discountStartAt;
  final DateTime? discountEndAt;
  final String description;
  final bool isDeleted;
  final double averageRating;
  final int reviewCount;
  final List<ProductVariant> productVariants;
  final int soldCount;

  bool get hasActiveDiscount {
    if (!isDiscountActive || discountPercent <= 0 || discountPercent > 90) {
      return false;
    }
    final now = DateTime.now();
    return (discountStartAt == null || !discountStartAt!.isAfter(now)) &&
        (discountEndAt == null || !discountEndAt!.isBefore(now));
  }

  double effectivePrice([double additionalPrice = 0]) {
    final original = basePrice + additionalPrice;
    return hasActiveDiscount
        ? (original * (100 - discountPercent) / 100).roundToDouble()
        : original;
  }

  Product({
    required this.productId,
    required this.categoryId,
    required this.categoryName,
    required this.productName,
    required this.productCode,
    required this.basePrice,
    this.discountPercent = 0,
    this.isDiscountActive = false,
    this.discountStartAt,
    this.discountEndAt,
    required this.description,
    required this.isDeleted,
    required this.averageRating,
    required this.reviewCount,
    required this.productVariants,
    required this.soldCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var variantsList = json['productVariants'] as List? ?? [];

    return Product(
      productId: json['productId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['category'] != null
          ? (json['category']['categoryName'] ?? '')
          : '',
      productName: json['productName'] ?? '',
      productCode: json['productCode'] ?? '',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      isDiscountActive: json['isDiscountActive'] ?? false,
      discountStartAt: _parseServerDate(json['discountStartAt']),
      discountEndAt: _parseServerDate(json['discountEndAt']),
      description: json['description'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      productVariants: variantsList
          .map((i) => ProductVariant.fromJson(i))
          .toList(),
      soldCount: json['soldCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'categoryId': categoryId,
    'category': {'categoryName': categoryName},
    'productName': productName,
    'productCode': productCode,
    'basePrice': basePrice,
    'discountPercent': discountPercent,
    'isDiscountActive': isDiscountActive,
    'discountStartAt': discountStartAt?.toIso8601String(),
    'discountEndAt': discountEndAt?.toIso8601String(),
    'description': description,
    'isDeleted': isDeleted,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
    'productVariants': productVariants.map((e) => e.toJson()).toList(),
    'soldCount': soldCount,
  };
}
