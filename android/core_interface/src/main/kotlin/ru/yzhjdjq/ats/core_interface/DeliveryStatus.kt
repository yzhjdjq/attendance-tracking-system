package ru.yzhjdjq.ats.core_interface

/**
 * Статус отправки сообщения.
 *
 * Часть контракта с Flutter. Имена значений и [toChannelValue] должны
 * совпадать с Dart-enum `DeliveryStatus` (camelCase в Dart).
 *
 *  - [NOT_IMPLEMENTED] - core-библиотека отсутствует (StubMesh).
 *  - [SENDING] - сообщение передано в Mesh сервис.
 *  - [SENT] - сообщение отправлено в Mesh сеть.
 *  - [DELIVERED] - получатель подтвердил доставку (резерв, ACK пока нет).
 *  - [FAILED] - отправить не удалось.
 */
enum class DeliveryStatus {
  NOT_IMPLEMENTED,
  SENDING,
  SENT,
  DELIVERED,
  FAILED;

  /**
   * Строковое представление для канала Dart.
   */
  fun toChannelValue(): String = when (this) {
    NOT_IMPLEMENTED -> "notImplemented"
    SENDING -> "sending"
    SENT -> "sent"
    DELIVERED -> "delivered"
    FAILED -> "failed"
  }
}
