import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/voucher.dart';
import '../../services/api_service.dart';
import '../../widgets/currency_formatter.dart';
import '../../l10n/l10n.dart';

class MyVouchersTab extends StatefulWidget {
  const MyVouchersTab({super.key});

  @override
  State<MyVouchersTab> createState() => _MyVouchersTabState();
}

class _MyVouchersTabState extends State<MyVouchersTab> {
  final ApiService _apiService = ApiService();
  List<VoucherModel> _allVouchers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'all'; // 'all', 'expiring', 'new'
  final Set<String> _copiedCodes = {};

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await _apiService.fetchActiveVouchers();
      setState(() {
        _allVouchers = res;
      });
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

  List<VoucherModel> _getFilteredVouchers() {
    final now = DateTime.now();
    if (_selectedFilter == 'expiring') {
      return _allVouchers.where((v) {
        final daysLeft = v.endDate.difference(now).inDays;
        return daysLeft >= 0 && daysLeft <= 7;
      }).toList();
    } else if (_selectedFilter == 'new') {
      return _allVouchers.where((v) {
        final ageDays = now.difference(v.startDate).inDays;
        return ageDays >= 0 && ageDays <= 7;
      }).toList();
    }
    return _allVouchers;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() {
      _copiedCodes.add(code);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.voucherCopiedMessage(code)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filteredVouchers = _getFilteredVouchers();
    final filters = [
      {'key': 'all', 'label': l10n.allAvailableVouchers},
      {'key': 'expiring', 'label': l10n.expiringSoonVouchers},
      {'key': 'new', 'label': l10n.newVouchers},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.myVoucherWalletTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.voucherWalletDescription,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        // Filter tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isSelected = _selectedFilter == f['key'];
              return InkWell(
                onTap: () => setState(() => _selectedFilter = f['key']!),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xffFF471A).withOpacity(0.1)
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xffFF471A)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xffFF471A)
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: Colors.grey.shade200),
        const SizedBox(height: 20),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Color(0xffFF471A)),
            ),
          )
        else if (_errorMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red.shade800),
            ),
          )
        else if (filteredVouchers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedFilter == 'expiring'
                        ? l10n.noExpiringVouchers
                        : (_selectedFilter == 'new'
                              ? l10n.noNewVouchers
                              : l10n.noAvailableVouchers),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredVouchers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final v = filteredVouchers[index];
              final isCopied = _copiedCodes.contains(v.voucherCode);
              final usageRatio = v.usageLimit > 0
                  ? (v.usedCount / v.usageLimit).clamp(0.0, 1.0)
                  : 0.0;
              final remaining = v.usageLimit - v.usedCount;
              final isAlmostFull = usageRatio >= 0.7 || remaining <= 10;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      // Left ticket stub
                      Container(
                        width: 120,
                        height: 165,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xffFF471A), Color(0xffFF6B4A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_offer_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              v.discountType == 1
                                  ? '${v.discountValue.toInt()}%'
                                  : '${(v.discountValue / 1000).toInt()}K',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              l10n.discountBadge,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top badge & expiry
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xffFF471A,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(
                                          0xffFF471A,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      v.voucherCode,
                                      style: const TextStyle(
                                        color: Color(0xffFF471A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    l10n.expiryDate(_formatDate(v.endDate)),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Voucher name & condition
                              Text(
                                v.voucherName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                v.description?.isNotEmpty == true
                                    ? l10n.voucherDescriptionMinOrder(
                                        v.description!,
                                        formatVND(v.minOrderAmount),
                                      )
                                    : '${l10n.orderFrom(formatVND(v.minOrderAmount))}${v.maxDiscountAmount != null ? ' - ${l10n.maxDiscount(formatVND(v.maxDiscountAmount!))}' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),

                              // Scarcity Indicator / Progress bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.voucherUsedPercent(
                                          (usageRatio * 100).toStringAsFixed(0),
                                        ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isAlmostFull
                                              ? Colors.red.shade700
                                              : Colors.orange.shade800,
                                        ),
                                      ),
                                      Text(
                                        l10n.remainingUses(remaining),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: usageRatio.clamp(
                                        0.05,
                                        1.0,
                                      ), // Min visibility 5%
                                      backgroundColor: Colors.grey.shade200,
                                      color: isAlmostFull
                                          ? Colors.redAccent
                                          : Colors.orange.shade600,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _copyToClipboard(v.voucherCode),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isCopied
                                            ? Colors.green
                                            : Colors.grey.shade400,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    icon: Icon(
                                      isCopied ? Icons.check : Icons.copy,
                                      size: 16,
                                      color: isCopied
                                          ? Colors.green
                                          : Colors.grey.shade700,
                                    ),
                                    label: Text(
                                      isCopied ? l10n.copied : l10n.copyCode,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isCopied
                                            ? Colors.green
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        '/',
                                        (route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffFF471A),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      l10n.useNow,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
