import 'package:ats/models/models.dart' show User;
import 'package:ats/services/services.dart' show StorageService;

class UserRepository {
  static const String _key = 'user';

  Future<User> load({User defaultValue = const User(isAuthenticated: false, username: null, accessToken: null)}) async {
    if (!StorageService.containsKey(_key)) {
      await StorageService.setObject(_key, defaultValue);
    }

    final loaded = StorageService.getObject<User>(_key, fromJson: User.fromJson);
    return loaded ?? defaultValue;
  }

  Future<void> save(User user) async {
    await StorageService.setObject(_key, user);
  }

  Future<void> clear() async {
    await StorageService.remove(_key);
  }
}
