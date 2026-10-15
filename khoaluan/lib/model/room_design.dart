import 'dart:convert';

class RoomDesignRecord {
  final String roomDesignId;
  final String title;
  final String roomImageUrl;
  final String? previewImageUrl;
  final String? accessToken;
  final bool isSaved;
  final DateTime? expiresAt;
  final List<RoomDesignItem> items;
  final List<RoomOcclusionEdit> occlusionEdits;

  const RoomDesignRecord({
    required this.roomDesignId,
    required this.title,
    required this.roomImageUrl,
    required this.previewImageUrl,
    required this.accessToken,
    required this.isSaved,
    required this.expiresAt,
    required this.items,
    required this.occlusionEdits,
  });

  factory RoomDesignRecord.fromJson(Map<String, dynamic> json) {
    dynamic scene = json['sceneJson'] ?? json['SceneJson'] ?? [];
    if (scene is String) {
      try {
        scene = jsonDecode(scene);
      } catch (_) {
        scene = [];
      }
    }
    final rawItems = scene is List
        ? scene
        : scene is Map && scene['items'] is List
        ? scene['items'] as List
        : const [];
    final rawOcclusionEdits = scene is Map && scene['occlusionEdits'] is List
        ? scene['occlusionEdits'] as List
        : const [];
    return RoomDesignRecord(
      roomDesignId: (json['roomDesignId'] ?? '').toString(),
      title: (json['title'] ?? 'Không gian của tôi').toString(),
      roomImageUrl: (json['roomImageUrl'] ?? '').toString(),
      previewImageUrl: json['previewImageUrl']?.toString(),
      accessToken: json['accessToken']?.toString(),
      isSaved: json['isSaved'] == true,
      expiresAt: DateTime.tryParse((json['expiresAt'] ?? '').toString()),
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => RoomDesignItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      occlusionEdits: rawOcclusionEdits
          .whereType<Map>()
          .map(
            (edit) =>
                RoomOcclusionEdit.fromJson(Map<String, dynamic>.from(edit)),
          )
          .toList(),
    );
  }
}

class RoomDesignItem {
  final String localId;
  final int productId;
  final int variantId;
  final int imageId;
  final String productName;
  final String variantLabel;
  final String transparentImageUrl;
  double x;
  double y;
  double scale;
  double rotation;
  double perspectiveYaw;
  double brightness;
  double shadowOpacity;
  bool flipHorizontal;
  int layerIndex;
  String placementSurface;
  bool useDepthScale;
  final List<RoomDesignCorner> perspectiveCorners;
  bool useAutoLighting;
  double shadowAngleOffset;
  double shadowSoftness;
  double colorTemperatureOffset;
  bool useOcclusion;

  RoomDesignItem({
    required this.localId,
    required this.productId,
    required this.variantId,
    required this.imageId,
    required this.productName,
    required this.variantLabel,
    required this.transparentImageUrl,
    this.x = 0.5,
    this.y = 0.65,
    this.scale = 1,
    this.rotation = 0,
    this.perspectiveYaw = 0,
    this.brightness = 1,
    this.shadowOpacity = 0.25,
    this.flipHorizontal = false,
    this.layerIndex = 0,
    this.placementSurface = 'free',
    this.useDepthScale = true,
    List<RoomDesignCorner>? perspectiveCorners,
    this.useAutoLighting = true,
    this.shadowAngleOffset = 0,
    this.shadowSoftness = 1,
    this.colorTemperatureOffset = 0,
    this.useOcclusion = true,
  }) : perspectiveCorners = perspectiveCorners ?? RoomDesignCorner.defaults();

