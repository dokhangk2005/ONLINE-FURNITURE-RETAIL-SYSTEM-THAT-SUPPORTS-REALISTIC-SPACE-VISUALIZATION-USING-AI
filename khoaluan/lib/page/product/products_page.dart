import 'package:flutter/material.dart';
import '../../model/product.dart';
import '../../model/category.dart';
import '../../services/api_service.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/currency_formatter.dart';
import '../../conf/responsive.dart';
import '../../l10n/l10n.dart';
import '../../widgets/web_page_route.dart';
import '../../widgets/product_price.dart';
import 'product_detail_page.dart';
import '../../utils/string_utils.dart';

class ProductsPage extends StatefulWidget {
  final int? initialCategoryId;
  const ProductsPage({super.key, this.initialCategoryId});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> _allProducts = [];
  List<Category> _categories = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Filter states
  int? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedColor;
  String? _selectedSize;
  String _sortBy = 'featured'; // 'featured', 'priceAsc', 'priceDesc', 'newest'
  String? _searchQuery;
  bool _isFilterPanelVisible = true;
  bool _showAllColors = false;

  static const int _defaultVisibleColorCount = 6;

  // Pagination states
  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _isFilterPanelVisible = context.isDesktop;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _selectedCategoryId = args;
      } else if (args is String) {
        _searchQuery = args;
      } else if (args is Map<String, dynamic>) {
        _selectedCategoryId = args['categoryId'];
        _searchQuery = args['searchQuery'];
      }
      _isInitialLoad = false;
      _applyFilters();
    }
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        ApiService().fetchCategories(),
        ApiService().fetchProducts(),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0] as List<Category>;
          _allProducts = results[1] as List<Product>;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<Product> temp = List.from(_allProducts);

    // Filter by Search Query
    if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
      final q = removeVietnameseTones(_searchQuery!.trim().toLowerCase());
      temp = temp
          .where(
            (p) =>
                removeVietnameseTones(p.productName.toLowerCase()).contains(q),
          )
          .toList();
    }

    // Filter by Category
    if (_selectedCategoryId != null) {
      final subCategoryIds = _categories
          .where((c) => c.parentCategoryId == _selectedCategoryId)
          .map((c) => c.categoryId)
          .toList();

      temp = temp.where((p) {
        return p.categoryId == _selectedCategoryId ||
            subCategoryIds.contains(p.categoryId);
      }).toList();
    }

    // Filter by Price range
    if (_minPrice != null) {
      temp = temp.where((p) => p.effectivePrice() >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      temp = temp.where((p) => p.effectivePrice() <= _maxPrice!).toList();
    }

    // Filter by Color
    if (_selectedColor != null) {
      temp = temp.where((p) {
        return p.productVariants.any(
          (v) => v.color.trim().toLowerCase() == _selectedColor!.toLowerCase(),
        );
      }).toList();
    }

    // Filter by Size
    if (_selectedSize != null) {
      temp = temp.where((p) {
        return p.productVariants.any(
          (v) => v.size.trim().toLowerCase() == _selectedSize!.toLowerCase(),
        );
      }).toList();
    }

    // Sort Products
    if (_sortBy == 'priceAsc') {
      temp.sort((a, b) => a.effectivePrice().compareTo(b.effectivePrice()));
    } else if (_sortBy == 'priceDesc') {
      temp.sort((a, b) => b.effectivePrice().compareTo(a.effectivePrice()));
    } else if (_sortBy == 'newest') {
      temp.sort((a, b) => b.productId.compareTo(a.productId));
    } else {
      // Default: featured / original order
    }

    setState(() {
      _filteredProducts = temp;
      _currentPage = 1;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = widget.initialCategoryId;
      _minPrice = null;
      _maxPrice = null;
      _selectedColor = null;
      _selectedSize = null;
      _searchQuery = null;
      _sortBy = 'featured';
      _applyFilters();
    });
  }

  // Get unique colors and sizes from all products to populate filters
  Set<String> _getUniqueColors() {
    return _allProducts
        .expand((p) => p.productVariants.map((v) => v.color.trim()))
        .where((c) => c.isNotEmpty)
        .toSet();
  }

  Set<String> _getUniqueSizes() {
    return _allProducts
        .expand((p) => p.productVariants.map((v) => v.size.trim()))
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      transparentNavbarAtTop: false,
      child: _isLoading
          ? const SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            )
          : _errorMessage.isNotEmpty
          ? SizedBox(
              height: 400,
              child: Center(
                child: Text(
                  context.l10n.homeLoadError(_errorMessage),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.allProductsTitle,
                          textAlign: context.isMobile
                              ? TextAlign.center
                              : TextAlign.left,
                          style: TextStyle(
                            fontSize: context.isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Filter bar
                        _buildFilterBar(),
                        const SizedBox(height: 20),

                        if (context.isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isFilterPanelVisible) ...[
                                SizedBox(
                                  width: 240,
                                  child: _buildFilterPanel(),
                                ),
                                const SizedBox(width: 24),
                              ],
                              Expanded(child: _buildProductGrid()),
                            ],
                          )
                        else ...[
                          if (_isFilterPanelVisible) ...[
                            _buildFilterPanel(compact: true),
                            const SizedBox(height: 24),
                          ],
                          _buildProductGrid(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ─── SORT DROPDOWN ────────────────────────────────────────────────────────
  Widget _buildSortDropdown() {
    final Map<String, String> sortOptions = {
      'featured': context.l10n.sortFeatured,
      'newest': context.l10n.sortNewest,
      'priceAsc': context.l10n.sortPriceLowHigh,
      'priceDesc': context.l10n.sortPriceHighLow,
    };

    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _sortBy = value;
          _applyFilters();
        });
      },
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      itemBuilder: (context) => sortOptions.entries.map((entry) {
        return PopupMenuItem<String>(
          value: entry.key,
          child: Text(
            entry.value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: _sortBy == entry.key
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: _sortBy == entry.key
                  ? const Color(0xFF4E73DF)
                  : Colors.black87,
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sortOptions[_sortBy] ?? context.l10n.sortFeatured,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(width: 24),
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── FILTER BAR ───────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    final filterControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterToggleButton(),
        const SizedBox(width: 12),
        _buildFilterDropdownButton(
          label: _selectedCategoryId == null
              ? context.l10n.category.toUpperCase()
              : _categoryName(_selectedCategoryId!),
          onTap: _showCategoryMenu,
          isActive: _selectedCategoryId != null,
        ),
        const SizedBox(width: 12),
        _buildFilterDropdownButton(
          label: _getPriceFilterLabel(),
          onTap: _showPriceMenu,
          isActive: _minPrice != null || _maxPrice != null,
        ),
        const SizedBox(width: 12),
        _buildFilterDropdownButton(
          label: _selectedColor ?? context.l10n.colors.toUpperCase(),
          onTap: _showColorMenu,
          isActive: _selectedColor != null,
        ),
        const SizedBox(width: 12),
        _buildFilterDropdownButton(
          label: _selectedSize ?? context.l10n.sizes.toUpperCase(),
          onTap: _showSizeMenu,
          isActive: _selectedSize != null,
        ),
      ],
    );

    if (context.isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            filterControls,
            const SizedBox(width: 12),
            _buildSortDropdown(),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: filterControls,
          ),
        ),
        const SizedBox(width: 16),
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildFilterToggleButton() {
    final activeCount = [
      _selectedCategoryId,
      _minPrice ?? _maxPrice,
      _selectedColor,
      _selectedSize,
    ].where((value) => value != null).length;

    return OutlinedButton.icon(
      onPressed: () {
        setState(() => _isFilterPanelVisible = !_isFilterPanelVisible);
      },
      icon: const Icon(Icons.filter_alt_outlined, size: 18),
      label: Text(
        activeCount == 0
            ? context.l10n.filters
            : context.l10n.filtersActive(activeCount),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        minimumSize: const Size(128, 42),
        side: BorderSide(
          color: _isFilterPanelVisible
              ? Colors.black87
              : const Color(0xFFCBD5E1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _categoryName(int categoryId) {
    for (final category in _categories) {
      if (category.categoryId == categoryId) return category.categoryName;
      for (final child in category.subCategories) {
        if (child.categoryId == categoryId) return child.categoryName;
      }
    }
    return context.l10n.category.toUpperCase();
  }

  Widget _buildFilterPanel({bool compact = false}) {
    final categories = _categoryChoices();
    final colors = _getUniqueColors().toList()..sort();
    final visibleColors = _showAllColors
        ? colors
        : <String>{
            ...colors.take(_defaultVisibleColorCount),
            ?_selectedColor,
          }.toList();
    final hiddenColorCount = colors.length - visibleColors.length;
    final sizes = _getUniqueSizes().toList()..sort();
    final priceBounds = _availablePriceBounds();
    final selectedMin = (_minPrice ?? priceBounds.start)
        .clamp(priceBounds.start, priceBounds.end)
        .toDouble();
    final selectedMax = (_maxPrice ?? priceBounds.end)
        .clamp(priceBounds.start, priceBounds.end)
        .toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD6D9DE)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.detailedFilters,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (compact)
                IconButton(
                  tooltip: context.l10n.closeFilters,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() => _isFilterPanelVisible = false);
                  },
                  icon: const Icon(Icons.close, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.category,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...categories.map(
            (category) => CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _selectedCategoryId == category.categoryId,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '(${_categoryProductCount(category)})',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              onChanged: (_) {
                _selectedCategoryId = _selectedCategoryId == category.categoryId
                    ? null
                    : category.categoryId;
                _applyFilters();
              },
            ),
          ),
          const Divider(height: 28),
          Text(
            context.l10n.priceRange,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            min: priceBounds.start,
            max: priceBounds.end,
            divisions: 20,
            values: RangeValues(
              selectedMin <= selectedMax ? selectedMin : selectedMax,
              selectedMax >= selectedMin ? selectedMax : selectedMin,
            ),
            activeColor: Colors.black87,
            inactiveColor: const Color(0xFFD7DADF),
            labels: RangeLabels(formatVND(selectedMin), formatVND(selectedMax)),
            onChanged: (values) {
              _minPrice = values.start <= priceBounds.start
                  ? null
                  : values.start;
              _maxPrice = values.end >= priceBounds.end ? null : values.end;
              _applyFilters();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  formatVND(selectedMin),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  formatVND(selectedMax),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          if (colors.isNotEmpty) ...[
            const Divider(height: 28),
            Text(
              context.l10n.colors,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: visibleColors.map((color) {
                final selected = _selectedColor == color;
                return ChoiceChip(
                  selected: selected,
                  showCheckmark: selected,
                  avatar: CircleAvatar(
                    backgroundColor: _colorForName(color),
                    radius: 8,
                  ),
                  label: Text(color, style: const TextStyle(fontSize: 12)),
                  onSelected: (_) {
                    _selectedColor = selected ? null : color;
                    _applyFilters();
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFF0F1F3),
                  side: BorderSide(
                    color: selected ? Colors.black87 : const Color(0xFFD6D9DE),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }).toList(),
            ),
            if (_showAllColors || hiddenColorCount > 0) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: () {
                  setState(() => _showAllColors = !_showAllColors);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.black87,
                ),
                icon: Icon(
                  _showAllColors ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: Text(
                  _showAllColors
                      ? context.l10n.showFewerColors
                      : context.l10n.showMoreColors(hiddenColorCount),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
          if (sizes.isNotEmpty) ...[
            const Divider(height: 28),
            Text(
              context.l10n.sizes,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            ...sizes.map(
              (size) => CheckboxListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _selectedSize == size,
                title: Text(size, style: const TextStyle(fontSize: 13)),
                onChanged: (_) {
                  _selectedSize = _selectedSize == size ? null : size;
                  _applyFilters();
                },
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(context.l10n.clearFilters),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Category> _categoryChoices() {
    final roots = _categories
        .where((category) => category.parentCategoryId == null)
        .toList();
    final source = roots.isNotEmpty ? roots : _categories;
    final seenIds = <int>{};
    return source.where((category) => seenIds.add(category.categoryId)).toList()
      ..sort((a, b) => a.categoryName.compareTo(b.categoryName));
  }

  int _categoryProductCount(Category category) {
    final categoryIds = <int>{category.categoryId};

    void addChildren(int parentId) {
      for (final candidate in _categories) {
        if (candidate.parentCategoryId == parentId &&
            categoryIds.add(candidate.categoryId)) {
          addChildren(candidate.categoryId);
        }
      }
    }

    addChildren(category.categoryId);
    for (final child in category.subCategories) {
      categoryIds.add(child.categoryId);
    }
    return _allProducts
        .where((product) => categoryIds.contains(product.categoryId))
        .length;
  }

  ({double start, double end}) _availablePriceBounds() {
    if (_allProducts.isEmpty) return (start: 0, end: 1000000);
    final prices = _allProducts
        .map((product) => product.effectivePrice())
        .toList();
    var start = prices.reduce((a, b) => a < b ? a : b);
    var end = prices.reduce((a, b) => a > b ? a : b);
    start = (start / 500000).floor() * 500000.0;
    end = (end / 500000).ceil() * 500000.0;
    if (end <= start) end = start + 500000;
    return (start: start, end: end);
  }

  Color _colorForName(String value) {
    final normalized = removeVietnameseTones(value.toLowerCase());
    if (normalized.contains('trang') || normalized.contains('white')) {
      return Colors.white;
    }
    if (normalized.contains('den') || normalized.contains('black')) {
      return Colors.black;
    }
    if (normalized.contains('nau') || normalized.contains('brown')) {
      return Colors.brown;
    }
    if (normalized.contains('xam') ||
        normalized.contains('gray') ||
        normalized.contains('grey')) {
      return Colors.grey;
    }
    if (normalized.contains('be') || normalized.contains('beige')) {
      return const Color(0xFFD8C3A5);
    }
    if (normalized.contains('do') || normalized.contains('red')) {
      return Colors.red;
    }
    if (normalized.contains('vang') || normalized.contains('yellow')) {
      return Colors.amber;
    }
    if (normalized.contains('xanh') || normalized.contains('blue')) {
      return Colors.blue;
    }
    return Colors.blueGrey;
  }

  Widget _buildFilterDropdownButton({
    required String label,
    required void Function(BuildContext) onTap,
    required bool isActive,
  }) {
    return Builder(
      builder: (buttonContext) {
        return GestureDetector(
          onTap: () => onTap(buttonContext),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? Colors.black : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(4),
              color: isActive ? Colors.black.withAlpha(8) : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPriceFilterLabel() {
    if (_minPrice == null && _maxPrice == null) {
      return context.l10n.productPrice;
    }
    if (_minPrice != null && _maxPrice != null) {
      return '${formatVND(_minPrice!)} - ${formatVND(_maxPrice!)}';
    }
    if (_minPrice != null) {
      return context.l10n.abovePrice(formatVND(_minPrice!));
    }
    return context.l10n.belowPrice(formatVND(_maxPrice!));
  }

  // ─── FILTER POPUP MENUS ───────────────────────────────────────────────────
  void _showCategoryMenu(BuildContext buttonContext) {
    final buttonRenderBox = buttonContext.findRenderObject() as RenderBox;
    final position = buttonRenderBox.localToGlobal(Offset.zero);
    final size = buttonRenderBox.size;

    // Determine the active parent category ID if navigating from one
    int? activeParentId;
    if (widget.initialCategoryId != null) {
      final cat = _categories.firstWhere(
        (c) => c.categoryId == widget.initialCategoryId,
        orElse: () => Category(
          categoryId: 0,
          categoryName: '',
          categoryCode: '',
          imageUrl: '',
          subCategories: [],
        ),
      );
      if (cat.categoryId != 0) {
        activeParentId = cat.parentCategoryId ?? cat.categoryId;
      }
    }

    showMenu<int?>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 400,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      items: [
        PopupMenuItem<int?>(
          value: -1,
          child: Text(
            activeParentId != null
                ? context.l10n.allSubcategories
                : context.l10n.allCategories,
          ),
        ),
        ...() {
          if (activeParentId != null) {
            return _categories.where(
              (c) => c.parentCategoryId == activeParentId,
            );
          }
          return _categories.where((c) => c.parentCategoryId != null);
        }().map((cat) {
          return PopupMenuItem<int?>(
            value: cat.categoryId,
            child: Text(cat.categoryName),
          );
        }),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedCategoryId = value == -1
              ? (activeParentId ?? widget.initialCategoryId)
              : value;
          _applyFilters();
        });
      }
    });
  }

  void _showPriceMenu(BuildContext buttonContext) {
    final buttonRenderBox = buttonContext.findRenderObject() as RenderBox;
    final position = buttonRenderBox.localToGlobal(Offset.zero);
    final size = buttonRenderBox.size;

    showMenu<Map<String, double?>>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 400,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      items: [
        PopupMenuItem<Map<String, double?>>(
          value: const {'min': null, 'max': null},
          child: Text(context.l10n.allPriceRanges),
        ),
        PopupMenuItem<Map<String, double?>>(
          value: const {'min': 0, 'max': 5000000},
          child: Text(context.l10n.belowPrice(formatVND(5000000.0))),
        ),
        PopupMenuItem<Map<String, double?>>(
          value: const {'min': 5000000, 'max': 10000000},
          child: Text('${formatVND(5000000)} – ${formatVND(10000000)}'),
        ),
        PopupMenuItem<Map<String, double?>>(
          value: const {'min': 10000000, 'max': 20000000},
          child: Text('${formatVND(10000000)} – ${formatVND(20000000)}'),
        ),
        PopupMenuItem<Map<String, double?>>(
          value: const {'min': 20000000, 'max': null},
          child: Text(context.l10n.abovePrice(formatVND(20000000.0))),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _minPrice = value['min'];
          _maxPrice = value['max'];
          _applyFilters();
        });
      }
    });
  }

  void _showColorMenu(BuildContext buttonContext) {
    final buttonRenderBox = buttonContext.findRenderObject() as RenderBox;
    final position = buttonRenderBox.localToGlobal(Offset.zero);
    final size = buttonRenderBox.size;
    final colors = _getUniqueColors();

    showMenu<String?>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 400,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      items: [
        PopupMenuItem<String?>(
          value: 'all',
          child: Text(context.l10n.allColors),
        ),
        ...colors.map((color) {
          return PopupMenuItem<String?>(value: color, child: Text(color));
        }),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedColor = value == 'all' ? null : value;
          _applyFilters();
        });
      }
    });
  }

  void _showSizeMenu(BuildContext buttonContext) {
    final buttonRenderBox = buttonContext.findRenderObject() as RenderBox;
    final position = buttonRenderBox.localToGlobal(Offset.zero);
    final size = buttonRenderBox.size;
    final sizes = _getUniqueSizes();

    showMenu<String?>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 400,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      items: [
        PopupMenuItem<String?>(
          value: 'all',
          child: Text(context.l10n.allSizes),
        ),
        ...sizes.map((size) {
          return PopupMenuItem<String?>(value: size, child: Text(size));
        }),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedSize = value == 'all' ? null : value;
          _applyFilters();
        });
      }
    });
  }

  // ─── PRODUCT GRID ─────────────────────────────────────────────────────────
  Widget _buildProductGrid() {
    if (_filteredProducts.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            context.l10n.noMatchingProducts,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ),
      );
    }

    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);

    // Calculate paginated products
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final paginatedProducts = _filteredProducts.sublist(
      startIndex,
      endIndex > _filteredProducts.length ? _filteredProducts.length : endIndex,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paginatedProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 24,
            crossAxisSpacing: 16,
            childAspectRatio: isMobile ? 0.68 : 0.76,
          ),
          itemBuilder: (context, index) {
            return _ProductsPageProductCard(product: paginatedProducts[index]);
          },
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildPagination() {
    final totalPages = (_filteredProducts.length / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey, size: 20),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
          ),
          const SizedBox(width: 16),
          ...List.generate(totalPages, (index) {
            final pageNum = index + 1;
            final isSelected = pageNum == _currentPage;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentPage = pageNum;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    pageNum.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── DEDICATED PRODUCT CARD TO MATCH THE MOCKUP EXACTLY ──────────────────────
class _ProductsPageProductCard extends StatefulWidget {
  const _ProductsPageProductCard({required this.product});

  final Product product;

  @override
  State<_ProductsPageProductCard> createState() =>
      _ProductsPageProductCardState();
}

class _ProductsPageProductCardState extends State<_ProductsPageProductCard> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

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
                    // Hover overlay
                    if (_isHover)
                      Positioned.fill(
                        child: Container(color: Colors.black.withAlpha(20)),
                      ),
                    // Red Promotion Tag (-25%)
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
              // Product title
              Text(
                widget.product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              // Price and sold count row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProductPrice(
                    product: widget.product,
                    saleFontSize: isMobile ? 12 : 14,
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
