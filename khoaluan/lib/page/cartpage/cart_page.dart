import 'package:flutter/material.dart';
import '../../conf/responsive.dart';
import '../../l10n/l10n.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/currency_formatter.dart';
import '../../services/cart_service.dart';
import '../../model/cart_item.dart';
import '../../widgets/product_price.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      isFooterSmall: false,
      child: Column(children: [CartBreadcrumb(), CartContent()]),
    );
  }
}

class CartBreadcrumb extends StatelessWidget {
  const CartBreadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = context.isMobile ? 20.0 : 64.0;
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      color: const Color(0xfff5f5f5),
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: isMobile ? 12 : 18,
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                context.l10n.home,
                style: TextStyle(
                  color: const Color(0xff5f6670),
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '/',
            style: TextStyle(
              color: const Color(0xff9a9a9a),
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(width: 10),
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartService.cartItems,
            builder: (context, items, _) {
              return Text(
                context.l10n.cartItemCount(CartService.totalQuantity),
                style: TextStyle(
                  color: const Color(0xff8a8f98),
                  fontSize: isMobile ? 14 : 16,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CartContent extends StatelessWidget {
  const CartContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final hPad = switch (context.screenSize) {
      ScreenSize.mobile => 20.0,
      ScreenSize.tablet => 40.0,
      ScreenSize.desktop => 64.0,
    };

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 300 : 450),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        hPad,
        isMobile ? 32 : 48,
        hPad,
        isMobile ? 48 : 64,
      ),
      child: Column(
        children: [
          Text(
            context.l10n.yourCart,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: isMobile ? 24 : 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(width: 60, height: 3, color: const Color(0xff333333)),
          SizedBox(height: isMobile ? 28 : 40),

          ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartService.cartItems,
            builder: (context, items, _) {
              if (items.isEmpty) {
                return const EmptyCartMessage();
              }

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCartList(context, items, isMobile),
                    const SizedBox(height: 24),
                    const OrderSummaryBox(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildCartList(context, items, isMobile),
                  ),
                  SizedBox(width: isTablet ? 32 : 60),
                  const Expanded(flex: 4, child: OrderSummaryBox()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    List<CartItem> items,
    bool isMobile,
  ) {
    return Column(
      children: items
          .map((item) => _buildCartItemWidget(context, item, isMobile))
          .toList(),
    );
  }

  Widget _buildCartItemWidget(
    BuildContext context,
    CartItem item,
    bool isMobile,
  ) {
    String imageUrl = 'assets/images/products/product-.jpg';
    if (item.variant != null && item.variant!.productImages.isNotEmpty) {
      final firstImage = item.variant!.productImages.first.imageUrl;
      imageUrl = firstImage.startsWith('http')
          ? firstImage
          : 'http://localhost:5024$firstImage';
    } else if (item.product.productVariants.isNotEmpty) {
      for (var variant in item.product.productVariants) {
        if (variant.productImages.isNotEmpty) {
          final firstImage = variant.productImages.first.imageUrl;
          imageUrl = firstImage.startsWith('http')
              ? firstImage
              : 'http://localhost:5024$firstImage';
          break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffeeeeee))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: isMobile ? 80 : 100,
            height: isMobile ? 80 : 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image:
                    (imageUrl.startsWith('http')
                            ? NetworkImage(imageUrl)
                            : AssetImage(imageUrl))
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.productName,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.variant != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${item.variant!.material} - ${item.variant!.color}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isMobile ? 13 : 15,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ProductPrice(
                  product: item.product,
                  additionalPrice: item.variant?.additionalPrice ?? 0,
                  saleFontSize: isMobile ? 15 : 18,
                  saleColor: const Color(0xFFC8815F),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Quantity control
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              final errorMsg = CartService.updateQuantity(
                                item,
                                item.quantity - 1,
                              );
                              if (errorMsg != null) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.remove, size: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final errorMsg = CartService.updateQuantity(
                                item,
                                item.quantity + 1,
                              );
                              if (errorMsg != null) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.add, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => CartService.removeItem(item),
                      tooltip: context.l10n.remove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyCartMessage extends StatelessWidget {
  const EmptyCartMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.l10n.emptyCart,
          style: const TextStyle(
            color: Color(0xff555555),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          child: Text(context.l10n.continueShopping),
        ),
      ],
    );
  }
}

class OrderSummaryBox extends StatelessWidget {
  const OrderSummaryBox({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        24,
        isMobile ? 16 : 24,
        22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffdddddd), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.orderInformation,
            style: TextStyle(
              color: Colors.black,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xffe5e5e5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                context.l10n.total,
                style: TextStyle(
                  color: const Color(0xff555555),
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              ValueListenableBuilder<List<CartItem>>(
                valueListenable: CartService.cartItems,
                builder: (context, _, __) {
                  return Text(
                    formatVND(CartService.totalAmount),
                    style: TextStyle(
                      color: const Color(0xffff4a22),
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xffe5e5e5)),
          const SizedBox(height: 16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/checkout'),
              child: Container(
                width: double.infinity,
                height: 48,
                alignment: Alignment.center,
                color: const Color(0xffff0000),
                child: Text(
                  context.l10n.checkout,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.reply, color: Color(0xff555555), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.continueBuying,
                    style: const TextStyle(
                      color: Color(0xff555555),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
