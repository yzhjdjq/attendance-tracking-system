import 'package:ats/l10n/extensions/extensions.dart'
    show PermissionKindL10nExtension, PermissionUiStatusL10nExtension;
import 'package:ats/providers/providers.dart'
    show PermissionsProvider, PermissionEntry, PermissionUiStatus;
import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart' show ReadContext, WatchContext;

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<PermissionsProvider>().refreshAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final perms = context.watch<PermissionsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).permission_page_title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: S.of(context).permission_action_refresh,
            onPressed: perms.isLoading ? null : perms.refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: perms.isLoading && perms.statuses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final entry in perms.trackedPermissions)
                  _PermissionTile(
                    entry: entry,
                    status: perms.statusOf(entry.permission),
                    onRequest: () => perms.request(entry.permission),
                  ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: perms.isLoading
                              ? null
                              : perms.requestAllMissing,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            S.of(context).permission_action_requestAll,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: perms.openAppSettingsPage,
                          icon: const Icon(Icons.settings),
                          label: Text(
                            S.of(context).permission_action_openSystemSettings,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.entry,
    required this.status,
    required this.onRequest,
  });

  final PermissionEntry entry;
  final PermissionUiStatus status;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (icon, color) = _iconFor(status);
    final needsSystemSettings =
        status == PermissionUiStatus.permanentlyDenied ||
        status == PermissionUiStatus.restricted;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(entry.kind.title(context)),
      subtitle: Text(
        '${entry.kind.description(context)}\n${s.permission_statusLabel}: ${status.label(context)}',
      ),
      isThreeLine: true,
      trailing: status == PermissionUiStatus.granted
          ? const Icon(Icons.check, color: Colors.green)
          : TextButton(
              onPressed: needsSystemSettings ? openAppSettings : onRequest,
              child: Text(
                needsSystemSettings
                    ? s.permission_action_open
                    : s.permission_action_request,
              ),
            ),
    );
  }

  (IconData, Color) _iconFor(PermissionUiStatus status) {
    switch (status) {
      case PermissionUiStatus.granted:
        return (Icons.check_circle, Colors.green);
      case PermissionUiStatus.denied:
        return (Icons.error_outline, Colors.orange);
      case PermissionUiStatus.permanentlyDenied:
        return (Icons.block, Colors.red);
      case PermissionUiStatus.restricted:
        return (Icons.lock_outline, Colors.red);
      case PermissionUiStatus.unknown:
        return (Icons.help_outline, Colors.grey);
    }
  }
}
