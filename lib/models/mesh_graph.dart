class MeshGraphNode {
  final String peerId;
  final bool isSelf;

  const MeshGraphNode({required this.peerId, required this.isSelf});

  factory MeshGraphNode.fromMap(Map<String, dynamic> map) {
    return MeshGraphNode(
      peerId: map['peerId'] as String,
      isSelf: map['isSelf'] as bool? ?? false,
    );
  }

  String get shortId => peerId.length > 8 ? peerId.substring(0, 8) : peerId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeshGraphNode &&
          runtimeType == other.runtimeType &&
          peerId == other.peerId &&
          isSelf == other.isSelf;

  @override
  int get hashCode => Object.hash(peerId, isSelf);

  @override
  String toString() => 'MeshGraphNode($shortId${isSelf ? ", self" : ""})';
}

class MeshGraphEdge {
  final String peerA;
  final String peerB;
  final double? weight;
  final double? weightAtoB;
  final double? weightBtoA;
  final int lastSeen;

  const MeshGraphEdge({
    required this.peerA,
    required this.peerB,
    this.weight,
    this.weightAtoB,
    this.weightBtoA,
    required this.lastSeen,
  });

  factory MeshGraphEdge.fromMap(Map<String, dynamic> map) {
    return MeshGraphEdge(
      peerA: map['peerA'] as String,
      peerB: map['peerB'] as String,
      weight: (map['weight'] as num?)?.toDouble(),
      weightAtoB: (map['weightAtoB'] as num?)?.toDouble(),
      weightBtoA: (map['weightBtoA'] as num?)?.toDouble(),
      lastSeen: (map['lastSeen'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeshGraphEdge &&
          runtimeType == other.runtimeType &&
          peerA == other.peerA &&
          peerB == other.peerB &&
          weight == other.weight &&
          weightAtoB == other.weightAtoB &&
          weightBtoA == other.weightBtoA &&
          lastSeen == other.lastSeen;

  @override
  int get hashCode =>
      Object.hash(peerA, peerB, weight, weightAtoB, weightBtoA, lastSeen);

  @override
  String toString() =>
      'MeshGraphEdge(${_short(peerA)} ↔ ${_short(peerB)}, w=$weight)';

  static String _short(String s) => s.length > 8 ? s.substring(0, 8) : s;
}

class MeshGraph {
  final String selfPeerId;
  final List<MeshGraphNode> nodes;
  final List<MeshGraphEdge> edges;
  final int updatedAt;

  const MeshGraph({
    required this.selfPeerId,
    required this.nodes,
    required this.edges,
    required this.updatedAt,
  });

  factory MeshGraph.fromMap(Map<String, dynamic> map) {
    return MeshGraph(
      selfPeerId: map['selfPeerId'] as String,
      nodes: (map['nodes'] as List)
          .map(
            (e) => MeshGraphNode.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      edges: (map['edges'] as List)
          .map(
            (e) => MeshGraphEdge.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      updatedAt: (map['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }

  static MeshGraph empty(String selfPeerId) => MeshGraph(
    selfPeerId: selfPeerId,
    nodes: const [],
    edges: const [],
    updatedAt: 0,
  );

  MeshGraphNode? nodeById(String peerId) {
    for (final n in nodes) {
      if (n.peerId == peerId) return n;
    }
    return null;
  }

  List<MeshGraphEdge> edgesForNode(String peerId) {
    return edges.where((e) => e.peerA == peerId || e.peerB == peerId).toList();
  }

  /// BFS-слои от self.
  /// Узлы, недостижимые от self, не попадают в Map.
  /// Возвращает [Map<peerId, layer>].
  Map<String, int> computeBfsLayers() {
    final layers = <String, int>{selfPeerId: 0};
    final queue = <String>[selfPeerId];
    final adjacency = <String, List<String>>{};
    for (final e in edges) {
      adjacency.putIfAbsent(e.peerA, () => []).add(e.peerB);
      adjacency.putIfAbsent(e.peerB, () => []).add(e.peerA);
    }
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final currentLayer = layers[current]!;
      for (final neighbor in adjacency[current] ?? const []) {
        if (!layers.containsKey(neighbor)) {
          layers[neighbor] = currentLayer + 1;
          queue.add(neighbor);
        }
      }
    }
    return layers;
  }
}
