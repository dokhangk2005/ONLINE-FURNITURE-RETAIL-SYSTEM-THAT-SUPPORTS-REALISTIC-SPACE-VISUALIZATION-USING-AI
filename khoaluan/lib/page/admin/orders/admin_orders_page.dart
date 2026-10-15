import 'package:flutter/material.dart';
import '../../../widgets/currency_formatter.dart';
import '../../../services/api_service.dart';
import '../../../model/order.dart';
import '../../../l10n/l10n.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final ApiService _apiService = ApiService();
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = true;
  String _selectedStatusFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  OrderModel? _selectedOrder; // For detail view sidebar/modal

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final orders = await _apiService.fetchAdminOrders();
      if (!mounted) return;
      setState(() {
        _allOrders = orders;
        _filteredOrders = orders;
        _isLoading = false;
        // Keep selected order updated if it exists
        if (_selectedOrder != null) {
          _selectedOrder = orders.firstWhere(
            (o) => o.orderId == _selectedOrder!.orderId,
            orElse: () => _selectedOrder!,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loadOrderListError(e))),
      );
    }
  }

  void _applyFilterAndSearch() {
    var list = _allOrders;
    if (_selectedStatusFilter == 'Unpaid') {
      list = list
          .where(
            (o) =>
                o.paymentStatus.toLowerCase() == 'pending' &&
                o.orderStatus.toLowerCase() != 'cancelled',
          )
          .toList();
    } else if (_selectedStatusFilter == 'Pending') {
      list = list
          .where((o) => o.orderStatus.toLowerCase() == 'pending')
          .toList();
    } else if (_selectedStatusFilter == 'Processing') {
      list = list
          .where((o) => o.orderStatus.toLowerCase() == 'processing')
          .toList();
    } else if (_selectedStatusFilter == 'Delivered') {
      list = list
          .where((o) => o.orderStatus.toLowerCase() == 'delivered')
          .toList();
    } else if (_selectedStatusFilter == 'Returned') {
      list = list
          .where((o) => o.orderStatus.toLowerCase() == 'returned')
          .toList();
    } else if (_selectedStatusFilter == 'Cancelled') {
      list = list
          .where((o) => o.orderStatus.toLowerCase() == 'cancelled')
          .toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (o) =>
                o.userFullName.toLowerCase().contains(query) ||
                o.userEmail.toLowerCase().contains(query) ||
                o.orderCode.toLowerCase().contains(query) ||
                o.orderId.toString() == query,
          )
          .toList();
    }

    setState(() {
      _filteredOrders = list;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'shipping':
        return Colors.purple;
      case 'rescheduled':
        return Colors.deepOrange;
      case 'delivered':
        return Colors.green;
      case 'returned':
        return Colors.brown;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return context.l10n.awaitingConfirmation;
      case 'processing':
        return context.l10n.awaitingDelivery;
      case 'shipping':
        return context.l10n.shipping;
      case 'rescheduled':
        return context.l10n.rescheduledDelivery;
      case 'delivered':
        return context.l10n.delivered;
      case 'returned':
        return context.l10n.returned;
      case 'cancelled':
        return context.l10n.cancelled;
      default:
        return status;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return context.l10n.paid;
      case 'failed':
        return context.l10n.paymentFailed;
      case 'pending':
      default:
        return context.l10n.awaitingPayment;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green.shade700;
      case 'failed':
        return Colors.red.shade700;
      case 'pending':
      default:
        return Colors.amber.shade700;
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    if (newStatus.toLowerCase() == 'cancelled') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.confirmCancelOrder),
          content: Text(context.l10n.confirmCancelOrderBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.no),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(context.l10n.cancelOrder),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.black)),
    );
    try {
      await _apiService.updateOrderStatusAdmin(orderId, newStatus);
      if (!mounted) return;
      Navigator.of(context).pop(); // pop loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.orderStatusUpdated)));
      _loadOrders();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // pop loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.updateError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Area: Order List & Controls
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.adminOrderManagement,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Filter and Search Row
                  Row(
                    children: [
                      // Status filter tabs
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                [
                                  {'key': 'All', 'label': context.l10n.all},
                                  {
                                    'key': 'Unpaid',
                                    'label': context.l10n.awaitingPayment,
                                  },
                                  {
                                    'key': 'Pending',
                                    'label': context.l10n.awaitingConfirmation,
                                  },
                                  {
                                    'key': 'Processing',
                                    'label': context.l10n.awaitingDelivery,
                                  },
                                  {
                                    'key': 'Delivered',
                                    'label': context.l10n.delivered,
                                  },
                                  {
                                    'key': 'Returned',
                                    'label': context.l10n.returned,
                                  },
                                  {
                                    'key': 'Cancelled',
                                    'label': context.l10n.cancelled,
                                  },
                                ].map((f) {
                                  final status = f['key']!;
                                  final label = f['label']!;
                                  final isSelected =
                                      _selectedStatusFilter == status;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedStatusFilter = status;
                                      });
                                      _applyFilterAndSearch();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Search field
                      SizedBox(
                        width: 250,
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => _applyFilterAndSearch(),
                          decoration: InputDecoration(
                            hintText: context.l10n.searchOrdersHint,
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Table / List
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : _filteredOrders.isEmpty
                        ? Center(child: Text(context.l10n.noOrdersFound))
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ListView.builder(
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  final isSelected =
                                      _selectedOrder?.orderId == order.orderId;
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade100,
                                        ),
                                      ),
                                    ),
                                    child: Material(
                                      color: isSelected
                                          ? const Color(0xFFF3F4F6)
                                          : Colors.transparent,
                                      child: ListTile(
                                        onTap: () {
                                          setState(() {
                                            _selectedOrder = order;
                                          });
                                        },
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              order.orderCode.isNotEmpty
                                                  ? order.orderCode
                                                  : context.l10n.orderNumber(
                                                      order.orderId,
                                                    ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              formatVND(order.totalAmount),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    context.l10n
                                                        .customerSummary(
                                                          order.userFullName,
                                                          order.userEmail,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    context.l10n.orderDate(
                                                      order.orderDate
                                                          .split("T")
                                                          .first,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  // Payment state badge
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _getPaymentStatusColor(
                                                            order.paymentStatus,
                                                          ).withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _getPaymentStatusText(
                                                        order.paymentStatus,
                                                      ),
                                                      style: TextStyle(
                                                        color:
                                                            _getPaymentStatusColor(
                                                              order
                                                                  .paymentStatus,
                                                            ),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Order state badge
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(
                                                        order.orderStatus,
                                                      ).withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _getStatusText(
                                                        order.orderStatus,
                                                      ),
                                                      style: TextStyle(
                                                        color: _getStatusColor(
                                                          order.orderStatus,
                                                        ),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Right Area: Details Sidebar (if selected)
          if (_selectedOrder != null)
            Container(
              width: 450,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
              child: _buildDetailsSidebar(_selectedOrder!),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSidebar(OrderModel order) {
    final isFinalized =
        order.orderStatus.toLowerCase() == 'cancelled' ||
        order.orderStatus.toLowerCase() == 'delivered';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderCode.isNotEmpty
                    ? context.l10n.orderDetailsCode(order.orderCode)
                    : context.l10n.orderDetailsNumber(order.orderId),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedOrder = null),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Sidebar Content Scroll
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Status & Updater dropdown
                Text(
                  context.l10n.orderStatusLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      order.orderStatus,
                    ).withValues(alpha: 0.08),
                    border: Border.all(
                      color: _getStatusColor(
                        order.orderStatus,
                      ).withValues(alpha: 0.35),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        order.orderStatus.toLowerCase() == 'delivered'
                            ? Icons.check_circle
                            : order.orderStatus.toLowerCase() == 'shipping' ||
                                  order.orderStatus.toLowerCase() ==
                                      'rescheduled'
                            ? Icons.local_shipping
                            : Icons.receipt_long,
                        color: _getStatusColor(order.orderStatus),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _getStatusText(order.orderStatus),
                        style: TextStyle(
                          color: _getStatusColor(order.orderStatus),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.orderStatus.toLowerCase() == 'shipping' ||
                    order.orderStatus.toLowerCase() == 'rescheduled')
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            context.l10n.shipperOwnsDeliveryConfirmation,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff8a4b08),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (order.orderStatus.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateStatus(order.orderId, 'processing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.confirmOrder,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
                if (order.orderStatus.toLowerCase() == 'pending' ||
                    order.orderStatus.toLowerCase() == 'processing') ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateStatus(order.orderId, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(context.l10n.cancelOrderFull),
                    ),
                  ),
                ],
                if (isFinalized)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      context.l10n.completedOrderLocked,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Customer Info
                Text(
                  context.l10n.customerDeliveryInformation,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                if (order.shipperName != null && order.shipperName!.isNotEmpty)
                  _buildSidebarInfoRow(
                    context.l10n.assignedShipper,
                    order.shipperName!,
                  ),
                _buildSidebarInfoRow(
                  context.l10n.customerNameLabel,
                  order.userFullName,
                ),
                _buildSidebarInfoRow('Email:', order.userEmail),
                _buildSidebarInfoRow(
                  context.l10n.deliveryAddressLabel,
                  order.shippingAddress,
                ),
                if (order.deliveryTimeSlot != null)
                  _buildSidebarInfoRow(
                    context.l10n.appointmentSlot,
                    order.deliveryTimeSlot!,
                  ),
                _buildSidebarInfoRow(
                  context.l10n.assemblyServiceLabel,
                  order.includesAssembly
                      ? context.l10n.assemblyRequested(
                          formatVND(order.assemblyFee),
                        )
                      : context.l10n.none,
                ),
                const SizedBox(height: 24),

                // Payment Info
                Text(
                  context.l10n.paymentSection,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSidebarInfoRow(
                  context.l10n.methodLabel,
                  order.paymentMethod.toUpperCase(),
                ),
                _buildSidebarInfoRow(
                  context.l10n.paymentStatusLabel,
                  _getPaymentStatusText(order.paymentStatus),
                ),
                const SizedBox(height: 24),

                // Items list
                Text(
                  context.l10n.orderedProducts,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.orderDetails.length,
                  itemBuilder: (context, i) {
                    final item = order.orderDetails[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.l10n.classification(
                                    item.color,
                                    item.size,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.l10n.quantity(item.quantity),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatVND(item.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Total Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.totalPaymentLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      formatVND(order.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
