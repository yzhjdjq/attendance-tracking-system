import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// No description provided for @appNameShort.
  ///
  /// In ru, this message translates to:
  /// **'СУП'**
  String get appNameShort;

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Система учета посещаемости'**
  String get appName;

  /// No description provided for @aboutApp.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutApp;

  /// No description provided for @copyright.
  ///
  /// In ru, this message translates to:
  /// **'© 2026 Nikita Yarovoi'**
  String get copyright;

  /// No description provided for @menu.
  ///
  /// In ru, this message translates to:
  /// **'меню'**
  String get menu;

  /// No description provided for @home_page_title.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get home_page_title;

  /// No description provided for @mark_visit_page_title.
  ///
  /// In ru, this message translates to:
  /// **'Отметка посещения'**
  String get mark_visit_page_title;

  /// No description provided for @logout_action.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout_action;

  /// No description provided for @enter_login_message.
  ///
  /// In ru, this message translates to:
  /// **'Введите логин'**
  String get enter_login_message;

  /// No description provided for @authorize_error_message.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка авторизации'**
  String get authorize_error_message;

  /// No description provided for @authorize.
  ///
  /// In ru, this message translates to:
  /// **'Авторизация'**
  String get authorize;

  /// Подпись текстового поля логина (имя пользователя / электронная почта)
  ///
  /// In ru, this message translates to:
  /// **'Логин'**
  String get login;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// Текст кнопки авторизации
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authorizeAction;

  /// No description provided for @bluetooth_permissions_required.
  ///
  /// In ru, this message translates to:
  /// **'Требуются разрешения Bluetooth'**
  String get bluetooth_permissions_required;

  /// No description provided for @poll_started.
  ///
  /// In ru, this message translates to:
  /// **'Начинаю опрос участников... (ретрансляция через mesh)'**
  String get poll_started;

  /// No description provided for @attendance_marked_mesh_sent.
  ///
  /// In ru, this message translates to:
  /// **'Отправляю отметку о посещаемости через mesh сеть'**
  String get attendance_marked_mesh_sent;

  /// No description provided for @mark_visit_request_permissions.
  ///
  /// In ru, this message translates to:
  /// **'Запросить разрешения'**
  String get mark_visit_request_permissions;

  /// No description provided for @mark_visit_direct_connections.
  ///
  /// In ru, this message translates to:
  /// **'Прямые BLE подключения'**
  String get mark_visit_direct_connections;

  /// No description provided for @mark_visit_no_connections.
  ///
  /// In ru, this message translates to:
  /// **'Нет активных подключений. Убедитесь, что Bluetooth и геолокация включены, а также есть активные клиенты рядом.'**
  String get mark_visit_no_connections;

  /// No description provided for @mark_visit_role_teacher.
  ///
  /// In ru, this message translates to:
  /// **'Преподаватель'**
  String get mark_visit_role_teacher;

  /// No description provided for @mark_visit_role_student.
  ///
  /// In ru, this message translates to:
  /// **'Студент'**
  String get mark_visit_role_student;

  /// No description provided for @mark_visit_role_selected.
  ///
  /// In ru, this message translates to:
  /// **'Роль'**
  String get mark_visit_role_selected;

  /// No description provided for @mark_visit_instruction_poll.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите кнопку для начала опроса'**
  String get mark_visit_instruction_poll;

  /// No description provided for @mark_visit_instruction_attendance.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите кнопку для отметки посещаемости'**
  String get mark_visit_instruction_attendance;

  /// No description provided for @mark_visit_start_poll.
  ///
  /// In ru, this message translates to:
  /// **'Начать опрос ({delay} сек)'**
  String mark_visit_start_poll(Object delay);

  /// No description provided for @mark_visit_mark_attendance.
  ///
  /// In ru, this message translates to:
  /// **'Отметиться'**
  String get mark_visit_mark_attendance;

  /// No description provided for @mark_visit_poll_active.
  ///
  /// In ru, this message translates to:
  /// **'Опрос активен... Ожидание ответов'**
  String get mark_visit_poll_active;

  /// No description provided for @mark_visit_attended.
  ///
  /// In ru, this message translates to:
  /// **'Отметившиеся'**
  String get mark_visit_attended;

  /// No description provided for @mark_visit_connected_peers.
  ///
  /// In ru, this message translates to:
  /// **'Соседи в сети'**
  String get mark_visit_connected_peers;

  /// No description provided for @mark_visit_log_events.
  ///
  /// In ru, this message translates to:
  /// **'Лог событий'**
  String get mark_visit_log_events;

  /// No description provided for @mark_visit_my_peer_id.
  ///
  /// In ru, this message translates to:
  /// **'Ваш ID'**
  String get mark_visit_my_peer_id;

  /// No description provided for @mark_visit_clear_log.
  ///
  /// In ru, this message translates to:
  /// **'Очистить лог'**
  String get mark_visit_clear_log;

  /// No description provided for @mark_visit_enable_auto_scroll_action.
  ///
  /// In ru, this message translates to:
  /// **'Включить автопрокрутку'**
  String get mark_visit_enable_auto_scroll_action;

  /// No description provided for @mark_visit_disable_auto_scroll_action.
  ///
  /// In ru, this message translates to:
  /// **'Выключить автопрокрутку'**
  String get mark_visit_disable_auto_scroll_action;

  /// No description provided for @mark_visit_auto_scroll_enabled.
  ///
  /// In ru, this message translates to:
  /// **'Автопрокрутка включена'**
  String get mark_visit_auto_scroll_enabled;

  /// No description provided for @mark_visit_auto_scroll_disabled.
  ///
  /// In ru, this message translates to:
  /// **'Автопрокрутка выключена'**
  String get mark_visit_auto_scroll_disabled;

  /// No description provided for @mark_visit_log_empty.
  ///
  /// In ru, this message translates to:
  /// **'Нет сообщений'**
  String get mark_visit_log_empty;

  /// No description provided for @mark_visit_log_cleared.
  ///
  /// In ru, this message translates to:
  /// **'Лог очищен'**
  String get mark_visit_log_cleared;

  /// No description provided for @mark_visit_attendance_marked.
  ///
  /// In ru, this message translates to:
  /// **'Отметка о посещаемости отправлена'**
  String get mark_visit_attendance_marked;

  /// No description provided for @mark_visit_poll_started.
  ///
  /// In ru, this message translates to:
  /// **'Опрос участников начат (ретрансляция через mesh)'**
  String get mark_visit_poll_started;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
