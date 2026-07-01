import 'package:ats/providers/providers.dart' show UserRoleViewModel;
import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';

class MarkVisitActionButtonWidget extends StatelessWidget {
  final UserRoleViewModel role;
  final bool isPollActive;
  final bool hasError;
  final VoidCallback onPressed;

  const MarkVisitActionButtonWidget({
    super.key,
    required this.role,
    required this.isPollActive,
    required this.hasError,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasError ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: role == UserRoleViewModel.teacher
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          role == UserRoleViewModel.teacher ? '📢 ${S.of(context).mark_visit_start_poll(10)}' : '✅ ${S.of(context).mark_visit_mark_attendance}',
        ),
      ),
    );
  }
}