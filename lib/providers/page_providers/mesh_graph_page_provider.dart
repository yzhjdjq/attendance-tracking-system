import 'dart:async' show StreamSubscription;

import 'package:ats/models/models.dart' show MeshGraph;
import 'package:ats/providers/providers.dart'
    show BleMeshServiceProvider, SingletonMixin;
import 'package:flutter/material.dart' show ChangeNotifier;

/// ViewModel для экрана «Топология ЛВС».
///
/// Хранит текущий граф, состояние паузы, видимость легенды и подписку
/// на поток графа из [BleMeshServiceProvider]. View (MeshTopologyPage)
/// только слушает изменения и отображает.
class MeshGraphPageProvider extends ChangeNotifier with SingletonMixin {
  static MeshGraphPageProvider get instance =>
      SingletonMixin.getInstance<MeshGraphPageProvider>();

  static Future<MeshGraphPageProvider> initialize({
    required BleMeshServiceProvider bleMeshServiceProvider,
  }) async {
    if (SingletonMixin.isInitialized<MeshGraphPageProvider>()) {
      return instance;
    }

    final provider = MeshGraphPageProvider._internal(bleMeshServiceProvider);
    return provider;
  }

  MeshGraphPageProvider._internal(this._bleMeshServiceProvider) {
    SingletonMixin.registerInstance(this);
  }

  static bool get isInitialized =>
      SingletonMixin.isInitialized<MeshGraphPageProvider>();

  late final BleMeshServiceProvider _bleMeshServiceProvider;

  StreamSubscription<MeshGraph>? _subscription;
  MeshGraph? _graph;
  bool _paused = false;
  bool _showLegend = true;

  MeshGraph? get graph => _graph;
  bool get paused => _paused;
  bool get showLegend => _showLegend;
  bool get isLoading => _graph == null;

  void start() {
    if (_subscription != null) return;
    _bleMeshServiceProvider.getGraphSnapshot().then((graph) {
      if (graph != null) {
        _graph = graph;
        notifyListeners();
      }
    });
    _subscription = _bleMeshServiceProvider.graph.listen((graph) {
      if (_paused) return;
      _graph = graph;
      notifyListeners();
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void togglePause() {
    _paused = !_paused;
    notifyListeners();
  }

  void toggleLegend() {
    _showLegend = !_showLegend;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
