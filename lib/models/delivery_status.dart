/// Статус доставки сообщения.
enum DeliveryStatus {
  notImplemented,
  sending,
  sent,
  delivered,
  failed;

  static DeliveryStatus fromChannelValue(String? value) {
    return value == null
        ? DeliveryStatus.failed
        : DeliveryStatus.values.firstWhere(
            (s) => s.name == value,
            orElse: () => DeliveryStatus.failed,
          );
  }

  bool get isTerminal =>
      this == DeliveryStatus.delivered ||
      this == DeliveryStatus.failed ||
      this == DeliveryStatus.notImplemented;
}
