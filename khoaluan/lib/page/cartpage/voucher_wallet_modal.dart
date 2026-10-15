import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../model/voucher.dart';
import '../../services/api_service.dart';
import '../../widgets/currency_formatter.dart';

class VoucherWalletModal extends StatefulWidget {
  final double currentSubtotal;
  final ValueChanged<VoucherModel> onSelectVoucher;

  const VoucherWalletModal({
    super.key,
    required this.currentSubtotal,
    required this.onSelectVoucher,
  });

  @override
  State<VoucherWalletModal> createState() => _VoucherWalletModalState();
}

class _VoucherWalletModalState extends State<VoucherWalletModal> {
  final ApiService _apiService = ApiService();
  List<VoucherModel> _vouchers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadActiveVouchers();
  }

  Future<void> _loadActiveVouchers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await _apiService.fetchActiveVouchers();
      setState(() {
        _vouchers = res;
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 550,
        height: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.voucherWallet,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.currentOrder(formatVND(widget.currentSubtotal)),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    )
                  : _vouchers.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noAvailableVouchers,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _vouchers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (ctx, i) {
                        final v = _vouchers[i];
                        final isEligible =
                            widget.currentSubtotal >= v.minOrderAmount;
                        final needed =
                            v.minOrderAmount - widget.currentSubtotal;
                        String discountTitle = v.discountType == 1
                            ? context.l10n.discountPercent(
                                v.discountValue.toStringAsFixed(0),
                              )
                            : context.l10n.discountAmount(
                                formatVND(v.discountValue),
                              );

                        return Container(
                          decoration: BoxDecoration(
                            color: isEligible
                                ? Colors.white
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isEligible
                                  ? Colors.orange.shade300
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: isEligible
                                ? [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.08),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: isEligible
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFFF6B6B),
                                            Color(0xFFFF8E53),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade400,
                                            Colors.grey.shade500,
                                          ],
                                        ),
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.card_giftcard,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      discountTitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              v.voucherCode,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                                letterSpacing: 0.5,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            context.l10n.expiresOn(
                                              _formatDate(v.endDate),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        v.voucherName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (v.description != null &&
                                          v.description!.isNotEmpty)
                                        Text(
                                          v.description!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (isEligible)
                                            Text(
                                              context.l10n.voucherUsage(
                                                v.usedCount,
                                                v.usageLimit,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          else
                                            Text(
                                              context.l10n.spendMoreToUse(
                                                formatVND(needed),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isEligible
                                                  ? const Color(0xFFFF6B6B)
                                                  : Colors.grey,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              minimumSize: Size.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            onPressed: isEligible
                                                ? () {
                                                    widget.onSelectVoucher(v);
                                                    Navigator.of(context).pop();
                                                  }
                                                : null,
                                            child: Text(
                                              context.l10n.apply,
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
