import 'dart:async' show StreamSubscription;

import 'package:ats/models/models.dart'
    show DeliveryStatus, Message, MessageType, TextPayload, AttendanceReport;
import 'package:ats/providers/providers.dart'
    show BleMeshServiceProvider, UserProvider, UserRoleViewModel;
import 'package:ats/services/services.dart' show BleMeshService;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:ats/providers/singleton_provider.dart' show SingletonMixin;
import 'package:uuid/uuid.dart' show Uuid;

enum DeliveryStatusViewModel {
  notImplemented,
  success,
  error;

  static DeliveryStatusViewModel fromDeliveryStatus(DeliveryStatus result) {
    return switch (result) {
      DeliveryStatus.notImplemented => DeliveryStatusViewModel.notImplemented,
      DeliveryStatus.sending ||
      DeliveryStatus.sent ||
      DeliveryStatus.delivered => DeliveryStatusViewModel.success,
      DeliveryStatus.failed => DeliveryStatusViewModel.error,
    };
  }
}

class MarkVisitPageProvider with ChangeNotifier, SingletonMixin {
  static MarkVisitPageProvider get instance =>
      SingletonMixin.getInstance<MarkVisitPageProvider>();

  static Future<MarkVisitPageProvider> initialize({
    required BleMeshServiceProvider bleMeshServiceProvider,
    required UserProvider userProvider,
  }) async {
    if (SingletonMixin.isInitialized<MarkVisitPageProvider>()) {
      return instance;
    }

    final provider = MarkVisitPageProvider._internal(
      bleMeshServiceProvider,
      userProvider,
    );
    return provider;
  }

  MarkVisitPageProvider._internal(
    this._bleMeshServiceProvider,
    this._userProvider,
  ) {
    SingletonMixin.registerInstance(this);
    subscribeToMeshServiceState();
    subscribeToReceiveMessage();
  }

  static bool get isInitialized =>
      SingletonMixin.isInitialized<MarkVisitPageProvider>();

  late final BleMeshServiceProvider _bleMeshServiceProvider;
  late final UserProvider _userProvider;

  StreamSubscription<bool>? _meshServiceStateSubscription;
  StreamSubscription<Message>? _messagesSubscription;

  List<String> _logMessages = [];
  final Map<String, String> _attendedStudents = {};
  String? _errorMessage;
  bool _autoScrollLog = true;
  bool _isMeshServiceState = false;
  static const _uuid = Uuid();

  bool get canStart => _bleMeshServiceProvider.canStart;
  UserRoleViewModel get role => _userProvider.roleOrStudent;
  List<String> get logMessages => _logMessages;
  List<String> get attendedStudents => _attendedStudents.values.toList();
  String? get errorMessage => _errorMessage;
  bool get autoScrollLog => _autoScrollLog;
  String get userId => _userProvider.username ?? '';
  Future<int> getDirectConnectionsCount() async =>
      await _bleMeshServiceProvider.getDirectConnectionsCount();

  void subscribeToMeshServiceState() {
    _bleMeshServiceProvider.isMeshServiceRunning.then(
      (state) => {_isMeshServiceState = state},
    );
    _meshServiceStateSubscription = _bleMeshServiceProvider.serviceState.listen(
      (newState) {
        if (_isMeshServiceState != newState) {
          _isMeshServiceState = newState;
          notifyListeners();
        }
      },
    );
  }

  void subscribeToReceiveMessage() {
    _messagesSubscription = _bleMeshServiceProvider.messages.listen((message) {
      addLog(_formatMessage(message));

      if (message.messageType == MessageType.attend &&
          message.originalSenderId != _bleMeshServiceProvider.userId &&
          _bleMeshServiceProvider.userId != null) {
        final senderId = message.originalSenderId;
        if (!_attendedStudents.containsKey(senderId)) {
          final fullName = switch (message.payload) {
            TextPayload(:final text) => text,
            _ => senderId,
          };
          _attendedStudents[senderId] = fullName;
          notifyListeners();
        }
      }

      if (message.messageType == MessageType.poll &&
          message.originalSenderId != _bleMeshServiceProvider.userId &&
          _bleMeshServiceProvider.userId != null) {
        _sendAttendResponse(message.originalSenderId);
      }
    });
  }

