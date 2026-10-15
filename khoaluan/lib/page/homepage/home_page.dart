import 'dart:async';
import 'package:flutter/material.dart';
import '../../conf/const.dart';
import '../../conf/responsive.dart';
import '../../l10n/l10n.dart';
import '../../model/product.dart';
import '../../model/category.dart';
import '../../services/api_service.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/web_page_route.dart';
import '../../widgets/product_price.dart';
import '../product/product_detail_page.dart';

// ─── HomePage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  Timer? _timer;
  Future<List<dynamic>>? _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _homeDataFuture = Future.wait([
      ApiService().fetchCategories(),
      ApiService().fetchProducts(),
    ]);
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(
      const Duration(seconds: 6),
      (_) => _goToNextSlide(),
    );
  }

  void _resetAutoSlide() {
    _timer?.cancel();
    _startAutoSlide();
  }

  void _goToNextSlide() {
    setState(() {
      currentIndex = (currentIndex + 1) % homeSliderImages.length;
    });
  }

  void _goToPreviousSlide() {
    setState(() {
      currentIndex =
          (currentIndex - 1 + homeSliderImages.length) %
          homeSliderImages.length;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final screenHeight = context.screenHeight;
    final heroHeight = isMobile ? screenHeight * 0.6 : screenHeight;
    final navbarHeight = isMobile ? 64.0 : 78.0;

    return MainLayout(
      transparentNavbarAtTop: true,
      transparentThreshold: heroHeight - navbarHeight,
      child: FutureBuilder<List<dynamic>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                SizedBox(
                  height: heroHeight,
                  child: HomeHeroSection(
                    currentIndex: currentIndex,
                    onPrevious: () {
                      _goToPreviousSlide();
                      _resetAutoSlide();
                    },
                    onNext: () {
                      _goToNextSlide();
                      _resetAutoSlide();
                    },
                    isMobile: isMobile,
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Column(
              children: [
                SizedBox(
                  height: heroHeight,
                  child: HomeHeroSection(
                    currentIndex: currentIndex,
                    onPrevious: () {
                      _goToPreviousSlide();
                      _resetAutoSlide();
                    },
                    onNext: () {
                      _goToNextSlide();
                      _resetAutoSlide();
                    },
                    isMobile: isMobile,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(context.l10n.homeLoadError(snapshot.error!)),
                  ),
                ),
              ],
            );
          }

          final categories = snapshot.data?[0] as List<Category>? ?? [];
          final products = snapshot.data?[1] as List<Product>? ?? [];

          return Column(
            children: [
              SizedBox(
                height: heroHeight,
                child: HomeHeroSection(
                  currentIndex: currentIndex,
                  onPrevious: () {
                    _goToPreviousSlide();
                    _resetAutoSlide();
                  },
                  onNext: () {
                    _goToNextSlide();
                    _resetAutoSlide();
                  },
                  isMobile: isMobile,
                ),
              ),
              CategorySection(
                categories: categories
                    .where((c) => c.parentCategoryId == null)
                    .take(6)
                    .toList(),
              ),
              products.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Text(context.l10n.noProducts),
                      ),
                    )
                  : BestSellerSection(products: products),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

// ─── Hero Section
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    required this.currentIndex,
    required this.onPrevious,
    required this.onNext,
    this.isMobile = false,
  });

  final int currentIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 900),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image.asset(
              homeSliderImages[currentIndex],
              key: ValueKey<int>(currentIndex),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          right: isMobile ? 16 : 130,
          bottom: isMobile ? 24 : 70,
          child: SliderControls(
            currentIndex: currentIndex,
            total: homeSliderImages.length,
            onPrevious: onPrevious,
            onNext: onNext,
            compact: isMobile,
          ),
        ),
      ],
    );
  }
}

// ─── Slider Controls
class SliderControls extends StatelessWidget {
  const SliderControls({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.onPrevious,
    required this.onNext,
    this.compact = false,
  });

  final int currentIndex;
  final int total;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dividerWidth = compact ? 28.0 : 55.0;
    final spacing = compact ? 12.0 : 35.0;

    final divider = Container(
      margin: EdgeInsets.symmetric(horizontal: compact ? 8 : 16),
      width: dividerWidth,
      height: 1,
      color: Colors.white,
    );

    return Row(
      children: [
        SliderArrowButton(
          icon: Icons.arrow_back,
          onTap: onPrevious,
          compact: compact,
        ),
        divider,
        SizedBox(width: spacing),
        Text(
          '${currentIndex + 1} / $total',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 12 : 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        SizedBox(width: spacing),
        divider,
        SliderArrowButton(
          icon: Icons.arrow_forward,
          onTap: onNext,
          compact: compact,
        ),
      ],
    );
  }
}

class SliderArrowButton extends StatelessWidget {
  const SliderArrowButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 48.0;
    final iconSize = compact ? 24.0 : 34.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: Colors.transparent,
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}

// Helper to map category name to image
String _getCategoryImage(String categoryName) {
  final nameLower = categoryName.toLowerCase();
  if (nameLower.contains('ăn')) {
    return '${uriCategoryImg}.jpg';
  } else if (nameLower.contains('khách')) {
    return '${uriCategoryImg}.jpg';
  } else if (nameLower.contains('ngủ')) {
    return '${uriCategoryImg}.jpg';
  } else if (nameLower.contains('tắm')) {
    return '${uriCategoryImg}.jpg';
  } else if (nameLower.contains('việc')) {
    return '${uriCategoryImg}.jpg';
  } else if (nameLower.contains('lối vào') || nameLower.contains('hành lang')) {
    return '${uriCategoryImg}.jpg';
  }
  return '${uriCategoryImg}.jpg'; // default fallback
}

