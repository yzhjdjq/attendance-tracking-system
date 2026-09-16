import 'package:ats/models/models.dart' show AttendanceReport;
import 'package:ats/services/services.dart' show AttendanceExportService, S;
import 'package:flutter/material.dart';

class ExportAttendanceDialog extends StatefulWidget {
  final AttendanceReport Function({
    required String groupName,
    required String subject,
  })
  buildReport;

  const ExportAttendanceDialog({super.key, required this.buildReport});

  static Future<void> show(
    BuildContext context, {
    required AttendanceReport Function({
      required String groupName,
      required String subject,
    })
    buildReport,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ExportAttendanceDialog(buildReport: buildReport),
    );
  }

  @override
  State<ExportAttendanceDialog> createState() => _ExportAttendanceDialogState();
}

class _ExportAttendanceDialogState extends State<ExportAttendanceDialog> {
  final _groupController = TextEditingController();
  final _subjectController = TextEditingController();
  final _exportService = const AttendanceExportService();

  String? _groupError;
  String? _subjectError;
  bool _busy = false;

  @override
  void dispose() {
    _groupController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _copyReport() async {
    final report = _validateAndBuild();
    if (report == null) return;

    setState(() => _busy = true);
    try {
      await _exportService.copyToClipboard(report);
      if (!mounted) return;
      _showSnackBar(S.of(context).attendance_export_copied);
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveReport() async {
    final report = _validateAndBuild();
    if (report == null) return;

    setState(() => _busy = true);
    try {
      final path = await _exportService.saveToDownloads(report);
      if (!mounted) return;
      final message = path == null
          ? S.of(context).attendance_export_save_failed
          : '${S.of(context).attendance_export_saved}: $path';
      _showSnackBar(message);
      if (path != null) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  AttendanceReport? _validateAndBuild() {
    final group = _groupController.text.trim();
    final subject = _subjectController.text.trim();

    setState(() {
      _groupError = group.isEmpty
          ? S.of(context).attendance_export_group_required
          : null;
      _subjectError = subject.isEmpty
          ? S.of(context).attendance_export_subject_required
          : null;
    });

    if (group.isEmpty || subject.isEmpty) return null;

    return widget.buildReport(groupName: group, subject: subject);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(s.attendance_export_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _groupController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.attendance_export_group_label,
                prefixIcon: const Icon(Icons.groups_outlined),
                errorText: _groupError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.attendance_export_subject_label,
                prefixIcon: const Icon(Icons.menu_book_outlined),
                errorText: _subjectError,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.attendance_export_date_auto_note,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(s.attendance_export_cancel),
        ),
        TextButton.icon(
          onPressed: _busy ? null : _copyReport,
          icon: const Icon(Icons.copy_all_outlined),
          label: Text(s.attendance_export_copy_action),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _saveReport,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined),
          label: Text(s.attendance_export_save_action),
        ),
      ],
    );
  }
}
