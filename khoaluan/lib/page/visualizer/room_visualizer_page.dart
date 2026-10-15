import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../model/product.dart';
import '../../model/room_analysis.dart';
import '../../model/room_design.dart';
import '../../model/scene_harmonization.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/download_helper.dart';
import '../../utils/placement_snap.dart';
import '../../widgets/main_layout.dart';
import '../../l10n/l10n.dart';

enum VisualizerMode { manual, aiGenerate }

enum AnalysisLayer { original, overlay, depth, floor, wall }

class RoomVisualizerPage extends StatefulWidget {
  const RoomVisualizerPage({
    super.key,
    this.initialProduct,
    this.initialVariant,
  });

  final Product? initialProduct;
  final ProductVariant? initialVariant;

  @override
  State<RoomVisualizerPage> createState() => _RoomVisualizerPageState();
}

class _RoomVisualizerPageState extends State<RoomVisualizerPage> {
  final ApiService _api = ApiService();
  final GlobalKey _canvasKey = GlobalKey();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placementPromptController =
      TextEditingController();

  List<Product> _products = [];
  final List<RoomDesignItem> _items = [];
  RoomDesignRecord? _design;
  Uint8List? _roomBytes;
  String? _selectedItemId;
  VisualizerMode _mode = VisualizerMode.manual;
  RoomAnalysisResult? _analysis;
  AnalysisLayer _analysisLayer = AnalysisLayer.original;

  SceneHarmonizationStatus? _aiStatus;
  final List<({Product product, ProductVariant variant})> _aiProducts = [];
  SceneHarmonizationResult? _aiResult;

  bool _loadingProducts = true;
  bool _uploadingRoom = false;
  bool _saving = false;
  bool _exporting = false;
  bool _loadingAiStatus = true;
  bool _generatingAi = false;
  bool _analyzing = false;
  bool _titleInitialized = false;

  double _gestureStartScale = 1;
  double _gestureStartRotation = 0;
  Offset _lastFocalPoint = Offset.zero;

