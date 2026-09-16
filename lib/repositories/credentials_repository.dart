import 'dart:convert';
import 'package:crypto/crypto.dart';

class CredentialsRepository {
  static const String _salt = 'ats::v1::2026';

  static const Map<String, String> _teacherPasswordHashes = {
    'admin': '433f29db07b1dc7e4eb3a0f87a2b3e872e94e21296979df7710adfb15d1e1e7f',
  };

  static bool hasTeacher(String login) =>
      _teacherPasswordHashes.containsKey(login);

  static String hashPassword(String login, String password) =>
      sha256.convert(utf8.encode('$login:$password:$_salt')).toString();

  static bool verifyTeacherPassword(String login, String password) {
    final storedHash = _teacherPasswordHashes[login];
    if (storedHash == null) return false;
    return hashPassword(login, password) == storedHash;
  }

  static String get salt => _salt;
}
