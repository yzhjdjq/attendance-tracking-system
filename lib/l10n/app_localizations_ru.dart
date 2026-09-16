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
  String get authorize_error_invalid_credentials => 'Неверный логин или пароль';

  @override
  String get authorize_error_empty_login => 'Введите логин';

  @override
  String get authorize_error_empty_password => 'Введите пароль';

  @override
  String get authorize_error_empty_full_name => 'Введите ФИО';

  @override
  String get authorize_error_unknown => 'Ошибка авторизации';

  @override
  String get menu => 'меню';

  @override
  String get home_page_title => 'Главная';

  @override
  String get mark_visit_page_title => 'Отметка посещения';

  @override
  String get logout_action => 'Выйти';

  @override
  String get settings_page_title => 'Настройки';

  @override
  String get login_mode_teacher => 'Преподаватель';

  @override
  String get login_mode_student => 'Студент';

  @override
  String get login_mode_switch => 'Режим входа';

  @override
  String get full_name => 'ФИО';

  @override
  String get enter_full_name_message => 'Введите ФИО';

  @override
  String get register_and_login_action => 'Войти как студент';

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
  String get mark_visit_start_poll => 'Провести опрос';

  @override
  String get mark_visit_mark_attendance => 'Отметиться';

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

  @override
  String get permission_bluetoothScan_title => 'Bluetooth Scan';

  @override
  String get permission_bluetoothScan_description =>
      'Поиск BLE-устройств рядом';

  @override
  String get permission_bluetoothConnect_title => 'Bluetooth Connect';

  @override
  String get permission_bluetoothConnect_description =>
      'Подключение к найденным BLE-устройствам';

  @override
  String get permission_bluetoothAdvertise_title => 'Bluetooth Advertise';

  @override
  String get permission_bluetoothAdvertise_description =>
      'Открытие собственного BLE-сервиса';

  @override
  String get permission_location_title => 'Геолокация';

  @override
  String get permission_location_description =>
      'Обязательна для BLE-сканирования на Android ≤ 11';

  @override
  String get permission_notification_title => 'Уведомления';

  @override
  String get permission_notification_description =>
      'Нужны, чтобы BLE-сервис работал в фоне';

  @override
  String get permission_statusLabel => 'Статус';

  @override
  String get permission_status_granted => 'выдано';

  @override
  String get permission_status_denied => 'отклонено';

  @override
  String get permission_status_permanentlyDenied => 'запрещено навсегда';

  @override
  String get permission_status_restricted => 'ограничено';

  @override
  String get permission_status_unknown => 'неизвестно';

  @override
  String get profile_unknown_name => 'q';

  @override
  String get permission_page_title => 'Разрешения приложения';

  @override
  String get permission_action_request => 'Запросить';

  @override
  String get permission_action_open => 'Открыть';

  @override
  String get permission_action_requestAll => 'Запросить все';

  @override
  String get permission_action_openSystemSettings => 'Настройки ОС';

  @override
  String get permission_action_refresh => 'Обновить статусы';

  @override
  String get settings_profile_name_saved => 'Новое ФИО сохранено';

  @override
  String get settings_profile_name_title => 'ФИО';

  @override
  String get settings_profile_name_save_action => 'Сохранить изменения';
}
