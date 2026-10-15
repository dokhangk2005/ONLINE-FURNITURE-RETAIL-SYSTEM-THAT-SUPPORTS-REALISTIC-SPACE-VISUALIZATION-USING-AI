class RevenueReport {
  final RevenueRange range;
  final RevenueSummary summary;
  final List<RevenueTimelinePoint> timeline;
  final List<ProductRevenueItem> products;
  final List<CategoryRevenueItem> categories;

  const RevenueReport({
    required this.range,
    required this.summary,
    required this.timeline,
    required this.products,
    required this.categories,
  });

  factory RevenueReport.fromJson(Map<String, dynamic> json) {
    return RevenueReport(
      range: RevenueRange.fromJson(_map(json['range'])),
      summary: RevenueSummary.fromJson(_map(json['summary'])),
      timeline: _list(
        json['timeline'],
      ).map((item) => RevenueTimelinePoint.fromJson(_map(item))).toList(),
      products: _list(
        json['products'],
      ).map((item) => ProductRevenueItem.fromJson(_map(item))).toList(),
      categories: _list(
        json['categories'],
      ).map((item) => CategoryRevenueItem.fromJson(_map(item))).toList(),
    );
  }
}

class RevenueRange {
  final DateTime from;
  final DateTime to;
  final String groupBy;
  final DateTime previousFrom;
  final DateTime previousTo;

  const RevenueRange({
    required this.from,
    required this.to,
    required this.groupBy,
    required this.previousFrom,
    required this.previousTo,
  });

  factory RevenueRange.fromJson(Map<String, dynamic> json) {
    return RevenueRange(
      from: _date(json['from']),
      to: _date(json['to']),
      groupBy: json['groupBy']?.toString() ?? 'month',
      previousFrom: _date(json['previousFrom']),
      previousTo: _date(json['previousTo']),
    );
  }
}

class RevenueSummary {
  final double totalRevenue;
  final double merchandiseRevenue;
  final double shippingRevenue;
  final double assemblyRevenue;
  final double estimatedDiscount;
  final int orderCount;
  final int itemCount;
  final int customerCount;
  final double averageOrderValue;
  final int voucherOrderCount;
  final double previousRevenue;
  final int previousOrderCount;
  final double revenueChangePercent;
  final double orderChangePercent;

  const RevenueSummary({
    required this.totalRevenue,
    required this.merchandiseRevenue,
    required this.shippingRevenue,
    required this.assemblyRevenue,
    required this.estimatedDiscount,
    required this.orderCount,
    required this.itemCount,
    required this.customerCount,
    required this.averageOrderValue,
    required this.voucherOrderCount,
    required this.previousRevenue,
    required this.previousOrderCount,
    required this.revenueChangePercent,
    required this.orderChangePercent,
  });

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      totalRevenue: _double(json['totalRevenue']),
      merchandiseRevenue: _double(json['merchandiseRevenue']),
      shippingRevenue: _double(json['shippingRevenue']),
      assemblyRevenue: _double(json['assemblyRevenue']),
      estimatedDiscount: _double(json['estimatedDiscount']),
      orderCount: _int(json['orderCount']),
      itemCount: _int(json['itemCount']),
      customerCount: _int(json['customerCount']),
      averageOrderValue: _double(json['averageOrderValue']),
      voucherOrderCount: _int(json['voucherOrderCount']),
      previousRevenue: _double(json['previousRevenue']),
      previousOrderCount: _int(json['previousOrderCount']),
      revenueChangePercent: _double(json['revenueChangePercent']),
      orderChangePercent: _double(json['orderChangePercent']),
    );
  }
}

class RevenueTimelinePoint {
  final DateTime periodStart;
  final double revenue;
  final int orderCount;
  final int itemCount;
  final double averageOrderValue;

  const RevenueTimelinePoint({
    required this.periodStart,
    required this.revenue,
    required this.orderCount,
    required this.itemCount,
    required this.averageOrderValue,
  });

  factory RevenueTimelinePoint.fromJson(Map<String, dynamic> json) {
    return RevenueTimelinePoint(
      periodStart: _date(json['periodStart']),
      revenue: _double(json['revenue']),
      orderCount: _int(json['orderCount']),
      itemCount: _int(json['itemCount']),
      averageOrderValue: _double(json['averageOrderValue']),
    );
  }
}

class ProductRevenueItem {
  final int productId;
  final String productName;
  final String productCode;
  final String categoryName;
  final int quantitySold;
  final int orderCount;
  final double revenue;
  final double averageSellingPrice;
  final double sharePercent;

  const ProductRevenueItem({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.categoryName,
    required this.quantitySold,
    required this.orderCount,
    required this.revenue,
    required this.averageSellingPrice,
    required this.sharePercent,
  });

  factory ProductRevenueItem.fromJson(Map<String, dynamic> json) {
    return ProductRevenueItem(
      productId: _int(json['productId']),
      productName: json['productName']?.toString() ?? '',
      productCode: json['productCode']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      quantitySold: _int(json['quantitySold']),
      orderCount: _int(json['orderCount']),
      revenue: _double(json['revenue']),
      averageSellingPrice: _double(json['averageSellingPrice']),
      sharePercent: _double(json['sharePercent']),
    );
  }
}

class CategoryRevenueItem {
  final int categoryId;
  final String categoryName;
  final int quantitySold;
  final int orderCount;
  final int productCount;
  final double revenue;
  final double sharePercent;

  const CategoryRevenueItem({
    required this.categoryId,
    required this.categoryName,
    required this.quantitySold,
    required this.orderCount,
    required this.productCount,
    required this.revenue,
    required this.sharePercent,
  });

  factory CategoryRevenueItem.fromJson(Map<String, dynamic> json) {
    return CategoryRevenueItem(
      categoryId: _int(json['categoryId']),
      categoryName: json['categoryName']?.toString() ?? '',
      quantitySold: _int(json['quantitySold']),
      orderCount: _int(json['orderCount']),
      productCount: _int(json['productCount']),
      revenue: _double(json['revenue']),
      sharePercent: _double(json['sharePercent']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

double _double(dynamic value) => value is num ? value.toDouble() : 0;

int _int(dynamic value) => value is num ? value.toInt() : 0;

DateTime _date(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970);
}
