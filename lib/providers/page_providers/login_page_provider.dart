import 'package:ats/providers/model_providers/model_providers.dart'
    show UserProvider;
import 'package:ats/providers/singleton_provider.dart' show SingletonMixin;
import 'package:ats/services/services.dart' show AuthFailureReason;
import 'package:flutter/foundation.dart' show ChangeNotifier;

enum LoginMode { teacher, student }

class LoginPageProvider with ChangeNotifier, SingletonMixin {
  static LoginPageProvider get instance =>
      SingletonMixin.getInstance<LoginPageProvider>();

  static Future<LoginPageProvider> initialize({
    required UserProvider userProvider,
  }) async {
    if (SingletonMixin.isInitialized<LoginPageProvider>()) return instance;
    final provider = LoginPageProvider._internal(userProvider);
    return provider;
  }

  LoginPageProvider._internal(this._userProvider) {
    SingletonMixin.registerInstance(this);
    _userProvider.addListener(notifyListeners);
  }

  static bool get isInitialized =>
      SingletonMixin.isInitialized<LoginPageProvider>();

  late final UserProvider _userProvider;

  LoginMode _mode = LoginMode.teacher;
  bool _isSubmitting = false;
  AuthFailureReason? _lastFailure;

  LoginMode get mode => _mode;
  bool get isSubmitting => _isSubmitting;
  AuthFailureReason? get lastFailure => _lastFailure;

  void setMode(LoginMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _lastFailure = null;
    notifyListeners();
  }

  Future<bool> submitTeacherLogin({
    required String login,
    required String password,
  }) async {
    _setSubmitting(true);
    final failure = await _userProvider.authenticateWithCredentials(
      login,
      password,
    );
    _lastFailure = failure;
    _setSubmitting(false);
    return failure == null;
  }

  Future<bool> submitStudentRegistration({required String fullName}) async {
    _setSubmitting(true);
    final failure = await _userProvider.registerStudentSession(fullName);
    _lastFailure = failure;
    _setSubmitting(false);
    return failure == null;
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
