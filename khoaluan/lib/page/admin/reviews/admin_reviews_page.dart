import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../../model/review.dart';
import '../../../model/product.dart';
import '../../../model/category.dart';
import '../../../services/api_service.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  // Level 1 data
  List<AdminProductReviewSummary> _productsSummary = [];
  List<Category> _allCategories = [];
  List<Product> _allProducts = [];

  // Filter state
  int? _selectedParentCategoryId;
  int? _selectedSubcategoryId;

  // Level 2 data
  AdminProductReviewSummary? _selectedProduct;
  List<Review> _productReviews = [];
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadProductsSummary();
  }

  Future<void> _loadProductsSummary() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _apiService.fetchAdminProductsReviewsSummary();
      final categories = await _apiService.fetchCategories();
      final products = await _apiService.fetchProducts();
      setState(() {
        _productsSummary = summary;
        _allCategories = categories;
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(context.l10n.productListLoadError(e.toString()));
    }
  }

  Future<void> _loadProductReviews(AdminProductReviewSummary product) async {
    setState(() {
      _selectedProduct = product;
      _isLoadingReviews = true;
    });
    try {
      final reviews = await _apiService.fetchAdminProductReviews(
        product.productId,
      );
      setState(() {
        _productReviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => _isLoadingReviews = false);
      _showSnackBar(context.l10n.productReviewsLoadError(e.toString()));
    }
  }

  Future<void> _approveReview(int reviewId) async {
    try {
      await _apiService.approveReviewAdmin(reviewId);
      _showSnackBar(context.l10n.reviewApprovedSuccess);
      if (_selectedProduct != null) {
        _loadProductReviews(_selectedProduct!);
        _loadProductsSummary(); // reload summaries as well
      }
    } catch (e) {
      _showSnackBar(context.l10n.reviewApprovalError(e.toString()));
    }
  }

  Future<void> _rejectReview(int reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmReject),
        content: Text(context.l10n.confirmRejectReview),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.reject),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.rejectReviewAdmin(reviewId);
      _showSnackBar(context.l10n.reviewRejectedSuccess);
      if (_selectedProduct != null) {
        _loadProductReviews(_selectedProduct!);
        _loadProductsSummary(); // reload summaries as well
      }
    } catch (e) {
      _showSnackBar(context.l10n.reviewRejectError(e.toString()));
    }
  }

  Future<void> _showReplyDialog(Review review) async {
    final replyController = TextEditingController(
      text: review.adminReply ?? '',
    );
    bool submittingReply = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(context.l10n.replyToReview),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.reviewCustomerNameLabel(review.userFullName),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.commentQuoted(review.comment),
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.replyContent,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: replyController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: context.l10n.storeReplyHint,
                      filled: true,
                      fillColor: const Color(0xfff8f9fa),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: submittingReply
                    ? null
                    : () => Navigator.pop(context),
                child: Text(
                  context.l10n.cancel,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: submittingReply
                    ? null
                    : () async {
                        if (replyController.text.trim().isEmpty) {
                          _showSnackBar(context.l10n.replyRequired);
                          return;
                        }
                        setDialogState(() => submittingReply = true);
                        try {
                          final message = await _apiService.submitAdminReply(
                            review.reviewId,
                            replyController.text.trim(),
                          );
                          if (context.mounted) Navigator.pop(context);
                          _showSnackBar(message);
                          if (_selectedProduct != null) {
                            _loadProductReviews(_selectedProduct!);
                          }
                        } catch (e) {
                          _showSnackBar(
                            context.l10n.sendReplyError(e.toString()),
                          );
                          setDialogState(() => submittingReply = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: submittingReply
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(context.l10n.sendReply),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: _selectedProduct == null ? _buildLevel1View() : _buildLevel2View(),
    );
  }

  // MÀN HÌNH CẤP 1: DANH SÁCH SẢN PHẨM TỔNG HỢP
  Widget _buildLevel1View() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.reviewManagementByProduct,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5A5C69),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E73DF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                context.l10n.refresh,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: _loadProductsSummary,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB8D1FF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF3567C8),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.aiReviewModerationDescription,
                  style: const TextStyle(color: Color(0xFF244A91), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.businessProducts,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E73DF),
                      ),
                    ),
                    if (!_isLoading && _allCategories.isNotEmpty) ...[
                      const SizedBox(width: 24),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<int?>(
                                value: _selectedParentCategoryId,
                                menuMaxHeight: 350,
                                decoration: InputDecoration(
                                  labelText: context.l10n.parentCategory,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      context.l10n.allParentCategories,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  ..._allCategories
                                      .where((c) => c.parentCategoryId == null)
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c.categoryId,
                                          child: Text(
                                            c.categoryName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedParentCategoryId = val;
                                    _selectedSubcategoryId = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<int?>(
                                value: _selectedSubcategoryId,
                                menuMaxHeight: 350,
                                disabledHint: Text(
                                  context.l10n.chooseSubcategory,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                decoration: InputDecoration(
                                  labelText: context.l10n.subcategory,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                                items: _selectedParentCategoryId == null
                                    ? null
                                    : [
                                        DropdownMenuItem(
                                          value: null,
                                          child: Text(
                                            context.l10n.allSubcategories,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        ..._allCategories
                                            .where(
                                              (c) =>
                                                  c.parentCategoryId ==
                                                  _selectedParentCategoryId,
                                            )
                                            .map(
                                              (c) => DropdownMenuItem(
                                                value: c.categoryId,
                                                child: Text(
                                                  c.categoryName,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ],
                                onChanged: _selectedParentCategoryId == null
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _selectedSubcategoryId = val;
                                        });
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : () {
                        final filteredSummaries = _productsSummary.where((p) {
                          final prod = _allProducts.firstWhere(
                            (item) => item.productId == p.productId,
                            orElse: () => Product(
                              productId: 0,
                              categoryId: 0,
                              categoryName: '',
                              productName: '',
                              productCode: '',
                              basePrice: 0,
                              description: '',
                              isDeleted: false,
                              averageRating: 0,
                              reviewCount: 0,
                              productVariants: [],
                              soldCount: 0,
                            ),
                          );
                          if (prod.productId == 0) return true;

                          if (_selectedParentCategoryId != null) {
                            final cat = _allCategories.firstWhere(
                              (c) => c.categoryId == prod.categoryId,
                              orElse: () => Category(
                                categoryId: 0,
                                categoryName: '',
                                categoryCode: '',
                                imageUrl: '',
                                subCategories: [],
                              ),
                            );
                            if (cat.categoryId == 0) return false;
                            final actualParentId =
                                cat.parentCategoryId ?? cat.categoryId;
                            if (actualParentId != _selectedParentCategoryId)
                              return false;
                          }

                          if (_selectedSubcategoryId != null) {
                            if (prod.categoryId != _selectedSubcategoryId)
                              return false;
                          }

                          return true;
                        }).toList();

                        if (filteredSummaries.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(40.0),
                            child: Center(
                              child: Text(
                                context.l10n.noProductsMatchFilter,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xFFF8F9FC),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  context.l10n.productCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.averageStars,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.totalReviews,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.pendingApproval,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  context.l10n.actions,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: filteredSummaries.map((p) {
                              final prod = _allProducts.firstWhere(
                                (item) => item.productId == p.productId,
                                orElse: () => Product(
                                  productId: 0,
                                  categoryId: 0,
                                  categoryName: '',
                                  productName: '',
                                  productCode: '',
                                  basePrice: 0,
                                  description: '',
                                  isDeleted: false,
                                  averageRating: 0,
                                  reviewCount: 0,
                                  productVariants: [],
                                  soldCount: 0,
                                ),
                              );
                              final code =
                                  (prod.productId != 0 &&
                                      prod.productCode.isNotEmpty)
                                  ? prod.productCode
                                  : '#${p.productId}';
                              return DataRow(
                                cells: [
                                  DataCell(Text(code)),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 300,
                                      ),
                                      child: Text(
                                        p.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          p.averageRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      context.l10n.reviewCountText(
                                        p.totalCount,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    p.pendingCount > 0
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              context.l10n.pendingReviewCount(
                                                p.pendingCount,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            '0',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                  ),
                                  DataCell(
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF4E73DF,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.list, size: 14),
                                      label: Text(
                                        context.l10n.viewDetails,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      onPressed: () => _loadProductReviews(p),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      }(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // MÀN HÌNH CẤP 2: CHI TIẾT ĐÁNH GIÁ CỦA SẢN PHẨM ĐÃ CHỌN
  Widget _buildLevel2View() {
    final p = _selectedProduct!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _selectedProduct = null;
                  _productReviews = [];
                });
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.productReviewHeading(p.productName),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A5C69),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E73DF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                context.l10n.refresh,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () => _loadProductReviews(p),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.detailedReviewList,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E73DF),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.ratingReviewSummary(
                            p.averageRating.toStringAsFixed(1),
                            p.totalCount,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _isLoadingReviews
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _productReviews.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Text(
                            context.l10n.productHasNoReviews,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFFF8F9FC),
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                context.l10n.sender,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                context.l10n.starCount,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                context.l10n.customerOpinion,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                context.l10n.time,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                context.l10n.status,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                context.l10n.storeReply,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                context.l10n.actions,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: _productReviews.map((r) {
                            String displayDate = r.createdAt;
                            try {
                              final dt = DateTime.parse(r.createdAt);
                              displayDate = '${dt.day}/${dt.month}/${dt.year}';
                            } catch (_) {}

                            return DataRow(
                              cells: [
                                DataCell(Text(r.userFullName)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < r.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      );
                                    }),
                                  ),
                                ),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 220,
                                    ),
                                    child: Text(
                                      r.comment.isNotEmpty
                                          ? r.comment
                                          : context.l10n.noComment,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(displayDate)),
                                DataCell(
                                  r.isApproved
                                      ? Text(
                                          context.l10n.approved,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Text(
                                          context.l10n.pendingApproval,
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 220,
                                    ),
                                    child: Text(
                                      r.adminReply != null &&
                                              r.adminReply!.isNotEmpty
                                          ? r.adminReply!
                                          : context.l10n.notReplied,
                                      style: TextStyle(
                                        color: r.adminReply != null
                                            ? Colors.black87
                                            : Colors.grey,
                                        fontStyle: r.adminReply == null
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!r.isApproved)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                          tooltip: context.l10n.approve,
                                          onPressed: () =>
                                              _approveReview(r.reviewId),
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.reply,
                                          color: Colors.blue,
                                        ),
                                        tooltip: context.l10n.reply,
                                        onPressed: () => _showReplyDialog(r),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        tooltip: context.l10n.deleteReview,
                                        onPressed: () =>
                                            _rejectReview(r.reviewId),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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
