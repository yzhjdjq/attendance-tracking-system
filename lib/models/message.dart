import 'dart:typed_data';

class Message {
  final int len;
  final String recipientId;
  final Uint8List payload;

  const Message({required this.len, required this.recipientId, required this.payload});

  Map<String, dynamic> toJson() {
    return {'len': len, 'recipientId': recipientId, 'payload': payload.toList()};
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      len: json['len'] as int,
      recipientId: json['recipientId'] as String,
      payload: Uint8List.fromList((json['payload'] as List<int>).toList()),
    );
  }

  Message copyWith({int? len, String? recipientId, Uint8List? payload}) {
    return Message(
      len: len ?? this.len,
      recipientId: recipientId ?? this.recipientId,
      payload: payload ?? this.payload,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Message &&
              runtimeType == other.runtimeType &&
              len == other.len &&
              recipientId == other.recipientId &&
              payload == other.payload;

  @override
  int get hashCode => Object.hash(len, recipientId, payload);

  @override
  String toString() {
    return 'Message(len: $len, recipientId: $recipientId, payload: $payload)';
  }
}
