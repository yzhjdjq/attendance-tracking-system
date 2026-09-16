import 'dart:convert';
import 'package:intl/intl.dart';

class AttendanceReport {
  final String groupName;
  final String subject;
  final DateTime date;
  final List<String> students;

  const AttendanceReport({
    required this.groupName,
    required this.subject,
    required this.date,
    required this.students,
  });

  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln('ОТЧЁТ О ПОСЕЩАЕМОСТИ');
    buffer.writeln('=' * 40);
    buffer.writeln('Группа:  $groupName');
    buffer.writeln('Предмет: $subject');
    buffer.writeln('Дата:    ${_formatDate(date)}');
    buffer.writeln('Отметилось: ${students.length}');
    buffer.writeln('=' * 40);
    buffer.writeln();

    if (students.isEmpty) {
      buffer.writeln('Нет отметившихся студентов.');
    } else {
      for (var i = 0; i < students.length; i++) {
        buffer.writeln('${(i + 1).toString().padLeft(3, ' ')}. ${students[i]}');
      }
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Сформировано: ${_formatDateTime(DateTime.now())}');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
    'groupName': groupName,
    'subject': subject,
    'date': date.toIso8601String(),
    'students': students,
    'generatedAt': DateTime.now().toIso8601String(),
  };

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  String suggestedFileName() {
    final safeGroup = groupName
        .trim()
        .replaceAll(RegExp(r'[^\wА-Яа-яЁё0-9-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final datePart = DateFormat('yyyy-MM-dd').format(date);
    return 'attendance_${safeGroup}_$datePart.txt';
  }

  static String _formatDate(DateTime d) =>
      DateFormat('dd.MM.yyyy', 'ru').format(d);

  static String _formatDateTime(DateTime d) =>
      DateFormat('dd.MM.yyyy HH:mm:ss', 'ru').format(d);
}
