import 'package:ats/models/models.dart' show User, UserRole, AuthMethod;
import 'package:ats/repositories/repositories.dart' show CredentialsRepository;
import 'package:uuid/uuid.dart' show Uuid;

sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final User user;
  const AuthSuccess(this.user);
}

class AuthFailure extends AuthResult {
  final AuthFailureReason reason;
  const AuthFailure(this.reason);
}

enum AuthFailureReason {
  invalidCredentials,
  emptyLogin,
  emptyPassword,
  emptyFullName,
  unknown,
}

class AuthService {
  const AuthService();

  static const String defaultTeacherFullName = 'Преподаватель';

  // from User::empty()
  static const String _namespaceUuid = '6feb195a-fe09-43db-8a30-645633422944';

  AuthResult authenticateWithCredentials(String login, String password) {
    final trimmedLogin = login.trim();
    if (trimmedLogin.isEmpty) {
      return const AuthFailure(AuthFailureReason.emptyLogin);
    }
    if (password.isEmpty) {
      return const AuthFailure(AuthFailureReason.emptyPassword);
    }

    if (!CredentialsRepository.verifyTeacherPassword(trimmedLogin, password)) {
      return const AuthFailure(AuthFailureReason.invalidCredentials);
    }

    return AuthSuccess(
      User(
        id: _generateUserId(trimmedLogin),
        isAuthenticated: true,
        username: trimmedLogin,
        role: UserRole.teacher,
        fullName: defaultTeacherFullName,
        authMethod: AuthMethod.credentials,
      ),
    );
  }

  AuthResult registerStudentSession(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      return const AuthFailure(AuthFailureReason.emptyFullName);
    }
    final login = _generateStudentLogin(trimmed);
    return AuthSuccess(
      User(
        id: _generateUserId(login),
        isAuthenticated: true,
        username: login,
        role: UserRole.student,
        fullName: trimmed,
        authMethod: AuthMethod.session,
      ),
    );
  }

  String _generateUserId(String login) =>
      const Uuid().v5(_namespaceUuid, login);

  String _generateStudentLogin(String fullName) => fullName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zа-я0-9]'), '_')
      .split('')
      .take(22)
      .join();
}
