import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ats/models/models.dart' show MeshGraph;
import 'package:ats/services/services.dart' show S;

/// Инфо-панель над графом: количество узлов, ребер, время с последнего обновления.
class MeshGraphInfoBar extends StatefulWidget {
  final MeshGraph graph;

  const MeshGraphInfoBar({super.key, required this.graph});

  @override
  State<MeshGraphInfoBar> createState() => _MeshGraphInfoBarState();
}

class _MeshGraphInfoBarState extends State<MeshGraphInfoBar> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  @override
  void didUpdateWidget(covariant MeshGraphInfoBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph.updatedAt != widget.graph.updatedAt) {
      _scheduleTick();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _scheduleTick() {
    _ticker?.cancel();
    final deltaSec = _deltaSeconds();
    final interval = deltaSec < 60
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);
    _ticker = Timer(interval, () {
      if (!mounted) return;
      setState(() {});
      _scheduleTick();
    });
  }

  int _deltaSeconds() {
    final updatedAt = widget.graph.updatedAt;
    if (updatedAt <= 0) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return ((now - updatedAt) / 1000).floor().clamp(0, 1 << 30);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final graph = widget.graph;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.device_hub,
            label: '${S.of(context).topology_nodes}: ${graph.nodes.length}',
          ),
          const SizedBox(width: 12),
          _StatChip(
            icon: Icons.share,
            label: '${S.of(context).topology_edges}: ${graph.edges.length}',
          ),
          const Spacer(),
          Text(
            _formatUpdated(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatUpdated(BuildContext context) {
    final updatedAt = widget.graph.updatedAt;
    if (updatedAt <= 0) return '';
    final deltaSec = _deltaSeconds();
    if (deltaSec < 1) return S.of(context).topology_updated_just_now;
    if (deltaSec < 60) {
      return '$deltaSec ${S.of(context).topology_updated_seconds_ago}';
    }
    final deltaMin = (deltaSec / 60).floor();
    return '$deltaMin ${S.of(context).topology_updated_minutes_ago}';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
