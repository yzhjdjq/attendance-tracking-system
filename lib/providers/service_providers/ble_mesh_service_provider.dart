import 'dart:async' show StreamController;

import 'package:ats/providers/providers.dart' show SingletonMixin;
import 'package:ats/services/ble_mesh_service.dart';
import 'package:flutter/material.dart' show ChangeNotifier;

class BleMeshServiceProvider with ChangeNotifier, SingletonMixin {
  static BleMeshServiceProvider get instance =>
      SingletonMixin.getInstance<BleMeshServiceProvider>();

  static Future<BleMeshServiceProvider> initialize() async {
    if (SingletonMixin.isInitialized<BleMeshServiceProvider>()) {
      return instance;
    }

    final provider = BleMeshServiceProvider._internal();
    return provider;
  }

  BleMeshServiceProvider._internal() {
    SingletonMixin.registerInstance(this);

    BleMeshService.events.listen( (event) {
      _messages.add(event);
    });
  }

  static bool get isInitialized =>
      SingletonMixin.isInitialized<BleMeshServiceProvider>();

  static bool _isCoreInitialized = false;
  String _userId = 'empty';
  final StreamController<String> _messages = StreamController<String>.broadcast();

  String get userId => _userId;

  Stream<String> get messages => _messages.stream;

  void setUserId(String? userId) {
    _userId = userId ?? '';
    if (_isCoreInitialized) {
      BleMeshService.setUserId(userId);
    }
    else {
      BleMeshService.initMeshService(_userId);
      _isCoreInitialized = true;
    }
    notifyListeners();
  }

  Future<int> getDirectConnectionsCount() async => await BleMeshService.getNumberOfNetworkMembers();

  Future<SendResult> sendMessage(String message) async => await BleMeshService.sendMessage(message);
}
