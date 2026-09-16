import 'package:ats/pages/pages.dart' show EditTeacherNamePage, PermissionsPage;
import 'package:ats/providers/providers.dart' show UserProvider;
import 'package:ats/services/services.dart' show S;
import 'package:ats/widgets/widgets.dart' show MainDrawerWidget;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext, WatchContext;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final user = context.watch<UserProvider>();
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(s.settings_page_title),
      ),
      drawer: MainDrawerWidget(
        role: context.read<UserProvider>().roleOrStudent,
      ),
      body: ListView(
        children: [
          if (user.isAuthenticated)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Text(
                        _initials(user.fullName ?? ''),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName?.isEmpty ?? true
                                ? s.profile_unknown_name
                                : user.fullName!,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.isTeacher
                                ? s.login_mode_teacher
                                : s.login_mode_student,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user.isTeacher)
                      IconButton(
                        tooltip: s.settings_profile_name_title,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditTeacherNamePage(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

          const Divider(height: 1),

          if (isAndroid)
            ListTile(
              leading: const Icon(Icons.security),
              title: Text(s.permission_page_title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PermissionsPage()),
                );
              },
            ),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}
