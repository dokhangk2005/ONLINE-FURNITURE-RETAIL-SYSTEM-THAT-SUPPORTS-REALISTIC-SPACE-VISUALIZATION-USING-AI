import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../model/category.dart';
import '../../../services/api_service.dart';
import '../../../l10n/l10n.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;
  final int? initialParentId;
  const CategoryFormPage({super.key, this.category, this.initialParentId});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TextEditingController nameController;
  late TextEditingController codeController;

  Uint8List?
  selectedImageNameBytes; // placeholder if needed, let's keep original
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  String currentImageUrl = '';
  List<Category> _categories = [];
  int? selectedParentId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.category?.categoryName ?? '',
    );
    codeController = TextEditingController(
      text: widget.category?.categoryCode ?? '',
    );
    currentImageUrl = widget.category?.imageUrl ?? '';
    selectedParentId =
        widget.category?.parentCategoryId ?? widget.initialParentId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _apiService.fetchCategories();
      setState(() {
        _categories = cats;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.invalidCategoryName),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      String finalImageUrl = currentImageUrl;

      // If user picked a local image, upload it first to get relative URL
      if (selectedImageBytes != null && selectedImageName != null) {
        finalImageUrl = await _apiService.uploadImage(
          selectedImageBytes!,
          selectedImageName!,
        );
      }

      if (widget.category == null) {
        await _apiService.createCategory(
          nameController.text.trim(),
          imageUrl: finalImageUrl,
          categoryCode: codeController.text.trim(),
          parentCategoryId: selectedParentId,
        );
      } else {
        await _apiService.updateCategory(
          widget.category!.categoryId,
          nameController.text.trim(),
          imageUrl: finalImageUrl,
          categoryCode: codeController.text.trim(),
          parentCategoryId: selectedParentId,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.saveCategoryError(e))),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: Text(
          widget.category == null
              ? context.l10n.addNewCategory
              : context.l10n.editCategory,
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4E73DF),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.categoryInformation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4E73DF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return context.l10n.requiredField(
                              context.l10n.categoryName,
                            );
                          }
                          return val.trim().length < 2
                              ? context.l10n.minLengthField(
                                  context.l10n.categoryName,
                                  2,
                                )
                              : null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: context.l10n.categoryNameRequired,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: codeController,
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            return RegExp(
                                  r'^[A-Za-z0-9\-_]+$',
                                ).hasMatch(val.trim())
                                ? null
                                : context.l10n.invalidCode(
                                    context.l10n.categoryCode,
                                  );
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: context.l10n.categoryCodeAuto,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.category == null || _categories.isNotEmpty)
                        DropdownButtonFormField<int?>(
                          value: selectedParentId,
                          decoration: InputDecoration(
                            labelText: context.l10n.parentCategoryOptional,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(context.l10n.rootCategoryOption),
                            ),
                            ..._categories
                                .where(
                                  (c) =>
                                      c.parentCategoryId == null &&
                                      (widget.category == null ||
                                          c.categoryId !=
                                              widget.category!.categoryId),
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
                              selectedParentId = val;
                            });
                          },
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (selectedParentId == null) ...[
                        // Image picker section for Category
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.categoryImage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4E73DF),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.upload_file,
                                      size: 16,
                                    ),
                                    label: Text(
                                      context.l10n.uploadFromDevice,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () async {
                                      final result = await FilePicker.pickFiles(
                                        type: FileType.image,
                                        withData: true,
                                      );
                                      if (result != null &&
                                          result.files.first.bytes != null) {
                                        setState(() {
                                          selectedImageBytes =
                                              result.files.first.bytes;
                                          selectedImageName =
                                              result.files.first.name;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedImageName != null
                                          ? context.l10n.selectedFile(
                                              selectedImageName!,
                                            )
                                          : (currentImageUrl.isNotEmpty
                                                ? context.l10n.useCurrentImage
                                                : context.l10n.noImageSelected),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (selectedImageBytes != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          selectedImageBytes = null;
                                          selectedImageName = null;
                                        });
                                      },
                                    ),
                                ],
                              ),
                              if (selectedImageBytes != null ||
                                  currentImageUrl.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: selectedImageBytes != null
                                      ? Image.memory(
                                          selectedImageBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          currentImageUrl.startsWith('http')
                                              ? currentImageUrl
                                              : 'http://localhost:5024$currentImageUrl',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                  ),
                                        ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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
                                borderRadius: BorderRadius.circular(4),
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
                              backgroundColor: const Color(0xFF4E73DF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: _isLoading ? null : _saveCategory,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
