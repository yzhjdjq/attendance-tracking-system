// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appNameShort => 'СУП';

  @override
  String get appName => 'Система учета посещаемости';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get copyright => '© 2026 Nikita Yarovoi';

  @override
  String get menu => 'меню';

  @override
  String get home_page_title => 'Главная';

  @override
  String get logout_action => 'Выйти';

  @override
  String get enter_login_message => 'Введите логин';

  @override
  String get authorize_error_message => 'Ошибка авторизации';

  @override
  String get authorize => 'Авторизация';

  @override
  String get login => 'Логин';

  @override
  String get password => 'Пароль';

  @override
  String get authorizeAction => 'Войти';
}
