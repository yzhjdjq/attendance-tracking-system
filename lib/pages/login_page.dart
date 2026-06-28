import 'package:ats/providers/providers.dart' show LoginPageProvider;
import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:ats/pages/pages.dart' show HomePage;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty) {
      setState(() {
        _errorMessage = S.of(context).enter_login_message;
      });
      return;
    }

    try {
      context.read<LoginPageProvider>().authorize(login, password);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = S.of(context).authorize_error_message;
        });
      }
    }
  }

  Future<void> _onEnterPressed() async {
    await _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    S.of(context).authorize,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: _loginController,
                    decoration: InputDecoration(
                      labelText: S.of(context).login,
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: S.of(context).password,
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onSubmitted: (_) => _onEnterPressed(),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    ),
                    child: Text(S.of(context).authorizeAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
