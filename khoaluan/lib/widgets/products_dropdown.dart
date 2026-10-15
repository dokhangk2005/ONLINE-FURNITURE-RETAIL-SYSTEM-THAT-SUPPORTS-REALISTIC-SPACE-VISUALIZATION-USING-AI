import 'package:flutter/material.dart';
import '../model/category.dart';
import '../services/api_service.dart';
import 'shared_navbar.dart';

class ProductsDropdown extends StatefulWidget {
  const ProductsDropdown({
    super.key,
    required this.title,
    required this.textColor,
    required this.onTap,
  });

  final String title;
  final Color textColor;
  final VoidCallback onTap;

  @override
  State<ProductsDropdown> createState() => _ProductsDropdownState();
}

class _ProductsDropdownState extends State<ProductsDropdown> {
  bool _isHovering = false;
  bool _isDropdownHovering = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService().fetchCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Category? _hoveredParent;

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setOverlayState) {
          final parents = _categories
              .where((c) => c.parentCategoryId == null)
              .toList();
          final List<Category> subCats = _hoveredParent == null
              ? []
              : _categories
                    .where(
                      (c) => c.parentCategoryId == _hoveredParent!.categoryId,
                    )
                    .toList();
          final bool hasSubCats = _hoveredParent != null && subCats.isNotEmpty;
          final double overlayWidth = hasSubCats ? 380.0 : 180.0;

          // Calculate height dynamically to prevent IntrinsicHeight layout assertions
          final int leftCount = parents.length;
          final int rightCount = subCats.length;
          final int maxItems = leftCount > rightCount ? leftCount : rightCount;
          final double calculatedHeight = (maxItems * 44.0) + 16.0;
          final double overlayHeight = calculatedHeight > 350.0
              ? 350.0
              : calculatedHeight;

          return Positioned(
            width: overlayWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height),
              child: MouseRegion(
                onEnter: (_) {
                  _isDropdownHovering = true;
                },
                onExit: (_) {
                  _isDropdownHovering = false;
                  _checkHideOverlay();
                },
                child: Material(
                  elevation: 4,
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Container(
                          height: overlayHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left column: Parent Categories
                              Container(
                                width: 180,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  itemCount: parents.length,
                                  itemBuilder: (context, index) {
                                    final cat = parents[index];
                                    final itemSubCats = _categories
                                        .where(
                                          (c) =>
                                              c.parentCategoryId ==
                                              cat.categoryId,
                                        )
                                        .toList();
                                    final bool isCurrentHovered =
                                        _hoveredParent?.categoryId ==
                                        cat.categoryId;

                                    return MouseRegion(
                                      onEnter: (_) {
                                        setOverlayState(() {
                                          _hoveredParent = cat;
                                        });
                                      },
                                      child: InkWell(
                                        onTap: () {
                                          _hideOverlay();
                                          Navigator.pushNamed(
                                            context,
                                            '/products',
                                            arguments: cat.categoryId,
                                          );
                                        },
                                        hoverColor: const Color(0xFFF3F4F6),
                                        child: Container(
                                          color: isCurrentHovered
                                              ? const Color(0xFFF3F4F6)
                                              : Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  cat.categoryName,
                                                  style: TextStyle(
                                                    color: isCurrentHovered
                                                        ? const Color(
                                                            0xFF4E73DF,
                                                          )
                                                        : Colors.black87,
                                                    fontSize: 14,
                                                    fontWeight: isCurrentHovered
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (itemSubCats.isNotEmpty)
                                                Icon(
                                                  Icons.chevron_right,
                                                  size: 16,
                                                  color: isCurrentHovered
                                                      ? const Color(0xFF4E73DF)
                                                      : Colors.grey,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Vertical divider and Right column (Subcategories)
                              if (hasSubCats) ...[
                                const VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                                Container(
                                  width: 199, // 200 total width minus divider
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: subCats.length,
                                    itemBuilder: (context, index) {
                                      final cat = subCats[index];
                                      return InkWell(
                                        onTap: () {
                                          _hideOverlay();
                                          Navigator.pushNamed(
                                            context,
                                            '/products',
                                            arguments: cat.categoryId,
                                          );
                                        },
                                        hoverColor: const Color(0xFFF3F4F6),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          child: Text(
                                            cat.categoryName,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hoveredParent = null;
  }

  void _checkHideOverlay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isHovering && !_isDropdownHovering) {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          _isHovering = true;
          _showOverlay();
        },
        onExit: (_) {
          _isHovering = false;
          _checkHideOverlay();
        },
        child: SharedNavbarButton(
          title: widget.title,
          onTap: widget.onTap,
          textColor: widget.textColor,
        ),
      ),
    );
  }
}