  RoomDesignItem? get _selectedItem {
    final index = _items.indexWhere((item) => item.localId == _selectedItemId);
    return index < 0 ? null : _items[index];
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadAiStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_titleInitialized) {
      _titleController.text = context.l10n.mySpace;
      _titleInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placementPromptController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _api.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products
            .where(
              (product) => product.productVariants.any(
                (variant) => variant.productImages.isNotEmpty,
              ),
            )
            .toList();
        _loadingProducts = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingProducts = false);
      _showMessage('$error', isError: true);
    }
  }

  Future<void> _loadAiStatus() async {
    try {
      final status = await _api.fetchSceneHarmonizationStatus();
      if (!mounted) return;
      setState(() {
        _aiStatus = status;
        _loadingAiStatus = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _aiStatus = null;
        _loadingAiStatus = false;
      });
    }
  }

  Future<void> _pickRoomImage() async {
    if (_generatingAi) {
      _showMessage(context.l10n.waitForAiGeneration, isError: true);
      return;
    }
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (picked == null || picked.files.single.bytes == null) return;
    final file = picked.files.single;
    if (file.size > 10 * 1024 * 1024) {
      _showMessage(context.l10n.roomImageTooLarge, isError: true);
      return;
    }

    setState(() => _uploadingRoom = true);
    try {
      final design = await _api.createRoomDesign(
        file.bytes!,
        file.name,
        title: _titleController.text,
      );
      if (!mounted) return;
      setState(() {
        _design = design;
        _roomBytes = file.bytes!;
        _items.clear();
        _selectedItemId = null;
        _mode = VisualizerMode.manual;
        _aiProducts.clear();
        _aiResult = null;
        _analysis = null;
        _analysisLayer = AnalysisLayer.original;
      });
      _placementPromptController.clear();
      _showMessage(context.l10n.roomUploaded);

      await _analyzeRoom(design);

      final initialProduct = widget.initialProduct;
      if (initialProduct != null) {
        final initialVariant =
            widget.initialVariant ??
            initialProduct.productVariants.cast<ProductVariant?>().firstWhere(
              (variant) => variant!.productImages.isNotEmpty,
              orElse: () => null,
            );
        if (initialVariant != null) {
          await _addManualProduct(initialProduct, initialVariant);
        }
      }
    } catch (error) {
      _showMessage('$error', isError: true);
    } finally {
      if (mounted) setState(() => _uploadingRoom = false);
    }
  }

  Future<void> _analyzeRoom(RoomDesignRecord design) async {
    setState(() => _analyzing = true);
    try {
      final analysis = await _api.analyzeRoomDesign(
        design.roomDesignId,
        design.accessToken,
      );
      if (!mounted || _design?.roomDesignId != design.roomDesignId) return;
      setState(() => _analysis = analysis);
    } catch (error) {
      _showMessage('$error', isError: true);
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  List<ProductVariant> _usableVariants(Product product) => product
      .productVariants
      .where((variant) => variant.productImages.isNotEmpty)
      .toList();

  String _variantLabel(ProductVariant variant) {
    final label = [
      variant.color,
      variant.material,
      variant.size,
    ].where((value) => value.trim().isNotEmpty).join(' • ');
    return label.isEmpty ? context.l10n.defaultVariant : label;
  }

  ProductImage _variantImage(ProductVariant variant) =>
      variant.productImages.firstWhere(
        (image) => image.isThumbnail,
        orElse: () => variant.productImages.first,
      );

  Future<ProductVariant?> _chooseVariant(Product product) async {
    final variants = _usableVariants(product);
    if (variants.isEmpty) return null;
    if (variants.length == 1) return variants.first;
    return showDialog<ProductVariant>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.chooseProductVariant(product.productName)),
        content: SizedBox(
          width: 480,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: variants.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (_, index) {
              final variant = variants[index];
              return ListTile(
                leading: _productImage(
                  _variantImage(variant).imageUrl,
                  width: 58,
                  height: 58,
                ),
                title: Text(_variantLabel(variant)),
                subtitle: Text(
                  context.l10n.stockRemaining(variant.stockQuantity),
                ),
                onTap: () => Navigator.pop(dialogContext, variant),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectManualProduct(Product product) async {
    if (_design == null) {
      _showMessage(context.l10n.uploadRoomFirst, isError: true);
      return;
    }
    final variant = await _chooseVariant(product);
    if (variant != null) await _addManualProduct(product, variant);
  }

  Future<void> _addManualProduct(
    Product product,
    ProductVariant variant,
  ) async {
    final image = _variantImage(variant);
    try {
      final result = await _api.removeProductImageBackground(image.imageId);
      if (!mounted) return;
      final item = RoomDesignItem(
        localId: DateTime.now().microsecondsSinceEpoch.toString(),
        productId: product.productId,
        variantId: variant.variantId,
        imageId: image.imageId,
        productName: product.productName,
        variantLabel: _variantLabel(variant),
        transparentImageUrl: ApiService.absoluteUrl(
          (result['transparentImageUrl'] ?? '').toString(),
        ),
        x: 0.5,
        y: 0.68,
        layerIndex: _items.length,
        placementSurface: 'floor',
      );
      setState(() {
        _items.add(item);
        _selectedItemId = item.localId;
      });
      _showMessage(context.l10n.backgroundRemovedAdded);
    } catch (error) {
      _showMessage('$error', isError: true);
    }
  }

  Future<Product?> _chooseProduct() => showDialog<Product>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.chooseProduct),
      content: SizedBox(
        width: 650,
        height: 520,
        child: _loadingProducts
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _products.length,
                itemBuilder: (_, index) {
                  final product = _products[index];
                  final variant = _usableVariants(product).first;
                  return InkWell(
                    onTap: () => Navigator.pop(dialogContext, product),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _productImage(
                              _variantImage(variant).imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(9),
                            child: Text(
                              product.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    ),
  );

  Future<void> _selectAiProduct() async {
    if (_design == null) {
      _showMessage(context.l10n.uploadRoomFirst, isError: true);
      return;
    }
    final product = await _chooseProduct();
    if (product == null || !mounted) return;
    final variant = await _chooseVariant(product);
    if (variant == null || !mounted) return;
    if (_aiProducts.any(
      (item) => item.variant.variantId == variant.variantId,
    )) {
      return;
    }
    setState(() {
      if (_aiProducts.length < 5) {
        _aiProducts.add((product: product, variant: variant));
      }
      _aiResult = null;
    });
  }

  Future<void> _generateAiPreview() async {
    final design = _design;
    final selections = List.of(_aiProducts);
    if (design == null || selections.isEmpty) {
      _showMessage(context.l10n.chooseAtLeastOneProduct, isError: true);
      return;
    }
    if (_aiStatus?.available != true) {
      _showMessage(
        _aiStatus?.message ?? context.l10n.aiServiceNotReady,
        isError: true,
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.generateNewAiImageTitle),
        content: Text(
          _placementPromptController.text.trim().isEmpty
              ? context.l10n.aiGenerateConfirmAuto
              : context.l10n.aiGenerateConfirmPrompt,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.generateImage),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _generatingAi = true);
    try {
      final result = await _api.generateRoomPreview(
        design.roomDesignId,
        design.accessToken,
        selections.map((item) => _variantImage(item.variant).imageId).toList(),
        selections.map((item) => item.product.productName).toList(),
        selections.map((item) => _variantLabel(item.variant)).toList(),
        placementPrompt: _placementPromptController.text.trim(),
      );
      if (!mounted) return;
      await precacheImage(
        NetworkImage(result.imageUrl, headers: _authHeaders),
        context,
      );
      if (!mounted) return;
      setState(() => _aiResult = result);
      _showMessage(
        result.fromCache
            ? context.l10n.aiImageLoadedFromCache
            : context.l10n.aiImageGenerated,
      );
    } catch (error) {
      _showMessage('$error', isError: true);
    } finally {
      if (mounted) setState(() => _generatingAi = false);
    }
  }

  Map<String, String>? get _authHeaders => AuthService.token == null
      ? null
      : {'Authorization': 'Bearer ${AuthService.token}'};

  Future<void> _saveDesign({bool notify = true}) async {
    final design = _design;
    if (design == null) return;
    setState(() => _saving = true);
    try {
      await _api.saveRoomDesign(
        design.roomDesignId,
        design.accessToken,
        _titleController.text.trim().isEmpty
            ? context.l10n.mySpace
            : _titleController.text.trim(),
        _items,
        const [],
      );
      if (notify) _showMessage(context.l10n.designSaved);
    } catch (error) {
      _showMessage('$error', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _exportDesign() async {
    if (_design == null) return;
    setState(() => _exporting = true);
    await WidgetsBinding.instance.endOfFrame;
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(context.l10n.cannotCreateResultImage);
      }
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data?.buffer.asUint8List();
      if (bytes == null) {
        throw Exception(context.l10n.cannotCreateResultImage);
      }
      await downloadBytes(
        bytes,
        'phoi-canh-${DateTime.now().millisecondsSinceEpoch}.png',
      );
      _showMessage(context.l10n.visualizationDownloaded);
    } catch (error) {
      _showMessage('$error', isError: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      showFooter: false,
      isScrollable: false,
      child: ColoredBox(
        color: const Color(0xFFF5F3EF),
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _design == null
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 1050;
                        if (wide) {
                          return Row(
                            children: [
                              Expanded(child: _buildWorkspace()),
                              SizedBox(width: 360, child: _buildSidebar()),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Expanded(flex: 5, child: _buildWorkspace()),
                            Expanded(flex: 4, child: _buildSidebar()),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() => Material(
    color: Colors.white,
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.chair_outlined, color: Color(0xFF6D28D9)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              context.l10n.roomVisualizerTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _uploadingRoom ? null : _pickRoomImage,
            icon: const Icon(Icons.upload_file),
            label: Text(
              _design == null
                  ? context.l10n.uploadRoomImage
                  : context.l10n.changeRoomImage,
            ),
          ),
          if (_design != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: context.l10n.saveDesign,
              onPressed: _saving ? null : _saveDesign,
              icon: _saving
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Icon(Icons.save_outlined),
            ),
            IconButton(
              tooltip: context.l10n.exportImage,
              onPressed: _exporting ? null : _exportDesign,
              icon: const Icon(Icons.download_outlined),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Card(
      elevation: 0,
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 64,
              color: Color(0xFF6D28D9),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.uploadYourRoom,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.roomImageRequirements),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _uploadingRoom ? null : _pickRoomImage,
              icon: const Icon(Icons.upload_file),
              label: Text(
                _uploadingRoom
                    ? context.l10n.uploadingImage
                    : context.l10n.chooseRoomImage,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildWorkspace() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        SegmentedButton<VisualizerMode>(
          segments: [
            ButtonSegment(
              value: VisualizerMode.manual,
              icon: const Icon(Icons.touch_app_outlined),
              label: Text(context.l10n.manualAdjustment),
            ),
            ButtonSegment(
              value: VisualizerMode.aiGenerate,
              icon: const Icon(Icons.auto_awesome),
              label: Text(context.l10n.aiGenerateImage),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: _generatingAi
              ? null
              : (selection) => setState(() {
                  _mode = selection.first;
                  _selectedItemId = null;
                  _analysisLayer = AnalysisLayer.original;
                }),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: RepaintBoundary(
                key: _canvasKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      fit: StackFit.expand,
                      children: [
                        _roomImage(),
                        if (_mode == VisualizerMode.manual &&
                            _analysisLayer == AnalysisLayer.original)
                          ...(_items.toList()..sort(
                                (a, b) => a.layerIndex.compareTo(b.layerIndex),
                              ))
                              .map(
                                (item) => _sceneItem(
                                  item,
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                              ),
                        if (_mode == VisualizerMode.manual && _items.isEmpty)
                          _CanvasHint(
                            text: context.l10n.chooseProductManualHint,
                          ),
                        if (_mode == VisualizerMode.aiGenerate &&
                            _aiResult != null)
                          Image.network(
                            _aiResult!.imageUrl,
                            fit: BoxFit.cover,
                            headers: _authHeaders,
                          ),
                        if (_mode == VisualizerMode.aiGenerate &&
                            _aiResult == null &&
                            !_generatingAi)
                          _CanvasHint(text: context.l10n.chooseProductAiHint),
                        if (_generatingAi)
                          ColoredBox(
                            color: const Color(0x66000000),
                            child: Center(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(),
                                      const SizedBox(width: 12),
                                      Text(context.l10n.aiGeneratingNewImage),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_mode == VisualizerMode.manual &&
                            _analysis != null &&
                            !_exporting)
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: _analysisLayerSelector(),
                          ),
                        if (_analyzing)
                          Positioned(
                            left: 14,
                            top: 14,
                            child: Chip(
                              label: Text(context.l10n.analyzingSpace),
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
      ],
    ),
  );

  String _imageUrlWithAccess(String value) {
    final absolute = ApiService.absoluteUrl(value);
    final token = _design?.accessToken;
    if (token == null || token.isEmpty) return absolute;
    return Uri.parse(
      absolute,
    ).replace(queryParameters: {'accessToken': token}).toString();
  }

  Widget _roomImage() {
    final layerUrl = switch (_analysisLayer) {
      AnalysisLayer.overlay => _analysis?.overlayUrl,
      AnalysisLayer.depth => _analysis?.depthMapUrl,
      AnalysisLayer.floor => _analysis?.floorMaskUrl,
      AnalysisLayer.wall => _analysis?.wallMaskUrl,
      AnalysisLayer.original => null,
    };
    if (_mode == VisualizerMode.manual && layerUrl != null) {
      return Image.network(
        _imageUrlWithAccess(layerUrl),
        fit: BoxFit.cover,
        headers: _authHeaders,
      );
    }
    return _roomBytes != null
        ? Image.memory(_roomBytes!, fit: BoxFit.cover)
        : Image.network(
            _imageUrlWithAccess(_design!.roomImageUrl),
            fit: BoxFit.cover,
            headers: _authHeaders,
          );
  }

  Widget _analysisLayerSelector() => Card(
    color: Colors.white.withValues(alpha: 0.94),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            [
                  (AnalysisLayer.original, context.l10n.designLayer),
                  (AnalysisLayer.overlay, context.l10n.floorWallLayer),
                  (AnalysisLayer.depth, context.l10n.depthLayer),
                  (AnalysisLayer.floor, context.l10n.floorMaskLayer),
                  (AnalysisLayer.wall, context.l10n.wallMaskLayer),
                ]
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text(entry.$2),
                      selected: _analysisLayer == entry.$1,
                      onSelected: (_) =>
                          setState(() => _analysisLayer = entry.$1),
                    ),
                  ),
                )
                .toList(),
      ),
    ),
  );

  Widget _sceneItem(RoomDesignItem item, double width, double height) {
    const baseSize = 190.0;
    final depth = item.useDepthScale
        ? (0.72 + (_analysis?.depthGrid?.sample(item.x, item.y) ?? 0.5) * 0.56)
        : 1.0;
    final size = (baseSize * item.scale * depth).clamp(60.0, 540.0);
    final selected = item.localId == _selectedItemId && !_exporting;
    final yawScale = math.cos(item.perspectiveYaw).abs().clamp(0.3, 1.0);
    return Positioned(
      left: item.x * width - size / 2,
      top: item.y * height - size / 2,
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => setState(() => _selectedItemId = item.localId),
        onScaleStart: (details) {
          setState(() => _selectedItemId = item.localId);
          _gestureStartScale = item.scale;
          _gestureStartRotation = item.rotation;
          _lastFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          final delta = details.focalPoint - _lastFocalPoint;
          _lastFocalPoint = details.focalPoint;
          setState(() {
            final snapped = snapToPlacementPlane(
              item.placementSurface == 'floor'
                  ? _analysis?.floorPlane
                  : _analysis?.wallPlane,
              item.placementSurface,
              item.x + delta.dx / width,
              item.y + delta.dy / height,
            );
            item.x = snapped.dx;
            item.y = snapped.dy;
            item.scale = (_gestureStartScale * details.scale).clamp(0.35, 2.8);
            item.rotation = _gestureStartRotation + details.rotation;
          });
        },
        child: Transform.rotate(
          angle: item.rotation,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(color: const Color(0xFF2563EB), width: 2)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.translate(
                  offset: Offset(10 * math.sin(item.shadowAngleOffset), 44),
                  child: Transform.scale(
                    scaleX: 1.05,
                    scaleY: 0.13,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: item.shadowOpacity.clamp(0, 0.6),
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12 * item.shadowSoftness,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(item.perspectiveYaw),
                  child: Transform.scale(
                    scaleX: item.flipHorizontal ? -yawScale : yawScale,
                    child: ColorFiltered(
                      // Chỉ điều chỉnh RGB; luôn giữ alpha gốc của ảnh PNG.
                      // ColorFilter.mode trước đây nhân cả kênh alpha nên ảnh
                      // sản phẩm bị trong suốt và nhìn như bị mờ.
                      colorFilter: ColorFilter.matrix([
                        item.brightness,
                        0,
                        0,
                        0,
                        0,
                        0,
                        item.brightness,
                        0,
                        0,
                        0,
                        0,
                        0,
                        item.brightness,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Image.network(
                        item.transparentImageUrl,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() => _mode == VisualizerMode.aiGenerate
      ? _buildAiSidebar()
      : _buildManualSidebar();

  Widget _buildManualSidebar() => ColoredBox(
    color: Colors.white,
    child: DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.chair_outlined),
                text: context.l10n.productsTab,
              ),
              Tab(
                icon: const Icon(Icons.tune),
                text: context.l10n.adjustmentsTab,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_buildProductGrid(), _buildItemControls()],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildProductGrid() {
    if (_loadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _products.length,
      itemBuilder: (_, index) {
        final product = _products[index];
        final variant = _usableVariants(product).first;
        return InkWell(
          onTap: () => _selectManualProduct(product),
          child: Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _productImage(
                    _variantImage(variant).imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemControls() {
    final item = _selectedItem;
    if (item == null) {
      return Center(child: Text(context.l10n.selectProductOnCanvas));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          item.productName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Text(item.variantLabel, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: item.placementSurface,
          decoration: InputDecoration(
            labelText: context.l10n.placementSurface,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 'free',
              child: Text(context.l10n.freePlacement),
            ),
            DropdownMenuItem(
              value: 'floor',
              child: Text(context.l10n.floorSurface),
            ),
            DropdownMenuItem(
              value: 'wall-left',
              child: Text(context.l10n.leftWall),
            ),
            DropdownMenuItem(
              value: 'wall-right',
              child: Text(context.l10n.rightWall),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              item.placementSurface = value;
              item.perspectiveYaw = switch (value) {
                'wall-left' => -0.68,
                'wall-right' => 0.68,
                _ => 0,
              };
              final snapped = snapToPlacementPlane(
                value == 'floor' ? _analysis?.floorPlane : _analysis?.wallPlane,
                value,
                item.x,
                item.y,
              );
              item.x = snapped.dx;
              item.y = snapped.dy;
            });
          },
        ),
        _slider(
          context.l10n.sizeControl,
          item.scale,
          0.35,
          2.8,
          (value) => setState(() => item.scale = value),
        ),
        _slider(
          context.l10n.flatRotation,
          item.rotation,
          -math.pi,
          math.pi,
          (value) => setState(() => item.rotation = value),
        ),
        _slider(
          context.l10n.perspectiveRotation,
          item.perspectiveYaw,
          -1.15,
          1.15,
          (value) => setState(() => item.perspectiveYaw = value),
        ),
        _slider(
          context.l10n.brightness,
          item.brightness,
          0.5,
          1.5,
          (value) => setState(() => item.brightness = value),
        ),
        _slider(
          context.l10n.shadowIntensity,
          item.shadowOpacity,
          0,
          0.6,
          (value) => setState(() => item.shadowOpacity = value),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.flipProduct),
          value: item.flipHorizontal,
          onChanged: (value) => setState(() => item.flipHorizontal = value),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  final copy = item.copyWith(
                    newLocalId: DateTime.now().microsecondsSinceEpoch
                        .toString(),
                    newLayer: _items.length,
                  );
                  _items.add(copy);
                  _selectedItemId = copy.localId;
                }),
                icon: const Icon(Icons.copy_outlined),
                label: Text(context.l10n.duplicate),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  _items.remove(item);
                  _selectedItemId = null;
                }),
                icon: const Icon(Icons.delete_outline),
                label: Text(context.l10n.delete),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAiProductStack() {
    final height = 106.0 + ((_aiProducts.length - 1) * 54.0);
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(_aiProducts.length, (index) {
          final item = _aiProducts[index];
          final image = _variantImage(item.variant);
          return Positioned(
            top: index * 54.0,
            left: index * 7.0,
            right: 0,
            child: Material(
              elevation: 3 + index.toDouble(),
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 104,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _productImage(
                        image.imageUrl,
                        width: 76,
                        height: 76,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _variantLabel(item.variant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.removeProductFromScene,
                      onPressed: _generatingAi
                          ? null
                          : () => setState(() {
                              _aiProducts.removeAt(index);
                              _aiResult = null;
                            }),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAiSidebar() {
    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            context.l10n.aiFromRoomAndProducts,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.aiFromRoomAndProductsDescription,
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 14),
          _referenceCard(
            number: '1',
            title: context.l10n.roomImage,
            subtitle: context.l10n.uploadedImage,
            image: _roomImage(),
          ),
          const SizedBox(height: 10),
          if (_aiProducts.isEmpty)
            _referenceCard(
              number: '2',
              title: context.l10n.noProductSelected,
              subtitle: context.l10n.chooseVariantBelow,
              image: const ColoredBox(
                color: Color(0xFFF1F5F9),
                child: Icon(Icons.chair_outlined, size: 48),
              ),
            )
          else ...[
            Text(
              context.l10n.selectedProducts,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _buildAiProductStack(),
          ],
          const SizedBox(height: 10),
          if (_aiProducts.length < 5)
            OutlinedButton.icon(
              onPressed: _generatingAi ? null : _selectAiProduct,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(context.l10n.addProductToAiScene),
            ),
          const SizedBox(height: 14),
          TextField(
            controller: _placementPromptController,
            enabled: !_generatingAi,
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
            onChanged: (_) {
              if (_aiResult != null) {
                setState(() => _aiResult = null);
              }
            },
            decoration: InputDecoration(
              labelText: context.l10n.desiredPlacementOptional,
              hintText: context.l10n.placementPromptHint,
              prefixIcon: const Icon(Icons.place_outlined),
              alignLabelWithHint: true,
            ),
          ),
          Text(
            context.l10n.placementPromptHelp,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (_loadingAiStatus)
            const LinearProgressIndicator()
          else if (_aiStatus?.available != true)
            Text(
              _aiStatus?.message ?? context.l10n.aiServiceUnavailable,
              style: const TextStyle(color: Colors.redAccent),
            )
          else ...[
            Text(
              '${_aiStatus!.provider} • ${_aiStatus!.model} • ${_aiStatus!.quality}',
              style: const TextStyle(
                color: Color(0xFF6D28D9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _generatingAi || _aiProducts.isEmpty
                  ? null
                  : _generateAiPreview,
              icon: _generatingAi
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _generatingAi
                    ? context.l10n.aiGenerating
                    : _aiResult == null
                    ? context.l10n.generateNewImageWithAi
                    : context.l10n.regenerateImage,
              ),
            ),
          ],
          if (_aiResult != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _exporting ? null : _exportDesign,
              icon: const Icon(Icons.download_outlined),
              label: Text(context.l10n.downloadCurrentAiImage),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            context.l10n.aiImageDisclaimer,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _referenceCard({
    required String number,
    required String title,
    required String subtitle,
    required Widget image,
  }) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: image),
        ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xFF6D28D9),
            foregroundColor: Colors.white,
            child: Text(number),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ],
    ),
  );

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    ],
  );

  Widget _productImage(
    String value, {
    required double width,
    required double height,
  }) => Image.network(
    ApiService.absoluteUrl(value),
    width: width,
    height: height,
    fit: BoxFit.contain,
    errorBuilder: (_, _, _) => const ColoredBox(
      color: Color(0xFFF1F5F9),
      child: Icon(Icons.broken_image_outlined),
    ),
  );
}

class _CanvasHint extends StatelessWidget {
  const _CanvasHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );
}
