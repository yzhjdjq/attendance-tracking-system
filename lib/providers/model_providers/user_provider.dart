import 'package:ats/models/models.dart' show User, UserRole, AuthMethod;
import 'package:ats/providers/providers.dart'
    show SingletonMixin, BleMeshServiceProvider;
import 'package:ats/repositories/repositories.dart' show UserRepository;
import 'package:ats/services/services.dart'
    show AuthService, AuthFailure, AuthFailureReason, AuthResult, AuthSuccess;
import 'package:flutter/foundation.dart' show ChangeNotifier;

enum UserRoleViewModel {
  teacher,
  student;

  static UserRoleViewModel? fromUserRoleOrNull(UserRole? role) {
    if (role == UserRole.teacher) {
      return UserRoleViewModel.teacher;
    } else if (role == UserRole.student) {
      return UserRoleViewModel.student;
    }

    return null;
  }

  static UserRoleViewModel fromUserRoleOrStudent(UserRole? role) {
    if (role == UserRole.teacher) {
      return UserRoleViewModel.teacher;
    }

    return UserRoleViewModel.student;
  }
}

class UserProvider with ChangeNotifier, SingletonMixin {
  static UserProvider get instance =>
      SingletonMixin.getInstance<UserProvider>();

  static Future<UserProvider> initialize({
    required BleMeshServiceProvider bleMeshServiceProvider,
  }) async {
    if (SingletonMixin.isInitialized<UserProvider>()) return instance;
    final provider = UserProvider._internal(bleMeshServiceProvider);
    await provider._loadDataFromRepository();
    return provider;
  }

  UserProvider._internal(this._bleMeshServiceProvider) {
    SingletonMixin.registerInstance(this);
  }

  static bool get isInitialized => SingletonMixin.isInitialized<UserProvider>();

  late final BleMeshServiceProvider _bleMeshServiceProvider;
  final UserRepository _userRepo = UserRepository();
  final AuthService _authService = const AuthService();

  static User _user = const User(isAuthenticated: false);

  Future<void> _loadDataFromRepository() async {
    _user = await _userRepo.load(defaultValue: _user);
    _bleMeshServiceProvider.setUserId(
      _user.isAuthenticated ? _user.username : null,
    );
    notifyListeners();
  }

  void _saveDataToRepository() async {
    await _userRepo.save(_user);
    _bleMeshServiceProvider.setUserId(
      _user.isAuthenticated ? _user.username : null,
    );
    notifyListeners();
  }

  bool get isAuthenticated => _user.isAuthenticated;
  String? get username => _user.username;
  String? get fullName => _user.fullName;
  UserRoleViewModel? get role =>
      UserRoleViewModel.fromUserRoleOrNull(_user.role);
  UserRoleViewModel get roleOrStudent =>
      UserRoleViewModel.fromUserRoleOrStudent(_user.role);
  bool get isTeacher => _user.isTeacher;
  bool get isStudent => _user.isStudent;
  AuthMethod? get authMethod => _user.authMethod;
  User get user => _user;

  Future<AuthFailureReason?> authenticateWithCredentials(
    String login,
    String password,
  ) async {
    final result = _authService.authenticateWithCredentials(login, password);
    return _applyAuthResult(result);
  }

  Future<AuthFailureReason?> registerStudentSession(String fullName) async {
    final result = _authService.registerStudentSession(fullName);
    return _applyAuthResult(result);
  }

  Future<bool> updateFullName(String fullName) async {
    if (!_user.isAuthenticated) return false;

    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return false;

    _user = _user.copyWith(fullName: trimmed);
    _saveDataToRepository();
    return true;
  }

  Future<AuthFailureReason?> _applyAuthResult(AuthResult result) async {
    switch (result) {
      case AuthSuccess(:final user):
        final savedUser = await _userRepo.load(defaultValue: const User());
        final mergedUser =
            user.role == UserRole.teacher &&
                savedUser.username == user.username &&
                (savedUser.fullName?.trim().isNotEmpty ?? false)
            ? user.copyWith(fullName: savedUser.fullName)
            : user;

        _user = mergedUser;
        _saveDataToRepository();
        return null;
      case AuthFailure(:final reason):
        return reason;
    }
  }

  Future<void> logout() async {
    _user = const User(
      isAuthenticated: false,
      username: null,
      accessToken: null,
      role: null,
    );
    _saveDataToRepository();
  }
}
