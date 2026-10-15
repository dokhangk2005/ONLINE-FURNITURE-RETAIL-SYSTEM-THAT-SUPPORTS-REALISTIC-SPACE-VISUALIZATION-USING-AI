import 'package:flutter/material.dart';
import '../../../model/voucher.dart';
import '../../../services/api_service.dart';
import '../../../widgets/currency_formatter.dart';
import 'voucher_form_modal.dart';
import '../../../l10n/l10n.dart';

class AdminVouchersPage extends StatefulWidget {
  const AdminVouchersPage({super.key});

  @override
  State<AdminVouchersPage> createState() => _AdminVouchersPageState();
}

class _AdminVouchersPageState extends State<AdminVouchersPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<VoucherModel> _allVouchers = [];
  List<VoucherModel> _filteredVouchers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVouchers();
    _searchController.addListener(_filterVouchers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final vouchers = await _apiService.fetchAdminVouchers();
      setState(() {
        _allVouchers = vouchers;
        _filteredVouchers = vouchers;
      });
      _filterVouchers();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterVouchers() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredVouchers = _allVouchers);
    } else {
      setState(() {
        _filteredVouchers = _allVouchers
            .where(
              (v) =>
                  v.voucherCode.toLowerCase().contains(query) ||
                  v.voucherName.toLowerCase().contains(query),
            )
            .toList();
      });
    }
  }

  void _openVoucherModal([VoucherModel? voucher]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          VoucherFormModal(voucher: voucher, onSaved: _loadVouchers),
    );
  }

  Future<void> _deleteVoucher(VoucherModel voucher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text(context.l10n.confirmDeleteVoucher(voucher.voucherCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteVoucherAdmin(voucher.voucherId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.voucherDeleted),
          backgroundColor: Colors.green,
        ),
      );
      _loadVouchers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.deleteVoucherError(e)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.voucherManagementTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5A5C69),
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CC88A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle, size: 18),
                    label: Text(
                      context.l10n.createVoucher,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _openVoucherModal(),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E73DF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(context.l10n.refresh),
                    onPressed: _loadVouchers,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.voucherListTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E73DF),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: context.l10n.searchVoucherHint,
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_filteredVouchers.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(context.l10n.noSystemVouchers),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF8F9FC),
                      ),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 65,
                      columns: [
                        DataColumn(
                          label: Text(
                            context.l10n.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A5C69),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.campaignName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A5C69),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.offer,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A5C69),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.minimumOrder,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A5C69),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.usedSupported,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A5C69),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.expiry,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A5C69),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.status,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A5C69),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            context.l10n.operations,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A5C69),
                            ),
                          ),
                        ),
                      ],
                      rows: _filteredVouchers.map((v) {
                        String discountText = v.discountType == 1
                            ? '${context.l10n.percentageDiscount(v.discountValue.toStringAsFixed(0))}${v.maxDiscountAmount != null ? ' (${context.l10n.maximumAmountSuffix(formatVND(v.maxDiscountAmount!))})' : ''}'
                            : context.l10n.cashDiscount(
                                formatVND(v.discountValue),
                              );

                        bool isExpired = now.isAfter(v.endDate);
                        bool isOut = v.usedCount >= v.usageLimit;
                        String statusLabel = context.l10n.operating;
                        Color statusBg = Colors.green.shade50;
                        Color statusColor = Colors.green.shade700;

                        if (!v.isActive) {
                          statusLabel = context.l10n.locked;
                          statusBg = Colors.grey.shade200;
                          statusColor = Colors.grey.shade700;
                        } else if (isExpired) {
                          statusLabel = context.l10n.expired;
                          statusBg = Colors.red.shade50;
                          statusColor = Colors.red.shade700;
                        } else if (isOut) {
                          statusLabel = context.l10n.usageExhausted;
                          statusBg = Colors.orange.shade50;
                          statusColor = Colors.orange.shade700;
                        }

                        return DataRow(
                          cells: [
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EEF5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  v.voucherCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4E73DF),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                v.voucherName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                discountText,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Text(formatVND(v.minOrderAmount))),
                            DataCell(
                              Row(
                                children: [
                                  Text(
                                    '${v.usedCount} / ${v.usageLimit}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 60,
                                    child: LinearProgressIndicator(
                                      value: v.usageLimit > 0
                                          ? (v.usedCount / v.usageLimit).clamp(
                                              0.0,
                                              1.0,
                                            )
                                          : 1.0,
                                      backgroundColor: Colors.grey.shade200,
                                      color: isOut
                                          ? Colors.orange
                                          : const Color(0xFF4E73DF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(_formatDate(v.endDate))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    tooltip: context.l10n.edit,
                                    onPressed: () => _openVoucherModal(v),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    tooltip: context.l10n.delete,
                                    onPressed: () => _deleteVoucher(v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
