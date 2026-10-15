import 'package:flutter/material.dart';

import '../model/product.dart';
import 'currency_formatter.dart';

String discountLabel(double percent) {
  final value = percent % 1 == 0
      ? percent.toStringAsFixed(0)
      : percent.toStringAsFixed(2);
  return '-$value%';
}

class ProductDiscountBadge extends StatelessWidget {
  const ProductDiscountBadge({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    if (!product.hasActiveDiscount) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        discountLabel(product.discountPercent),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProductPrice extends StatelessWidget {
  const ProductPrice({
    super.key,
    required this.product,
    this.additionalPrice = 0,
    this.saleFontSize = 15,
    this.originalFontSize = 12,
    this.saleColor = const Color(0xFFE53935),
    this.axis = Axis.vertical,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final Product product;
  final double additionalPrice;
  final double saleFontSize;
  final double originalFontSize;
  final Color saleColor;
  final Axis axis;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final original = product.basePrice + additionalPrice;
    if (!product.hasActiveDiscount) {
      return Text(
        formatVND(original),
        style: TextStyle(
          color: Colors.black87,
          fontSize: saleFontSize,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final children = <Widget>[
      Text(
        formatVND(original),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: originalFontSize,
          decoration: TextDecoration.lineThrough,
        ),
      ),
      SizedBox(
        width: axis == Axis.horizontal ? 8 : 0,
        height: axis == Axis.vertical ? 2 : 0,
      ),
      Text(
        formatVND(product.effectivePrice(additionalPrice)),
        style: TextStyle(
          color: saleColor,
          fontSize: saleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
    return axis == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
  }
}
