import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/currency_formatter.dart';

class AdminDeliveryPage extends StatefulWidget {
  const AdminDeliveryPage({super.key});

  @override
  State<AdminDeliveryPage> createState() => _AdminDeliveryPageState();
}

class _AdminDeliveryPageState extends State<AdminDeliveryPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> _stats = {};
  List<dynamic> _shippers = [];
  List<dynamic> _orders = [];
  List<dynamic> _reconciliations = [];
  List<dynamic> _shipperPerformance = [];
  bool _isReconciliationAction = false;

  late TabController _tabController;

  String _localizedSlot(String value) {
    if (value.contains('13') || value.contains('Chiều')) {
      return context.l10n.afternoonSlot;
    }
    if (value.contains('18') || value.contains('Tối')) {
      return context.l10n.eveningSlot;
    }
    return context.l10n.morningSlot;
  }

  String _localizedShipperStatus(String value, bool available) {
    if (value.isEmpty || value == 'Sẵn sàng' || value == 'Không sẵn sàng') {
      return available ? context.l10n.available : context.l10n.unavailable;
    }
    return value;
  }

  Map<String, dynamic> _performanceFor(int shipperId) {
    for (final raw in _shipperPerformance) {
      final item = Map<String, dynamic>.from(raw as Map);
      if ((item['userId'] as num?)?.toInt() == shipperId) {
        return Map<String, dynamic>.from((item['performance'] as Map?) ?? {});
      }
    }
    return const {};
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _apiService.fetchDeliveryAdminOverview(),
        _apiService.fetchAdminReconciliations(),
        _apiService.fetchAdminShipperPerformance(period: 'week'),
      ]);
      final data = results[0] as Map<String, dynamic>;
      setState(() {
        _stats = data['stats'] ?? {};
        _shippers = data['shippers'] ?? [];
        _orders = data['orders'] ?? [];
        _reconciliations = results[1] as List<dynamic>;
        _shipperPerformance = results[2] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              context.l10n.deliveryDispatchLoadError(_error!),
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      );
    }

    // Filter orders by tab logic
    final morningOrders = _orders.where((o) {
      final slot = (o['deliveryTimeSlot'] ?? '').toString().toLowerCase();
      return slot.contains('08') || slot.contains('sáng') || slot.isEmpty;
    }).toList();

    final afternoonOrders = _orders.where((o) {
      final slot = (o['deliveryTimeSlot'] ?? '').toString().toLowerCase();
      return slot.contains('13') || slot.contains('chiều');
    }).toList();

    final eveningOrders = _orders.where((o) {
      final slot = (o['deliveryTimeSlot'] ?? '').toString().toLowerCase();
      return slot.contains('18') || slot.contains('tối');
    }).toList();

    final alertOrders = _orders.where((o) {
      final status = (o['orderStatus'] ?? '').toString().toLowerCase();
      final attempts = o['deliveryAttemptCount'] ?? 0;
      final notes = (o['deliveryNotes'] ?? '').toString();
      return status == 'rescheduled' ||
          status == 'cancelled' ||
          attempts > 1 ||
          notes.isNotEmpty;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.deliveryControlCenter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.deliveryControlDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.refreshMetrics),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E73DF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 1: Logistics Analytics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context.l10n.activeDispatchOrders,
                  context.l10n.orderCount(_stats['activeDeliveryCount'] ?? 0),
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  context.l10n.totalDistance,
                  '${_stats['totalDistanceKm'] ?? 0} km',
                  Icons.map,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  context.l10n.collectedShippingFees,
                  formatVND((_stats['totalShippingFees'] ?? 0).toDouble()),
                  Icons.monetization_on,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  context.l10n.earnedAssemblyFees,
                  formatVND((_stats['totalAssemblyFees'] ?? 0).toDouble()),
                  Icons.handyman,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Section 2: Shipper Workload Monitor
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.engineering,
                      color: Color(0xFF4E73DF),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.teamWorkloadMonitoring,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.teamWorkloadDescription,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const Divider(height: 24),
                _shippers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(context.l10n.noShippers),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _shippers.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final shipper = _shippers[index];
                          final String status = shipper['status'] ?? '';
                          final bool isAvailable =
                              shipper['isAvailableForDelivery'] == true;
                          final performance = _performanceFor(
                            (shipper['userId'] as num?)?.toInt() ?? 0,
                          );
                          final Color statusColor = isAvailable
                              ? Colors.green
                              : Colors.grey;

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: statusColor.withOpacity(0.15),
                                child: Icon(Icons.person, color: statusColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shipper['fullName'] ?? 'Shipper',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      context.l10n.phoneSummary(
                                        shipper['phone']?.toString().isEmpty !=
                                                false
                                            ? context.l10n.unknown
                                            : shipper['phone'].toString(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _buildInfoBadge(
                                      context.l10n.activeDeliverySummary(
                                        shipper['activeOrdersCount'],
                                      ),
                                      Colors.blue,
                                    ),
                                    _buildInfoBadge(
                                      context.l10n.completedDeliverySummary(
                                        shipper['completedOrdersCount'],
                                      ),
                                      Colors.green,
                                    ),
                                    _buildInfoBadge(
                                      context.l10n.adminOnTimeRate(
                                        ((performance['onTimeRate'] as num?) ??
                                                0)
                                            .toDouble(),
                                      ),
                                      Colors.teal,
                                    ),
                                    _buildInfoBadge(
                                      context.l10n.adminFailedAttempts(
                                        (performance['failedDeliveries']
                                                    as num?)
                                                ?.toInt() ??
                                            0,
                                      ),
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _localizedShipperStatus(
                                        status,
                                        isAvailable,
                                      ).toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildAdminReconciliationSection(),
          const SizedBox(height: 32),

          // Section 3: Time-Slot Scheduling & Alert Center
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.deliveryScheduleTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.deliveryScheduleDescription,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  color: Colors.grey[50],
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF4E73DF),
                    unselectedLabelColor: Colors.grey[700],
                    indicatorColor: const Color(0xFF4E73DF),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        text: context.l10n.morningShift(morningOrders.length),
                      ),
                      Tab(
                        text: context.l10n.afternoonShift(
                          afternoonOrders.length,
                        ),
                      ),
                      Tab(
                        text: context.l10n.eveningShift(eveningOrders.length),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.issuesReschedule(alertOrders.length),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersTable(morningOrders),
                      _buildOrdersTable(afternoonOrders),
                      _buildOrdersTable(eveningOrders),
                      _buildOrdersTable(alertOrders, isAlertView: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminReconciliationSection() {
    final submitted = _reconciliations.where(
      (entry) =>
          (entry['handoverStatus'] ?? '').toString().toLowerCase() ==
          'submitted',
    );
    final submittedAmount = submitted.fold<double>(
      0,
      (sum, entry) => sum + ((entry['amount'] as num?) ?? 0).toDouble(),
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                color: Color(0xFF4E73DF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.adminReconciliationTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  context.l10n.waitingHandoverSummary(
                    submitted.length,
                    formatVND(submittedAmount),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.adminReconciliationDescription,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const Divider(height: 24),
          if (_reconciliations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Text(context.l10n.noReconciliationEntries)),
            )
          else
            ..._reconciliations.map((raw) {
              final entry = Map<String, dynamic>.from(raw as Map);
              final status = (entry['handoverStatus'] ?? '').toString();
              final isSubmitted = status.toLowerCase() == 'submitted';
              final color = switch (status.toLowerCase()) {
                'confirmed' => Colors.green,
                'submitted' => Colors.blue,
                'rejected' => Colors.red,
                _ => Colors.orange,
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payments_outlined, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry['orderCode'] ?? '#${entry['orderId']}'} · ${entry['shipperName'] ?? 'Shipper'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${entry['paymentMethod'] ?? ''} · ${formatVND(((entry['amount'] as num?) ?? 0).toDouble())}',
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(_adminHandoverLabel(status)),
                        labelStyle: TextStyle(color: color),
                        backgroundColor: color.withValues(alpha: 0.08),
                      ),
                      const SizedBox(width: 8),
                      if ((entry['collectionProofImage'] ?? '')
                          .toString()
                          .isNotEmpty)
                        IconButton(
                          tooltip: context.l10n.paymentProof,
                          onPressed: () => _showProofImageDialog(
                            entry['collectionProofImage'].toString(),
                          ),
                          icon: const Icon(Icons.image_outlined),
                        ),
                      if (isSubmitted) ...[
                        OutlinedButton(
                          onPressed: _isReconciliationAction
                              ? null
                              : () => _decideReconciliation(entry, false),
                          child: Text(context.l10n.reject),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _isReconciliationAction
                              ? null
                              : () => _decideReconciliation(entry, true),
                          icon: const Icon(Icons.check),
                          label: Text(context.l10n.confirmHandover),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _adminHandoverLabel(String status) => switch (status.toLowerCase()) {
    'submitted' => context.l10n.handoverSubmitted,
    'confirmed' => context.l10n.handoverConfirmed,
    'rejected' => context.l10n.handoverRejected,
    _ => context.l10n.handoverPending,
  };

  Future<void> _decideReconciliation(
    Map<String, dynamic> entry,
    bool confirm,
  ) async {
    final noteController = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          confirm
              ? context.l10n.confirmMoneyHandoverTitle
              : context.l10n.rejectReconciliationTitle,
        ),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: confirm
                ? context.l10n.reconciliationNoteOptional
                : context.l10n.rejectionReasonRequired,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!confirm && noteController.text.trim().isEmpty) return;
              Navigator.pop(dialogContext, true);
            },
            child: Text(confirm ? context.l10n.confirm : context.l10n.reject),
          ),
        ],
      ),
    );
    final note = noteController.text.trim();
    noteController.dispose();
    if (accepted != true || !mounted) return;
    setState(() => _isReconciliationAction = true);
    try {
      await _apiService.decideAdminReconciliation(
        (entry['paymentId'] as num).toInt(),
        confirm: confirm,
        note: note,
      );
      final data = await _apiService.fetchAdminReconciliations();
      if (!mounted) return;
      setState(() => _reconciliations = data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            confirm
                ? context.l10n.handoverConfirmedSuccess
                : context.l10n.reconciliationRejectedSuccess,
          ),
          backgroundColor: confirm ? Colors.green : Colors.orange,
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isReconciliationAction = false);
    }
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212529),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(icon, size: 36, color: color.withOpacity(0.4)),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOrdersTable(List<dynamic> list, {bool isAlertView = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAlertView ? Icons.check_circle_outline : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              isAlertView
                  ? context.l10n.noDeliveryIssues
                  : context.l10n.noShiftOrders,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final order = list[index];
        final String status = (order['orderStatus'] ?? '').toString();
        final String notes = (order['deliveryNotes'] ?? '').toString();
        final bool includesAssembly = order['includesAssembly'] ?? false;
        final num assemblyFee = order['assemblyFee'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAlertView
                ? Colors.orange.withOpacity(0.03)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAlertView
                  ? Colors.orange.shade200
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.orderCode(
                          (order['orderCode'] ?? order['orderId']).toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusChip(status),
                      if (includesAssembly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            context.l10n.assemblyIncludedBadge(
                              formatVND(assemblyFee.toDouble()),
                            ),
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
                  Row(
                    children: [
                      if (order['deliveryProofImage'] != null &&
                          order['deliveryProofImage']!.toString().isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _showProofImageDialog(
                            order['deliveryProofImage'].toString(),
                          ),
                          icon: const Icon(Icons.image, color: Colors.green),
                          label: Text(
                            context.l10n.acceptanceImage,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (order['deliveryCancellationProofImage'] != null &&
                          order['deliveryCancellationProofImage']
                              .toString()
                              .isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _showProofImageDialog(
                            order['deliveryCancellationProofImage'].toString(),
                          ),
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                          ),
                          label: Text(
                            context.l10n.cancellationProof,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (status.toLowerCase() != 'delivered' &&
                          status.toLowerCase() != 'cancelled')
                        ElevatedButton.icon(
                          onPressed: () => _showRescheduleDialog(order),
                          icon: const Icon(Icons.edit_calendar, size: 18),
                          label: Text(context.l10n.dispatchChangeShift),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E73DF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.customerContactSummary(
                            order['userFullName'].toString(),
                            order['userPhone'].toString(),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.addressSummary(
                            order['shippingAddress'].toString(),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.responsibleShipper,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          order['shipperName'] ?? context.l10n.unassigned,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: order['shipperId'] == null
                                ? Colors.red
                                : Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.distanceSummary(
                            order['deliveryDistanceKm'] ?? 0,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Text(
                    context.l10n.issueHistoryNotes(notes),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.brown[900],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = Colors.blue[100]!;
    Color text = Colors.blue[900]!;
    String label = status;

    if (status.toLowerCase() == 'rescheduled') {
      bg = Colors.orange[100]!;
      text = Colors.orange[900]!;
      label = context.l10n.rescheduledSecondTime;
    } else if (status.toLowerCase() == 'delivered') {
      bg = Colors.green[100]!;
      text = Colors.green[900]!;
      label = context.l10n.completedStatus;
    } else if (status.toLowerCase() == 'assigned') {
      bg = Colors.blue[100]!;
      text = Colors.blue[900]!;
      label = context.l10n.deliveryStatusAssigned;
    } else if (status.toLowerCase() == 'accepted') {
      bg = Colors.indigo[100]!;
      text = Colors.indigo[900]!;
      label = context.l10n.deliveryStatusAccepted;
    } else if (status.toLowerCase() == 'pickedup') {
      bg = Colors.deepPurple[100]!;
      text = Colors.deepPurple[900]!;
      label = context.l10n.deliveryStatusPickedUp;
    } else if (status.toLowerCase() == 'shipping') {
      bg = Colors.blue[100]!;
      text = Colors.blue[900]!;
      label = context.l10n.deliveryStatusShipping;
    } else if (status.toLowerCase() == 'arrived') {
      bg = Colors.teal[100]!;
      text = Colors.teal[900]!;
      label = context.l10n.deliveryStatusArrived;
    } else if (status.toLowerCase() == 'processing') {
      bg = Colors.amber[100]!;
      text = Colors.amber[900]!;
      label = context.l10n.awaitingDispatch;
    } else if (status.toLowerCase() == 'pending') {
      bg = Colors.grey[200]!;
      text = Colors.grey[800]!;
      label = context.l10n.awaitingConfirmation;
    } else if (status.toLowerCase() == 'cancelled') {
      bg = Colors.red[100]!;
      text = Colors.red[900]!;
      label = context.l10n.cancelled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showProofImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.acceptanceImageTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(context.l10n.cannotLoadImage),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> order) {
    final availableShippers = _shippers
        .where((s) => s['isAvailableForDelivery'] == true)
        .toList();
    int? selectedShipperId = order['shipperId'];
    String selectedTimeSlot =
        (order['deliveryTimeSlot'] ?? 'Sáng (08:00 - 12:00)').toString();
    if (!selectedTimeSlot.contains('Sáng') &&
        !selectedTimeSlot.contains('Chiều') &&
        !selectedTimeSlot.contains('Tối')) {
      selectedTimeSlot = 'Sáng (08:00 - 12:00)';
    }
    final TextEditingController adminNoteController = TextEditingController();

    final List<String> slots = [
      'Sáng (08:00 - 12:00)',
      'Chiều (13:00 - 17:00)',
      'Tối (18:00 - 20:00)',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            context.l10n.dispatchDialogTitle(
              (order['orderCode'] ?? order['orderId']).toString(),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.assignShipperRequired,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value:
                      availableShippers.any(
                        (s) => s['userId'] == selectedShipperId,
                      )
                      ? selectedShipperId
                      : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: Text(context.l10n.chooseResponsibleShipper),
                  items: availableShippers.map<DropdownMenuItem<int>>((s) {
                    final int uId = s['userId'];
                    final String name = s['fullName'] ?? 'Shipper $uId';
                    final String workload = _localizedShipperStatus(
                      (s['status'] ?? '').toString(),
                      s['isAvailableForDelivery'] == true,
                    );
                    return DropdownMenuItem<int>(
                      value: uId,
                      child: Text('$name ($workload)'),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedShipperId = val),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.newTimeSlot,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: slots.contains(selectedTimeSlot)
                      ? selectedTimeSlot
                      : slots[0],
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: slots
                      .map(
                        (val) => DropdownMenuItem<String>(
                          value: val,
                          child: Text(_localizedSlot(val)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setStateDialog(() {
                    if (val != null) selectedTimeSlot = val;
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.adminDispatchNote,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: adminNoteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: context.l10n.adminDispatchNoteHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E73DF),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (selectedShipperId == null || selectedShipperId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.mustChooseShipper),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await _apiService.rescheduleDeliveryOrder(
                    order['orderId'],
                    shipperId: selectedShipperId,
                    deliveryTimeSlot: selectedTimeSlot,
                    adminNote: adminNoteController.text.isNotEmpty
                        ? adminNoteController.text
                        : null,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.dispatchSaved),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.genericError(e)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(context.l10n.saveDispatch),
            ),
          ],
        ),
      ),
    );
  }
}
