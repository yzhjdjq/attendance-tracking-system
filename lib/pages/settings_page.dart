import 'package:ats/pages/pages.dart' show PermissionsPage;
import 'package:ats/services/services.dart' show S;
import 'package:ats/widgets/widgets.dart' show MainDrawerWidget;
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(S.of(context).settings_page_title),
      ),
      drawer: const MainDrawerWidget(),
      body: ListView(
        children: [
          if (isAndroid)
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Разрешения приложения'),
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
}
