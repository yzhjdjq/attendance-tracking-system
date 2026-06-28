import 'package:ats/services/services.dart' show BleMeshService, S, SendResult;
import 'package:flutter/material.dart';
import 'package:ats/widgets/widgets.dart' show MainDrawer;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  String _tooltipText = 'Loading...';

  @override
  void initState() {
    super.initState();
    BleMeshService.sendMessage().then((value) {
      setState(() {
        _tooltipText = switch (value) {
          SendResult.notImplemented => 'Не реализовано',
          SendResult.success => 'Успешно',
          SendResult.error => 'Ошибка',
        };
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(S.of(context).home_page_title),
        actions: <Widget>[],
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Вы успешно авторизованы!'),
            const SizedBox(height: 16),
            Text('Счетчик: $_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: _tooltipText,
        child: const Icon(Icons.add),
      ),
    );
  }
}
