import 'package:ats/models/models.dart' show User, UserRole, AuthMethod;
import 'package:ats/repositories/repositories.dart' show CredentialsRepository;

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
    return AuthSuccess(
      User(
        isAuthenticated: true,
        username: _generateStudentLogin(trimmed),
        role: UserRole.student,
        fullName: trimmed,
        authMethod: AuthMethod.session,
      ),
    );
  }

  String _generateStudentLogin(String fullName) {
    final base = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zа-я0-9]'), '')
        .split('')
        .take(18)
        .join();
    final suffix = fullName.hashCode.toRadixString(16).substring(0, 4);
    return '$base-$suffix';
  }
}
