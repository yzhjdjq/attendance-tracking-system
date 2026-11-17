import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ats/models/models.dart'
    show MeshGraph, MeshGraphEdge, MeshGraphNode;

class GraphColors {
  GraphColors._();

  static const Color self = Color(0xFF30D5A9);
  static const Color neighbor = Color(0xFF546E7A);
  static const Color remote = Color(0xFFB0BEC5);
  static const Color nodeBorder = Colors.white;

  static const Color edgeStrong = Color(0xFF4CAF50);
  static const Color edgeMedium = Color(0xFFFF9800);
  static const Color edgeWeak = Color(0xFFF44336);
  static const Color edgeUnknown = Color(0xFFCFD8DC);
}

/// Виджет с кастомной отрисовкой графа BLE Mesh сети.
///
/// Раскладка — BFS-слои от self: self в центре, прямые соседи на первом
/// кольце, их соседи — на втором и т.д. Узлы, недостижимые от self,
/// располагаются на внешнем кольце и подсвечиваются серым.
///
/// Вся область графа масштабируется и панорамируется через InteractiveViewer.
class MeshGraphCanvas extends StatefulWidget {
  final MeshGraph graph;
  final void Function(String peerId)? onNodeTap;

  const MeshGraphCanvas({super.key, required this.graph, this.onNodeTap});

  @override
  State<MeshGraphCanvas> createState() => MeshGraphCanvasState();
}

