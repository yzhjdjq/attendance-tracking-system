import 'package:ats/providers/service_providers/ble_mesh_service_provider.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:ats/models/models.dart' show User;
import 'package:ats/providers/providers.dart' show SingletonMixin;
import 'package:ats/repositories/repositories.dart' show UserRepository;

class UserProvider with ChangeNotifier, SingletonMixin {
  static UserProvider get instance {
    return SingletonMixin.getInstance<UserProvider>();
  }

  static Future<UserProvider> initialize({
    required BleMeshServiceProvider bleMeshServiceProvider,
  }) async {
    if (SingletonMixin.isInitialized<UserProvider>()) {
      return instance;
    }

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
  static User _user = const User(
    isAuthenticated: false,
    username: null,
    accessToken: null,
    role: null,
  );

  Future<void> _loadDataFromRepository() async {
    _user = await _userRepo.load(defaultValue: _user);
    _bleMeshServiceProvider.setUserId(_user.username);
  }

  void _saveDataToRepository() async {
    await _userRepo.save(_user);
    notifyListeners();
  }

  bool get isAuthenticated => _user.isAuthenticated;

  String get username => _user.username ?? '';

  void authenticate(String login, String password) async {
    _user = User(isAuthenticated: true, username: login);
    _saveDataToRepository();
    _bleMeshServiceProvider.setUserId(login);
  }

  void logout() async {
    _user = const User(
      isAuthenticated: false,
      username: null,
      accessToken: null,
      role: null,
    );
    _saveDataToRepository();
    _bleMeshServiceProvider.setUserId(null);
  }
}
