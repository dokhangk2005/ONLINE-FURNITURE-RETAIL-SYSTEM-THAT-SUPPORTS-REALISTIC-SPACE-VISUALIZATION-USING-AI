import 'package:flutter/material.dart';
import '../../../model/product.dart';
import '../../../services/api_service.dart';
import 'product_form_page.dart';
import '../../../widgets/currency_formatter.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../../widgets/web_page_route.dart';
import '../../../model/category.dart';
import '../../../l10n/l10n.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  List<Category> _categories = [];
  int? _selectedParentFilterCategoryId;
  int? _selectedChildFilterCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final cats = await _apiService.fetchCategories();
      final prods = await _apiService.fetchProducts(includeDeleted: true);
      if (mounted) {
        setState(() {
          _categories = cats;
          _products = prods;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.loadProductsError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: context.l10n.confirmDeleteProduct,
        content: context.l10n.confirmDeleteProductBody,
      ),
    );
    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.deleteProduct(id);
      await _loadProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.genericError(e))));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      context.l10n.productListTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4E73DF),
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 250,
                      height: 36,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: context.l10n.searchProductHint,
                          hintStyle: const TextStyle(fontSize: 13),
                          prefixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 8,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim().toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    DropdownButton<int?>(
                      value: _selectedParentFilterCategoryId,
                      hint: Text(context.l10n.mainCategory),
                      underline: Container(),
                      menuMaxHeight: 350,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(context.l10n.allCategories),
                        ),
                        ..._categories
                            .where((c) => c.parentCategoryId == null)
                            .map((c) {
                              return DropdownMenuItem<int?>(
                                value: c.categoryId,
                                child: Text(c.categoryName),
                              );
                            }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedParentFilterCategoryId = val;
                          _selectedChildFilterCategoryId = null;
                        });
                      },
                    ),
                    if (_selectedParentFilterCategoryId != null) ...[
                      const SizedBox(width: 16),
                      DropdownButton<int?>(
                        value: _selectedChildFilterCategoryId,
                        hint: Text(context.l10n.subCategory),
                        underline: Container(),
                        menuMaxHeight: 350,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(context.l10n.allChildren),
                          ),
                          ..._categories
                              .where(
                                (c) =>
                                    c.parentCategoryId ==
                                    _selectedParentFilterCategoryId,
                              )
                              .map((c) {
                                return DropdownMenuItem<int?>(
                                  value: c.categoryId,
                                  child: Text(c.categoryName),
                                );
                              }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedChildFilterCategoryId = val;
                          });
                        },
                      ),
                    ],
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E73DF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(context.l10n.addProduct),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      WebPageRoute(
                        page: const ProductFormPage(),
                        animated: false,
                      ),
                    );
                    if (result == true) {
                      _loadProducts();
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.grey.shade200),
                child: DataTable(
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 72,
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                  columns: [
                    DataColumn(
                      label: Text(
                        context.l10n.productCode,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        context.l10n.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        context.l10n.price,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        context.l10n.category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        context.l10n.status,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        context.l10n.actions,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: () {
                    var filtered = _selectedParentFilterCategoryId == null
                        ? _products
                        : (_selectedChildFilterCategoryId != null
                              ? _products
                                    .where(
                                      (p) =>
                                          p.categoryId ==
                                          _selectedChildFilterCategoryId,
                                    )
                                    .toList()
                              : () {
                                  final childIds = _categories
                                      .where(
                                        (c) =>
                                            c.parentCategoryId ==
                                            _selectedParentFilterCategoryId,
                                      )
                                      .map((c) => c.categoryId)
                                      .toList();
                                  return _products
                                      .where(
                                        (p) =>
                                            p.categoryId ==
                                                _selectedParentFilterCategoryId ||
                                            childIds.contains(p.categoryId),
                                      )
                                      .toList();
                                }());

                    if (_searchQuery.isNotEmpty) {
                      filtered = filtered.where((p) {
                        return p.productName.toLowerCase().contains(
                              _searchQuery,
                            ) ||
                            p.productCode.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }

                    return filtered.map((p) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              p.productCode.isNotEmpty
                                  ? p.productCode
                                  : '#${p.productId}',
                            ),
                          ),
                          DataCell(Text(p.productName)),
                          DataCell(
                            p.hasActiveDiscount
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatVND(p.basePrice),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      Text(
                                        formatVND(p.effectivePrice()),
                                        style: const TextStyle(
                                          color: Color(0xFFE53935),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        context.l10n.discountPercent(
                                          p.discountPercent % 1 == 0
                                              ? p.discountPercent
                                                    .toStringAsFixed(0)
                                              : p.discountPercent
                                                    .toStringAsFixed(2),
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFFE53935),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(formatVND(p.basePrice)),
                          ),
                          DataCell(
                            Text(
                              p.categoryName.isNotEmpty
                                  ? p.categoryName
                                  : context.l10n.categoryNumber(p.categoryId),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: p.isDeleted
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: p.isDeleted
                                      ? Colors.red.shade200
                                      : Colors.green.shade200,
                                ),
                              ),
                              child: Text(
                                p.isDeleted
                                    ? context.l10n.discontinued
                                    : context.l10n.onSale,
                                style: TextStyle(
                                  color: p.isDeleted
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      WebPageRoute(
                                        page: ProductFormPage(product: p),
                                        animated: false,
                                      ),
                                    );
                                    if (result == true) {
                                      _loadProducts();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteProduct(p.productId),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  }(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
