import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ats/providers/providers.dart' show UserProvider;
import 'package:ats/services/services.dart' show S;
import 'package:ats/pages/pages.dart'
    show HomePage, LoginPage, MarkVisitPage, SettingsPage;

class MainDrawerWidget extends StatelessWidget {
  const MainDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _MainDrawerHeader(),
          _buildDrawerItem(
            icon: Icons.home,
            title: S.of(context).home_page_title,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.monitor_heart,
            title: S.of(context).mark_visit_page_title,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MarkVisitPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: S.of(context).settings_page_title,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: S.of(context).logout_action,
            onTap: () {
              context.read<UserProvider>().logout();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

class _MainDrawerHeader extends StatelessWidget {
  const _MainDrawerHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              radius: 30,
              child: Text(
                S.of(context).appNameShort,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).appName,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
