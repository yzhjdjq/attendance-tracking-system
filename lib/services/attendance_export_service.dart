import 'dart:convert' show utf8;
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ats/models/models.dart' show AttendanceReport;

class AttendanceExportService {
  const AttendanceExportService();

  Future<void> copyToClipboard(AttendanceReport report) async {
    await Clipboard.setData(ClipboardData(text: report.toPlainText()));
  }

  Future<String?> saveToDownloads(AttendanceReport report) async {
    final bytes = Uint8List.fromList(utf8.encode(report.toPlainText()));
    final fileName = report.suggestedFileName();

    try {
      if (kIsWeb) {
        final path = await FileSaver.instance.saveFile(
          name: fileName.replaceAll('.txt', ''),
          bytes: bytes,
          fileExtension: 'txt',
          mimeType: MimeType.text,
        );
        return path;
      }

      if (Platform.isAndroid) {
        final path = await FileSaver.instance.saveFile(
          name: fileName.replaceAll('.txt', ''),
          bytes: bytes,
          fileExtension: 'txt',
          mimeType: MimeType.text,
        );
        return path;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AttendanceExportService.saveToDownloads error: $e');
      }
      return null;
    }
  }
}
