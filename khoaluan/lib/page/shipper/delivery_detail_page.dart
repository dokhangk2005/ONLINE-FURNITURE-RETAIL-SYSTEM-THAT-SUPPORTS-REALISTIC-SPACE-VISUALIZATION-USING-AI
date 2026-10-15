import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/l10n.dart';
import '../../model/order.dart';
import '../../services/api_service.dart';
import '../../widgets/currency_formatter.dart';
import '../../widgets/language_switcher.dart';

class DeliveryDetailPage extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onStatusUpdated;

  const DeliveryDetailPage({
    super.key,
    required this.order,
    required this.onStatusUpdated,
  });

  @override
  State<DeliveryDetailPage> createState() => _DeliveryDetailPageState();
}

class _DeliveryDetailPageState extends State<DeliveryDetailPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late String _currentStatus;
  late bool _otpVerified;
  String? _proofImageUrl;
  Uint8List? _proofBytes;
  String? _paymentProofUrl;
  Uint8List? _paymentProofBytes;
  late bool _paymentCollected;
  final _otpController = TextEditingController();
  final _paymentNoteController = TextEditingController();
  late final TextEditingController _recipientController;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.orderStatus;
    _otpVerified = widget.order.otpVerified;
    _proofImageUrl = widget.order.deliveryProofImage;
    _paymentProofUrl = widget.order.paymentCollectionProofImage;
    _paymentCollected = widget.order.paymentCollectedAt != null;
    _recipientController = TextEditingController(
      text: widget.order.deliveryRecipientName ?? widget.order.userFullName,
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _paymentNoteController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.cannotCallNumber(phoneNumber))),
        );
      }
    }
  }

  Future<void> _openGoogleMaps(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.cannotOpenGoogleMaps)),
        );
      }
    }
  }

  Future<void> _callCustomer() async {
    final phone = widget.order.userPhone.replaceAll(RegExp(r'\s+'), '');
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _pickProofImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    final file = result.files.single;
    setState(() => _isLoading = true);
    try {
      final imageUrl = await _apiService.uploadImage(file.bytes!, file.name);
      if (!mounted) return;
      setState(() {
        _proofBytes = file.bytes;
        _proofImageUrl = imageUrl;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPaymentProofImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    final file = result.files.single;
    setState(() => _isLoading = true);
    try {
      final imageUrl = await _apiService.uploadImage(file.bytes!, file.name);
      if (!mounted) return;
      setState(() {
        _paymentProofBytes = file.bytes;
        _paymentProofUrl = imageUrl;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _requiresPaymentCollection {
    final method = widget.order.paymentMethod.toUpperCase();
    return method == 'COD' || method == 'POS';
  }

  Future<void> _confirmPaymentCollection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.confirmCollectedPayment),
        content: Text(
          context.l10n.confirmCollectedPaymentMessage(
            formatVND(widget.order.amountToCollect),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.confirmDeliveryPaymentCollection(
        widget.order.orderId,
        proofImage: _paymentProofUrl,
        note: _paymentNoteController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _paymentCollected = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.paymentCollectedSuccess),
          backgroundColor: Colors.green,
        ),
      );
      widget.onStatusUpdated();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptAssignment() async {
    await _performAction(
      () => _apiService.acceptDeliveryAssignment(widget.order.orderId),
      nextStatus: 'Accepted',
      successMessage: context.l10n.assignmentAccepted,
    );
  }

  Future<void> _rejectAssignment() async {
    final assignmentRejectedMessage = context.l10n.assignmentRejected;
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.rejectDeliveryTitle),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.rejectReason,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, reasonController.text.trim()),
            child: Text(context.l10n.confirmReject),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (reason == null || reason.isEmpty) return;
    await _performAction(
      () => _apiService.rejectDeliveryAssignment(widget.order.orderId, reason),
      successMessage: assignmentRejectedMessage,
      closeAfterSuccess: true,
    );
  }

  Future<void> _advanceStatus(String status, String message) async {
    await _performAction(
      () => _apiService.updateDeliveryProgress(widget.order.orderId, status),
      nextStatus: status,
      successMessage: message,
    );
  }

  Future<void> _requestOtp() async {
    await _performAction(
      () => _apiService.requestDeliveryOtp(widget.order.orderId),
      successMessage: context.l10n.otpSent,
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.otpMustBeSixDigits)));
      return;
    }
    await _performAction(
      () => _apiService.verifyDeliveryOtp(widget.order.orderId, otp),
      successMessage: context.l10n.otpVerifiedSuccess,
    );
    if (mounted) setState(() => _otpVerified = true);
  }

  Future<void> _performAction(
    Future<void> Function() action, {
    String? nextStatus,
    required String successMessage,
    bool closeAfterSuccess = false,
  }) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
      if (!mounted) return;
      if (nextStatus != null) setState(() => _currentStatus = nextStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
      widget.onStatusUpdated();
      if (closeAfterSuccess) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmCompleteDelivery() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.confirmDeliveryCompletion),
          content: Text(context.l10n.confirmDeliveryCompletionMessage),
          actions: <Widget>[
            TextButton(
              child: Text(context.l10n.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.confirmComplete),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _isLoading = true;
                });

                try {
                  await _apiService.completeDeliveryShipper(
                    widget.order.orderId,
                    proofImage: _proofImageUrl,
                    recipientName: _recipientController.text.trim(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.deliveryCompletedSuccess),
                        backgroundColor: Colors.green,
                      ),
                    );
                    widget.onStatusUpdated();
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.genericError(e.toString())),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _validateAndCompleteDelivery() {
    final message = _requiresPaymentCollection && !_paymentCollected
        ? context.l10n.collectPaymentBeforeComplete
        : !_otpVerified
        ? context.l10n.deliveryOtpRequired
        : (_proofImageUrl == null || _proofImageUrl!.trim().isEmpty)
        ? context.l10n.deliveryProofRequired
        : _recipientController.text.trim().isEmpty
        ? context.l10n.deliveryRecipientRequired
        : null;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.orange[800]),
      );
      return;
    }
    _confirmCompleteDelivery();
  }

  Future<void> _reportDeliveryIssue() async {
    String selectedReason = 'Khách vắng nhà (Xin hẹn lại)';
    final TextEditingController noteController = TextEditingController();
    final List<String> reasons = [
      'Khách vắng nhà (Xin hẹn lại)',
      'Khách xin đổi lịch / giờ giao',
      'Sai thông tin địa chỉ hoặc SĐT',
      'Sự cố kỹ thuật lắp đặt / hàng hóa',
      'Lý do thời tiết / giao thông',
    ];

    String localizedReason(String reason) => switch (reason) {
      'Khách vắng nhà (Xin hẹn lại)' => context.l10n.customerAbsentReason,
      'Khách xin đổi lịch / giờ giao' => context.l10n.customerRescheduleReason,
      'Sai thông tin địa chỉ hoặc SĐT' => context.l10n.incorrectContactReason,
      'Sự cố kỹ thuật lắp đặt / hàng hóa' => context.l10n.technicalIssueReason,
      _ => context.l10n.weatherTrafficReason,
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  Text(context.l10n.reportIssue),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.chooseIncompleteReason),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedReason,
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
                      items: reasons.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            localizedReason(value),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setStateDialog(() {
                            selectedReason = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(context.l10n.issueDetailNote),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: context.l10n.issueNoteHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await _pickProofImage();
                        if (dialogContext.mounted) setStateDialog(() {});
                      },
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(
                        _proofImageUrl == null
                            ? context.l10n.attachIssueProof
                            : context.l10n.changeDeliveryProof,
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(context.l10n.cancel),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(context.l10n.sendReport),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await _apiService.reportDeliveryIssue(
                        widget.order.orderId,
                        selectedReason,
                        noteController.text,
                        proofImage: _proofImageUrl,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              this.context.l10n.issueReportedSuccess,
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        widget.onStatusUpdated();
                        Navigator.of(this.context).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              this.context.l10n.genericError(e.toString()),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _cancelDeliveryOrder() async {
    String selectedReason = 'customer_refused';
    String? cancellationProofUrl;
    Uint8List? cancellationProofBytes;
    bool isUploading = false;
    final noteController = TextEditingController();
    final reasons = <String>[
      'customer_refused',
      'damaged_goods',
      'incorrect_order',
      'unsafe_delivery',
      'other',
    ];

    String reasonLabel(String reason) => switch (reason) {
      'customer_refused' => context.l10n.shipperCancelCustomerRefused,
      'damaged_goods' => context.l10n.shipperCancelDamagedGoods,
      'incorrect_order' => context.l10n.shipperCancelIncorrectOrder,
      'unsafe_delivery' => context.l10n.shipperCancelUnsafeDelivery,
      _ => context.l10n.otherReason,
    };

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(context.l10n.shipperCancelOrder)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.shipperCancelWarning,
                  style: TextStyle(color: Colors.red.shade700),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.cancellationReason,
                    border: const OutlineInputBorder(),
                  ),
                  items: reasons
                      .map(
                        (reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reasonLabel(reason)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedReason = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    labelText: context.l10n.cancellationNote,
                    hintText: context.l10n.cancellationNoteHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () async {
                          final result = await FilePicker.pickFiles(
                            type: FileType.image,
                            withData: true,
                          );
                          if (result == null ||
                              result.files.single.bytes == null) {
                            return;
                          }
                          final file = result.files.single;
                          setDialogState(() => isUploading = true);
                          try {
                            final imageUrl = await _apiService.uploadImage(
                              file.bytes!,
                              file.name,
                            );
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              cancellationProofUrl = imageUrl;
                              cancellationProofBytes = file.bytes;
                            });
                          } catch (error) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text('$error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (dialogContext.mounted) {
                              setDialogState(() => isUploading = false);
                            }
                          }
                        },
                  icon: isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_a_photo_outlined),
                  label: Text(context.l10n.optionalCancellationProof),
                ),
                if (cancellationProofBytes != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      cancellationProofBytes!,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: isUploading
                  ? null
                  : () async {
                      Navigator.of(dialogContext).pop();
                      await _performAction(
                        () => _apiService.cancelDeliveryOrder(
                          widget.order.orderId,
                          reason: reasonLabel(selectedReason),
                          note: noteController.text.trim(),
                          proofImage: cancellationProofUrl,
                        ),
                        nextStatus: 'Cancelled',
                        successMessage: context.l10n.shipperCancelSuccess,
                        closeAfterSuccess: true,
                      );
                    },
              icon: const Icon(Icons.cancel_outlined),
              label: Text(context.l10n.confirmCancelOrder),
            ),
          ],
        ),
      ),
    );
    noteController.dispose();
  }

  Widget _buildPaymentCollectionCard() {
    final handoverStatus = widget.order.paymentHandoverStatus.toLowerCase();
    final handoverLabel = switch (handoverStatus) {
      'submitted' => context.l10n.handoverSubmitted,
      'confirmed' => context.l10n.handoverConfirmed,
      'rejected' => context.l10n.handoverRejected,
      _ => context.l10n.handoverPending,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _paymentCollected ? Colors.green.shade50 : Colors.amber.shade50,
        border: Border.all(
          color: _paymentCollected
              ? Colors.green.shade300
              : Colors.amber.shade400,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _paymentCollected
                    ? Icons.payments_outlined
                    : Icons.warning_amber_rounded,
                color: _paymentCollected ? Colors.green : Colors.amber[900],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.amountToCollect(
                    formatVND(widget.order.amountToCollect),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(context.l10n.paymentMethodSummary(widget.order.paymentMethod)),
          if (_paymentCollected) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 20),
                const SizedBox(width: 6),
                Text(
                  context.l10n.paymentCollected,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(context.l10n.handoverStatusSummary(handoverLabel)),
          ] else ...[
            const SizedBox(height: 12),
            TextField(
              controller: _paymentNoteController,
              decoration: InputDecoration(
                labelText: context.l10n.paymentCollectionNote,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickPaymentProofImage,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _paymentProofUrl == null
                    ? context.l10n.addPaymentProof
                    : context.l10n.changePaymentProof,
              ),
            ),
            if (_paymentProofBytes != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _paymentProofBytes!,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _confirmPaymentCollection,
                icon: const Icon(Icons.price_check_outlined),
                label: Text(context.l10n.confirmPaymentCollected),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkflowActions(bool isDone) {
    if (isDone) return const SizedBox.shrink();
    final status = _currentStatus.toLowerCase();
    Widget primary(String label, IconData icon, VoidCallback onPressed) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: _isLoading ? null : onPressed,
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final children = <Widget>[
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openGoogleMaps(widget.order.shippingAddress),
              icon: const Icon(Icons.navigation_outlined),
              label: Text(context.l10n.deliveryDirections),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _callCustomer,
              icon: const Icon(Icons.phone_outlined),
              label: Text(context.l10n.callCustomer),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
    ];

    if (status == 'assigned' || status == 'rescheduled') {
      children.add(
        primary(
          context.l10n.acceptDelivery,
          Icons.check_circle_outline,
          _acceptAssignment,
        ),
      );
      if (status == 'assigned') {
        children.addAll([
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _rejectAssignment,
              icon: const Icon(Icons.close),
              label: Text(context.l10n.rejectDelivery),
            ),
          ),
        ]);
      }
    } else if (status == 'accepted') {
      children.add(
        primary(
          context.l10n.pickedUpFromWarehouse,
          Icons.inventory_2_outlined,
          () => _advanceStatus('PickedUp', context.l10n.pickedUpConfirmed),
        ),
      );
    } else if (status == 'pickedup') {
      children.add(
        primary(
          context.l10n.startDelivery,
          Icons.local_shipping_outlined,
          () => _advanceStatus('Shipping', context.l10n.deliveryOnTheWay),
        ),
      );
    } else if (status == 'shipping') {
      children.add(
        primary(
          context.l10n.arrivedDestination,
          Icons.location_on_outlined,
          () => _advanceStatus('Arrived', context.l10n.arrivedNotification),
        ),
      );
    } else if (status == 'arrived') {
      children.addAll([
        if (_requiresPaymentCollection) ...[
          _buildPaymentCollectionCard(),
          const SizedBox(height: 12),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.verifyRecipient,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (!_otpVerified) ...[
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _requestOtp,
                  icon: const Icon(Icons.email_outlined),
                  label: Text(context.l10n.sendOtpByEmail),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _otpController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: context.l10n.deliveryOtpLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      child: Text(context.l10n.verifyOtp),
                    ),
                  ],
                ),
              ] else
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.otpVerified,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: context.l10n.actualRecipientName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickProofImage,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  _proofImageUrl == null
                      ? context.l10n.chooseDeliveryProof
                      : context.l10n.changeDeliveryProof,
                ),
              ),
              if (_proofBytes != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _proofBytes!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        primary(
          context.l10n.confirmDelivered,
          Icons.task_alt,
          _validateAndCompleteDelivery,
        ),
      ]);
    }

    if (status != 'assigned') {
      children.addAll([
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade800,
            ),
            onPressed: _isLoading ? null : _reportDeliveryIssue,
            icon: const Icon(Icons.warning_amber_rounded),
            label: Text(context.l10n.reportIssueReschedule),
          ),
        ),
      ]);
    }
    final cancelBlocked =
        _paymentCollected ||
        widget.order.paymentStatus.toLowerCase() == 'success';
    children.addAll([
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: _isLoading || cancelBlocked ? null : _cancelDeliveryOrder,
          icon: const Icon(Icons.cancel_outlined),
          label: Text(context.l10n.shipperCancelOrder),
        ),
      ),
      if (cancelBlocked) ...[
        const SizedBox(height: 6),
        Text(
          context.l10n.paidOrderCancellationRequiresAdmin,
          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    ]);
    return Column(children: children);
  }

  String _statusLabel() => switch (_currentStatus.toLowerCase()) {
    'assigned' => context.l10n.deliveryStatusAssigned,
    'accepted' => context.l10n.deliveryStatusAccepted,
    'pickedup' => context.l10n.deliveryStatusPickedUp,
    'shipping' => context.l10n.deliveryStatusShipping,
    'arrived' => context.l10n.deliveryStatusArrived,
    'rescheduled' => context.l10n.rescheduledAttempt(
      widget.order.deliveryAttemptCount,
    ),
    'delivered' => context.l10n.deliveryAssemblySuccessful,
    'cancelled' => context.l10n.cancelled,
    _ => context.l10n.deliveryInProgress,
  };

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = _currentStatus.toLowerCase();
    final isDone =
        normalizedStatus == 'delivered' || normalizedStatus == 'cancelled';
    final double subtotal =
        widget.order.totalAmount -
        widget.order.shippingFee -
        widget.order.assemblyFee;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.deliveryDetailTitle(widget.order.orderCode)),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: LanguageSwitcher(
              color: Colors.white,
              height: 40,
              horizontalPadding: 6,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDone ? Icons.check_circle : Icons.local_shipping,
                          color: isDone ? Colors.green : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _statusLabel(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? Colors.green[800]
                                      : Colors.orange[800],
                                ),
                              ),
                              if (widget.order.deliveryTimeSlot != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  context.l10n.shipperAppointmentSlot(
                                    widget.order.deliveryTimeSlot!,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (widget.order.includesAssembly) ...[
                                const SizedBox(height: 4),
                                Text(
                                  context.l10n.homeAssemblyRequired(
                                    formatVND(widget.order.assemblyFee),
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                              if (widget.order.deliveryNotes != null &&
                                  widget.order.deliveryNotes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.amber),
                                  ),
                                  child: Text(
                                    context.l10n.incidentHistory(
                                      widget.order.deliveryNotes!,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.brown[900],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customer info
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.recipientInformation,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.grey),
                              const SizedBox(width: 12),
                              Text(
                                widget.order.userFullName,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.grey),
                              const SizedBox(width: 12),
                              Text(
                                widget.order.userPhone.isEmpty
                                    ? context.l10n.phoneNotUpdated
                                    : widget.order.userPhone,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (widget.order.userPhone.isNotEmpty)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.call, size: 18),
                                  label: Text(context.l10n.callNow),
                                  onPressed: () =>
                                      _makePhoneCall(widget.order.userPhone),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.order.shippingAddress,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[700],
                                side: BorderSide(color: Colors.blue[700]!),
                              ),
                              icon: const Icon(Icons.map),
                              label: Text(
                                context.l10n.openGoogleMapsDirections,
                              ),
                              onPressed: () =>
                                  _openGoogleMaps(widget.order.shippingAddress),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Order items
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.deliveryItemsCount(
                              widget.order.orderDetails.length,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.order.orderDetails.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final item = widget.order.orderDetails[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Colors.brown[100],
                                  child: Text(
                                    '${item.quantity}x',
                                    style: TextStyle(
                                      color: Colors.brown[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  context.l10n.colorSizeSummary(
                                    item.color,
                                    item.size,
                                  ),
                                ),
                                trailing: Text(
                                  formatVND(item.price * item.quantity),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Financial summary
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.orderInvoiceSummary,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.l10n.merchandiseAmount),
                              Text(
                                formatVND(subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.shippingFeeDistance(
                                  widget.order.deliveryDistanceKm != null
                                      ? ' (${widget.order.deliveryDistanceKm!.toStringAsFixed(1)} km)'
                                      : '',
                                ),
                              ),
                              Text(
                                formatVND(widget.order.shippingFee),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (widget.order.includesAssembly) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.assemblyServiceFee),
                                Text(
                                  formatVND(widget.order.assemblyFee),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.grandTotal,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatVND(widget.order.totalAmount),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  widget.order.paymentStatus.toLowerCase() ==
                                      'success'
                                  ? Colors.green[50]
                                  : Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widget.order.paymentStatus.toLowerCase() ==
                                          'success'
                                      ? Icons.check_circle
                                      : Icons.monetization_on,
                                  color:
                                      widget.order.paymentStatus
                                              .toLowerCase() ==
                                          'success'
                                      ? Colors.green
                                      : Colors.amber[800],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.order.paymentStatus.toLowerCase() ==
                                            'success'
                                        ? context.l10n.paidNoCashCollection(
                                            widget.order.paymentMethod,
                                          )
                                        : context.l10n.collectCashCod(
                                            formatVND(
                                              widget.order.amountToCollect,
                                            ),
                                          ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          widget.order.paymentStatus
                                                  .toLowerCase() ==
                                              'success'
                                          ? Colors.green[800]
                                          : Colors.amber[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildWorkflowActions(isDone),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
