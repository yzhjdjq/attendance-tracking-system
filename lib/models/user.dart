enum UserRole { teacher, student }

enum AuthMethod { credentials, session }

class User {
  final bool isAuthenticated;
  final String? username;
  final String? accessToken;
  final UserRole? role;
  final String? fullName;
  final AuthMethod? authMethod;

  const User({
    this.isAuthenticated = false,
    this.username,
    this.accessToken,
    this.role = UserRole.student,
    this.fullName,
    this.authMethod,
  });

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
  bool get isSessionAuth => authMethod == AuthMethod.session;

  Map<String, dynamic> toJson() => {
    'isAuthenticated': isAuthenticated,
    'username': username,
    'accessToken': accessToken,
    'role': role?.name,
    'fullName': fullName,
    'authMethod': authMethod?.name,
  };

  static User fromJson(Map<String, dynamic> json) {
    return User(
      isAuthenticated: json['isAuthenticated'] ?? false,
      username: json['username'] as String?,
      accessToken: json['accessToken'] as String?,
      role: json['role'] != null
          ? UserRole.values.firstWhere((r) => r.name == json['role'])
          : null,
      fullName: json['fullName'] as String?,
      authMethod: json['authMethod'] != null
          ? AuthMethod.values.firstWhere((m) => m.name == json['authMethod'])
          : null,
    );
  }

  User copyWith({
    bool? isAuthenticated,
    String? username,
    String? accessToken,
    UserRole? role,
    String? fullName,
    AuthMethod? authMethod,
    bool clearAccessToken = false,
    bool clearAuthMethod = false,
  }) {
    return User(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      accessToken: clearAccessToken ? null : (accessToken ?? this.accessToken),
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      authMethod: clearAuthMethod ? null : (authMethod ?? this.authMethod),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          isAuthenticated == other.isAuthenticated &&
          username == other.username &&
          accessToken == other.accessToken &&
          role == other.role &&
          fullName == other.fullName &&
          authMethod == other.authMethod;

  @override
  int get hashCode => Object.hash(
    isAuthenticated,
    username,
    accessToken,
    role,
    fullName,
    authMethod,
  );
}
