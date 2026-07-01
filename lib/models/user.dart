enum UserRole { teacher, student }

class User {
  final bool isAuthenticated;
  final String? username;
  final String? accessToken;
  final UserRole? role;

  const User({this.isAuthenticated = false, this.username, this.accessToken, this.role = UserRole.student});

  Map<String, dynamic> toJson() {
    return {'isAuthenticated': isAuthenticated, 'username': username, 'accessToken': accessToken, 'role': role};
  }

  static User fromJson(Map<String, dynamic> json) {
    bool iIsAuthenticated = json['isAuthenticated'] ?? false;
    String? iUsername = json['username'];
    String? iAccessToken = json['accessToken'];
    UserRole? iRole = json['role'];

    return User(isAuthenticated: iIsAuthenticated, username: iUsername, accessToken: iAccessToken, role: iRole);
  }

  User copyWith({bool? isAuthenticated, String? username, String? accessToken, UserRole? role}) {
    return User(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      accessToken: accessToken ?? this.accessToken,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          isAuthenticated == other.isAuthenticated &&
          username == other.username &&
          accessToken == other.accessToken &&
          role == other.role;

  @override
  int get hashCode => Object.hash(isAuthenticated, username, accessToken, role);

  @override
  String toString() {
    return 'User(isAuthenticated: $isAuthenticated, username: $username, accessToken: $accessToken, role: $role)';
  }
}