  factory RoomDesignItem.fromJson(Map<String, dynamic> json) => RoomDesignItem(
    localId: (json['localId'] ?? DateTime.now().microsecondsSinceEpoch)
        .toString(),
    productId: (json['productId'] as num?)?.toInt() ?? 0,
    variantId: (json['variantId'] as num?)?.toInt() ?? 0,
    imageId: (json['imageId'] as num?)?.toInt() ?? 0,
    productName: (json['productName'] ?? 'Sản phẩm').toString(),
    variantLabel: (json['variantLabel'] ?? '').toString(),
    transparentImageUrl: (json['transparentImageUrl'] ?? '').toString(),
    x: (json['x'] as num?)?.toDouble() ?? 0.5,
    y: (json['y'] as num?)?.toDouble() ?? 0.65,
    scale: (json['scale'] as num?)?.toDouble() ?? 1,
    rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
    perspectiveYaw: (json['perspectiveYaw'] as num?)?.toDouble() ?? 0,
    brightness: (json['brightness'] as num?)?.toDouble() ?? 1,
    shadowOpacity: (json['shadowOpacity'] as num?)?.toDouble() ?? 0.25,
    flipHorizontal: json['flipHorizontal'] == true,
    layerIndex: (json['layerIndex'] as num?)?.toInt() ?? 0,
    placementSurface: (json['placementSurface'] ?? 'free').toString(),
    useDepthScale: json['useDepthScale'] != false,
    perspectiveCorners: RoomDesignCorner.parseList(json['perspectiveCorners']),
    useAutoLighting: json['useAutoLighting'] != false,
    shadowAngleOffset: (json['shadowAngleOffset'] as num?)?.toDouble() ?? 0,
    shadowSoftness: (json['shadowSoftness'] as num?)?.toDouble() ?? 1,
    colorTemperatureOffset:
        (json['colorTemperatureOffset'] as num?)?.toDouble() ?? 0,
    useOcclusion: json['useOcclusion'] != false,
  );

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'productId': productId,
    'variantId': variantId,
    'imageId': imageId,
    'productName': productName,
    'variantLabel': variantLabel,
    'transparentImageUrl': transparentImageUrl,
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
    'perspectiveYaw': perspectiveYaw,
    'brightness': brightness,
    'shadowOpacity': shadowOpacity,
    'flipHorizontal': flipHorizontal,
    'layerIndex': layerIndex,
    'placementSurface': placementSurface,
    'useDepthScale': useDepthScale,
    'perspectiveCorners': perspectiveCorners
        .map((corner) => corner.toJson())
        .toList(),
    'useAutoLighting': useAutoLighting,
    'shadowAngleOffset': shadowAngleOffset,
    'shadowSoftness': shadowSoftness,
    'colorTemperatureOffset': colorTemperatureOffset,
    'useOcclusion': useOcclusion,
  };

  void resetPerspective({bool floorPerspective = false}) {
    perspectiveCorners
      ..clear()
      ..addAll(
        floorPerspective
            ? RoomDesignCorner.floorDefaults()
            : RoomDesignCorner.defaults(),
      );
  }

  RoomDesignItem clone() => RoomDesignItem(
    localId: localId,
    productId: productId,
    variantId: variantId,
    imageId: imageId,
    productName: productName,
    variantLabel: variantLabel,
    transparentImageUrl: transparentImageUrl,
    x: x,
    y: y,
    scale: scale,
    rotation: rotation,
    perspectiveYaw: perspectiveYaw,
    brightness: brightness,
    shadowOpacity: shadowOpacity,
    flipHorizontal: flipHorizontal,
    layerIndex: layerIndex,
    placementSurface: placementSurface,
    useDepthScale: useDepthScale,
    perspectiveCorners: perspectiveCorners
        .map((corner) => RoomDesignCorner(corner.x, corner.y))
        .toList(),
    useAutoLighting: useAutoLighting,
    shadowAngleOffset: shadowAngleOffset,
    shadowSoftness: shadowSoftness,
    colorTemperatureOffset: colorTemperatureOffset,
    useOcclusion: useOcclusion,
  );

  RoomDesignItem withVariant({
    required int newVariantId,
    required int newImageId,
    required String newVariantLabel,
    required String newTransparentImageUrl,
  }) => RoomDesignItem(
    localId: localId,
    productId: productId,
    variantId: newVariantId,
    imageId: newImageId,
    productName: productName,
    variantLabel: newVariantLabel,
    transparentImageUrl: newTransparentImageUrl,
    x: x,
    y: y,
    scale: scale,
    rotation: rotation,
    perspectiveYaw: perspectiveYaw,
    brightness: brightness,
    shadowOpacity: shadowOpacity,
    flipHorizontal: flipHorizontal,
    layerIndex: layerIndex,
    placementSurface: placementSurface,
    useDepthScale: useDepthScale,
    perspectiveCorners: perspectiveCorners
        .map((corner) => RoomDesignCorner(corner.x, corner.y))
        .toList(),
    useAutoLighting: useAutoLighting,
    shadowAngleOffset: shadowAngleOffset,
    shadowSoftness: shadowSoftness,
    colorTemperatureOffset: colorTemperatureOffset,
    useOcclusion: useOcclusion,
  );

  RoomDesignItem copyWith({
    required String newLocalId,
    required int newLayer,
  }) => RoomDesignItem(
    localId: newLocalId,
    productId: productId,
    variantId: variantId,
    imageId: imageId,
    productName: productName,
    variantLabel: variantLabel,
    transparentImageUrl: transparentImageUrl,
    x: (x + 0.04).clamp(0.05, 0.95),
    y: (y + 0.04).clamp(0.05, 0.95),
    scale: scale,
    rotation: rotation,
    perspectiveYaw: perspectiveYaw,
    brightness: brightness,
    shadowOpacity: shadowOpacity,
    flipHorizontal: flipHorizontal,
    layerIndex: newLayer,
    placementSurface: placementSurface,
    useDepthScale: useDepthScale,
    perspectiveCorners: perspectiveCorners
        .map((corner) => RoomDesignCorner(corner.x, corner.y))
        .toList(),
    useAutoLighting: useAutoLighting,
    shadowAngleOffset: shadowAngleOffset,
    shadowSoftness: shadowSoftness,
    colorTemperatureOffset: colorTemperatureOffset,
    useOcclusion: useOcclusion,
  );
}

