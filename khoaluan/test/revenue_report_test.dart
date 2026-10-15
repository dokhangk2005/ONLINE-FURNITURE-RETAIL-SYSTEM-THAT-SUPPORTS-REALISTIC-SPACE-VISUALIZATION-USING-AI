import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/revenue_report.dart';

void main() {
  test('đọc đầy đủ báo cáo doanh thu theo thời gian, sản phẩm và danh mục', () {
    final report = RevenueReport.fromJson({
      'range': {
        'from': '2026-01-01T00:00:00',
        'to': '2026-12-31T00:00:00',
        'groupBy': 'month',
        'previousFrom': '2025-01-01T00:00:00',
        'previousTo': '2025-12-31T00:00:00',
      },
      'summary': {
        'totalRevenue': 12000000,
        'merchandiseRevenue': 12500000,
        'shippingRevenue': 200000,
        'assemblyRevenue': 100000,
        'estimatedDiscount': 800000,
        'orderCount': 2,
        'itemCount': 3,
        'customerCount': 2,
        'averageOrderValue': 6000000,
        'voucherOrderCount': 1,
        'previousRevenue': 10000000,
        'previousOrderCount': 1,
        'revenueChangePercent': 20,
        'orderChangePercent': 100,
      },
      'timeline': [
        {
          'periodStart': '2026-08-01T00:00:00',
          'revenue': 12000000,
          'orderCount': 2,
          'itemCount': 3,
          'averageOrderValue': 6000000,
        },
      ],
      'products': [
        {
          'productId': 1,
          'productName': 'Bàn ăn',
          'productCode': 'BAN-01',
          'categoryName': 'Bàn ăn',
          'quantitySold': 3,
          'orderCount': 2,
          'revenue': 12500000,
          'averageSellingPrice': 4166666.67,
          'sharePercent': 100,
        },
      ],
      'categories': [
        {
          'categoryId': 1003,
          'categoryName': 'Bàn ăn',
          'quantitySold': 3,
          'orderCount': 2,
          'productCount': 1,
          'revenue': 12500000,
          'sharePercent': 100,
        },
      ],
    });

    expect(report.range.groupBy, 'month');
    expect(report.summary.totalRevenue, 12000000);
    expect(report.summary.estimatedDiscount, 800000);
    expect(report.timeline.single.orderCount, 2);
    expect(report.products.single.productCode, 'BAN-01');
    expect(report.categories.single.productCount, 1);
  });
}
