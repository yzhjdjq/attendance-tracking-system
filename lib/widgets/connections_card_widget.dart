import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';

class ConnectionsCardWidget extends StatelessWidget {
  static const double _borderRoundRadius = 12.0;

  final int directConnectionsCount;

  const ConnectionsCardWidget({super.key, required this.directConnectionsCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRoundRadius)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(_borderRoundRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🔗 ${S.of(context).mark_visit_direct_connections}:', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '$directConnectionsCount',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: directConnectionsCount > 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (directConnectionsCount == 0)
              Padding(
                padding: const EdgeInsets.only(left: _borderRoundRadius * 3, top: 8.0),
                child: Text(
                  S.of(context).mark_visit_no_connections,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.left,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