  bool isMeshServiceRunning() => _isMeshServiceState;

  void addLog(String message) {
    final timestamp = DateTime.now().toString();
    _logMessages = (_logMessages + ['[$timestamp] $message'])
        .take(120)
        .toList();
    notifyListeners();
  }

  void addLogRaw(String message) {
    _logMessages = (_logMessages + [message]).take(120).toList();
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

  Future<DeliveryStatusViewModel> sendMessage(Message message) async {
    return DeliveryStatusViewModel.fromDeliveryStatus(
      await BleMeshService.sendMessage(message),
    );
  }

  void startService() {
    if (_bleMeshServiceProvider.userId != null) {
      BleMeshService.initMeshService(_bleMeshServiceProvider.userId!);
      Future.delayed(
        Duration(milliseconds: 700),
        () => {
          if (_isMeshServiceState == false)
            {
              _bleMeshServiceProvider.isMeshServiceRunning.then(
                (state) => {_isMeshServiceState = state},
              ),
            },
        },
      );
    }
  }

  String _formatMessage(Message message) {
    final ts = message.timestamp.toLocal();
    final time =
        '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}:'
        '${ts.second.toString().padLeft(2, '0')}';
    final textPayload = message.payload is TextPayload ? (message.payload as TextPayload).text : '';

    return switch (message.messageType) {
      MessageType.attend =>
        '📋 ATTEND from $textPayload at $time',
      MessageType.poll => '📋 POLL from ${message.originalSenderId} at $time',
      MessageType.text =>
        '💬 TEXT from ${message.originalSenderId} at $time: '
            '${(message.payload as TextPayload).text}',
    };
  }

  String _formatOutgoing(Message message, DeliveryStatus status) {
    final ts = message.timestamp.toLocal();
    final time =
        '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}:'
        '${ts.second.toString().padLeft(2, '0')}';

    final statusLabel = switch (status) {
      DeliveryStatus.notImplemented => '❌ не реализовано',
      DeliveryStatus.sending => '⏳ отправляется',
      DeliveryStatus.sent => '✅ отправлено',
      DeliveryStatus.delivered => '✅ доставлено',
      DeliveryStatus.failed => '❌ ошибка',
    };

    return switch (message.messageType) {
      MessageType.attend =>
        '📤 ATTEND → ${message.recipientId ?? "everyone"} at $time [$statusLabel]',
      MessageType.poll => '📤 POLL → everyone at $time [$statusLabel]',
      MessageType.text =>
        '📤 TEXT → ${message.recipientId ?? "everyone"} at $time [$statusLabel]: '
            '${(message.payload as TextPayload).text}',
    };
  }

  Future<void> _sendAttendResponse(String teacherId) async {
    final message = buildAttendMessage(
      fullName: _userProvider.fullName ?? userId, recipientId: teacherId);
    final status = await _bleMeshServiceProvider.sendMessage(message);

    addLogRaw(_formatOutgoing(message, status));
  }

  Message buildAttendMessage({required String fullName, String? recipientId}) {
    return Message(
      id: _uuid.v4(),
      originalSenderId: userId,
      recipientId: recipientId,
      messageType: MessageType.attend,
      timestamp: DateTime.now().toUtc(),
      payload: TextPayload(fullName),
    );
  }

  Message buildPollMessage() {
    return Message(
      id: _uuid.v4(),
      originalSenderId: userId,
      messageType: MessageType.poll,
      timestamp: DateTime.now().toUtc(),
      payload: null,
    );
  }

  Message buildTextMessage(String text) {
    return Message(
      id: _uuid.v4(),
      originalSenderId: userId,
      messageType: MessageType.text,
      timestamp: DateTime.now().toUtc(),
      payload: TextPayload(text),
    );
  }

  AttendanceReport buildAttendanceReport({
    required String groupName,
    required String subject,
  }) {
    return AttendanceReport(
      groupName: groupName,
      subject: subject,
      date: DateTime.now(),
      students: List.unmodifiable(_attendedStudents.values),
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _meshServiceStateSubscription?.cancel();
    super.dispose();
  }
}
