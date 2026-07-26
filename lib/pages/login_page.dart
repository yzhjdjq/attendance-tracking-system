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
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        S.of(context).authorize,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildTextField(
                        context: context,
                        controller: _loginController,
                        labelText: S.of(context).login,
                        prefixIcon: Icons.person,
                        keyboardType: TextInputType.text,
                        theme: theme,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        context: context,
                        controller: _passwordController,
                        labelText: S.of(context).password,
                        prefixIcon: Icons.lock,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        theme: theme,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.onErrorContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      _buildLoginButton(context, theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required ThemeData theme,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onSubmitted: (_) => _onEnterPressed(),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
        border: _buildOutlineBorder(context, theme),
        enabledBorder: _buildOutlineBorder(context, theme, active: false),
        focusedBorder: _buildFocusedBorder(context, theme),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  OutlineInputBorder _buildOutlineBorder(BuildContext context, ThemeData theme, {bool active = true}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.outline,
        width: 1.5,
      ),
    );
  }

  OutlineInputBorder _buildFocusedBorder(BuildContext context, ThemeData theme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.primary,
        width: 2,
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 2,
      ),
      child: Text(
        S.of(context).authorizeAction,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
