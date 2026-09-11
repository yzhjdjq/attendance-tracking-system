import 'package:ats/models/models.dart' show UserRole;
import 'package:ats/providers/service_providers/ble_mesh_service_provider.dart';
import 'package:ats/services/services.dart' show BleMeshService, SendResult;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:ats/providers/singleton_provider.dart' show SingletonMixin;

enum UserRoleViewModel {
  teacher,
  student;

  static UserRoleViewModel fromUserRole(UserRole role) {
    if (role == UserRole.teacher) {
      return UserRoleViewModel.teacher;
    }

    return UserRoleViewModel.student;
  }
}

enum SendResultViewModel {
  notImplemented,
  success,
  error;

  static SendResultViewModel fromSendResult(SendResult result) {
    return switch (result) {
      SendResult.notImplemented => SendResultViewModel.notImplemented,
      SendResult.success => SendResultViewModel.success,
      SendResult.error => SendResultViewModel.error,
    };
  }
}

class MarkVisitPageProvider with ChangeNotifier, SingletonMixin {
  static MarkVisitPageProvider get instance =>
      SingletonMixin.getInstance<MarkVisitPageProvider>();

  static Future<MarkVisitPageProvider> initialize({required BleMeshServiceProvider bleMeshServiceProvider}) async {
    if (SingletonMixin.isInitialized<MarkVisitPageProvider>()) {
      return instance;
    }

    final provider = MarkVisitPageProvider._internal(bleMeshServiceProvider);
    return provider;
  }

  MarkVisitPageProvider._internal(this._bleMeshServiceProvider) {
    SingletonMixin.registerInstance(this);
    subscribeToReceiveMessage();
  }

  static bool get isInitialized =>
      SingletonMixin.isInitialized<MarkVisitPageProvider>();

  late final BleMeshServiceProvider _bleMeshServiceProvider;

  UserRoleViewModel _role = UserRoleViewModel.student;
  List<String> _logMessages = [];
  List<String> _attendedStudents = [];
  bool _isPollActive = false;
  String? _errorMessage;
  bool _autoScrollLog = true;

  UserRoleViewModel get role => _role;
  List<String> get logMessages => _logMessages;
  List<String> get attendedStudents => _attendedStudents;
  bool get isPollActive => _isPollActive;
  String? get errorMessage => _errorMessage;
  bool get autoScrollLog => _autoScrollLog;
  String get userId => _bleMeshServiceProvider.userId;
  Future<int> getDirectConnectionsCount() async=> await _bleMeshServiceProvider.getDirectConnectionsCount();

  void subscribeToReceiveMessage() {
    _bleMeshServiceProvider.messages.listen((message) {
      _logMessages.add(message);
      notifyListeners();
    });
  }

  void setRole(UserRoleViewModel role) {
    _role = role;
    notifyListeners();
  }

  void setAttendedStudents(List<String> students) {
    _attendedStudents = students;
    notifyListeners();
  }

  void setIsPollActive(bool value) {
    _isPollActive = value;
    notifyListeners();
  }

  void addLog(String message) {
    final timestamp = DateTime.now().toString();
    _logMessages = (_logMessages + ['[$timestamp] $message']).take(50).toList();
    notifyListeners();
  }

  void clearLogs() {
    _logMessages = [];
    notifyListeners();
  }

  void setAutoScrollLog(bool value) {
    _autoScrollLog = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<SendResultViewModel> sendMessage(String message) async {
    return SendResultViewModel.fromSendResult(
      await BleMeshService.sendMessage(message),
    );
  }
}
