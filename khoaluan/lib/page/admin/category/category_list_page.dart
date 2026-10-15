import 'package:flutter/material.dart';
import '../../../model/category.dart';
import '../../../services/api_service.dart';
import 'category_form_page.dart';
import '../../../widgets/confirm_delete_dialog.dart';
import '../../../widgets/web_page_route.dart';
import '../../../l10n/l10n.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final cats = await _apiService.fetchCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.loadCategoriesError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteCategory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: context.l10n.confirmDeleteCategory,
        content: context.l10n.confirmDeleteCategoryBody,
      ),
    );
    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.deleteCategory(id);
      await _loadCategories();
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
                Text(
                  context.l10n.categoryListTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF4E73DF),
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
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(context.l10n.addCategory),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      WebPageRoute(
                        page: const CategoryFormPage(),
                        animated: false,
                      ),
                    );
                    if (result == true) {
                      _loadCategories();
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: () {
              final parents = _categories
                  .where((c) => c.parentCategoryId == null)
                  .toList();
              if (parents.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(context.l10n.noCategories),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: parents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final parent = parents[index];
                  final children = _categories
                      .where((c) => c.parentCategoryId == parent.categoryId)
                      .toList();

                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.transparent),
                      ),
                      collapsedShape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.transparent),
                      ),
                      title: Row(
                        children: [
                          Text(
                            '#${parent.categoryId}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            parent.categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 20,
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                WebPageRoute(
                                  page: CategoryFormPage(category: parent),
                                  animated: false,
                                ),
                              );
                              if (result == true) {
                                _loadCategories();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => _deleteCategory(parent.categoryId),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.expand_more),
                        ],
                      ),
                      children: children.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  context.l10n.noSubcategories,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ]
                          : children.map((child) {
                              return ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 32,
                                  right: 16,
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      '#${child.categoryId}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      child.categoryName,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          WebPageRoute(
                                            page: CategoryFormPage(
                                              category: child,
                                            ),
                                            animated: false,
                                          ),
                                        );
                                        if (result == true) {
                                          _loadCategories();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          _deleteCategory(child.categoryId),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                    ),
                  );
                },
              );
            }(),
          ),
        ],
      ),
    );
  }
}
