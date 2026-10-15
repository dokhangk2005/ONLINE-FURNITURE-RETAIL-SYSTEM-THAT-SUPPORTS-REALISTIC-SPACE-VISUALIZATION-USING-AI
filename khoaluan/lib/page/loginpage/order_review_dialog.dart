import 'package:flutter/material.dart';

import '../../model/order.dart';
import '../../services/api_service.dart';
import '../../l10n/l10n.dart';

Future<String?> showOrderReviewDialog(
  BuildContext context,
  OrderItem item,
) async {
  var selectedStars = 5;
  var submitting = false;
  final commentController = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = context.l10n;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(l10n.reviewProductTitle(item.productName)),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.verifiedPurchaseDelivered,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.satisfactionLevel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          tooltip: '$star ★',
                          iconSize: 38,
                          onPressed: submitting
                              ? null
                              : () =>
                                    setDialogState(() => selectedStars = star),
                          icon: Icon(
                            selectedStars >= star
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: commentController,
                      enabled: !submitting,
                      maxLines: 4,
                      maxLength: 2000,
                      decoration: InputDecoration(
                        labelText: l10n.optionalComment,
                        hintText: l10n.reviewHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitting
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton.icon(
                onPressed: submitting
                    ? null
                    : () async {
                        setDialogState(() => submitting = true);
                        try {
                          final response = await ApiService().submitReview(
                            item.orderDetailId,
                            item.productId,
                            selectedStars,
                            commentController.text.trim(),
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.pop(
                            dialogContext,
                            response['message']?.toString() ??
                                l10n.reviewSuccess,
                          );
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                          setDialogState(() => submitting = false);
                        }
                      },
                icon: submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.rate_review_outlined),
                label: Text(l10n.submitReview),
              ),
            ],
          );
        },
      );
    },
  );

  commentController.dispose();
  return result;
}
