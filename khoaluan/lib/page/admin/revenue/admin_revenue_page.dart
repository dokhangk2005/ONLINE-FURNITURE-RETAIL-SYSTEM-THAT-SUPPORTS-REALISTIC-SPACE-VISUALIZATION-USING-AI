import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../model/revenue_report.dart';
import '../../../services/api_service.dart';
import '../../../widgets/currency_formatter.dart';

class AdminRevenuePage extends StatefulWidget {
  const AdminRevenuePage({super.key});

  @override
  State<AdminRevenuePage> createState() => _AdminRevenuePageState();
}

class _AdminRevenuePageState extends State<AdminRevenuePage> {
  final ApiService _api = ApiService();
  final TextEditingController _productSearchController =
      TextEditingController();

  RevenueReport? _report;
  bool _isLoading = true;
  String _errorMessage = '';
  String _preset = 'thisYear';
  String _groupBy = 'month';
  late DateTimeRange _dateRange;
  int _productSortColumn = 6;
  bool _productSortAscending = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(today.year, 1, 1),
      end: DateTime(today.year, today.month, today.day),
    );
    _loadReport();
  }

  @override
  void dispose() {
    _productSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final report = await _api.fetchAdminRevenueReport(
        from: _dateRange.start,
        to: _dateRange.end,
        groupBy: _groupBy,
      );
      if (!mounted) return;
      setState(() => _report = report);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectPreset(String value) {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    late DateTime start;
    late String groupBy;

    switch (value) {
      case 'today':
        start = end;
        groupBy = 'day';
        break;
      case 'last7Days':
        start = end.subtract(const Duration(days: 6));
        groupBy = 'day';
        break;
      case 'last30Days':
        start = end.subtract(const Duration(days: 29));
        groupBy = 'day';
        break;
      case 'thisMonth':
        start = DateTime(end.year, end.month, 1);
        groupBy = 'day';
        break;
      case 'allTime':
        start = DateTime(2000, 1, 1);
        groupBy = 'year';
        break;
      case 'thisYear':
      default:
        start = DateTime(end.year, 1, 1);
        groupBy = 'month';
        break;
    }

    setState(() {
      _preset = value;
      _groupBy = groupBy;
      _dateRange = DateTimeRange(start: start, end: end);
    });
    _loadReport();
  }

  Future<void> _pickDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      helpText: context.l10n.chooseRevenueRange,
      saveText: context.l10n.apply,
      cancelText: context.l10n.cancel.toUpperCase(),
    );
    if (result == null) return;
    final days = result.duration.inDays + 1;
    setState(() {
      _preset = 'custom';
      _dateRange = result;
      _groupBy = days <= 370
          ? 'day'
          : days <= 3660
          ? 'month'
          : 'year';
    });
    _loadReport();
  }

  void _changeGroupBy(String value) {
    final days = _dateRange.duration.inDays + 1;
    final unsupported =
        (value == 'day' && days > 370) ||
        (value == 'month' && days > 3660) ||
        (value == 'year' && days > 14610);
    if (unsupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.dateRangeTooLong),
          duration: const Duration(seconds: 3),
          persist: false,
        ),
      );
      return;
    }
    setState(() => _groupBy = value);
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8F9FC),
      child: RefreshIndicator(
        onRefresh: _loadReport,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 20),
              if (_isLoading)
                const SizedBox(
                  height: 420,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage.isNotEmpty)
                _buildError()
              else if (_report != null)
                _buildReport(_report!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.revenueManagement,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
              SizedBox(height: 5),
              Text(
                context.l10n.revenueManagementDescription,
                style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: context.l10n.reloadReport,
          onPressed: _isLoading ? null : _loadReport,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final presets = <String, String>{
      'today': context.l10n.today,
      'last7Days': context.l10n.last7Days,
      'last30Days': context.l10n.last30Days,
      'thisMonth': context.l10n.thisMonth,
      'thisYear': context.l10n.thisYear,
      'allTime': context.l10n.allTime,
      'custom': context.l10n.custom,
    };
    final groups = <String, String>{
      'day': context.l10n.byDay,
      'month': context.l10n.byMonth,
      'year': context.l10n.byYear,
    };

    return _AdminCard(
      child: Wrap(
        spacing: 16,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(
            width: 210,
            child: DropdownButtonFormField<String>(
              initialValue: _preset,
              decoration: InputDecoration(
                labelText: context.l10n.dateRange,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: presets.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      enabled: entry.key != 'custom',
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null && value != 'custom') _selectPreset(value);
              },
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              initialValue: _groupBy,
              decoration: InputDecoration(
                labelText: context.l10n.aggregationLevel,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: groups.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) _changeGroupBy(value);
              },
            ),
          ),
          OutlinedButton.icon(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.date_range_outlined),
            label: Text(
              '${_formatDate(_dateRange.start)}  –  ${_formatDate(_dateRange.end)}',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(260, 49),
              foregroundColor: const Color(0xFF2D3748),
            ),
          ),
          FilledButton.icon(
            onPressed: _isLoading ? null : _loadReport,
            icon: const Icon(Icons.analytics_outlined),
            label: Text(context.l10n.viewReport),
            style: FilledButton.styleFrom(
              minimumSize: const Size(165, 49),
              backgroundColor: const Color(0xFF4E73DF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return _AdminCard(
      child: SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadReport,
                child: Text(context.l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReport(RevenueReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(report.summary),
        const SizedBox(height: 20),
        _buildComparisonAndComposition(report.summary, report.range),
        const SizedBox(height: 20),
        _buildTrendSection(report.timeline),
        const SizedBox(height: 20),
        _buildCategorySection(report.categories),
        const SizedBox(height: 20),
        _buildProductSection(report.products),
        const SizedBox(height: 20),
        _buildTimelineTable(report.timeline),
        const SizedBox(height: 20),
        _buildMethodologyNote(),
      ],
    );
  }

  Widget _buildSummaryCards(RevenueSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1180
            ? 4
            : constraints.maxWidth >= 760
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
        final cards = [
          _MetricCard(
            title: context.l10n.totalRevenue,
            value: formatVND(summary.totalRevenue),
            subtitle: context.l10n.afterFeesAndOffers,
            icon: Icons.payments_outlined,
            color: const Color(0xFF4E73DF),
            change: summary.revenueChangePercent,
          ),
          _MetricCard(
            title: context.l10n.deliveredOrders,
            value: _formatNumber(summary.orderCount),
            subtitle: context.l10n.deliveredOrdersOnly,
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF1CC88A),
            change: summary.orderChangePercent,
          ),
          _MetricCard(
            title: context.l10n.productsSold,
            value: _formatNumber(summary.itemCount),
            subtitle: context.l10n.totalItemsInOrders,
            icon: Icons.chair_outlined,
            color: const Color(0xFF36B9CC),
          ),
          _MetricCard(
            title: context.l10n.averageOrderValue,
            value: formatVND(summary.averageOrderValue),
            subtitle: context.l10n.customerCountText(
              _formatNumber(summary.customerCount),
            ),
            icon: Icons.receipt_long_outlined,
            color: const Color(0xFFF6C23E),
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildComparisonAndComposition(
    RevenueSummary summary,
    RevenueRange range,
  ) {
    final comparison = _AdminCard(
      title: context.l10n.comparePreviousPeriod,
      child: Column(
        children: [
          _ComparisonRow(
            label: context.l10n.revenue,
            current: formatVND(summary.totalRevenue),
            previous: formatVND(summary.previousRevenue),
            change: summary.revenueChangePercent,
          ),
          const Divider(height: 28),
          _ComparisonRow(
            label: context.l10n.ordersLabel,
            current: _formatNumber(summary.orderCount),
            previous: _formatNumber(summary.previousOrderCount),
            change: summary.orderChangePercent,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.l10n.previousPeriodRange(
                _formatDate(range.previousFrom),
                _formatDate(range.previousTo),
              ),
              style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
            ),
          ),
        ],
      ),
    );

    final composition = _AdminCard(
      title: context.l10n.revenueComposition,
      child: Column(
        children: [
          _ValueRow(
            label: context.l10n.merchandiseBeforeOffers,
            value: formatVND(summary.merchandiseRevenue),
          ),
          _ValueRow(
            label: context.l10n.shippingFee,
            value: formatVND(summary.shippingRevenue),
          ),
          _ValueRow(
            label: context.l10n.assemblyFee,
            value: formatVND(summary.assemblyRevenue),
          ),
          _ValueRow(
            label: context.l10n.estimatedDiscount,
            value: '-${formatVND(summary.estimatedDiscount)}',
            valueColor: Colors.redAccent,
          ),
          const Divider(height: 24),
          _ValueRow(
            label: context.l10n.recognizedRevenue,
            value: formatVND(summary.totalRevenue),
            bold: true,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.l10n.voucherOrderCountText(
                _formatNumber(summary.voucherOrderCount),
              ),
              style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [comparison, const SizedBox(height: 16), composition],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: comparison),
            const SizedBox(width: 16),
            Expanded(child: composition),
          ],
        );
      },
    );
  }

  Widget _buildTrendSection(List<RevenueTimelinePoint> points) {
    return _AdminCard(
      title: context.l10n.revenueOrderTrend,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Legend(color: const Color(0xFF4E73DF), label: context.l10n.revenue),
          const SizedBox(width: 16),
          _Legend(
            color: const Color(0xFF1CC88A),
            label: context.l10n.ordersLabel,
          ),
        ],
      ),
      child: points.isEmpty
          ? _EmptyReport(message: context.l10n.noTimelineData)
          : SizedBox(
              height: 310,
              width: double.infinity,
              child: CustomPaint(
                painter: _RevenueChartPainter(
                  points: points,
                  groupBy: _groupBy,
                ),
              ),
            ),
    );
  }

  Widget _buildCategorySection(List<CategoryRevenueItem> categories) {
    return _AdminCard(
      title: context.l10n.revenueByCategory,
      subtitle: context.l10n.revenueCategoryCount(categories.length),
      child: categories.isEmpty
          ? _EmptyReport(message: context.l10n.noCategoryRevenue)
          : Column(
              children: [
                ...categories
                    .take(6)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.categoryName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  formatVND(item.revenue),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    '${item.sharePercent.toStringAsFixed(1)}%',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Color(0xFF718096),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            LinearProgressIndicator(
                              value: (item.sharePercent / 100).clamp(0, 1),
                              minHeight: 7,
                              borderRadius: BorderRadius.circular(8),
                              backgroundColor: const Color(0xFFE9ECEF),
                              color: const Color(0xFF4E73DF),
                            ),
                          ],
                        ),
                      ),
                    ),
                const Divider(height: 28),
                _horizontalTable(
                  DataTable(
                    columns: [
                      const DataColumn(label: Text('#')),
                      DataColumn(label: Text(context.l10n.category)),
                      DataColumn(
                        label: Text(context.l10n.productsTab),
                        numeric: true,
                      ),
                      DataColumn(label: Text(context.l10n.sold), numeric: true),
                      DataColumn(
                        label: Text(context.l10n.ordersLabel),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(context.l10n.revenue),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(context.l10n.share),
                        numeric: true,
                      ),
                    ],
                    rows: categories.asMap().entries.map((entry) {
                      final item = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text('${entry.key + 1}')),
                          DataCell(Text(item.categoryName)),
                          DataCell(Text(_formatNumber(item.productCount))),
                          DataCell(Text(_formatNumber(item.quantitySold))),
                          DataCell(Text(_formatNumber(item.orderCount))),
                          DataCell(Text(formatVND(item.revenue))),
                          DataCell(
                            Text('${item.sharePercent.toStringAsFixed(2)}%'),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProductSection(List<ProductRevenueItem> products) {
    final query = _productSearchController.text.trim().toLowerCase();
    final visible = products.where((item) {
      if (query.isEmpty) return true;
      return item.productName.toLowerCase().contains(query) ||
          item.productCode.toLowerCase().contains(query) ||
          item.categoryName.toLowerCase().contains(query);
    }).toList();

    int compare(ProductRevenueItem a, ProductRevenueItem b) {
      final result = switch (_productSortColumn) {
        1 => a.productName.compareTo(b.productName),
        2 => a.categoryName.compareTo(b.categoryName),
        3 => a.quantitySold.compareTo(b.quantitySold),
        4 => a.orderCount.compareTo(b.orderCount),
        5 => a.averageSellingPrice.compareTo(b.averageSellingPrice),
        7 => a.sharePercent.compareTo(b.sharePercent),
        _ => a.revenue.compareTo(b.revenue),
      };
      return _productSortAscending ? result : -result;
    }

    visible.sort(compare);

    return _AdminCard(
      title: context.l10n.revenueByProduct,
      subtitle: context.l10n.revenueProductCount(products.length),
      trailing: SizedBox(
        width: 280,
        child: TextField(
          controller: _productSearchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: context.l10n.searchRevenueProductHint,
            prefixIcon: const Icon(Icons.search, size: 20),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ),
      child: visible.isEmpty
          ? _EmptyReport(message: context.l10n.noMatchingRevenueProducts)
          : _horizontalTable(
              DataTable(
                sortColumnIndex: _productSortColumn,
                sortAscending: _productSortAscending,
                columns: [
                  const DataColumn(label: Text('#')),
                  DataColumn(
                    label: Text(context.l10n.productsTab),
                    onSort: (column, ascending) =>
                        _sortProducts(column, ascending),
                  ),
                  DataColumn(
                    label: Text(context.l10n.category),
                    onSort: (column, ascending) =>
                        _sortProducts(column, ascending),
                  ),
                  DataColumn(
                    label: Text(context.l10n.sold),
                    numeric: true,
                    onSort: (column, ascending) =>
                        _sortProducts(column, ascending),
                  ),
                  DataColumn(
                    label: Text(context.l10n.ordersLabel),
                    numeric: true,
                    onSort: (column, ascending) =>
                        _sortProducts(column, ascending),
                  ),
                  DataColumn(
                    label: Text(context.l10n.averageSellingPrice),
                    numeric: true,
                    onSort: (column, ascending) =>
                        _sortProducts(column, ascending),
                  ),
                  DataColumn(
                    label: Text(context.l10n.revenue),
                    numeric: true,
                    onSort: (column, ascending) =>
                        _sortProducts(column, ascending),
                  ),
                  DataColumn(
                    label: Text(context.l10n.share),
                    numeric: true,
                    onSort: (column, ascending) =>
                        _sortProducts(column, ascending),
                  ),
                ],
                rows: visible.asMap().entries.map((entry) {
                  final item = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('${entry.key + 1}')),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (item.productCode.isNotEmpty)
                                Text(
                                  item.productCode,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF718096),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(item.categoryName)),
                      DataCell(Text(_formatNumber(item.quantitySold))),
                      DataCell(Text(_formatNumber(item.orderCount))),
                      DataCell(Text(formatVND(item.averageSellingPrice))),
                      DataCell(
                        Text(
                          formatVND(item.revenue),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataCell(
                        Text('${item.sharePercent.toStringAsFixed(2)}%'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  void _sortProducts(int column, bool ascending) {
    setState(() {
      _productSortColumn = column;
      _productSortAscending = ascending;
    });
  }

  Widget _buildTimelineTable(List<RevenueTimelinePoint> timeline) {
    return _AdminCard(
      title: context.l10n.detailByGroup(_groupLabel(_groupBy).toLowerCase()),
      subtitle: context.l10n.periodCountText(timeline.length),
      child: _horizontalTable(
        DataTable(
          columns: [
            DataColumn(label: Text(context.l10n.reportingPeriod)),
            DataColumn(label: Text(context.l10n.ordersLabel), numeric: true),
            DataColumn(label: Text(context.l10n.productsTab), numeric: true),
            DataColumn(
              label: Text(context.l10n.averageOrderValue),
              numeric: true,
            ),
            DataColumn(label: Text(context.l10n.revenue), numeric: true),
          ],
          rows: timeline.reversed.map((point) {
            return DataRow(
              cells: [
                DataCell(Text(_periodLabel(point.periodStart, _groupBy))),
                DataCell(Text(_formatNumber(point.orderCount))),
                DataCell(Text(_formatNumber(point.itemCount))),
                DataCell(Text(formatVND(point.averageOrderValue))),
                DataCell(
                  Text(
                    formatVND(point.revenue),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMethodologyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.revenueMethodology,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E3A5F),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalTable(DataTable table) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: table,
      ),
    );
  }

  String _periodLabel(DateTime value, String groupBy) {
    return switch (groupBy) {
      'day' => _formatDate(value),
      'month' => context.l10n.monthYear(
        value.month.toString().padLeft(2, '0'),
        value.year,
      ),
      _ => context.l10n.yearValue(value.year),
    };
  }

  String _groupLabel(String groupBy) {
    return switch (groupBy) {
      'day' => context.l10n.byDay,
      'month' => context.l10n.byMonth,
      _ => context.l10n.byYear,
    };
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  const Spacer(),
                ?trailing,
              ],
            ),
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.change,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? change;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 9),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (change != null) ...[
                      _ChangeBadge(value: change!),
                      const SizedBox(width: 7),
                    ],
                    Flexible(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withAlpha(24),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 25),
          ),
        ],
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final color = positive ? const Color(0xFF138A5B) : const Color(0xFFC53030);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${positive ? '+' : ''}${value.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.change,
  });

  final String label;
  final String current;
  final String previous;
  final double change;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
              ),
              const SizedBox(height: 5),
              Text(
                current,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ChangeBadge(value: change),
            const SizedBox(height: 5),
            Text(
              context.l10n.previousPeriodValue(previous),
              style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
                color: const Color(0xFF4A5568),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? const Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
        ),
      ],
    );
  }
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(message, style: const TextStyle(color: Color(0xFF718096))),
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  const _RevenueChartPainter({required this.points, required this.groupBy});

  final List<RevenueTimelinePoint> points;
  final String groupBy;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const left = 58.0;
    const top = 16.0;
    const bottom = 42.0;
    const right = 14.0;
    final plotWidth = math.max(1.0, size.width - left - right);
    final plotHeight = math.max(1.0, size.height - top - bottom);
    final maxRevenue = math.max(
      1.0,
      points.map((point) => point.revenue).reduce(math.max),
    );
    final maxOrders = math.max(
      1,
      points.map((point) => point.orderCount).reduce(math.max),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    final labelStyle = const TextStyle(fontSize: 10, color: Color(0xFF718096));
    for (var i = 0; i <= 4; i++) {
      final y = top + plotHeight * i / 4;
      canvas.drawLine(Offset(left, y), Offset(left + plotWidth, y), gridPaint);
      final value = maxRevenue * (4 - i) / 4;
      _drawText(canvas, _compactMoney(value), Offset(0, y - 7), labelStyle, 52);
    }

    final slot = plotWidth / points.length;
    final barWidth = math.min(30.0, math.max(3.0, slot * 0.55));
    final barPaint = Paint()..color = const Color(0xFF4E73DF).withAlpha(205);
    final linePaint = Paint()
      ..color = const Color(0xFF1CC88A)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = const Color(0xFF1CC88A);
    final orderPath = Path();
    final labelStep = math.max(1, (points.length / 8).ceil());

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = left + slot * (i + 0.5);
      final barHeight = plotHeight * point.revenue / maxRevenue;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - barWidth / 2,
            top + plotHeight - barHeight,
            barWidth,
            barHeight,
          ),
          const Radius.circular(3),
        ),
        barPaint,
      );
      final orderY = top + plotHeight * (1 - point.orderCount / maxOrders);
      if (i == 0) {
        orderPath.moveTo(x, orderY);
      } else {
        orderPath.lineTo(x, orderY);
      }
      canvas.drawCircle(Offset(x, orderY), 3.2, dotPaint);

      if (i % labelStep == 0 || i == points.length - 1) {
        _drawText(
          canvas,
          _shortPeriodLabel(point.periodStart, groupBy),
          Offset(x - slot / 2, top + plotHeight + 11),
          labelStyle,
          slot * labelStep,
          align: TextAlign.center,
        );
      }
    }
    canvas.drawPath(orderPath, linePaint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
    double width, {
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
    )..layout(maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.groupBy != groupBy;
  }
}

String _formatDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}

String _shortPeriodLabel(DateTime value, String groupBy) {
  return switch (groupBy) {
    'day' => '${value.day}/${value.month}',
    'month' => 'M${value.month}/${value.year.toString().substring(2)}',
    _ => '${value.year}',
  };
}

String _compactMoney(double value) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(0)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
  return value.toStringAsFixed(0);
}

String _formatNumber(num value) {
  final digits = value.toInt().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
