import 'package:ats/providers/providers.dart' show UserProvider;
import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTeacherNamePage extends StatefulWidget {
  const EditTeacherNamePage({super.key});

  @override
  State<EditTeacherNamePage> createState() => _EditTeacherNamePageState();
}

class _EditTeacherNamePageState extends State<EditTeacherNamePage> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<UserProvider>().fullName,
    );
    _controller.addListener(_clearError);
  }

  @override
  void dispose() {
    _controller.removeListener(_clearError);
    _controller.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  Future<void> _save() async {
    final provider = context.read<UserProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);

    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _errorText = s.enter_full_name_message);
      return;
    }

    final ok = await provider.updateFullName(value);
    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.settings_profile_name_saved)),
      );
      navigator.pop();
    } else {
      setState(() => _errorText = s.authorize_error_unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(s.settings_profile_name_title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: s.full_name,
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  errorText: _errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(s.settings_profile_name_save_action),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
