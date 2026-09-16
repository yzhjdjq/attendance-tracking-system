import 'dart:async' show StreamController, StreamSubscription;

import 'package:ats/models/models.dart' show DeliveryStatus, Message;
import 'package:ats/providers/providers.dart'
    show PermissionsProvider, SingletonMixin;
import 'package:ats/services/ble_mesh_service.dart';
import 'package:flutter/material.dart' show ChangeNotifier;

class BleMeshServiceProvider with ChangeNotifier, SingletonMixin {
  static BleMeshServiceProvider get instance =>
      SingletonMixin.getInstance<BleMeshServiceProvider>();

  static Future<BleMeshServiceProvider> initialize({
    required PermissionsProvider permissionsProvider,
  }) async {
    if (SingletonMixin.isInitialized<BleMeshServiceProvider>()) {
      return instance;
    }

    final provider = BleMeshServiceProvider._internal(permissionsProvider);
    return provider;
  }

  BleMeshServiceProvider._internal(this._permissionsProvider) {
    SingletonMixin.registerInstance(this);

    _permissionsProvider.addListener(_onPermissionsChanged);

    _isServiceStateSubscription = BleMeshService.serviceStateEvents.listen((
      state,
    ) {
      _isServiceState.add(state);

      if (state == true) {
        _enableEventSubscriptions();
      } else {
        _disableEventSubscriptions();
      }
    });
  }

  static bool get isInitialized =>
      SingletonMixin.isInitialized<BleMeshServiceProvider>();

  late final PermissionsProvider _permissionsProvider;

  String? _userId;

  bool _isCoreInitialized = false;
  final StreamController<bool> _isServiceState =
      StreamController<bool>.broadcast();
  StreamSubscription<bool>? _isServiceStateSubscription;
  final StreamController<Message> _messages =
      StreamController<Message>.broadcast();
  StreamSubscription<Message>? _messagesSubscription;
  final StreamController<int> _neighboringMembers =
      StreamController<int>.broadcast();
  StreamSubscription<int>? _neighboringMembersSubscription;

  void _enableEventSubscriptions() {
    _messagesSubscription?.cancel();
    _messagesSubscription = BleMeshService.receiveMessageEvents.listen((
      message,
    ) {
      _messages.add(message);
    });

    _neighboringMembersSubscription?.cancel();
    _neighboringMembersSubscription = BleMeshService.neighboringMembersEvents
        .listen((count) {
          _neighboringMembers.add(count);
        });
  }

  void _disableEventSubscriptions() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;

    _neighboringMembersSubscription?.cancel();
    _neighboringMembersSubscription = null;
  }

  void _onPermissionsChanged() {
    BleMeshService.isMeshForegroundServiceRunning().then(
      (state) => {
        if (state == false) {setUserId(userId)},
      },
    );
  }

  bool get canStart =>
      userId != null && _permissionsProvider.allMeshPermissionsGranted;

  String? get userId => _userId;

  Stream<bool> get serviceState => _isServiceState.stream;
  Stream<Message> get messages => _messages.stream;
  Stream<int> get neighboringMembers => _neighboringMembers.stream;

  Future<bool> get isMeshServiceRunning async =>
      await BleMeshService.isMeshForegroundServiceRunning();

  void setUserId(String? userId) {
    _userId = userId;

    if (_isCoreInitialized) {
      BleMeshService.setUserId(userId);
    } else if (canStart) {
      BleMeshService.initMeshService(_userId!);
      _isCoreInitialized = true;
    } else {
      return;
    }
    notifyListeners();
  }

  Future<int> getDirectConnectionsCount() async =>
      await BleMeshService.getNumberOfNetworkMembers();

  Future<DeliveryStatus> sendMessage(Message message) async =>
      await BleMeshService.sendMessage(message);

  @override
  void dispose() {
    _permissionsProvider.removeListener(_onPermissionsChanged);
    _isServiceStateSubscription?.cancel();
    _messagesSubscription?.cancel();
    _neighboringMembersSubscription?.cancel();

    super.dispose();
  }
}
