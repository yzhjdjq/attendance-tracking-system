import 'package:ats/providers/providers.dart' show MarkVisitPageProvider;
import 'package:ats/services/services.dart' show S;
import 'package:ats/widgets/widgets.dart' show ExportAttendanceDialog;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;

class AttendedStudentsCardWidget extends StatelessWidget {
  final List<String> students;

  const AttendedStudentsCardWidget({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '📋 ${S.of(context).mark_visit_attended} (${students.length}):',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: S.of(context).attendance_export_title,
                  icon: const Icon(Icons.ios_share),
                  onPressed: students.isEmpty
                      ? null
                      : () => ExportAttendanceDialog.show(
                          context,
                          buildReport:
                              ({required groupName, required subject}) =>
                                  context
                                      .read<MarkVisitPageProvider>()
                                      .buildAttendanceReport(
                                        groupName: groupName,
                                        subject: subject,
                                      ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...students.map((student) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  '• $student',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
