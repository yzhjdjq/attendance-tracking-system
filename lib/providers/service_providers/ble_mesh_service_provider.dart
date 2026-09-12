import 'dart:async' show StreamController, StreamSubscription;

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

    _isServiceStateSubscription = BleMeshService.serviceStateEvents.listen((state) {
      _isServiceState.add(state);
      
      if (state == true){
        _enableEventSubscriptions();
      }
      else {
        _disableEventSubscriptions();
      }
    });
  }

  static bool get isInitialized =>
      SingletonMixin.isInitialized<BleMeshServiceProvider>();

  static String? _userId;

  static bool _isCoreInitialized = false;
  static StreamSubscription<bool>? _isServiceStateSubscription;
  static final StreamController<bool> _isServiceState = StreamController<bool>.broadcast();
  static StreamSubscription<String>? _messagesSubscription;
  static final StreamController<String> _messages = StreamController<String>.broadcast();

  void _enableEventSubscriptions() {
    _messagesSubscription?.cancel();
    _messagesSubscription = BleMeshService.receiveMessageEvents.listen((event) {
      _messages.add(event);
    });
  }

  void _disableEventSubscriptions() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  String? get userId => _userId;

  Stream<String> get messages => _messages.stream;
  Stream<bool> get serviceState => _isServiceState.stream;

  void setUserId(String? userId) {
    _userId = userId;

    if (_isCoreInitialized) {
      BleMeshService.setUserId(userId);
    }
    else if (userId != null) {
      BleMeshService.initMeshService(_userId!);
      _isCoreInitialized = true;
    }
    else {
      return;
    }
    notifyListeners();
  }

  Future<int> getDirectConnectionsCount() async => await BleMeshService.getNumberOfNetworkMembers();

  Future<SendResult> sendMessage(String message) async => await BleMeshService.sendMessage(message);

  @override
  void dispose() {
    _isServiceStateSubscription?.cancel();
    _messagesSubscription?.cancel();

    super.dispose();
  }
}
