import 'package:flutter/material.dart';
import '../../model/category.dart';
import '../../model/product.dart';
import '../../model/order.dart';
import '../../model/revenue_report.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../homepage/home_page.dart';
import '../../widgets/web_page_route.dart';
import 'category/category_list_page.dart';
import 'product/product_list_page.dart';
import 'reviews/admin_reviews_page.dart';
import 'orders/admin_orders_page.dart';
import 'users/admin_users_page.dart';
import 'vouchers/admin_vouchers_page.dart';
import 'delivery/admin_delivery_page.dart';
import 'questions/admin_questions_page.dart';
import 'recommendations/admin_recommendations_page.dart';
import 'revenue/admin_revenue_page.dart';
import '../../l10n/l10n.dart';
import '../../widgets/currency_formatter.dart';
import '../../widgets/language_switcher.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _redirectingToLogin = false;
  int _selectedIndex = 0; // 0: Dashboard, 1: Categories, 2: Products

  List<Category> _categories = [];
  List<Product> _products = [];
  List<OrderModel> _orders = [];
  RevenueReport? _dashboardRevenueReport;

  @override
  void initState() {
    super.initState();
    AuthService.currentUser.addListener(_handleAuthStateChanged);
    if (_hasValidAdminSession) {
      _loadData();
    } else {
      _redirectToLogin();
    }
  }

  @override
  void dispose() {
    AuthService.currentUser.removeListener(_handleAuthStateChanged);
    super.dispose();
  }

  bool get _hasValidAdminSession =>
      AuthService.currentUser.value?['roleId'] == 1 &&
      AuthService.hasValidSession;

  void _handleAuthStateChanged() {
    if (!_hasValidAdminSession) _redirectToLogin();
  }

  void _redirectToLogin() {
    if (_redirectingToLogin) return;
    _redirectingToLogin = true;
    AuthService.logout();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final cats = await _apiService.fetchCategories();
      final prods = await _apiService.fetchProducts();
      final orders = await _apiService.fetchAdminOrders();
      RevenueReport? revenueReport;
      try {
        final now = DateTime.now();
        revenueReport = await _apiService.fetchAdminRevenueReport(
          from: DateTime(now.year),
          to: DateTime(now.year, 12, 31),
          groupBy: 'month',
        );
      } catch (error) {
        debugPrint('Dashboard revenue report unavailable: $error');
      }
      if (mounted) {
        setState(() {
          _categories = cats;
          _products = prods;
          _orders = orders;
          _dashboardRevenueReport = revenueReport;
        });
      }
    } catch (e) {
      if (!_hasValidAdminSession) {
        _redirectToLogin();
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.loadDataError(e))));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Main content + topbar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopbar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (_selectedIndex == 3 ||
                            _selectedIndex == 4 ||
                            _selectedIndex == 5 ||
                            _selectedIndex == 6 ||
                            _selectedIndex == 7 ||
                            _selectedIndex == 8 ||
                            _selectedIndex == 9 ||
                            _selectedIndex == 10)
                      ? _buildMainContent()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildMainContent(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final l10n = context.l10n;
    return Container(
      width: 250,
      color: const Color(0xFF212529),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Furniture Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.white24,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              children: [
                // CORE Section
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'CORE',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _buildSidebarItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                ),
                const SizedBox(height: 16),
                const Divider(
                  color: Colors.white24,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(height: 16),
                // INTERFACE Section
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'INTERFACE',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _buildSidebarItem(
                  icon: Icons.category,
                  title: l10n.adminManageCategories,
                  index: 1,
                ),
                _buildSidebarItem(
                  icon: Icons.shopping_bag,
                  title: l10n.adminManageProducts,
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.rate_review,
                  title: l10n.adminManageReviews,
                  index: 3,
                ),
                _buildSidebarItem(
                  icon: Icons.shopping_cart,
                  title: l10n.adminManageOrders,
                  index: 4,
                ),
                _buildSidebarItem(
                  icon: Icons.people,
                  title: l10n.adminManageAccounts,
                  index: 5,
                ),
                _buildSidebarItem(
                  icon: Icons.card_giftcard,
                  title: l10n.adminManagePromotions,
                  index: 6,
                ),
                _buildSidebarItem(
                  icon: Icons.local_shipping,
                  title: l10n.adminManageDelivery,
                  index: 7,
                ),
                _buildSidebarItem(
                  icon: Icons.support_agent,
                  title: l10n.adminQaSupport,
                  index: 8,
                ),
                _buildSidebarItem(
                  icon: Icons.auto_graph,
                  title: l10n.adminManageRecommendations,
                  index: 9,
                ),
                _buildSidebarItem(
                  icon: Icons.query_stats,
                  title: l10n.adminManageRevenue,
                  index: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  left: BorderSide(color: Color(0xFF4E73DF), width: 4),
                )
              : null,
          color: isSelected ? Colors.white.withAlpha(13) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopbar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.grey),
          const SizedBox(width: 16),
          const Spacer(),
          // Profile
          Row(
            children: [
              const Material(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.all(Radius.circular(8)),
                clipBehavior: Clip.antiAlias,
                child: LanguageSwitcher(height: 40, horizontalPadding: 8),
              ),
              const SizedBox(width: 16),
              const Stack(
                children: [
                  Icon(Icons.notifications, color: Colors.grey),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              const VerticalDivider(
                width: 1,
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
              ),
              const SizedBox(width: 24),
              PopupMenuButton<String>(
                offset: const Offset(0, 45),
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
                onSelected: (value) {
                  if (value == 'home') {
                    Navigator.pushAndRemoveUntil(
                      context,
                      WebPageRoute(page: const HomePage(), animated: false),
                      (route) => false,
                    );
                  } else if (value == 'logout') {
                    AuthService.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      WebPageRoute(page: const HomePage(), animated: false),
                      (route) => false,
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'home',
                      child: Row(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 18,
                            color: Color(0xFF2D2D2D),
                          ),
                          SizedBox(width: 8),
                          Text(
                            context.l10n.backToHome,
                            style: const TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            context.l10n.logout,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    children: [
                      const Text(
                        'Admin User',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const CategoryListPage();
      case 2:
        return const ProductListPage();
      case 3:
        return const AdminReviewsPage();
      case 4:
        return const AdminOrdersPage();
      case 5:
        return const AdminUsersPage();
      case 6:
        return const AdminVouchersPage();
      case 7:
        return const AdminDeliveryPage();
      case 8:
        return const AdminQuestionsPage();
      case 9:
        return const AdminRecommendationsPage();
      case 10:
        return const AdminRevenuePage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDashboardContent() {
    final l10n = context.l10n;
    final timeline = _dashboardRevenueReport?.timeline ?? const [];
    final deliverySuccessPoints = _deliverySuccessPoints();
    final revenue =
        _dashboardRevenueReport?.summary.totalRevenue ??
        _orders
            .where((o) {
              final status = o.orderStatus.trim().toLowerCase();
              return status == 'delivered' || status == 'đã giao';
            })
            .fold<double>(0, (sum, o) => sum + o.totalAmount);
    final outOfStock = _products
        .expand((p) => p.productVariants)
        .where((v) => v.stockQuantity <= 0)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5A5C69),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E73DF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                l10n.refreshData,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: _loadData,
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Stats Cards Row
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 240,
              child: _buildStatCard(
                l10n.categoriesMetric,
                _categories.length.toString(),
                const Color(0xFF4E73DF),
                Icons.category,
              ),
            ),
            SizedBox(
              width: 240,
              child: _buildStatCard(
                l10n.productsMetric,
                _products.length.toString(),
                const Color(0xFFF6C23E),
                Icons.shopping_bag,
              ),
            ),
            SizedBox(
              width: 240,
              child: _buildStatCard(
                l10n.collectedRevenue,
                formatVND(revenue),
                const Color(0xFF1CC88A),
                Icons.monetization_on,
              ),
            ),
            SizedBox(
              width: 240,
              child: _buildStatCard(
                l10n.outOfStockVariants,
                outOfStock.toString(),
                const Color(0xFFE74A3B),
                Icons.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (timeline.isEmpty && deliverySuccessPoints.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              l10n.noDashboardChartData,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final chartCount =
                  (timeline.isNotEmpty ? 1 : 0) +
                  (deliverySuccessPoints.isNotEmpty ? 1 : 0);
              final chartWidth = constraints.maxWidth >= 900 && chartCount > 1
                  ? (constraints.maxWidth - 24) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  if (timeline.isNotEmpty)
                    SizedBox(
                      width: chartWidth,
                      child: buildMockCardChart(
                        l10n.revenueByMonthDashboard,
                        MockAreaChartPainter(timeline),
                      ),
                    ),
                  if (deliverySuccessPoints.isNotEmpty)
                    SizedBox(
                      width: chartWidth,
                      child: buildMockCardChart(
                        l10n.ordersByMonthDashboard,
                        DeliverySuccessBarChartPainter(deliverySuccessPoints),
                      ),
                    ),
                ],
              );
            },
          ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.recentOrders,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ..._orders
                  .take(8)
                  .map(
                    (o) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(o.orderCode),
                      subtitle: Text(o.userFullName),
                      trailing: Text(
                        '${formatVND(o.totalAmount)} · ${o.orderStatus}',
                      ),
                    ),
                  ),
              if (_orders.isEmpty) Text(l10n.noOrdersYet),
            ],
          ),
        ),
      ],
    );
  }

  List<DeliverySuccessPoint> _deliverySuccessPoints() {
    final currentYear = DateTime.now().year;
    final totals = <int, int>{};
    final delivered = <int, int>{};
    for (final order in _orders) {
      final date = DateTime.tryParse(order.orderDate);
      if (date == null || date.year != currentYear) continue;
      totals.update(date.month, (value) => value + 1, ifAbsent: () => 1);
      if (order.orderStatus.trim().toLowerCase() == 'delivered') {
        delivered.update(date.month, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final months = totals.keys.toList()..sort();
    return months
        .map(
          (month) => DeliverySuccessPoint(
            month: month,
            totalOrders: totals[month]!,
            deliveredOrders: delivered[month] ?? 0,
          ),
        )
        .toList();
  }

  Widget _buildStatCard(String title, String val, Color color, IconData icon) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: color, width: 4.5)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                val,
                style: const TextStyle(
                  color: Color(0xFF5A5C69),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(icon, color: Colors.grey.shade300, size: 36),
        ],
      ),
    );
  }

  Widget buildMockCardChart(String title, CustomPainter painter) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E73DF),
                fontSize: 14,
              ),
            ),
          ),
          Container(
            height: 250,
            padding: const EdgeInsets.all(24.0),
            child: CustomPaint(painter: painter),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Mock Area Chart
class MockAreaChartPainter extends CustomPainter {
  const MockAreaChartPainter(this.data);

  final List<RevenueTimelinePoint> data;

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF4E73DF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..color = const Color(0xFF4E73DF).withAlpha(38)
      ..style = PaintingStyle.fill;

    final paintDot = Paint()
      ..color = const Color(0xFF4E73DF)
      ..style = PaintingStyle.fill;

    if (data.isEmpty) return;
    _drawGrid(canvas, size);
    final maxValue = data
        .map((point) => point.revenue)
        .fold<double>(0, (max, value) => value > max ? value : max);
    final chartHeight = size.height - 24;
    final points = List.generate(data.length, (index) {
      final x = data.length == 1
          ? size.width / 2
          : index * size.width / (data.length - 1);
      final ratio = maxValue <= 0 ? 0 : data[index].revenue / maxValue;
      return Offset(x, chartHeight - ratio * (chartHeight - 12));
    });

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path()
      ..moveTo(points[0].dx, chartHeight)
      ..lineTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    for (var point in points) {
      canvas.drawCircle(point, 5, paintDot);
    }
    _drawMonthLabels(canvas, size, data);
  }

  @override
  bool shouldRepaint(covariant MockAreaChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

class DeliverySuccessPoint {
  const DeliverySuccessPoint({
    required this.month,
    required this.totalOrders,
    required this.deliveredOrders,
  });

  final int month;
  final int totalOrders;
  final int deliveredOrders;

  double get successRate =>
      totalOrders == 0 ? 0 : deliveredOrders * 100 / totalOrders;
}

class DeliverySuccessBarChartPainter extends CustomPainter {
  const DeliverySuccessBarChartPainter(this.data);

  final List<DeliverySuccessPoint> data;

  @override
  void paint(Canvas canvas, Size size) {
    final paintBar = Paint()
      ..color = const Color(0xFF4E73DF)
      ..style = PaintingStyle.fill;

    if (data.isEmpty) return;
    _drawGrid(canvas, size);
    final chartBottom = size.height - 24;
    const chartTop = 24.0;
    final availableHeight = chartBottom - chartTop;
    final slotWidth = size.width / data.length;
    final barWidth = slotWidth * 0.55;

    for (int i = 0; i < data.length; i++) {
      final ratio = (data[i].successRate / 100).clamp(0.0, 1.0);
      final height = ratio * availableHeight;
      final x = i * slotWidth + (slotWidth - barWidth) / 2;
      final y = chartBottom - height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, height),
          const Radius.circular(3),
        ),
        paintBar,
      );

      final percentagePainter = TextPainter(
        text: TextSpan(
          text: '${data[i].successRate.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      percentagePainter.paint(
        canvas,
        Offset(
          x + (barWidth - percentagePainter.width) / 2,
          (y - percentagePainter.height - 3).clamp(0, chartBottom),
        ),
      );
    }
    _drawDeliveryMonthLabels(canvas, size, data);
  }

  @override
  bool shouldRepaint(covariant DeliverySuccessBarChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

void _drawGrid(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = const Color(0xFFE5E7EB)
    ..strokeWidth = 1;
  final chartHeight = size.height - 24;
  for (var i = 0; i <= 4; i++) {
    final y = chartHeight * i / 4;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
}

void _drawMonthLabels(
  Canvas canvas,
  Size size,
  List<RevenueTimelinePoint> data,
) {
  if (data.isEmpty) return;
  final slotWidth = size.width / data.length;
  final step = data.length > 8 ? 2 : 1;
  for (var i = 0; i < data.length; i += step) {
    final painter = TextPainter(
      text: TextSpan(
        text: 'T${data[i].periodStart.month}',
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = i * slotWidth + (slotWidth - painter.width) / 2;
    painter.paint(canvas, Offset(x, size.height - painter.height));
  }
}

void _drawDeliveryMonthLabels(
  Canvas canvas,
  Size size,
  List<DeliverySuccessPoint> data,
) {
  final slotWidth = size.width / data.length;
  for (var i = 0; i < data.length; i++) {
    final painter = TextPainter(
      text: TextSpan(
        text: 'T${data[i].month}',
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        i * slotWidth + (slotWidth - painter.width) / 2,
        size.height - painter.height,
      ),
    );
  }
}
