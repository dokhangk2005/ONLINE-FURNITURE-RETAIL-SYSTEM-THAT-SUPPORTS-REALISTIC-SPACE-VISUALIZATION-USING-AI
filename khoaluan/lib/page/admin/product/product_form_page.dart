import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../model/category.dart';
import '../../../model/product.dart';
import '../../../services/api_service.dart';
import '../../../widgets/currency_formatter.dart';
import '../../../l10n/l10n.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Category> _categories = [];

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descController;
  late TextEditingController codeController;
  late TextEditingController discountController;
  int? selectedParentCategoryId;
  int? selectedChildCategoryId;
  bool isHidden = false;
  bool isDiscountActive = false;
  DateTime? discountStartAt;
  DateTime? discountEndAt;

  // Danh sách biến thể sản phẩm
  List<Map<String, dynamic>> _variants = [];
  final Map<String, Uint8List> _uploadedImagePreviews = {};

  Widget _buildProductImage(String url, {BoxFit fit = BoxFit.cover}) {
    final localBytes = _uploadedImagePreviews[url];
    if (localBytes != null) {
      return Image.memory(
        localBytes,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.redAccent),
        ),
      );
    }
    return Image.network(
      ApiService.absoluteUrl(url),
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFFF5F5F5),
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.redAccent),
        ),
      ),
    );
  }

  final List<String> _furnitureColors = [
    'Gỗ sồi (Oak)',
    'Gỗ óc chó (Walnut)',
    'Gỗ tự nhiên',
    'Nâu gỗ (Brown)',
    'Trắng (White)',
    'Đen (Black)',
    'Xám (Grey)',
    'Kem (Beige)',
    'Nâu da bò (Tan)',
  ];

  final List<String> _furnitureSizes = [
    'Tiêu chuẩn',
    'S (Nhỏ)',
    'M (Vừa)',
    'L (Lớn)',
    '120x200 cm',
    '160x200 cm',
    '180x200 cm',
    '200x220 cm',
  ];

  String _localizedColor(String value) => switch (value) {
    'Gỗ sồi (Oak)' => context.l10n.oakColor,
    'Gỗ óc chó (Walnut)' => context.l10n.walnutColor,
    'Gỗ tự nhiên' => context.l10n.naturalWoodColor,
    'Nâu gỗ (Brown)' => context.l10n.brownWoodColor,
    'Trắng (White)' => context.l10n.whiteColor,
    'Đen (Black)' => context.l10n.blackColor,
    'Xám (Grey)' => context.l10n.greyColor,
    'Kem (Beige)' => context.l10n.beigeColor,
    'Nâu da bò (Tan)' => context.l10n.tanColor,
    _ => value,
  };

  String _localizedSize(String value) => switch (value) {
    'Tiêu chuẩn' => context.l10n.standardSize,
    'S (Nhỏ)' => context.l10n.smallSize,
    'M (Vừa)' => context.l10n.mediumSize,
    'L (Lớn)' => context.l10n.largeSize,
    _ => value,
  };

  String? _validateRequired(String? value, String field, int minLength) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.requiredField(field);
    }
    return value.trim().length < minLength
        ? context.l10n.minLengthField(field, minLength)
        : null;
  }

  String? _validateNumber(
    String? value,
    String field, {
    num min = 0,
    bool integer = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.requiredField(field);
    }
    final number = num.tryParse(value.trim().replaceAll(',', ''));
    if (number == null) return context.l10n.invalidNumber(field);
    if (integer && number != number.toInt()) {
      return context.l10n.integerRequired(field);
    }
    return number < min ? context.l10n.minimumValue(field, min) : null;
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.product?.productName ?? '',
    );
    priceController = TextEditingController(
      text: widget.product?.basePrice.toString() ?? '',
    );
    descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    codeController = TextEditingController(
      text: widget.product?.productCode ?? '',
    );
    discountController = TextEditingController(
      text: widget.product != null && widget.product!.discountPercent > 0
          ? widget.product!.discountPercent.toStringAsFixed(
              widget.product!.discountPercent % 1 == 0 ? 0 : 2,
            )
          : '',
    );
    isHidden = widget.product?.isDeleted ?? false;
    isDiscountActive = widget.product?.isDiscountActive ?? false;
    discountStartAt = widget.product?.discountStartAt?.toLocal();
    discountEndAt = widget.product?.discountEndAt?.toLocal();

    // Load variants if editing
    if (widget.product != null) {
      _variants = widget.product!.productVariants
          .map(
            (v) => <String, dynamic>{
              'variantId': v.variantId,
              'productId': v.productId,
              'material': v.material,
              'color': v.color,
              'size': v.size,
              'additionalPrice': v.additionalPrice,
              'stockQuantity': v.stockQuantity,
              'productImages': v.productImages
                  .map(
                    (img) => <String, dynamic>{
                      // Khi chỉnh sửa phải gửi URL file gốc về backend,
                      // không lưu URL hiển thị trung gian theo ImageId.
                      'imageUrl': img.sourceImageUrl,
                      'isThumbnail': img.isThumbnail,
                    },
                  )
                  .toList(),
            },
          )
          .toList();
    }

    _loadCategories();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    codeController.dispose();
    discountController.dispose();
    super.dispose();
  }

  Future<void> _pickDiscountDate({required bool isStart}) async {
    final initial =
        (isStart ? discountStartAt : discountEndAt) ??
        (isStart
            ? DateTime.now()
            : DateTime.now().add(const Duration(days: 7)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        discountStartAt = DateTime(picked.year, picked.month, picked.day);
      } else {
        discountEndAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          23,
          59,
          59,
        );
      }
    });
  }

  String _formatDate(DateTime? value) {
    if (value == null) return context.l10n.noDateLimit;
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _apiService.fetchCategories();
      setState(() {
        // API có thể trả cả danh mục gốc và bản lồng trong subCategories.
        // Chuẩn hóa theo ID để Dropdown luôn có đúng một option cho mỗi giá trị.
        final uniqueCategories = <int, Category>{};
        void addCategory(Category category) {
          uniqueCategories[category.categoryId] = category;
          for (final child in category.subCategories) {
            addCategory(child);
          }
        }

        for (final category in cats) {
          addCategory(category);
        }
        _categories = uniqueCategories.values.toList()
          ..sort((a, b) => a.categoryId.compareTo(b.categoryId));
        final productCatId = widget.product?.categoryId;
        if (productCatId != null) {
          // Find the category of the product
          final currentCat = _categories.firstWhere(
            (c) => c.categoryId == productCatId,
            orElse: () => Category(
              categoryId: 0,
              categoryName: '',
              categoryCode: '',
              imageUrl: '',
              subCategories: [],
            ),
          );
          if (currentCat.parentCategoryId != null) {
            final parentExists = _categories.any(
              (category) =>
                  category.categoryId == currentCat.parentCategoryId &&
                  category.parentCategoryId == null,
            );
            selectedParentCategoryId = parentExists
                ? currentCat.parentCategoryId
                : null;
            selectedChildCategoryId = parentExists ? productCatId : null;
          } else {
            selectedParentCategoryId = productCatId;
            selectedChildCategoryId = null;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.loadCategoriesError(e))),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVariantDialog({Map<String, dynamic>? variant, int? index}) {
    String selectedColor = variant != null
        ? variant['color']
        : _furnitureColors.first;
    String selectedSize = variant != null
        ? variant['size']
        : _furnitureSizes.first;
    final stockController = TextEditingController(
      text: variant != null ? variant['stockQuantity'].toString() : '0',
    );
    final priceController = TextEditingController(
      text: variant != null ? variant['additionalPrice'].toString() : '0',
    );
    bool isUploadingImg = false;
    List<String> variantImgUrls =
        (variant != null && variant['productImages'] != null)
        ? (variant['productImages'] as List)
              .map((img) => img['imageUrl'] as String)
              .toList()
        : [];

    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                variant == null
                    ? context.l10n.addNewVariant
                    : context.l10n.editVariant,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _furnitureColors.contains(selectedColor)
                            ? selectedColor
                            : _furnitureColors.first,
                        decoration: InputDecoration(
                          labelText: context.l10n.color,
                          border: const OutlineInputBorder(),
                        ),
                        items: _furnitureColors.map((color) {
                          return DropdownMenuItem(
                            value: color,
                            child: Text(_localizedColor(color)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedColor = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _furnitureSizes.contains(selectedSize)
                            ? selectedSize
                            : _furnitureSizes.first,
                        decoration: InputDecoration(
                          labelText: context.l10n.sizeControl,
                          border: const OutlineInputBorder(),
                        ),
                        items: _furnitureSizes.map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(_localizedSize(size)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedSize = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: stockController,
                        decoration: InputDecoration(
                          labelText: context.l10n.stockQuantity,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) => _validateNumber(
                          val,
                          context.l10n.stockQuantity,
                          integer: true,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: context.l10n.additionalPrice,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            _validateNumber(val, context.l10n.additionalPrice),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 16),
                      // Variant Multiple Images Picker
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.variantImages,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...variantImgUrls.map(
                                  (url) => Stack(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          child: _buildProductImage(url),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setDialogState(() {
                                              variantImgUrls.remove(url);
                                              _uploadedImagePreviews.remove(
                                                url,
                                              );
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isUploadingImg)
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF4E73DF),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () async {
                                      final result = await FilePicker.pickFiles(
                                        type: FileType.image,
                                        withData: true,
                                      );
                                      if (result == null) return;
                                      if (!mounted || !context.mounted) return;

                                      final selectedFile = result.files.first;
                                      if (selectedFile.bytes == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.l10n.cannotReadImage,
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setDialogState(() {
                                        isUploadingImg = true;
                                      });
                                      try {
                                        final url = await _apiService
                                            .uploadImage(
                                              selectedFile.bytes!,
                                              selectedFile.name,
                                            );
                                        if (!mounted || !context.mounted) {
                                          return;
                                        }
                                        setDialogState(() {
                                          _uploadedImagePreviews[url] =
                                              selectedFile.bytes!;
                                          variantImgUrls.add(url);
                                        });
                                      } catch (e) {
                                        if (!mounted || !context.mounted) {
                                          return;
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.l10n.imageUploadError(e),
                                            ),
                                          ),
                                        );
                                      } finally {
                                        if (mounted && context.mounted) {
                                          setDialogState(() {
                                            isUploadingImg = false;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.grey.shade50,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
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
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    context.l10n.cancel,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E73DF),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (!dialogFormKey.currentState!.validate()) {
                      return;
                    }
                    final int stock = int.tryParse(stockController.text) ?? 0;
                    final double addPrice =
                        double.tryParse(priceController.text) ?? 0.0;
                    setState(() {
                      final Map<String, dynamic> newVariant = <String, dynamic>{
                        'variantId': variant != null ? variant['variantId'] : 0,
                        'productId': variant != null ? variant['productId'] : 0,
                        'material': variant != null
                            ? variant['material']
                            : 'Gỗ',
                        'color': selectedColor,
                        'size': selectedSize,
                        'additionalPrice': addPrice,
                        'stockQuantity': stock,
                        'productImages': variantImgUrls
                            .map(
                              (url) => {
                                'imageUrl': url,
                                'isThumbnail': variantImgUrls.indexOf(url) == 0,
                              },
                            )
                            .toList(),
                      };
                      if (variant == null) {
                        _variants.add(newVariant);
                      } else if (index != null) {
                        _variants[index] = newVariant;
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text(context.l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.invalidProductFields),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final hasChildren = _categories.any(
      (c) => c.parentCategoryId == selectedParentCategoryId,
    );
    if (selectedParentCategoryId == null ||
        (hasChildren && selectedChildCategoryId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectFullCategoryPath)),
      );
      return;
    }

    final int finalCategoryId =
        selectedChildCategoryId ?? selectedParentCategoryId!;
    final double basePrice = double.tryParse(priceController.text) ?? 0.0;
    final double discountPercent =
        double.tryParse(discountController.text.trim()) ?? 0;
    if (discountPercent < 0 || discountPercent > 90) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.discountPercentRangeError)),
      );
      return;
    }
    if (isDiscountActive && discountPercent <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.activeDiscountRequiredError)),
      );
      return;
    }
    if (discountStartAt != null &&
        discountEndAt != null &&
        !discountEndAt!.isAfter(discountStartAt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.discountDateRangeError)),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final data = {
        'productName': nameController.text.trim(),
        'productCode': codeController.text.trim(),
        'basePrice': basePrice,
        'discountPercent': discountPercent,
        'isDiscountActive': isDiscountActive,
        'discountStartAt': discountStartAt?.toUtc().toIso8601String(),
        'discountEndAt': discountEndAt?.toUtc().toIso8601String(),
        'description': descController.text.trim(),
        'categoryId': finalCategoryId,
        'isDeleted': isHidden,
        'productVariants': _variants,
      };

      if (widget.product == null) {
        await _apiService.createProduct(data);
      } else {
        await _apiService.updateProduct(widget.product!.productId, data);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.saveProductError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double basePrice = double.tryParse(priceController.text) ?? 0.0;
    final double previewDiscount =
        double.tryParse(discountController.text.trim()) ?? 0;
    final bool previewHasDiscount =
        isDiscountActive && previewDiscount > 0 && previewDiscount <= 90;
    final double previewSalePrice = previewHasDiscount
        ? (basePrice * (100 - previewDiscount) / 100).roundToDouble()
        : basePrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: Text(
          widget.product == null
              ? context.l10n.addNewProduct
              : context.l10n.editProductInformation,
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4E73DF),
        elevation: 1,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _saveProduct,
            ),
        ],
      ),
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Form Inputs
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: nameController,
                                    validator: (val) => _validateRequired(
                                      val,
                                      context.l10n.productName,
                                      2,
                                    ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      labelText:
                                          context.l10n.productNameRequired,
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: codeController,
                                    validator: (val) {
                                      if (val != null &&
                                          val.trim().isNotEmpty) {
                                        return RegExp(
                                              r'^[A-Za-z0-9\-_]+$',
                                            ).hasMatch(val.trim())
                                            ? null
                                            : context.l10n.invalidCode(
                                                context.l10n.productCode,
                                              );
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      labelText: context.l10n.productCodeAuto,
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: priceController,
                                          validator: (val) => _validateNumber(
                                            val,
                                            context.l10n.basePrice,
                                            min: 1000,
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            labelText:
                                                context.l10n.basePriceRequired,
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 14,
                                                ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          isExpanded: true,
                                          menuMaxHeight: 350,
                                          decoration: InputDecoration(
                                            labelText:
                                                context.l10n.mainCategory,
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 14,
                                                ),
                                          ),
                                          initialValue:
                                              selectedParentCategoryId,
                                          items: _categories
                                              .where(
                                                (c) =>
                                                    c.parentCategoryId == null,
                                              )
                                              .map((c) {
                                                return DropdownMenuItem<int>(
                                                  value: c.categoryId,
                                                  child: Text(c.categoryName),
                                                );
                                              })
                                              .toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              selectedParentCategoryId = val;
                                              selectedChildCategoryId =
                                                  null; // Reset subcategory when parent changes
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F8FF),
                                      border: Border.all(
                                        color: const Color(0xFFC9D8FF),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            context.l10n.productDiscountTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          subtitle: Text(
                                            context.l10n.productDiscountHint,
                                          ),
                                          value: isDiscountActive,
                                          activeTrackColor: const Color(
                                            0xFF4E73DF,
                                          ),
                                          onChanged: (value) => setState(
                                            () => isDiscountActive = value,
                                          ),
                                        ),
                                        if (isDiscountActive) ...[
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: discountController,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (!isDiscountActive) {
                                                return null;
                                              }
                                              final number = double.tryParse(
                                                value?.trim() ?? '',
                                              );
                                              if (number == null ||
                                                  number <= 0 ||
                                                  number > 90) {
                                                return context
                                                    .l10n
                                                    .discountPercentRangeError;
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              labelText: context
                                                  .l10n
                                                  .discountPercentField,
                                              suffixText: '%',
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _DiscountDateField(
                                                  label: context
                                                      .l10n
                                                      .discountStartDate,
                                                  value: _formatDate(
                                                    discountStartAt,
                                                  ),
                                                  onTap: () =>
                                                      _pickDiscountDate(
                                                        isStart: true,
                                                      ),
                                                  onClear:
                                                      discountStartAt == null
                                                      ? null
                                                      : () => setState(
                                                          () =>
                                                              discountStartAt =
                                                                  null,
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _DiscountDateField(
                                                  label: context
                                                      .l10n
                                                      .discountEndDate,
                                                  value: _formatDate(
                                                    discountEndAt,
                                                  ),
                                                  onTap: () =>
                                                      _pickDiscountDate(
                                                        isStart: false,
                                                      ),
                                                  onClear: discountEndAt == null
                                                      ? null
                                                      : () => setState(
                                                          () => discountEndAt =
                                                              null,
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (selectedParentCategoryId != null &&
                                      _categories.any(
                                        (c) =>
                                            c.parentCategoryId ==
                                            selectedParentCategoryId,
                                      )) ...[
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<int>(
                                      key: ValueKey(
                                        'subcategory-$selectedParentCategoryId',
                                      ),
                                      isExpanded: true,
                                      menuMaxHeight: 350,
                                      decoration: InputDecoration(
                                        labelText: context.l10n.subCategory,
                                        border: const OutlineInputBorder(),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                      ),
                                      initialValue: selectedChildCategoryId,
                                      items: _categories
                                          .where(
                                            (c) =>
                                                c.parentCategoryId ==
                                                selectedParentCategoryId,
                                          )
                                          .map((c) {
                                            return DropdownMenuItem<int>(
                                              value: c.categoryId,
                                              child: Text(c.categoryName),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedChildCategoryId = val;
                                        });
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: descController,
                                    validator: (val) => _validateRequired(
                                      val,
                                      context.l10n.detailedDescription,
                                      5,
                                    ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      labelText: context
                                          .l10n
                                          .detailedDescriptionRequired,
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    maxLines: 4,
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          context.l10n.productVariantsHeading,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        icon: const Icon(Icons.add, size: 18),
                                        label: Text(context.l10n.addVariant),
                                        onPressed: () => _showVariantDialog(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_variants.isEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          context.l10n.noVariants,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _variants.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, idx) {
                                        final v = _variants[idx];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      context.l10n
                                                          .variantColorSize(
                                                            _localizedColor(
                                                              v['color']
                                                                  .toString(),
                                                            ),
                                                            _localizedSize(
                                                              v['size']
                                                                  .toString(),
                                                            ),
                                                          ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      context.l10n
                                                          .variantStockPrice(
                                                            v['stockQuantity'],
                                                            formatVND(
                                                              (v['additionalPrice']
                                                                      as num)
                                                                  .toDouble(),
                                                            ),
                                                          ),
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                  size: 18,
                                                ),
                                                onPressed: () =>
                                                    _showVariantDialog(
                                                      variant: v,
                                                      index: idx,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _variants.removeAt(idx);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  const SizedBox(height: 16),
                                  SwitchListTile(
                                    title: Text(
                                      context.l10n.temporarilyHideProduct,
                                    ),
                                    subtitle: Text(
                                      context.l10n.hiddenProductDescription,
                                    ),
                                    value: isHidden,
                                    activeTrackColor: const Color(0xFF4E73DF),
                                    onChanged: (val) {
                                      setState(() {
                                        isHidden = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          context.l10n.cancel,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF4E73DF,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        onPressed: _saveProduct,
                                        child: Text(
                                          context.l10n.save,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Right Live Preview
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.grey.shade50,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      context.l10n.productPreview,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 220,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: () {
                                        final hasVariantImg =
                                            _variants.isNotEmpty &&
                                            _variants.first['productImages'] !=
                                                null &&
                                            (_variants.first['productImages']
                                                    as List)
                                                .isNotEmpty;
                                        if (hasVariantImg) {
                                          final String url = _variants
                                              .first['productImages'][0]['imageUrl'];
                                          return _buildProductImage(url);
                                        }
                                        return const Center(
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                        );
                                      }(),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      nameController.text.trim().isEmpty
                                          ? context.l10n.productNamePlaceholder
                                          : nameController.text.trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (previewHasDiscount) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53935),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          context.l10n.discountPercent(
                                            previewDiscount % 1 == 0
                                                ? previewDiscount
                                                      .toStringAsFixed(0)
                                                : previewDiscount
                                                      .toStringAsFixed(2),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        formatVND(basePrice),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formatVND(previewSalePrice),
                                        style: const TextStyle(
                                          color: Color(0xFFE53935),
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        formatVND(basePrice),
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _DiscountDateField extends StatelessWidget {
  const _DiscountDateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: onClear == null
              ? const Icon(Icons.calendar_month_outlined, size: 20)
              : IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 18),
                ),
        ),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
