import 'package:flutter/material.dart';
import '../../conf/responsive.dart';
import '../../services/cart_service.dart';
import '../../model/cart_item.dart';
import '../../widgets/currency_formatter.dart';
import '../../model/product.dart';
import '../../services/api_service.dart';
import '../../widgets/web_page_route.dart';
import '../../page/product/product_detail_page.dart';
import '../utils/string_utils.dart';
import '../l10n/l10n.dart';
import 'product_price.dart';

// ─── Search Overlay ───────────────────────────────────────────────────────────
class SearchBarOverlay extends StatefulWidget {
  const SearchBarOverlay({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<SearchBarOverlay> createState() => _SearchBarOverlayState();
}

class _SearchBarOverlayState extends State<SearchBarOverlay> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final prods = await ApiService().fetchProducts();
      setState(() {
        _allProducts = prods;
      });
    } catch (e) {
      debugPrint('Error loading products for search: $e');
    }
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    final q = removeVietnameseTones(query.trim().toLowerCase());
    setState(() {
      _suggestions = _allProducts.where((p) {
        final cleanName = removeVietnameseTones(p.productName.toLowerCase());
        return cleanName.startsWith(q);
      }).toList();
    });
  }

  void _navigateToSearchResults(String query) {
    if (query.trim().isEmpty) return;
    widget.onClose();
    Navigator.pushNamed(context, '/products', arguments: query.trim());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search box container
          Container(
            width: double.infinity,
            height: isMobile ? 72 : 92,
            color: const Color(0xffeeeeee),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 18 : 24,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: context.l10n.search.toUpperCase(),
                      hintStyle: TextStyle(
                        color: const Color(0xffb8b8b8),
                        fontSize: isMobile ? 18 : 24,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.8,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                    onSubmitted: (value) {
                      _navigateToSearchResults(value);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: const Color(0xff444444),
                    size: isMobile ? 26 : 32,
                  ),
                  onPressed: () {
                    _navigateToSearchResults(_searchController.text);
                  },
                ),
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(
                      Icons.close,
                      color: const Color(0xff444444),
                      size: isMobile ? 30 : 38,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Autocomplete Dropdown List
          if (_suggestions.isNotEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxWidth: 1072),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._suggestions.take(5).map((product) {
                      String imgUrl = 'assets/images/products/product-.jpg';
                      if (product.productVariants.isNotEmpty) {
                        for (var variant in product.productVariants) {
                          if (variant.productImages.isNotEmpty) {
                            final firstImg =
                                variant.productImages.first.imageUrl;
                            if (firstImg.startsWith('http')) {
                              imgUrl = firstImg;
                            } else {
                              imgUrl = 'http://localhost:5024$firstImg';
                            }
                            break;
                          }
                        }
                      }

                      return InkWell(
                        onTap: () {
                          widget.onClose();
                          Navigator.push(
                            context,
                            WebPageRoute(
                              settings: RouteSettings(
                                name: '/product-detail?id=${product.productId}',
                                arguments: product,
                              ),
                              page: ProductDetailPage(
                                productId: product.productId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xfff0f0f0)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    ProductPrice(
                                      product: product,
                                      axis: Axis.horizontal,
                                      saleFontSize: 13,
                                      originalFontSize: 11,
                                      saleColor: const Color(0xFFC8815F),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: imgUrl.startsWith('http')
                                    ? Image.network(
                                        imgUrl,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        imgUrl,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    InkWell(
                      onTap: () {
                        _navigateToSearchResults(_searchController.text);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Text(
                          context.l10n.viewMoreProducts(_suggestions.length),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
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

// ─── Cart Popup Overlay ─────────────────────────────────────────────────────────
class CartPopupOverlay extends StatelessWidget {
  const CartPopupOverlay({
    super.key,
    required this.isMobile,
    required this.onClose,
    required this.onViewCart,
    required this.onCheckout,
  });

  final bool isMobile;
  final VoidCallback onClose;
  final VoidCallback onViewCart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final double topPosition = isMobile ? 60 : 78;
    final double popupWidth = isMobile
        ? MediaQuery.of(context).size.width - 24
        : 380;

    return Stack(
      children: [
        // Bấm ra ngoài popup thì tắt
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),

        Positioned(
          top: topPosition + 8,
          right: isMobile ? 12 : 64,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Mũi tên nhỏ phía trên popup
                Positioned(
                  top: -10,
                  right: isMobile ? 70 : 34,
                  child: Transform.rotate(
                    angle: 0.785398, // 45 độ
                    child: Container(
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ),

                Container(
                  width: popupWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 18 : 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xffdddddd),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            context.l10n.cartTitle,
                            style: const TextStyle(
                              color: Color(0xff6f7880),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const Spacer(),

                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: onClose,
                              child: const Icon(
                                Icons.close,
                                color: Color(0xff444444),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Container(height: 1, color: const Color(0xffdddddd)),

                      const SizedBox(height: 16),

                      ValueListenableBuilder<List<CartItem>>(
                        valueListenable: CartService.cartItems,
                        builder: (context, items, _) {
                          if (items.isEmpty) {
                            return Column(
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Color(0xff444444),
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.cartEmptyShort,
                                  style: const TextStyle(
                                    color: Color(0xff7a828a),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 1,
                                  color: const Color(0xffdddddd),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Text(
                                      context.l10n.total.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xff7a828a),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      formatVND(0),
                                      style: const TextStyle(
                                        color: Color(0xffff4a22),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 250,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];

                                    String imageUrl =
                                        'assets/images/products/product-.jpg';
                                    if (item.variant != null &&
                                        item
                                            .variant!
                                            .productImages
                                            .isNotEmpty) {
                                      final firstImage = item
                                          .variant!
                                          .productImages
                                          .first
                                          .imageUrl;
                                      imageUrl = firstImage.startsWith('http')
                                          ? firstImage
                                          : 'http://localhost:5024$firstImage';
                                    } else if (item
                                        .product
                                        .productVariants
                                        .isNotEmpty) {
                                      for (var variant
                                          in item.product.productVariants) {
                                        if (variant.productImages.isNotEmpty) {
                                          final firstImage = variant
                                              .productImages
                                              .first
                                              .imageUrl;
                                          imageUrl =
                                              firstImage.startsWith('http')
                                              ? firstImage
                                              : 'http://localhost:5024$firstImage';
                                          break;
                                        }
                                      }
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              image: DecorationImage(
                                                image:
                                                    (imageUrl.startsWith('http')
                                                            ? NetworkImage(
                                                                imageUrl,
                                                              )
                                                            : AssetImage(
                                                                imageUrl,
                                                              ))
                                                        as ImageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.product.productName
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                if (item.variant != null)
                                                  Text(
                                                    [
                                                          item.variant!.color,
                                                          item.variant!.size,
                                                          item
                                                              .variant!
                                                              .material,
                                                        ]
                                                        .where(
                                                          (s) => s.isNotEmpty,
                                                        )
                                                        .join(' / ')
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xfff1f3f5,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              2,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '${item.quantity}',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      formatVND(item.unitPrice),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFFC8815F,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  CartService.removeItem(item),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.black,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 1,
                                color: const Color(0xffdddddd),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Text(
                                    context.l10n.total.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xff7a828a),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatVND(CartService.totalAmount),
                                    style: const TextStyle(
                                      color: Color(0xffff4a22),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      isMobile
                          ? Column(
                              children: [
                                CartActionButton(
                                  title: context.l10n.viewCart,
                                  color: const Color(0xff444444),
                                  onTap: onViewCart,
                                ),
                                const SizedBox(height: 12),
                                CartActionButton(
                                  title: context.l10n.checkoutAction,
                                  color: const Color(0xff2f7199),
                                  onTap: onCheckout,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: CartActionButton(
                                    title: context.l10n.viewCart,
                                    color: const Color(0xff444444),
                                    onTap: onViewCart,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CartActionButton(
                                    title: context.l10n.checkoutAction,
                                    color: const Color(0xff2f7199),
                                    onTap: onCheckout,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CartActionButton extends StatefulWidget {
  const CartActionButton({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  State<CartActionButton> createState() => _CartActionButtonState();
}

class _CartActionButtonState extends State<CartActionButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHover = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: isHover ? 0.86 : 1,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            color: widget.color,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
