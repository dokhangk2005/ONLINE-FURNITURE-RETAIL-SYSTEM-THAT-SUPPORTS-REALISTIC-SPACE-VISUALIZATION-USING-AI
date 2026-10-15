import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../model/order.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/delivery_realtime_service.dart';
import '../../widgets/currency_formatter.dart';
import '../../widgets/language_switcher.dart';
import 'delivery_detail_page.dart';

class ShipperHomePage extends StatefulWidget {
  const ShipperHomePage({super.key});

  @override
  State<ShipperHomePage> createState() => _ShipperHomePageState();
}

class _ShipperHomePageState extends State<ShipperHomePage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isUpdatingAvailability = false;
  String _shiftStatus = 'Offline';
  Map<String, dynamic> _shipperProfile = {};
  Map<String, dynamic> _reconciliation = {};
  Map<String, dynamic> _performance = {};
  String _reconciliationPeriod = 'day';
  String _performancePeriod = 'day';
  bool _isFinanceAction = false;
  final DeliveryRealtimeService _realtime = DeliveryRealtimeService.instance;
  StreamSubscription<DeliveryRealtimeEvent>? _deliverySubscription;
  Timer? _realtimeRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _realtime.initialize();
    _deliverySubscription = _realtime.events.listen(_onDeliveryUpdated);
    _loadOrders();
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    final user = AuthService.currentUser.value;
    if (user == null) {
      setState(() {
        _errorMessage = context.l10n.sessionExpired;
        _isLoading = false;
      });
      return;
    }

    final int shipperId = (user['userId'] ?? user['UserId'] ?? 0) as int;
    try {
      final results = await Future.wait([
        _apiService.fetchShipperOrders(shipperId),
        _apiService.fetchShipperProfile(),
        _apiService.fetchShipperReconciliation(period: _reconciliationPeriod),
        _apiService.fetchShipperPerformance(period: _performancePeriod),
      ]);
      final orders = results[0] as List<OrderModel>;
      final profile = results[1] as Map<String, dynamic>;
      final reconciliation = results[2] as Map<String, dynamic>;
      final performance = results[3] as Map<String, dynamic>;
      setState(() {
        _allOrders = orders;
        _shiftStatus = (profile['deliveryShiftStatus'] ?? 'Offline').toString();
        _shipperProfile = profile;
        _reconciliation = reconciliation;
        _performance = performance;
      });
    } catch (e) {
      setState(() {
        _errorMessage = context.l10n.deliveryListLoadError(e.toString());
      });
    } finally {
      if (mounted && showLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onDeliveryUpdated(DeliveryRealtimeEvent event) {
    if (!mounted) return;
    final currentRoute = ModalRoute.of(context);
    final shouldNotify =
        (currentRoute == null || currentRoute.isCurrent) &&
        event.orderStatus.toLowerCase() == 'assigned';
    if (shouldNotify && event.message.isNotEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(event.message),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: context.l10n.refresh,
            onPressed: _loadOrders,
          ),
        ),
      );
    }
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = Timer(
      const Duration(milliseconds: 100),
      () => unawaited(_loadOrders(showLoading: false)),
    );
  }

  Future<void> _setShift(String status) async {
    if (_isUpdatingAvailability || status == _shiftStatus) return;
    setState(() => _isUpdatingAvailability = true);
    try {
      final result = await _apiService.updateShipperShift(
        status,
        breakUntil: status == 'Break'
            ? DateTime.now().add(const Duration(minutes: 30)).toIso8601String()
            : null,
      );
      if (!mounted) return;
      setState(() {
        _shiftStatus = (result['deliveryShiftStatus'] ?? status).toString();
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingAvailability = false);
    }
  }

  Future<void> _showShipperProfile() async {
    final vehicle = TextEditingController(
      text: (_shipperProfile['deliveryVehicleType'] ?? '').toString(),
    );
    final plate = TextEditingController(
      text: (_shipperProfile['deliveryVehiclePlate'] ?? '').toString(),
    );
    final area = TextEditingController(
      text: (_shipperProfile['deliveryServiceArea'] ?? '').toString(),
    );
    final maxOrders = TextEditingController(
      text: (_shipperProfile['maxConcurrentDeliveries'] ?? 3).toString(),
    );
    var bulky = _shipperProfile['canHandleBulkyItems'] == true;
    var assembly = _shipperProfile['canProvideAssembly'] == true;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.shipperProfileTitle),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: vehicle,
                    decoration: InputDecoration(
                      labelText: context.l10n.vehicleType,
                    ),
                  ),
                  TextField(
                    controller: plate,
                    decoration: InputDecoration(
                      labelText: context.l10n.vehiclePlate,
                    ),
                  ),
                  TextField(
                    controller: area,
                    decoration: InputDecoration(
                      labelText: context.l10n.serviceArea,
                    ),
                  ),
                  TextField(
                    controller: maxOrders,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.maxConcurrentDeliveries,
                    ),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.canHandleBulkyItems),
                    value: bulky,
                    onChanged: (value) =>
                        setDialogState(() => bulky = value ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.canProvideAssembly),
                    value: assembly,
                    onChanged: (value) =>
                        setDialogState(() => assembly = value ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await _apiService.updateShipperProfile({
                    'vehicleType': vehicle.text.trim(),
                    'vehiclePlate': plate.text.trim(),
                    'serviceArea': area.text.trim(),
                    'canHandleBulkyItems': bulky,
                    'canProvideAssembly': assembly,
                    'maxConcurrentDeliveries':
                        int.tryParse(maxOrders.text) ?? 3,
                  });
                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                } catch (error) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text('$error')));
                  }
                }
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
    vehicle.dispose();
    plate.dispose();
    area.dispose();
    maxOrders.dispose();
    if (saved == true) await _loadOrders();
  }

  Future<void> _logout() async {
    try {
      await _apiService.updateShipperAvailability(false);
    } catch (_) {
      // Vẫn cho phép đăng xuất nếu máy chủ tạm thời không phản hồi.
    }
    if (!mounted) return;
    AuthService.logout();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  void dispose() {
    _deliverySubscription?.cancel();
    _realtimeRefreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser.value;
    final String shipperName = user != null
        ? (user['fullName'] ?? user['FullName'] ?? 'Shipper')
        : 'Shipper';

    final activeOrders = _allOrders
        .where(
          (o) =>
              o.orderStatus.toLowerCase() != 'delivered' &&
              o.orderStatus.toLowerCase() != 'cancelled',
        )
        .toList();
    final completedOrders = _allOrders.where((o) {
      final status = o.orderStatus.toLowerCase();
      return status == 'delivered' || status == 'cancelled';
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.shipperPortalTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              context.l10n.employeeName(shipperName),
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: LanguageSwitcher(
              color: Colors.white,
              height: 40,
              horizontalPadding: 6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    const [
                      'Offline',
                      'Available',
                      'Delivering',
                      'Break',
                    ].contains(_shiftStatus)
                    ? _shiftStatus
                    : 'Offline',
                dropdownColor: Colors.brown[700],
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                onChanged: _isUpdatingAvailability
                    ? null
                    : (value) {
                        if (value != null) _setShift(value);
                      },
                items: [
                  DropdownMenuItem(
                    value: 'Offline',
                    child: Text(context.l10n.shiftEnd),
                  ),
                  DropdownMenuItem(
                    value: 'Available',
                    child: Text(context.l10n.shiftAvailable),
                  ),
                  DropdownMenuItem(
                    value: 'Delivering',
                    child: Text(context.l10n.shiftDelivering),
                  ),
                  DropdownMenuItem(
                    value: 'Break',
                    child: Text(context.l10n.shiftBreak),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.badge_outlined),
            tooltip: context.l10n.shipperProfileTitle,
            onPressed: _showShipperProfile,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.refreshList,
            onPressed: _loadOrders,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.logout,
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: const Icon(Icons.local_shipping),
              text: context.l10n.activeDeliveriesCount(activeOrders.length),
            ),
            Tab(
              icon: const Icon(Icons.task_alt),
              text: context.l10n.deliveryHistoryCount(completedOrders.length),
            ),
            Tab(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              text: context.l10n.reconciliationTab,
            ),
            Tab(
              icon: const Icon(Icons.insights_outlined),
              text: context.l10n.performanceTab,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadOrders,
                      child: Text(context.l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(activeOrders, isActive: true),
                _buildOrderList(completedOrders, isActive: false),
                _buildReconciliationTab(),
                _buildPerformanceTab(),
              ],
            ),
    );
  }

  Future<void> _changeReconciliationPeriod(String value) async {
    if (value == _reconciliationPeriod) return;
    setState(() => _reconciliationPeriod = value);
    try {
      final data = await _apiService.fetchShipperReconciliation(period: value);
      if (mounted) setState(() => _reconciliation = data);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _changePerformancePeriod(String value) async {
    if (value == _performancePeriod) return;
    setState(() => _performancePeriod = value);
    try {
      final data = await _apiService.fetchShipperPerformance(period: value);
      if (mounted) setState(() => _performance = data);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitReconciliation() async {
    if (_isFinanceAction) return;
    final paymentIds = ((_reconciliation['entries'] as List?) ?? const [])
        .whereType<Map>()
        .where((entry) {
          final status = '${entry['handoverStatus']}'.toLowerCase();
          return status == 'pending' || status == 'rejected';
        })
        .map((entry) => int.tryParse('${entry['paymentId']}'))
        .whereType<int>()
        .toList();
    if (paymentIds.isEmpty) return;
    setState(() => _isFinanceAction = true);
    try {
      await _apiService.submitShipperReconciliation(paymentIds: paymentIds);
      final data = await _apiService.fetchShipperReconciliation(
        period: _reconciliationPeriod,
      );
      if (!mounted) return;
      setState(() => _reconciliation = data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.reconciliationSubmittedSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isFinanceAction = false);
    }
  }

  Widget _periodSelector(String value, ValueChanged<String> onChanged) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'day', label: Text(context.l10n.byDay)),
        ButtonSegment(value: 'week', label: Text(context.l10n.byWeek)),
        ButtonSegment(value: 'month', label: Text(context.l10n.byMonth)),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }

  Widget _financeMetric(String label, num value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              formatVND(value.toDouble()),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconciliationTab() {
    final entries = (_reconciliation['entries'] as List?) ?? const [];
    final pendingCount =
        (_reconciliation['pendingCount'] as num?)?.toInt() ?? 0;
    return RefreshIndicator(
      onRefresh: () async {
        final data = await _apiService.fetchShipperReconciliation(
          period: _reconciliationPeriod,
        );
        if (mounted) setState(() => _reconciliation = data);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.collectionReconciliationTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _periodSelector(
                _reconciliationPeriod,
                (value) => unawaited(_changeReconciliationPeriod(value)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _financeMetric(
                context.l10n.totalCollected,
                (_reconciliation['collectedAmount'] as num?) ?? 0,
                Colors.blue,
              ),
              const SizedBox(width: 10),
              _financeMetric(
                context.l10n.pendingHandover,
                (_reconciliation['pendingAmount'] as num?) ?? 0,
                Colors.orange,
              ),
              const SizedBox(width: 10),
              _financeMetric(
                context.l10n.confirmedHandover,
                (_reconciliation['confirmedAmount'] as num?) ?? 0,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (pendingCount > 0)
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isFinanceAction ? null : _submitReconciliation,
                icon: const Icon(Icons.account_balance_outlined),
                label: Text(context.l10n.submitMoneyHandover(pendingCount)),
              ),
            ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text(context.l10n.noCollectedPayments)),
            )
          else
            ...entries.map((raw) {
              final entry = Map<String, dynamic>.from(raw as Map);
              final status = (entry['handoverStatus'] ?? '').toString();
              final color = switch (status.toLowerCase()) {
                'confirmed' => Colors.green,
                'submitted' => Colors.blue,
                'rejected' => Colors.red,
                _ => Colors.orange,
              };
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(Icons.payments_outlined, color: color),
                  ),
                  title: Text(
                    '${entry['orderCode'] ?? '#${entry['orderId']}'} · ${formatVND(((entry['amount'] as num?) ?? 0).toDouble())}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${entry['paymentMethod'] ?? ''} · ${_handoverLabel(status)}',
                  ),
                  trailing: Text(
                    _shortDate(entry['collectedAt']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _handoverLabel(String status) => switch (status.toLowerCase()) {
    'submitted' => context.l10n.handoverSubmitted,
    'confirmed' => context.l10n.handoverConfirmed,
    'rejected' => context.l10n.handoverRejected,
    _ => context.l10n.handoverPending,
  };

  String _shortDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return '';
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)} ${two(date.hour)}:${two(date.minute)}';
  }

  Widget _performanceMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 190,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final trend = (_performance['trend'] as List?) ?? const [];
    return RefreshIndicator(
      onRefresh: () async {
        final data = await _apiService.fetchShipperPerformance(
          period: _performancePeriod,
        );
        if (mounted) setState(() => _performance = data);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.personalPerformanceTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _periodSelector(
                _performancePeriod,
                (value) => unawaited(_changePerformancePeriod(value)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _performanceMetric(
                context.l10n.activeOrdersMetric,
                '${_performance['activeOrders'] ?? 0}',
                Icons.local_shipping_outlined,
                Colors.blue,
              ),
              _performanceMetric(
                context.l10n.completedOrdersMetric,
                '${_performance['completedOrders'] ?? 0}',
                Icons.task_alt,
                Colors.green,
              ),
              _performanceMetric(
                context.l10n.failedDeliveriesMetric,
                '${_performance['failedDeliveries'] ?? 0}',
                Icons.warning_amber_rounded,
                Colors.red,
              ),
              _performanceMetric(
                context.l10n.totalDistanceMetric,
                '${_performance['totalDistanceKm'] ?? 0} km',
                Icons.route_outlined,
                Colors.purple,
              ),
              _performanceMetric(
                context.l10n.onTimeRateMetric,
                '${_performance['onTimeRate'] ?? 0}%',
                Icons.schedule,
                Colors.teal,
              ),
              _performanceMetric(
                context.l10n.rescheduleCountMetric,
                '${_performance['rescheduleCount'] ?? 0}',
                Icons.event_repeat_outlined,
                Colors.orange,
              ),
              _performanceMetric(
                context.l10n.averageDeliveryTimeMetric,
                context.l10n.minuteCount(
                  ((_performance['averageDeliveryMinutes'] as num?) ?? 0)
                      .round(),
                ),
                Icons.timer_outlined,
                Colors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.performanceTrend,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (trend.isEmpty)
            Text(context.l10n.noPerformanceData)
          else
            ...trend.map((raw) {
              final point = Map<String, dynamic>.from(raw as Map);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(_shortDate(point['date']).split(' ').first),
                subtitle: Text(
                  context.l10n.performanceTrendSummary(
                    (point['completedOrders'] as num?)?.toInt() ?? 0,
                    (point['failedAttempts'] as num?)?.toInt() ?? 0,
                    ((point['distanceKm'] as num?) ?? 0).toDouble(),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.inbox : Icons.done_all,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? context.l10n.noPendingDeliveries
                  : context.l10n.noCompletedDeliveries,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DeliveryDetailPage(
                      order: order,
                      onStatusUpdated: _loadOrders,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.deliveryNoteCode(order.orderCode),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                          ),
                        ),
                        (() {
                          final normalizedStatus = order.orderStatus
                              .toLowerCase();
                          Color containerColor = normalizedStatus == 'cancelled'
                              ? Colors.red[100]!
                              : normalizedStatus == 'rescheduled'
                              ? Colors.amber[200]!
                              : (isActive
                                    ? Colors.orange[100]!
                                    : Colors.green[100]!);
                          Color textColor = normalizedStatus == 'cancelled'
                              ? Colors.red[900]!
                              : normalizedStatus == 'rescheduled'
                              ? Colors.red[900]!
                              : (isActive
                                    ? Colors.orange[900]!
                                    : Colors.green[900]!);
                          final statusText = switch (order.orderStatus
                              .toLowerCase()) {
                            'assigned' => context.l10n.deliveryStatusAssigned,
                            'accepted' => context.l10n.deliveryStatusAccepted,
                            'pickedup' => context.l10n.deliveryStatusPickedUp,
                            'shipping' => context.l10n.deliveryStatusShipping,
                            'arrived' => context.l10n.deliveryStatusArrived,
                            'rescheduled' => context.l10n.rescheduledAttempt(
                              order.deliveryAttemptCount,
                            ),
                            'cancelled' => context.l10n.cancelled,
                            _ =>
                              isActive
                                  ? context.l10n.deliveringStatus
                                  : context.l10n.successfulStatus,
                          };
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        })(),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_pin,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${order.userFullName} (${order.userPhone.isEmpty ? "No Phone" : order.userPhone})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.shippingAddress,
                            style: const TextStyle(color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (order.deliveryNotes != null &&
                        order.deliveryNotes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber[300]!),
                        ),
                        child: Text(
                          context.l10n.noteText(order.deliveryNotes!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown[900],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (order.deliveryTimeSlot != null ||
                        order.includesAssembly) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (order.deliveryTimeSlot != null) ...[
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.amber[800],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.deliveryTimeSlot!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[900],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (order.includesAssembly) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue[300]!),
                              ),
                              child: Text(
                                context.l10n.includesAssemblyBadge,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.totalCollection(
                            formatVND(order.totalAmount),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              context.l10n.viewDetails,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
