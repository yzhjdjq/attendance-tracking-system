class User {
  final bool isAuthenticated;
  final String? username;
  final String? accessToken;

  const User({this.isAuthenticated = false, this.username, this.accessToken});

  Map<String, dynamic> toJson() {
    return {'isAuthenticated': isAuthenticated, 'username': username, 'accessToken': accessToken};
  }

  static User fromJson(Map<String, dynamic> json) {
    bool iIsAuthenticated = json['isAuthenticated'] ?? false;
    String? iUsername = json['username'];
    String? iAccessToken = json['accessToken'];

    return User(isAuthenticated: iIsAuthenticated, username: iUsername, accessToken: iAccessToken);
  }

  User copyWith({bool? isAuthenticated, String? username, String? accessToken}) {
    return User(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          isAuthenticated == other.isAuthenticated &&
          username == other.username &&
          accessToken == other.accessToken;

  @override
  int get hashCode => Object.hash(isAuthenticated, username, accessToken);

  @override
  String toString() {
    return 'User(isAuthenticated: $isAuthenticated, username: $username, accessToken: $accessToken)';
  }
}
