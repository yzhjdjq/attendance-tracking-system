import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart' show ReadContext, WatchContext;

import 'package:ats/models/models.dart' show MeshGraph;
import 'package:ats/providers/providers.dart'
    show MeshGraphPageProvider, UserProvider;
import 'package:ats/services/services.dart' show S;
import 'package:ats/widgets/widgets.dart'
    show
        MainDrawerWidget,
        MeshGraphCanvas,
        MeshGraphCanvasState,
        MeshGraphInfoBar,
        GraphColors;

/// Экран «Топология ЛВС».
class MeshTopologyPage extends StatefulWidget {
  const MeshTopologyPage({super.key});

  @override
  State<MeshTopologyPage> createState() => _MeshTopologyPageState();
}

class _MeshTopologyPageState extends State<MeshTopologyPage> {
  final _canvasKey = GlobalKey<MeshGraphCanvasState>();

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (_isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<MeshGraphPageProvider>().start();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAndroid) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(S.of(context).topology_page_title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              S.of(context).topology_available_android_only,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final provider = context.watch<MeshGraphPageProvider>();
    final graph = provider.graph;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(S.of(context).topology_page_title),
        actions: [
          IconButton(
            icon: Icon(provider.paused ? Icons.play_arrow : Icons.pause),
            tooltip: provider.paused
                ? S.of(context).topology_resume
                : S.of(context).topology_pause,
            onPressed: provider.togglePause,
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: S.of(context).topology_reset_zoom,
            onPressed: graph == null
                ? null
                : () => _canvasKey.currentState?.resetZoom(),
          ),
          IconButton(
            icon: Icon(provider.showLegend ? Icons.info : Icons.info_outline),
            tooltip: S.of(context).topology_legend_title,
            onPressed: provider.toggleLegend,
          ),
        ],
      ),
      drawer: MainDrawerWidget(
        role: context.read<UserProvider>().roleOrStudent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (graph != null) MeshGraphInfoBar(graph: graph),
            Expanded(
              child: graph == null
                  ? const Center(child: CircularProgressIndicator())
                  : graph.nodes.isEmpty
                  ? const _EmptyGraphView()
                  : MeshGraphCanvas(
                      key: _canvasKey,
                      graph: graph,
                      onNodeTap: (peerId) =>
                          _showNodeDetails(context, graph, peerId),
                    ),
            ),
            if (provider.showLegend) const _LegendBar(),
          ],
        ),
      ),
    );
  }

  void _showNodeDetails(BuildContext context, MeshGraph graph, String peerId) {
    final node = graph.nodeById(peerId);
    if (node == null) return;

    final layers = graph.computeBfsLayers();
    final layer = layers[peerId];
    final edges = graph.edgesForNode(peerId);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return _NodeDetailsSheet(
          graph: graph,
          peerId: peerId,
          layer: layer,
          edges: edges,
        );
      },
    );
  }
}

class _EmptyGraphView extends StatelessWidget {
  const _EmptyGraphView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).topology_empty_title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).topology_empty_message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendBar extends StatelessWidget {
  const _LegendBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _LegendItem(
            color: GraphColors.self,
            label: S.of(context).topology_legend_self,
          ),
          _LegendItem(
            color: GraphColors.neighbor,
            label: S.of(context).topology_legend_neighbor,
          ),
          _LegendItem(
            color: GraphColors.remote,
            label: S.of(context).topology_legend_remote,
          ),
          _WeightLegendItem(
            color: GraphColors.edgeStrong,
            label: S.of(context).topology_legend_weight_strong,
          ),
          _WeightLegendItem(
            color: GraphColors.edgeMedium,
            label: S.of(context).topology_legend_weight_medium,
          ),
          _WeightLegendItem(
            color: GraphColors.edgeWeak,
            label: S.of(context).topology_legend_weight_weak,
          ),
          _WeightLegendItem(
            color: GraphColors.edgeUnknown,
            label: S.of(context).topology_legend_weight_unknown,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _WeightLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _WeightLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _NodeDetailsSheet extends StatelessWidget {
  final MeshGraph graph;
  final String peerId;
  final int? layer;
  final List edges;

  const _NodeDetailsSheet({
    required this.graph,
    required this.peerId,
    required this.layer,
    required this.edges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final node = graph.nodeById(peerId);
    final isSelf = node?.isSelf ?? false;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Row(
              children: [
                Icon(
                  isSelf ? Icons.my_location : Icons.hub,
                  color: isSelf
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isSelf
                        ? S.of(context).topology_legend_self
                        : S.of(context).topology_node_details,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _nodeInfoItem(context, S.of(context).topology_node_peer_id, peerId),
            _nodeInfoItem(
              context,
              S.of(context).topology_node_layer,
              layer?.toString() ?? S.of(context).topology_layer_unreachable,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).topology_node_connections,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (edges.isEmpty)
              Text(
                S.of(context).topology_node_no_connections,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...edges.map((e) {
                final other = (e.peerA as String) == peerId ? e.peerB : e.peerA;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      other as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${S.of(context).topology_edge_weight}: '
                      '${e.weight == null ? "—" : "${(e.weight as double).toStringAsFixed(1)} dBm"}',
                    ),
                  ),
                );
              }),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: peerId));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).topology_peer_id_copied),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy),
              label: Text(S.of(context).topology_copy_peer_id),
            ),
          ],
        );
      },
    );
  }

  Widget _nodeInfoItem(BuildContext context, String key, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              key,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
