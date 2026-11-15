import 'dart:typed_data' show Uint8List;
import 'package:cbor/simple.dart' show cbor;


/// Тип сообщения
enum MessageType {
  attend,
  poll,
  text;

  static MessageType fromName(String? name) {
    return MessageType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => MessageType.attend,
    );
  }
}

/// Полезная нагрузка сообщения
///
/// Sealed-иерархия: в зависимости от [MessageType] payload имеет разную форму.
/// Для MessageType::poll payload отсутствует (`null`).
sealed class MessagePayload {
  const MessagePayload();

  Uint8List toBytes();

  static MessagePayload fromBytes(MessageType type, Uint8List bytes) {
    final decoded = cbor.decode(bytes);
    if (decoded is! Map) {
      throw FormatException(
        'Payload must be a CBOR map, got ${decoded.runtimeType}',
      );
    }
    final map = Map<String, dynamic>.from(decoded);

    return switch (type) {
      MessageType.text => TextPayload(map['text'] as String),
      MessageType.attend => TextPayload(map['text'] as String),
      MessageType.poll => throw StateError(
        'MessageType::poll must not carry a payload',
      ),
    };
  }
}

class TextPayload extends MessagePayload {
  final String text;
  const TextPayload(this.text);

  @override
  Uint8List toBytes() {
    final encoded = cbor.encode({'text': text});
    return Uint8List.fromList(encoded);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TextPayload &&
              runtimeType == other.runtimeType &&
              text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextPayload(text: $text)';
}

class Message {
  /// UUID v4, генерируется на UI при создании
  final String id;

  /// userId автора сообщения
  final String originalSenderId;

  /// userId получателя. При текущей реализации всегда `null`
  final String? recipientId;

  final MessageType messageType;

  /// Время формирования сообщения в UTC
  final DateTime timestamp;

  /// Полезная нагрузка
  final MessagePayload? payload;

  const Message({
    required this.id,
    required this.originalSenderId,
    required this.messageType,
    required this.timestamp,
    this.recipientId,
    this.payload,
  });

  bool get isValid {
    return switch (messageType) {
      MessageType.attend => payload is TextPayload,
      MessageType.poll => payload == null,
      MessageType.text => payload is TextPayload,
    };
  }

  /// Сериализация для отправки в Kotlin-core
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalSenderId': originalSenderId,
      if (recipientId != null) 'recipientId': recipientId,
      'messageType': messageType.name,
      'timestampMs': timestamp.toUtc().millisecondsSinceEpoch,
      if (payload != null) 'payload': payload!.toBytes(),
    };
  }

  /// Десериализация из Kotlin-core.
  factory Message.fromMap(Map<String, dynamic> map) {
    final type = MessageType.fromName(map['messageType'] as String?);
    final rawPayload = map['payload'];

    return Message(
      id: map['id'] as String,
      originalSenderId: map['originalSenderId'] as String,
      recipientId: map['recipientId'] as String?,
      messageType: type,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestampMs'] as num).toInt(),
        isUtc: true,
      ),
      payload: rawPayload == null
    ? null
        : MessagePayload.fromBytes(type, rawPayload as Uint8List),
    );
  }

  Message copyWith({
    String? id,
    String? originalSenderId,
    String? recipientId,
    bool clearRecipientId = false,
    MessageType? messageType,
    DateTime? timestamp,
    MessagePayload? payload,
    bool clearPayload = false,
  }) {
    return Message(
      id: id ?? this.id,
      originalSenderId: originalSenderId ?? this.originalSenderId,
      recipientId: clearRecipientId ? null : (recipientId ?? this.recipientId),
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      payload: clearPayload ? null : (payload ?? this.payload),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          originalSenderId == other.originalSenderId &&
          recipientId == other.recipientId &&
          messageType == other.messageType &&
          timestamp == other.timestamp &&
          payload == other.payload;

  @override
  int get hashCode => Object.hash(
    id,
    originalSenderId,
    recipientId,
    messageType,
    timestamp,
    payload,
  );

  @override
  String toString() =>
      'Message(id: $id, type: ${messageType.name}, '
      'from: $originalSenderId, to: ${recipientId ?? "everyone"}, '
      'ts: $timestamp, payload: $payload)';
}
