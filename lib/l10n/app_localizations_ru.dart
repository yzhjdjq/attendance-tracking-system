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
  String get mark_visit_page_title => 'Отметка посещения';

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

  @override
  String get bluetooth_permissions_required => 'Требуются разрешения Bluetooth';

  @override
  String get poll_started =>
      'Начинаю опрос участников... (ретрансляция через mesh)';

  @override
  String get attendance_marked_mesh_sent =>
      'Отправляю отметку о посещаемости через mesh сеть';

  @override
  String get mark_visit_request_permissions => 'Запросить разрешения';

  @override
  String get mark_visit_direct_connections => 'Прямые BLE подключения';

  @override
  String get mark_visit_no_connections =>
      'Нет активных подключений. Убедитесь, что Bluetooth и геолокация включены, а также есть активные клиенты рядом.';

  @override
  String get mark_visit_role_teacher => 'Преподаватель';

  @override
  String get mark_visit_role_student => 'Студент';

  @override
  String get mark_visit_role_selected => 'Роль';

  @override
  String get mark_visit_instruction_poll => 'Нажмите кнопку для начала опроса';

  @override
  String get mark_visit_instruction_attendance =>
      'Нажмите кнопку для отметки посещаемости';

  @override
  String mark_visit_start_poll(Object delay) {
    return 'Начать опрос ($delay сек)';
  }

  @override
  String get mark_visit_mark_attendance => 'Отметиться';

  @override
  String get mark_visit_poll_active => 'Опрос активен... Ожидание ответов';

  @override
  String get mark_visit_attended => 'Отметившиеся';

  @override
  String get mark_visit_connected_peers => 'Соседи в сети';

  @override
  String get mark_visit_log_events => 'Лог событий';

  @override
  String get mark_visit_my_peer_id => 'Ваш ID';

  @override
  String get mark_visit_clear_log => 'Очистить лог';

  @override
  String get mark_visit_enable_auto_scroll_action => 'Включить автопрокрутку';

  @override
  String get mark_visit_disable_auto_scroll_action => 'Выключить автопрокрутку';

  @override
  String get mark_visit_auto_scroll_enabled => 'Автопрокрутка включена';

  @override
  String get mark_visit_auto_scroll_disabled => 'Автопрокрутка выключена';

  @override
  String get mark_visit_log_empty => 'Нет сообщений';

  @override
  String get mark_visit_log_cleared => 'Лог очищен';

  @override
  String get mark_visit_attendance_marked =>
      'Отметка о посещаемости отправлена';

  @override
  String get mark_visit_poll_started =>
      'Опрос участников начат (ретрансляция через mesh)';
}
