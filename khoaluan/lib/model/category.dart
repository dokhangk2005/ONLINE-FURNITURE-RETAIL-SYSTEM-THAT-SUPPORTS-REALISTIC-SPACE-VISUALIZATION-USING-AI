class Category {
  final int categoryId;
  final String categoryName;
  final String categoryCode;
  final String imageUrl;
  final int? parentCategoryId;
  final List<Category> subCategories;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.categoryCode,
    required this.imageUrl,
    this.parentCategoryId,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var subList = json['subCategories'] as List? ?? [];
    return Category(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      categoryCode: json['categoryCode'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      parentCategoryId: json['parentCategoryId'],
      subCategories: subList.map((item) => Category.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryCode': categoryCode,
      'imageUrl': imageUrl,
      'parentCategoryId': parentCategoryId,
      'subCategories': subCategories.map((item) => item.toJson()).toList(),
    };
  }
}
