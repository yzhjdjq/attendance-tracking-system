import 'package:ats/providers/providers.dart' show UserProvider, LoginPageProvider;
import 'package:ats/services/services.dart' show S, StorageService;
import 'package:ats/widgets/widgets.dart' show AuthCheckerWidget;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();
  await UserProvider.initialize();
  await LoginPageProvider.initialize(userProvider: UserProvider.instance);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider.instance),
        ChangeNotifierProvider(create: (context) => LoginPageProvider.instance),
      ],
      child: MaterialApp(
        locale: S.locale,
        supportedLocales: S.supportedLocales,
        localizationsDelegates: S.localizationDelegates,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const AuthCheckerWidget(),
      ),
    );
  }
}
