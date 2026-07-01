import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';

class ConnectedPeersCardWidget extends StatelessWidget {
  final List<String> peers;

  const ConnectedPeersCardWidget({super.key, required this.peers});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '🔗 ${S.of(context).mark_visit_connected_peers}: ${peers.join(', ')}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}