class RoomOcclusionEdit {
  final double x;
  final double y;
  final double radius;
  final bool restore;
  final int strokeId;

  const RoomOcclusionEdit({
    required this.x,
    required this.y,
    required this.radius,
    required this.restore,
    required this.strokeId,
  });

  factory RoomOcclusionEdit.fromJson(Map<String, dynamic> json) =>
      RoomOcclusionEdit(
        x: (json['x'] as num?)?.toDouble() ?? 0,
        y: (json['y'] as num?)?.toDouble() ?? 0,
        radius: (json['radius'] as num?)?.toDouble() ?? 0.03,
        restore: json['restore'] == true,
        strokeId: (json['strokeId'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'radius': radius,
    'restore': restore,
    'strokeId': strokeId,
  };
}

class RoomDesignCorner {
  double x;
  double y;

  RoomDesignCorner(this.x, this.y);

  factory RoomDesignCorner.fromJson(Map<String, dynamic> json) =>
      RoomDesignCorner(
        (json['x'] as num?)?.toDouble() ?? 0,
        (json['y'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  static List<RoomDesignCorner> defaults() => [
    RoomDesignCorner(0, 0),
    RoomDesignCorner(1, 0),
    RoomDesignCorner(1, 1),
    RoomDesignCorner(0, 1),
  ];

  static List<RoomDesignCorner> floorDefaults() => [
    RoomDesignCorner(0.12, 0.06),
    RoomDesignCorner(0.88, 0.06),
    RoomDesignCorner(1, 1),
    RoomDesignCorner(0, 1),
  ];

  static List<RoomDesignCorner> parseList(dynamic raw) {
    if (raw is! List || raw.length != 4) return defaults();
    final parsed = raw
        .whereType<Map>()
        .map(
          (corner) =>
              RoomDesignCorner.fromJson(Map<String, dynamic>.from(corner)),
        )
        .toList();
    return parsed.length == 4 ? parsed : defaults();
  }
}
