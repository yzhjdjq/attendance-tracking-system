import 'package:ats/models/models.dart' show UserRole;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:ats/providers/singleton_provider.dart' show SingletonMixin;

enum UserRoleViewModel {
  teacher,
  student;

  static UserRoleViewModel fromUserRole(UserRole role) {
    if ( role == UserRole.teacher ) {
      return UserRoleViewModel.teacher;
    }

    return UserRoleViewModel.student;
  }
}

class MarkVisitPageProvider with ChangeNotifier, SingletonMixin {
  static MarkVisitPageProvider get instance
    => SingletonMixin.getInstance<MarkVisitPageProvider>();

  static Future<MarkVisitPageProvider> initialize() async {
    if (SingletonMixin.isInitialized<MarkVisitPageProvider>()) {
      return instance;
    }

    final provider = MarkVisitPageProvider._internal();
    return provider;
  }

  MarkVisitPageProvider._internal() {
    SingletonMixin.registerInstance(this);
  }

  static bool get isInitialized => SingletonMixin.isInitialized<MarkVisitPageProvider>();

  UserRoleViewModel _role = UserRoleViewModel.student;
  String _myPeerId = '';
  List<String> _logMessages = [];
  List<String> _connectedPeers = [];
  List<String> _attendedStudents = [];
  bool _isPollActive = false;
  int _directConnectionsCount = 0;
  String? _errorMessage;
  bool _autoScrollLog = true;

  UserRoleViewModel get role => _role;
  String get myPeerId => _myPeerId;
  List<String> get logMessages => _logMessages;
  List<String> get connectedPeers => _connectedPeers;
  List<String> get attendedStudents => _attendedStudents;
  bool get isPollActive => _isPollActive;
  int get directConnectionsCount => _directConnectionsCount;
  String? get errorMessage => _errorMessage;
  bool get autoScrollLog => _autoScrollLog;

  void setRole(UserRoleViewModel role) {
    _role = role;
    notifyListeners();
  }

  void setMyPeerId(String peerId) {
    _myPeerId = peerId;
    addLog('✅ Mesh сервис подключен, ID: $peerId');
    notifyListeners();
  }

  void setConnectedPeers(List<String> peers) {
    _connectedPeers = peers;
    if (peers.isNotEmpty) {
      addLog('👥 Обнаружено ${peers.length} устройств');
    }
    notifyListeners();
  }

  void setDirectConnectionsCount(int count) {
    _directConnectionsCount = count;
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

  void updateFromService(Map<String, dynamic> data) {
    if (data.containsKey('myPeerId')) {
      _myPeerId = data['myPeerId'] as String;
    }
    if (data.containsKey('connectedPeers')) {
      _connectedPeers = List<String>.from(data['connectedPeers'] as List);
    }
    if (data.containsKey('directConnectionsCount')) {
      _directConnectionsCount = data['directConnectionsCount'] as int;
    }
    if (data.containsKey('attendedStudents')) {
      _attendedStudents = List<String>.from(data['attendedStudents'] as List);
    }
    if (data.containsKey('isPollActive')) {
      _isPollActive = data['isPollActive'] as bool;
    }
    if (data.containsKey('logMessages')) {
      _logMessages = List<String>.from(data['logMessages'] as List);
    }
    notifyListeners();
  }
}
