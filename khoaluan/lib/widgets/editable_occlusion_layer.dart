import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/room_design.dart';

class EditableOcclusionLayer extends StatefulWidget {
  const EditableOcclusionLayer({
    super.key,
    required this.foregroundUrl,
    required this.roomUrl,
    required this.roomBytes,
    required this.headers,
    required this.edits,
    required this.revision,
  });

  final String foregroundUrl;
  final String roomUrl;
  final Uint8List? roomBytes;
  final Map<String, String>? headers;
  final List<RoomOcclusionEdit> edits;
  final int revision;

  @override
  State<EditableOcclusionLayer> createState() => _EditableOcclusionLayerState();
}

class _EditableOcclusionLayerState extends State<EditableOcclusionLayer> {
  ui.Image? _foreground;
  ui.Image? _room;
  ImageStream? _foregroundStream;
  ImageStream? _roomStream;
  ImageStreamListener? _foregroundListener;
  ImageStreamListener? _roomListener;
  bool _resolved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_resolved) _resolveImages();
  }

  @override
  void didUpdateWidget(covariant EditableOcclusionLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.foregroundUrl != widget.foregroundUrl ||
        oldWidget.roomUrl != widget.roomUrl ||
        !identical(oldWidget.roomBytes, widget.roomBytes) ||
        !_sameHeaders(oldWidget.headers, widget.headers)) {
      _resolveImages();
    }
  }

  bool _sameHeaders(Map<String, String>? left, Map<String, String>? right) {
    if (identical(left, right)) return true;
    if (left == null || right == null || left.length != right.length) {
      return false;
    }
    return left.entries.every((entry) => right[entry.key] == entry.value);
  }

  void _resolveImages() {
    _resolved = true;
    _removeListeners();
    final configuration = createLocalImageConfiguration(context);
    final foregroundProvider = NetworkImage(
      widget.foregroundUrl,
      headers: widget.headers,
    );
    final roomProvider = widget.roomBytes != null
        ? MemoryImage(widget.roomBytes!) as ImageProvider
        : NetworkImage(widget.roomUrl, headers: widget.headers);

    _foregroundListener = ImageStreamListener(
      (info, _) {
        if (mounted) setState(() => _foreground = info.image);
      },
      onError: (_, _) {
        if (mounted) setState(() => _foreground = null);
      },
    );
    _roomListener = ImageStreamListener(
      (info, _) {
        if (mounted) setState(() => _room = info.image);
      },
      onError: (_, _) {
        if (mounted) setState(() => _room = null);
      },
    );
    _foregroundStream = foregroundProvider.resolve(configuration)
      ..addListener(_foregroundListener!);
    _roomStream = roomProvider.resolve(configuration)
      ..addListener(_roomListener!);
  }

  void _removeListeners() {
    if (_foregroundStream != null && _foregroundListener != null) {
      _foregroundStream!.removeListener(_foregroundListener!);
    }
    if (_roomStream != null && _roomListener != null) {
      _roomStream!.removeListener(_roomListener!);
    }
  }

  @override
  void dispose() {
    _removeListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _foreground;
    if (foreground == null) return const SizedBox.expand();
    return CustomPaint(
      painter: _OcclusionPainter(
        foreground: foreground,
        room: _room,
        edits: widget.edits,
        revision: widget.revision,
      ),
      size: Size.infinite,
    );
  }
}

class _OcclusionPainter extends CustomPainter {
  const _OcclusionPainter({
    required this.foreground,
    required this.room,
    required this.edits,
    required this.revision,
  });

  final ui.Image foreground;
  final ui.Image? room;
  final List<RoomOcclusionEdit> edits;
  final int revision;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());
    _paintImage(canvas, size, foreground);

    var index = 0;
    while (index < edits.length) {
      final restore = edits[index].restore;
      final path = Path();
      while (index < edits.length && edits[index].restore == restore) {
        final edit = edits[index];
        final radius = edit.radius * size.shortestSide;
        path.addOval(
          Rect.fromCircle(
            center: Offset(edit.x * size.width, edit.y * size.height),
            radius: radius,
          ),
        );
        index++;
      }

      if (restore && room != null) {
        canvas.save();
        canvas.clipPath(path);
        _paintImage(canvas, size, room!);
        canvas.restore();
      } else if (!restore) {
        canvas.drawPath(path, Paint()..blendMode = BlendMode.clear);
      }
    }
    canvas.restore();
  }

  void _paintImage(Canvas canvas, Size size, ui.Image image) {
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(covariant _OcclusionPainter oldDelegate) =>
      oldDelegate.foreground != foreground ||
      oldDelegate.room != room ||
      oldDelegate.revision != revision;
}
