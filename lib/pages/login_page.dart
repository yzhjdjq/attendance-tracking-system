import 'package:ats/pages/pages.dart' show HomePage;
import 'package:ats/providers/providers.dart' show LoginPageProvider, LoginMode;
import 'package:ats/services/services.dart' show S;
import 'package:ats/l10n/extensions/extensions.dart'
    show AuthFailureReasonL10nExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<LoginPageProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final bool success;
    if (provider.mode == LoginMode.teacher) {
      success = await provider.submitTeacherLogin(
        login: _loginController.text,
        password: _passwordController.text,
      );
    } else {
      success = await provider.submitStudentRegistration(
        fullName: _fullNameController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      final failure = provider.lastFailure;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            failure?.message(context) ?? S.of(context).authorize_error_message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginPageProvider>();
    final theme = Theme.of(context);
    final isTeacherMode = provider.mode == LoginMode.teacher;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).authorize,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),

                      SegmentedButton<LoginMode>(
                        segments: [
                          ButtonSegment(
                            value: LoginMode.teacher,
                            label: Text(S.of(context).login_mode_teacher),
                            icon: const Icon(Icons.school),
                          ),
                          ButtonSegment(
                            value: LoginMode.student,
                            label: Text(S.of(context).login_mode_student),
                            icon: const Icon(Icons.person_outline),
                          ),
                        ],
                        selected: {provider.mode},
                        onSelectionChanged: (set) {
                          provider.setMode(set.first);
                        },
                      ),

                      const SizedBox(height: 24),

                      if (isTeacherMode) ...[
                        _buildTextField(
                          controller: _loginController,
                          labelText: S.of(context).login,
                          prefixIcon: Icons.person,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          labelText: S.of(context).password,
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          theme: theme,
                        ),
                      ] else ...[
                        _buildTextField(
                          controller: _fullNameController,
                          labelText: S.of(context).full_name,
                          prefixIcon: Icons.badge_outlined,
                          theme: theme,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Сессионный вход. Данные будут сброшены при выходе.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: provider.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isTeacherMode
                                      ? S.of(context).authorizeAction
                                      : S.of(context).register_and_login_action,
                                ),
                        ),
                      ),
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
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required ThemeData theme,
    bool obscureText = false,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction ?? TextInputAction.next,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
