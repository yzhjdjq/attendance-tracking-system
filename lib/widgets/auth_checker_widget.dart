import 'package:ats/pages/pages.dart' show HomePage, LoginPage;
import 'package:ats/providers/providers.dart' show UserProvider;
import 'package:flutter/material.dart' show StatelessWidget, Widget, BuildContext;
import 'package:provider/provider.dart' show WatchContext;

class AuthCheckerWidget extends StatelessWidget {
  const AuthCheckerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<UserProvider>().isAuthenticated;

    if (isAuthenticated) {
      return const HomePage();
    }

    return const LoginPage();
  }
}