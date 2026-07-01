import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';

class AttendedStudentsCardWidget extends StatelessWidget {
  final List<String> students;

  const AttendedStudentsCardWidget({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 ${S.of(context).mark_visit_attended} (${students.length}):',
              style: Theme.of(context).textTheme.titleSmall,
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