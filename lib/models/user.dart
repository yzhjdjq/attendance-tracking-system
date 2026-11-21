/// Роль пользователя в системе.
enum UserRole { teacher, student }

/// Способ аутентификации.
enum AuthMethod { credentials, session }

/// Пользователь приложения.
class User {
  final String id;
  final bool isAuthenticated;
  final String username;
  final String? accessToken;
  final UserRole role;
  final String fullName;
  final AuthMethod authMethod;

  const User({
    required this.id,
    required this.isAuthenticated,
    required this.username,
    this.accessToken,
    required this.role,
    required this.fullName,
    required this.authMethod,
  });

  const User.empty()
    : id = '6feb195a-fe09-43db-8a30-645633422944',
      isAuthenticated = false,
      username = '',
      accessToken = null,
      role = UserRole.student,
      fullName = '',
      authMethod = AuthMethod.session;

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;

  User copyWith({
    String? id,
    bool? isAuthenticated,
    String? username,
    String? accessToken,
    UserRole? role,
    String? fullName,
    AuthMethod? authMethod,
    bool clearAccessToken = false,
  }) {
    return User(
      id: id ?? this.id,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      accessToken: clearAccessToken ? null : (accessToken ?? this.accessToken),
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      authMethod: authMethod ?? this.authMethod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isAuthenticated': isAuthenticated,
      'username': username,
      'accessToken': accessToken,
      'role': role.name,
      'fullName': fullName,
      'authMethod': authMethod.name,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      isAuthenticated: map['isAuthenticated'] as bool? ?? false,
      username: map['username'] as String,
      accessToken: map['accessToken'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.student,
      ),
      fullName: map['fullName'] as String,
      authMethod: AuthMethod.values.firstWhere(
        (a) => a.name == map['authMethod'],
        orElse: () => AuthMethod.session,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isAuthenticated == other.isAuthenticated &&
          username == other.username &&
          accessToken == other.accessToken &&
          role == other.role &&
          fullName == other.fullName &&
          authMethod == other.authMethod;

  @override
  int get hashCode => Object.hash(
    id,
    isAuthenticated,
    username,
    accessToken,
    role,
    fullName,
    authMethod,
  );

  @override
  String toString() =>
      'User(id: $id, username: $username, accessToken: $accessToken, '
      'role: ${role.name}, isAuthenticated: $isAuthenticated)';
}