// ─── Category Section
class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;

    final crossAxisCount = switch (screenSize) {
      ScreenSize.mobile => 2,
      ScreenSize.tablet => 3,
      ScreenSize.desktop => 3,
    };

    final hPad = switch (screenSize) {
      ScreenSize.mobile => 20.0,
      ScreenSize.tablet => 40.0,
      ScreenSize.desktop => 64.0,
    };

    final titleSize = switch (screenSize) {
      ScreenSize.mobile => 28.0,
      ScreenSize.tablet => 34.0,
      ScreenSize.desktop => 42.0,
    };

    final spacing = switch (screenSize) {
      ScreenSize.mobile => 16.0,
      ScreenSize.tablet => 24.0,
      ScreenSize.desktop => 48.0,
    };

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPad, 60, hPad, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.categories,
            style: TextStyle(
              color: Colors.black,
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: screenSize == ScreenSize.mobile ? 28 : 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: screenSize == ScreenSize.mobile ? 1.0 : 1.25,
            ),
            itemBuilder: (context, index) {
              return CategoryCard(category: categories[index]);
            },
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  const CategoryCard({super.key, required this.category});

  final Category category;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final titleSize = context.isMobile ? 16.0 : 24.0;
    final imagePath = _getCategoryImage(widget.category.categoryName);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/products',
            arguments: widget.category.categoryId,
          );
        },
        child: AnimatedScale(
          scale: isHover ? 1.02 : 1,
          duration: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            widget.category.imageUrl.isNotEmpty &&
                                (widget.category.imageUrl.startsWith('http') ||
                                    widget.category.imageUrl.startsWith(
                                      '/uploads',
                                    ))
                            ? Image.network(
                                widget.category.imageUrl.startsWith('http')
                                    ? widget.category.imageUrl
                                    : 'http://localhost:5024${widget.category.imageUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              )
                            : Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              ),
                      ),
                      if (isHover)
                        Positioned.fill(
                          child: Container(color: Colors.black.withAlpha(25)),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.isMobile ? 8 : 16),
              Text(
                widget.category.categoryName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Best Seller Section ───────────────────────────────────────────────────────
class BestSellerSection extends StatelessWidget {
  const BestSellerSection({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;

    final crossAxisCount = switch (screenSize) {
      ScreenSize.mobile => 2,
      ScreenSize.tablet => 3,
      ScreenSize.desktop => 5,
    };

    final hPad = switch (screenSize) {
      ScreenSize.mobile => 20.0,
      ScreenSize.tablet => 40.0,
      ScreenSize.desktop => 64.0,
    };

    final titleSize = switch (screenSize) {
      ScreenSize.mobile => 28.0,
      ScreenSize.tablet => 34.0,
      ScreenSize.desktop => 42.0,
    };

    final crossSpacing = switch (screenSize) {
      ScreenSize.mobile => 14.0,
      ScreenSize.tablet => 20.0,
      ScreenSize.desktop => 24.0,
    };

    final mainSpacing = switch (screenSize) {
      ScreenSize.mobile => 24.0,
      ScreenSize.tablet => 32.0,
      ScreenSize.desktop => 40.0,
    };

    final bestSellers = products.where((p) => p.soldCount > 0).toList();
    if (bestSellers.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedProducts = List<Product>.from(bestSellers)
      ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
    final displayProducts = sortedProducts.take(10).toList();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.bestSellingProducts,
            style: TextStyle(
              color: Colors.black,
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: screenSize == ScreenSize.mobile ? 24 : 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainSpacing,
              crossAxisSpacing: crossSpacing,
              childAspectRatio: screenSize == ScreenSize.mobile ? 0.65 : 0.72,
            ),
            itemBuilder: (context, index) {
              return ProductCard(product: displayProducts[index]);
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/products'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 1.5),
                  ),
                  child: Text(
                    context.l10n.viewMore,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    String? imageUrl;
    if (widget.product.productVariants.isNotEmpty) {
      for (var variant in widget.product.productVariants) {
        if (variant.productImages.isNotEmpty) {
          imageUrl = variant.productImages.first.imageUrl;
          break;
        }
      }
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
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
          scale: isHover ? 1.02 : 1,
          duration: const Duration(milliseconds: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child:
                          imageUrl != null &&
                              (imageUrl.startsWith('http') ||
                                  imageUrl.startsWith('/uploads'))
                          ? Image.network(
                              imageUrl.startsWith('http')
                                  ? imageUrl
                                  : ApiService.absoluteUrl(imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            )
                          : Image.asset(
                              imageUrl ?? 'assets/images/products/product-.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                    ),
                    if (isHover)
                      Positioned.fill(
                        child: Container(color: Colors.white.withAlpha(38)),
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
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                widget.product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isMobile ? 13 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProductPrice(
                    product: widget.product,
                    saleFontSize: isMobile ? 12 : 15,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.product.averageRating > 0) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          widget.product.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '|',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: isMobile ? 10 : 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        context.l10n.soldCount(widget.product.soldCount),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: isMobile ? 10 : 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
