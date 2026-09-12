import 'package:ats/providers/providers.dart'
    show UserProvider, LoginPageProvider, MarkVisitPageProvider;
import 'package:ats/providers/service_providers/ble_mesh_service_provider.dart';
import 'package:ats/services/services.dart' show S, StorageService;
import 'package:ats/widgets/widgets.dart' show AuthCheckerWidget;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();
  await BleMeshServiceProvider.initialize();
  await UserProvider.initialize(
    bleMeshServiceProvider: BleMeshServiceProvider.instance,
  );
  await LoginPageProvider.initialize(userProvider: UserProvider.instance);
  await MarkVisitPageProvider.initialize(
    bleMeshServiceProvider: BleMeshServiceProvider.instance,
  );
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
        ChangeNotifierProvider(
          create: (context) => MarkVisitPageProvider.instance,
        ),
      ],
      child: MaterialApp(
        locale: S.locale,
        supportedLocales: S.supportedLocales,
        localizationsDelegates: S.localizationDelegates,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(48, 213, 169, 1),
          ),
        ),
        home: const AuthCheckerWidget(),
      ),
    );
  }
}
