import 'package:flutter/material.dart';
import '../../../model/voucher.dart';
import '../../../services/api_service.dart';
import '../../../l10n/l10n.dart';

class VoucherFormModal extends StatefulWidget {
  final VoucherModel? voucher;
  final VoidCallback onSaved;

  const VoucherFormModal({super.key, this.voucher, required this.onSaved});

  @override
  State<VoucherFormModal> createState() => _VoucherFormModalState();
}

class _VoucherFormModalState extends State<VoucherFormModal> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _discountValController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _minOrderController;
  late TextEditingController _usageLimitController;

  int _discountType = 1; // 1: %, 2: VND
  bool _isActive = true;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isLoading = false;
  String _errorMessage = '';

  String? _required(String? value, String field, {int minLength = 1}) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.requiredField(field);
    }
    return value.trim().length < minLength
        ? context.l10n.minLengthField(field, minLength)
        : null;
  }

  String? _number(
    String? value,
    String field, {
    num min = 0,
    num? max,
    bool integer = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.requiredField(field);
    }
    final number = num.tryParse(value.trim());
    if (number == null) return context.l10n.invalidNumber(field);
    if (integer && number != number.toInt()) {
      return context.l10n.integerRequired(field);
    }
    if (number < min) return context.l10n.minimumValue(field, min);
    return max != null && number > max
        ? context.l10n.maximumValue(field, max)
        : null;
  }

  @override
  void initState() {
    super.initState();
    final v = widget.voucher;
    _codeController = TextEditingController(text: v?.voucherCode ?? '');
    _nameController = TextEditingController(text: v?.voucherName ?? '');
    _descController = TextEditingController(text: v?.description ?? '');
    _discountType = v?.discountType ?? 1;
    _discountValController = TextEditingController(
      text: v != null ? v.discountValue.toStringAsFixed(0) : '10',
    );
    _maxDiscountController = TextEditingController(
      text: v?.maxDiscountAmount != null
          ? v!.maxDiscountAmount!.toStringAsFixed(0)
          : '500000',
    );
    _minOrderController = TextEditingController(
      text: v != null ? v.minOrderAmount.toStringAsFixed(0) : '2000000',
    );
    _usageLimitController = TextEditingController(
      text: v != null ? v.usageLimit.toString() : '100',
    );
    _isActive = v?.isActive ?? true;
    _startDate = v?.startDate ?? DateTime.now();
    _endDate = v?.endDate ?? DateTime.now().add(const Duration(days: 90));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _discountValController.dispose();
    _maxDiscountController.dispose();
    _minOrderController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveVoucher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final newVoucher = VoucherModel(
      voucherId: widget.voucher?.voucherId ?? 0,
      voucherCode: _codeController.text.trim().toUpperCase(),
      voucherName: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      discountType: _discountType,
      discountValue: double.tryParse(_discountValController.text) ?? 0,
      maxDiscountAmount: _discountType == 1
          ? (double.tryParse(_maxDiscountController.text) ?? 0)
          : null,
      minOrderAmount: double.tryParse(_minOrderController.text) ?? 0,
      usageLimit: int.tryParse(_usageLimitController.text) ?? 100,
      usedCount: widget.voucher?.usedCount ?? 0,
      startDate: _startDate,
      endDate: _endDate,
      isActive: _isActive,
    );

    try {
      if (widget.voucher == null) {
        await _apiService.createVoucherAdmin(newVoucher);
      } else {
        await _apiService.updateVoucherAdmin(newVoucher.voucherId, newVoucher);
      }
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.voucher == null
                          ? context.l10n.createNewVoucher
                          : context.l10n.updateVoucher(
                              widget.voucher!.voucherCode,
                            ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E73DF),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 32),
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: context.l10n.voucherCodeHint,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final required = _required(v, context.l10n.code);
                          if (required != null) return required;
                          return RegExp(
                                r'^[A-Za-z0-9\-_]+$',
                              ).hasMatch(v!.trim())
                              ? null
                              : context.l10n.invalidCode(context.l10n.code);
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: context.l10n.campaignNameRequired,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => _required(
                          v,
                          context.l10n.campaignName,
                          minLength: 3,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: context.l10n.conditionDescription,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _discountType,
                        decoration: InputDecoration(
                          labelText: context.l10n.discountType,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text(context.l10n.percentageType),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(context.l10n.cashType),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _discountType = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _discountValController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _discountType == 1
                              ? context.l10n.discountPercentField
                              : context.l10n.discountCashField,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => _number(
                          v,
                          _discountType == 1
                              ? context.l10n.discountPercentField
                              : context.l10n.discountAmountField,
                          min: 1,
                          max: _discountType == 1 ? 100 : null,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_discountType == 1) ...[
                      Expanded(
                        child: TextFormField(
                          controller: _maxDiscountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.l10n.maximumDiscountVnd,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v != null && v.isNotEmpty)
                              ? _number(v, context.l10n.maximumDiscountVnd)
                              : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: TextFormField(
                        controller: _minOrderController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.minimumOrderVnd,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => _number(v, context.l10n.minimumOrder),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usageLimitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.totalIssueLimit,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => _number(
                          v,
                          context.l10n.totalIssueLimit.replaceAll('*', ''),
                          min: 1,
                          integer: true,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SwitchListTile(
                        title: Text(
                          context.l10n.activateImmediately,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        value: _isActive,
                        activeColor: const Color(0xFF4E73DF),
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: context.l10n.startDate,
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(_formatDate(_startDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: context.l10n.endDate,
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(_formatDate(_endDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        context.l10n.cancel,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E73DF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveVoucher,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              context.l10n.saveVoucher,
                              style: const TextStyle(
                                fontSize: 15,
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
      ),
    );
  }
}
