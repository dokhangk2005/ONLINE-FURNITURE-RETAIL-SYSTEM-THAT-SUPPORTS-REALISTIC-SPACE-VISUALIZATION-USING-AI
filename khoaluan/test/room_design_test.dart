import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/room_design.dart';

void main() {
  test('đọc được sceneJson do backend trả về', () {
    final record = RoomDesignRecord.fromJson({
      'roomDesignId': 'design-1',
      'title': 'Phòng khách',
      'roomImageUrl': '/api/room-designs/design-1/room',
      'sceneJson': jsonEncode([
        {
          'localId': 'item-1',
          'productId': 7,
          'variantId': 9,
          'imageId': 11,
          'productName': 'Sofa',
          'variantLabel': 'Màu kem',
          'transparentImageUrl': '/transparent.png',
          'x': 0.4,
          'y': 0.7,
          'scale': 1.2,
        },
      ]),
    });

    expect(record.items, hasLength(1));
    expect(record.items.single.productName, 'Sofa');
    expect(record.items.single.scale, 1.2);
  });

  test('giữ nguyên trạng thái khi tuần tự hóa sản phẩm phối cảnh', () {
    final item = RoomDesignItem(
      localId: 'item-2',
      productId: 2,
      variantId: 3,
      imageId: 4,
      productName: 'Bàn ăn',
      variantLabel: 'Màu đen',
      transparentImageUrl: '/table.png',
      x: 0.25,
      y: 0.75,
      rotation: 0.4,
      perspectiveYaw: -0.68,
      flipHorizontal: true,
      placementSurface: 'floor',
      useDepthScale: true,
      perspectiveCorners: [
        RoomDesignCorner(0.1, 0.05),
        RoomDesignCorner(0.9, 0.05),
        RoomDesignCorner(1, 1),
        RoomDesignCorner(0, 1),
      ],
      useAutoLighting: true,
      shadowAngleOffset: 0.35,
      shadowSoftness: 1.2,
      colorTemperatureOffset: -0.15,
      useOcclusion: false,
    );

    final restored = RoomDesignItem.fromJson(item.toJson());
    expect(restored.x, 0.25);
    expect(restored.y, 0.75);
    expect(restored.rotation, 0.4);
    expect(restored.perspectiveYaw, -0.68);
    expect(restored.flipHorizontal, isTrue);
    expect(restored.placementSurface, 'floor');
    expect(restored.useDepthScale, isTrue);
    expect(restored.perspectiveCorners, hasLength(4));
    expect(restored.perspectiveCorners.first.x, 0.1);
    expect(restored.useAutoLighting, isTrue);
    expect(restored.shadowAngleOffset, 0.35);
    expect(restored.shadowSoftness, 1.2);
    expect(restored.colorTemperatureOffset, -0.15);
    expect(restored.useOcclusion, isFalse);
  });

  test('đọc và lưu các nét sửa mask che khuất', () {
    final record = RoomDesignRecord.fromJson({
      'roomDesignId': 'design-mask',
      'title': 'Mask test',
      'roomImageUrl': '/room.png',
      'sceneJson': jsonEncode({
        'items': [],
        'occlusionEdits': [
          {'x': 0.4, 'y': 0.6, 'radius': 0.03, 'restore': false, 'strokeId': 7},
        ],
      }),
    });

    expect(record.occlusionEdits, hasLength(1));
    final edit = record.occlusionEdits.single;
    expect(edit.x, 0.4);
    expect(edit.restore, isFalse);
    expect(edit.strokeId, 7);
    expect(RoomOcclusionEdit.fromJson(edit.toJson()).radius, 0.03);
  });
}
