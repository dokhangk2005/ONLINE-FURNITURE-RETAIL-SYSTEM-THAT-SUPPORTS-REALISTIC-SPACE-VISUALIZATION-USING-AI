class Review {
  final int reviewId;
  final int rating;
  final String comment;
  final bool isApproved;
  final String createdAt;
  final String userFullName;
  final String? adminReply;
  final String? adminReplyAt;

  Review({
    required this.reviewId,
    required this.rating,
    required this.comment,
    required this.isApproved,
    required this.createdAt,
    required this.userFullName,
    this.adminReply,
    this.adminReplyAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      isApproved: json['isApproved'] ?? false,
      createdAt: json['createdAt'] ?? '',
      userFullName: json['userFullName'] ?? 'Khách hàng',
      adminReply: json['adminReply'],
      adminReplyAt: json['adminReplyAt'],
    );
  }
}

class AdminPendingReview {
  final int reviewId;
  final int rating;
  final String comment;
  final String createdAt;
  final String productName;
  final String userFullName;

  AdminPendingReview({
    required this.reviewId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.productName,
    required this.userFullName,
  });

  factory AdminPendingReview.fromJson(Map<String, dynamic> json) {
    return AdminPendingReview(
      reviewId: json['reviewId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      productName: json['productName'] ?? 'Sản phẩm',
      userFullName: json['userFullName'] ?? 'Khách hàng',
    );
  }
}

class AdminProductReviewSummary {
  final int productId;
  final String productName;
  final double averageRating;
  final int totalCount;
  final int pendingCount;

  AdminProductReviewSummary({
    required this.productId,
    required this.productName,
    required this.averageRating,
    required this.totalCount,
    required this.pendingCount,
  });

  factory AdminProductReviewSummary.fromJson(Map<String, dynamic> json) {
    return AdminProductReviewSummary(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalCount: json['totalCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
    );
  }
}