class MeshGraphCanvasState extends State<MeshGraphCanvas> {
  final _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToView());
  }

  void resetZoom() {
    _transformController.value = Matrix4.identity();
    _fitToView();
  }

  void _fitToView() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final size = box.size;
    final layout = _Layout.build(
      widget.graph,
    ); // пересчитываем, чтобы знать width/height
    final scale = math.min(
      size.width / layout.width,
      size.height / layout.height,
    );
    final scaleClamped = scale.clamp(0.5, 3.0);
    final tx = (size.width - layout.width * scaleClamped) / 2;
    final ty = (size.height - layout.height * scaleClamped) / 2;
    _transformController.value = Matrix4.identity()
      ..translateByDouble(tx, ty, .0, 1.0)
      ..scaleByDouble(scaleClamped, scaleClamped, scaleClamped, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final layout = _Layout.build(widget.graph);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.3,
            maxScale: 5.0,
            boundaryMargin: const EdgeInsets.all(200),
            constrained: false,
            child: SizedBox(
              width: layout.width,
              height: layout.height,
              child: GestureDetector(
                onTapUp: (details) {
                  final hit = layout.hitTest(details.localPosition);
                  if (hit != null) {
                    widget.onNodeTap?.call(hit);
                  }
                },
                child: CustomPaint(
                  painter: _MeshGraphPainter(
                    graph: widget.graph,
                    layout: layout,
                  ),
                  size: Size(layout.width, layout.height),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Раскладка графа: позиции узлов и сегменты ребер.
class _Layout {
  static const double baseRadius = 180;
  static const double nodeRadius = 24;
  static const double padding = 80;

  final double width;
  final double height;
  final Map<String, Offset> positions;
  final Map<String, int> layers;
  final List<_EdgeSegment> edges;

  _Layout._({
    required this.width,
    required this.height,
    required this.positions,
    required this.layers,
    required this.edges,
  });

  static _Layout build(MeshGraph graph) {
    final layers = graph.computeBfsLayers();
    final maxLayer = layers.values.isEmpty ? 0 : layers.values.reduce(math.max);

    final byLayer = <int, List<String>>{};
    for (final node in graph.nodes) {
      final layer = layers[node.peerId];
      if (layer == null) continue;
      byLayer.putIfAbsent(layer, () => []).add(node.peerId);
    }

    final positions = <String, Offset>{};
    final selfId = graph.selfPeerId;
    positions[selfId] = Offset.zero;

    for (var layer = 1; layer <= maxLayer; layer++) {
      final ids = byLayer[layer] ?? const <String>[];
      if (ids.isEmpty) continue;
      final radius = baseRadius * layer;
      final angleStep = 2 * math.pi / ids.length;
      final angleOffset = (layer % 2 == 0) ? math.pi / ids.length : 0.0;
      for (var i = 0; i < ids.length; i++) {
        final angle = angleStep * i - math.pi / 2 + angleOffset;
        positions[ids[i]] = Offset(
          radius * math.cos(angle),
          radius * math.sin(angle),
        );
      }
    }

    final unreachable = graph.nodes
        .where((n) => !positions.containsKey(n.peerId))
        .map((n) => n.peerId)
        .toList();
    if (unreachable.isNotEmpty) {
      final radius = baseRadius * (maxLayer + 1);
      final angleStep = 2 * math.pi / unreachable.length;
      for (var i = 0; i < unreachable.length; i++) {
        final angle = angleStep * i - math.pi / 2;
        positions[unreachable[i]] = Offset(
          radius * math.cos(angle),
          radius * math.sin(angle),
        );
      }
    }

    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;
    for (final pos in positions.values) {
      if (pos.dx < minX) minX = pos.dx;
      if (pos.dy < minY) minY = pos.dy;
      if (pos.dx > maxX) maxX = pos.dx;
      if (pos.dy > maxY) maxY = pos.dy;
    }
    minX -= nodeRadius;
    minY -= nodeRadius;
    maxX += nodeRadius;
    maxY += nodeRadius;

    final dx = -minX + padding;
    final dy = -minY + padding;
    final shifted = <String, Offset>{
      for (final entry in positions.entries)
        entry.key: entry.value + Offset(dx, dy),
    };

    final width = (maxX - minX) + padding * 2;
    final height = (maxY - minY) + padding * 2;

    final edges = <_EdgeSegment>[];
    for (final e in graph.edges) {
      final a = shifted[e.peerA];
      final b = shifted[e.peerB];
      if (a == null || b == null) continue;
      edges.add(_EdgeSegment(edge: e, from: a, to: b));
    }

    return _Layout._(
      width: width,
      height: height,
      positions: shifted,
      layers: layers,
      edges: edges,
    );
  }

  String? hitTest(Offset point) {
    for (final entry in positions.entries) {
      if ((entry.value - point).distance <= nodeRadius + 8) {
        return entry.key;
      }
    }
    return null;
  }
}

class _EdgeSegment {
  final MeshGraphEdge edge;
  final Offset from;
  final Offset to;

  const _EdgeSegment({
    required this.edge,
    required this.from,
    required this.to,
  });
}

/// Painter, который рисует ребра, узлы и подписи.
class _MeshGraphPainter extends CustomPainter {
  final MeshGraph graph;
  final _Layout layout;

  _MeshGraphPainter({required this.graph, required this.layout});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ребра.
    for (final segment in layout.edges) {
      final color = _edgeColor(segment.edge.weight);
      final strokeWidth = _edgeStrokeWidth(segment.edge.weight);
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(segment.from, segment.to, paint);
    }

    // 2. Узлы.
    for (final node in graph.nodes) {
      final pos = layout.positions[node.peerId];
      if (pos == null) continue;
      final color = _nodeColor(node);

      // Тень для self.
      if (node.isSelf) {
        final shadow = Paint()
          ..color = color.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(pos, _Layout.nodeRadius + 4, shadow);
      }

      // Круг.
      final fill = Paint()..color = color;
      canvas.drawCircle(pos, _Layout.nodeRadius, fill);

      // Обводка.
      final border = Paint()
        ..color = GraphColors.nodeBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = node.isSelf ? 3 : 2;
      canvas.drawCircle(pos, _Layout.nodeRadius, border);

      // Иконка ★ для self.
      if (node.isSelf) {
        final iconPainter = TextPainter(
          text: const TextSpan(
            text: '★',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        iconPainter.paint(
          canvas,
          pos - Offset(iconPainter.width / 2, iconPainter.height / 2),
        );
      }
    }

    // 3. Подписи узлов.
    for (final node in graph.nodes) {
      final pos = layout.positions[node.peerId];
      if (pos == null) continue;
      final label = _shortId(node.peerId);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF37474F),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: 80);
      tp.paint(canvas, pos + Offset(-tp.width / 2, _Layout.nodeRadius + 4));
    }
  }

  Color _nodeColor(MeshGraphNode node) {
    if (node.isSelf) return GraphColors.self;
    final layer = layout.layers[node.peerId];
    if (layer == 1) return GraphColors.neighbor;
    return GraphColors.remote;
  }

  String _shortId(String peerId) {
    return peerId.length > 8 ? '${peerId.substring(0, 8)}…' : peerId;
  }

  Color _edgeColor(double? weight) {
    if (weight == null) return GraphColors.edgeUnknown;
    if (weight >= -60) return GraphColors.edgeStrong;
    if (weight >= -80) return GraphColors.edgeMedium;
    return GraphColors.edgeWeak;
  }

  double _edgeStrokeWidth(double? weight) {
    if (weight == null) return 1.5;
    if (weight >= -60) return 3.5;
    if (weight >= -80) return 2.5;
    return 1.5;
  }

  @override
  bool shouldRepaint(covariant _MeshGraphPainter oldDelegate) {
    return oldDelegate.graph.updatedAt != graph.updatedAt;
  }
}
