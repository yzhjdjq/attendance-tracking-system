import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';

class ErrorCardWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorCardWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '❌ $errorMessage',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onErrorContainer,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(S.of(context).mark_visit_request_permissions),
            ),
          ],
        ),
      ),
    );
  }
}