import 'package:flutter/material.dart';
import '../../model/product.dart';
import '../../model/review.dart';
import '../../services/cart_service.dart';
import '../../services/api_service.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/web_page_route.dart';
import '../../widgets/product_price.dart';
import '../../conf/responsive.dart';
import '../../l10n/l10n.dart';
import '../visualizer/room_visualizer_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, this.productId});
  final int? productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductVariant? _selectedVariant;
  int _activeImageIndex = 0;
  String? _selectedColorName;
  String? _selectedSizeName;

  Color getFlutterColor(String colorName) {
    final name = colorName.trim().toLowerCase();
    if (name.contains('nâu') || name.contains('nau'))
      return const Color(0xFF8B4513);
    if (name.contains('kem') || name.contains('be'))
      return const Color(0xFFF5F5DC);
    if (name.contains('đen') || name.contains('den')) return Colors.black;
    if (name.contains('trắng') || name.contains('trang')) return Colors.white;
    if (name.contains('xám') || name.contains('xam')) return Colors.grey;
    if (name.contains('vàng') || name.contains('vang')) return Colors.amber;
    if (name.contains('xanh') ||
        name.contains('blue') ||
        name.contains('green')) {
      if (name.contains('lá') || name.contains('la') || name.contains('green'))
        return Colors.green;
      return Colors.blue;
    }
    return Colors.grey.shade400;
  }

  String cleanMaterialText(String text) {
    final regex = RegExp(
      r'\(?\*?\)?\s*Tiêu chuẩn California Air Resources Board.*',
      caseSensitive: false,
    );
    var cleaned = text.replaceAll(regex, '');
    cleaned = cleaned.replaceAll('(*)', '');
    return cleaned.trim();
  }

  List<Product> _relatedProducts = [];
  List<Product> _frequentlyBoughtTogether = [];
  bool _isRelatedLoading = true;
  bool _loadedRelated = false;
  Product? _product;
  bool _attemptedProductLoad = false;

  List<Review> _reviews = [];
  Map<String, dynamic> _stats = {};
  bool _isReviewsLoading = true;
  bool _isStatsLoading = true;
  int? _selectedRatingFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedRelated) {
      final product = ModalRoute.of(context)!.settings.arguments as Product?;
      if (product != null) {
        _product = product;
        _fetchRelatedProducts(product);
        _loadReviewsAndStats(product.productId);
        _loadedRelated = true;
      } else if (!_attemptedProductLoad && widget.productId != null) {
        _attemptedProductLoad = true;
        _loadProduct(widget.productId!);
      }
    }
  }

  Future<void> _loadProduct(int id) async {
    try {
      final product = await ApiService().fetchProduct(id);
      if (!mounted) return;
      setState(() {
        _product = product;
        _loadedRelated = true;
      });
      _fetchRelatedProducts(product);
      _loadReviewsAndStats(product.productId);
    } catch (_) {
      if (mounted) setState(() => _loadedRelated = true);
    }
  }

  Future<void> _loadReviewsAndStats(int productId) async {
    if (mounted) {
      setState(() {
        _isReviewsLoading = true;
        _isStatsLoading = true;
      });
    }

    try {
      final api = ApiService();
      final stats = await api.fetchReviewStats(productId);
      final reviews = await api.fetchReviews(
        productId,
        rating: _selectedRatingFilter,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _isStatsLoading = false;
          _reviews = reviews;
          _isReviewsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      if (mounted) {
        setState(() {
          _isReviewsLoading = false;
          _isStatsLoading = false;
        });
      }
    }
  }

  Future<void> _filterReviews(int productId, int? rating) async {
    if (mounted) {
      setState(() {
        _selectedRatingFilter = rating;
        _isReviewsLoading = true;
      });
    }
    try {
      final api = ApiService();
      final reviews = await api.fetchReviews(productId, rating: rating);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isReviewsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error filtering reviews: $e');
      if (mounted) {
        setState(() {
          _isReviewsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRelatedProducts(Product currentProduct) async {
    try {
      final api = ApiService();
      // Fetch Content-Based and Apriori recommendations concurrently
      final futures = await Future.wait([
        api.fetchSimilarProducts(currentProduct.productId),
        api.fetchFrequentlyBoughtTogether(currentProduct.productId),
      ]);

      if (mounted) {
        setState(() {
          _relatedProducts = futures[0];
          _frequentlyBoughtTogether = futures[1];
          _isRelatedLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRelatedLoading = false;
        });
      }
    }
  }

  // Default selection helper
  void _initDefaultVariant(Product product) {
    if (_selectedVariant == null && product.productVariants.isNotEmpty) {
      _selectedVariant = product.productVariants.first;
      _selectedColorName = _selectedVariant!.color.trim();
      _selectedSizeName = _selectedVariant!.size.trim();
    }
  }

  void _onColorSelected(Product product, String c) {
    setState(() {
      _selectedColorName = c;
      var match = product.productVariants.firstWhere(
        (v) =>
            v.color.trim().toLowerCase() == c.toLowerCase() &&
            v.size.trim().toLowerCase() == _selectedSizeName?.toLowerCase(),
        orElse: () => product.productVariants.firstWhere(
          (v) => v.color.trim().toLowerCase() == c.toLowerCase(),
        ),
      );
      _selectedVariant = match;
      _selectedSizeName = match.size.trim();
      _activeImageIndex = 0;
    });
  }

  void _onSizeSelected(Product product, String s) {
    setState(() {
      _selectedSizeName = s;
      var match = product.productVariants.firstWhere(
        (v) =>
            v.size.trim().toLowerCase() == s.toLowerCase() &&
            v.color.trim().toLowerCase() == _selectedColorName?.toLowerCase(),
        orElse: () => product.productVariants.firstWhere(
          (v) => v.size.trim().toLowerCase() == s.toLowerCase(),
        ),
      );
      _selectedVariant = match;
      _selectedColorName = match.color.trim();
      _activeImageIndex = 0;
    });
  }

  bool _isColorAvailableWithCurrentSize(Product product, String colorName) {
    if (_selectedSizeName == null || _selectedSizeName!.isEmpty) return true;
    return product.productVariants.any(
      (v) =>
          v.color.trim().toLowerCase() == colorName.toLowerCase() &&
          v.size.trim().toLowerCase() == _selectedSizeName!.toLowerCase(),
    );
  }

  bool _isSizeAvailableWithCurrentColor(Product product, String sizeName) {
    if (_selectedColorName == null || _selectedColorName!.isEmpty) return true;
    return product.productVariants.any(
      (v) =>
          v.size.trim().toLowerCase() == sizeName.toLowerCase() &&
          v.color.trim().toLowerCase() == _selectedColorName!.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;

    if (product == null) {
      return MainLayout(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(context.l10n.productNotFound),
          ),
        ),
      );
    }

    _initDefaultVariant(product);

    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    return MainLayout(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : (isTablet ? 32.0 : 64.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMobile
                    ? _buildMobileLayout(context, product)
                    : _buildDesktopLayout(context, product),
                const SizedBox(height: 64),
                _buildFrequentlyBoughtSection(product),
                if (_frequentlyBoughtTogether.isNotEmpty)
                  const SizedBox(height: 64),
                _buildRelatedProductsSection(product),
                const SizedBox(height: 64),
                _buildReviewsSection(product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(product, true),
        const SizedBox(height: 24),
        _buildInfoSection(context, product),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Product product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildImageSection(product, false)),
        const SizedBox(width: 64),
        Expanded(flex: 1, child: _buildInfoSection(context, product)),
      ],
    );
  }

  Widget _buildImageSection(Product product, bool isMobile) {
    final List<ProductImage> variantImages = [];
    if (_selectedVariant != null &&
        _selectedVariant!.productImages.isNotEmpty) {
      variantImages.addAll(_selectedVariant!.productImages);
    } else {
      for (var variant in product.productVariants) {
        if (variant.productImages.isNotEmpty) {
          variantImages.addAll(variant.productImages);
          break;
        }
      }
    }

    String imageUrl = 'assets/images/products/product-.jpg';
    if (variantImages.isNotEmpty) {
      if (_activeImageIndex < 0 || _activeImageIndex >= variantImages.length) {
        _activeImageIndex = 0;
      }
      imageUrl = variantImages[_activeImageIndex].imageUrl;
    }

    if (imageUrl.startsWith('/') && !imageUrl.startsWith('/assets')) {
      imageUrl = ApiService.absoluteUrl(imageUrl);
    }

    final mainImageWidget = AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
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
    );

    if (variantImages.length <= 1) {
      return mainImageWidget;
    }

    final thumbnailsWidget = SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(variantImages.length, (index) {
          final imgUrl = variantImages[index].imageUrl;
          final fullImgUrl =
              imgUrl.startsWith('/') && !imgUrl.startsWith('/assets')
              ? ApiService.absoluteUrl(imgUrl)
              : imgUrl;
          final isSelected = index == _activeImageIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeImageIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  fullImgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        thumbnailsWidget,
        const SizedBox(width: 24),
        Expanded(child: mainImageWidget),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Product product) {
    final additionalPrice = _selectedVariant?.additionalPrice ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.productName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        if (product.hasActiveDiscount) ...[
          ProductDiscountBadge(product: product),
          const SizedBox(height: 8),
        ],
        ProductPrice(
          product: product,
          additionalPrice: additionalPrice,
          saleFontSize: 24,
          originalFontSize: 15,
          saleColor: const Color(0xFFC8815F),
        ),
        const SizedBox(height: 8),
        if (_selectedVariant != null)
          Text(
            _selectedVariant!.stockQuantity > 0
                ? context.l10n.inStock(_selectedVariant!.stockQuantity)
                : context.l10n.temporarilyOutOfStock,
            style: TextStyle(
              fontSize: 14,
              color: _selectedVariant!.stockQuantity > 0
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        if (product.productVariants.isNotEmpty) ...[
          // Color Selection
          Builder(
            builder: (context) {
              final uniqueColors = product.productVariants
                  .map((v) => v.color.trim())
                  .where((c) => c.isNotEmpty)
                  .toSet()
                  .toList();

              if (uniqueColors.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedColorName ?? uniqueColors.first,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: uniqueColors.map((colorName) {
                      final isSelected =
                          _selectedColorName?.toLowerCase() ==
                          colorName.toLowerCase();
                      final isAvailable = _isColorAvailableWithCurrentSize(
                        product,
                        colorName,
                      );
                      return GestureDetector(
                        onTap: () => _onColorSelected(product, colorName),
                        child: Opacity(
                          opacity: isAvailable ? 1.0 : 0.4,
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black87
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: getFlutterColor(colorName),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),

          // Size Selection
          Builder(
            builder: (context) {
              final uniqueSizes = product.productVariants
                  .map((v) => v.size.trim())
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList();

              if (uniqueSizes.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: uniqueSizes.map((sizeName) {
                      final isSelected =
                          _selectedSizeName?.toLowerCase() ==
                          sizeName.toLowerCase();
                      final isAvailable = _isSizeAvailableWithCurrentColor(
                        product,
                        sizeName,
                      );
                      return GestureDetector(
                        onTap: () => _onSizeSelected(product, sizeName),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : (isAvailable
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade100),
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Opacity(
                            opacity: isAvailable ? 1.0 : 0.4,
                            child: Text(
                              sizeName,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                                decoration: isAvailable
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ],
        Text(
          context.l10n.productDescription,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          product.description.isEmpty
              ? context.l10n.noProductDescription
              : product.description,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        if (_selectedVariant != null) ...[
          if (_selectedVariant!.size.isNotEmpty) ...[
            Text(
              context.l10n.dimensionsLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedVariant!.size,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_selectedVariant!.material.isNotEmpty) ...[
            Text(
              context.l10n.materialLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              cleanMaterialText(_selectedVariant!.material),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed:
                      (_selectedVariant != null &&
                          _selectedVariant!.stockQuantity <= 0)
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          final errorMsg = CartService.addItem(
                            product,
                            _selectedVariant,
                          );
                          if (errorMsg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMsg),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    foregroundColor: Colors.black,
                    disabledForegroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    (_selectedVariant != null &&
                            _selectedVariant!.stockQuantity <= 0)
                        ? context.l10n.outOfStock
                        : context.l10n.addToCart,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_selectedVariant != null &&
                          _selectedVariant!.stockQuantity <= 0)
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          final errorMsg = CartService.addItem(
                            product,
                            _selectedVariant,
                          );
                          if (errorMsg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMsg),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          } else {
                            Navigator.pushNamed(context, '/checkout');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.l10n.buyNow,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                WebPageRoute(
                  page: RoomVisualizerPage(
                    initialProduct: product,
                    initialVariant: _selectedVariant,
                  ),
                  animated: false,
                ),
              );
            },
            icon: const Icon(Icons.view_in_ar_outlined),
            label: Text(
              context.l10n.tryInYourRoom,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC8815F),
              side: const BorderSide(color: Color(0xFFC8815F), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequentlyBoughtSection(Product product) {
    if (_isRelatedLoading) return const SizedBox.shrink();
    if (_frequentlyBoughtTogether.isEmpty) return const SizedBox.shrink();

    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                context.l10n.frequentlyBoughtTogether,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 60,
                child: Divider(color: Colors.black, thickness: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _frequentlyBoughtTogether.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 24,
            crossAxisSpacing: 16,
            childAspectRatio: isMobile ? 0.68 : 0.76,
          ),
          itemBuilder: (context, index) {
            return _RelatedProductCard(
              product: _frequentlyBoughtTogether[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRelatedProductsSection(Product product) {
    if (_isRelatedLoading) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                context.l10n.relatedProducts,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 60,
                child: Divider(color: Colors.black, thickness: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _relatedProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 24,
            crossAxisSpacing: 16,
            childAspectRatio: isMobile ? 0.68 : 0.76,
          ),
          itemBuilder: (context, index) {
            return _RelatedProductCard(product: _relatedProducts[index]);
          },
        ),
      ],
    );
  }

  // ─── REVIEWS SECTION ──────────────────────────────────────────────────────
  Widget _buildReviewsSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                context.l10n.productReviews,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 60,
                child: Divider(color: Colors.black, thickness: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _isStatsLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildReviewsStatsCard(product),
        const SizedBox(height: 32),
        if (!_isStatsLoading) _buildFilterChipsBar(product),
        const SizedBox(height: 24),
        _isReviewsLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildReviewsList(product),
      ],
    );
  }

  Widget _buildReviewsStatsCard(Product product) {
    final isMobile = context.isMobile;
    final averageRating = _stats['averageRating'] ?? 0.0;
    final totalCount = _stats['totalCount'] ?? 0;

    // Breakdown parsing
    final rawBreakdown = _stats['breakdown'];
    Map<String, dynamic> breakdown = {};
    if (rawBreakdown is Map) {
      rawBreakdown.forEach((key, value) {
        breakdown[key.toString()] = value;
      });
    }

    Map<String, dynamic> getStarData(int star) {
      final key = star.toString();
      if (breakdown.containsKey(key)) {
        final starData = breakdown[key];
        if (starData is Map) {
          return {
            'count': starData['count'] ?? 0,
            'percentage': (starData['percentage'] ?? 0.0).toDouble(),
          };
        }
      }
      return {'count': 0, 'percentage': 0.0};
    }

    final double avg = (averageRating as num).toDouble();

    // Cột 1: Điểm trung bình
    final Widget ratingSummaryColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              avg.toStringAsFixed(1),
              style: TextStyle(
                fontSize: isMobile ? 48 : 56,
                fontWeight: FontWeight.bold,
                color: const Color(0xffff9900),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.star,
              color: const Color(0xffff9900),
              size: isMobile ? 32 : 40,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.averageRating(totalCount),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 11 : 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            height: 1.3,
          ),
        ),
      ],
    );

    // Cột 2: Phân phối sao
    final Widget starBreakdownColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(5, (index) {
        final int star = 5 - index;
        final data = getStarData(star);
        final int count = data['count'];
        final double percent = data['percentage'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '$star ★',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xffff9900),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.reviewDistribution(
                  percent.toStringAsFixed(0),
                  count,
                ),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }),
    );

    // Việc tạo đánh giá chỉ được bắt đầu từ lịch sử đơn đã giao.
    final Widget actionButtonColumn = Center(
      child: Column(
        children: [
          Text(
            context.l10n.reviewDeliveredOnly,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xff666666)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/profile', arguments: 'orders'),
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(context.l10n.viewOrderHistory),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe5e5e5)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ratingSummaryColumn,
                const Divider(height: 32),
                starBreakdownColumn,
                const SizedBox(height: 24),
                actionButtonColumn,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: ratingSummaryColumn),
                Container(
                  width: 1,
                  height: 120,
                  color: const Color(0xffe5e5e5),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                Expanded(flex: 5, child: starBreakdownColumn),
                Container(
                  width: 1,
                  height: 120,
                  color: const Color(0xffe5e5e5),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                Expanded(flex: 3, child: actionButtonColumn),
              ],
            ),
    );
  }

  Widget _buildFilterChipsBar(Product product) {
    final int? selected = _selectedRatingFilter;
    final List<Map<String, dynamic>> filters = [
      {'label': context.l10n.all, 'value': null},
      {'label': '5 ★', 'value': 5},
      {'label': '4 ★', 'value': 4},
      {'label': '3 ★', 'value': 3},
      {'label': '2 ★', 'value': 2},
      {'label': '1 ★', 'value': 1},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((f) {
        final isSelected = selected == f['value'];
        return ChoiceChip(
          label: Text(
            f['label'],
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedColor: const Color(0xff0066cc),
          backgroundColor: const Color(0xfff5f5f5),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xff0066cc)
                  : const Color(0xffe5e5e5),
            ),
          ),
          onSelected: (_) {
            _filterReviews(product.productId, f['value']);
          },
        );
      }).toList(),
    );
  }

  Widget _buildReviewsList(Product product) {
    if (_reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xfffafafa),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            context.l10n.noMatchingReviews,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 32, color: Color(0xffeeeeee)),
      itemBuilder: (context, index) {
        final r = _reviews[index];
        String displayDate = r.createdAt;
        try {
          final dt = DateTime.parse(r.createdAt);
          displayDate = '${dt.day}/${dt.month}/${dt.year}';
        } catch (_) {}

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                r.userFullName.isNotEmpty
                    ? r.userFullName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r.userFullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        displayDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (starIdx) {
                      return Icon(
                        starIdx < r.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.comment.isNotEmpty
                        ? r.comment
                        : context.l10n.noWrittenReview,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (r.adminReply != null && r.adminReply!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.storeReply,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              if (r.adminReplyAt != null)
                                Text(
                                  () {
                                    try {
                                      final dt = DateTime.parse(
                                        r.adminReplyAt!,
                                      );
                                      return '${dt.day}/${dt.month}/${dt.year}';
                                    } catch (_) {
                                      return '';
                                    }
                                  }(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            r.adminReply!,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RelatedProductCard extends StatefulWidget {
  const _RelatedProductCard({required this.product});
  final Product product;

  @override
  State<_RelatedProductCard> createState() => _RelatedProductCardState();
}

class _RelatedProductCardState extends State<_RelatedProductCard> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    String imageUrl = 'assets/images/products/product-.jpg';
    if (widget.product.productVariants.isNotEmpty) {
      for (var variant in widget.product.productVariants) {
        if (variant.productImages.isNotEmpty) {
          final firstImage = variant.productImages.first.imageUrl;
          if (firstImage.startsWith('http')) {
            imageUrl = firstImage;
          } else {
            imageUrl = ApiService.absoluteUrl(firstImage);
          }
          break;
        }
      }
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHover = true),
      onExit: (_) => setState(() => _isHover = false),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            WebPageRoute(
              settings: RouteSettings(
                name: '/product-detail?id=${widget.product.productId}',
                arguments: widget.product,
              ),
              page: ProductDetailPage(productId: widget.product.productId),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHover ? 1.02 : 1,
          duration: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: imageUrl.startsWith('http')
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[100],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              )
                            : Image.asset(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[100],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              ),
                      ),
                    ),
                    if (_isHover)
                      Positioned.fill(
                        child: Container(color: Colors.black.withAlpha(20)),
                      ),
                    if (widget.product.hasActiveDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: ProductDiscountBadge(product: widget.product),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.product.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              ProductPrice(
                product: widget.product,
                saleFontSize: 14,
                saleColor: const Color(0xFFC8815F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
