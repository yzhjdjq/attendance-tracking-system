import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'
    show ChangeNotifier, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:permission_handler/permission_handler.dart';

import 'package:ats/providers/providers.dart' show SingletonMixin;

enum PermissionKind {
  bluetoothScan,
  bluetoothConnect,
  bluetoothAdvertise,
  location,
  notification,
}

class PermissionEntry {
  final Permission permission;
  final PermissionKind kind;
  const PermissionEntry({required this.permission, required this.kind});
}

enum PermissionUiStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unknown,
}

class PermissionsProvider with ChangeNotifier, SingletonMixin {
  static PermissionsProvider get instance =>
      SingletonMixin.getInstance<PermissionsProvider>();

  static Future<PermissionsProvider> initialize() async {
    if (SingletonMixin.isInitialized<PermissionsProvider>()) {
      return instance;
    }
    final provider = PermissionsProvider._internal();
    await provider._detectSdkInt();
    await provider.refreshAll();
    return provider;
  }

  PermissionsProvider._internal() {
    SingletonMixin.registerInstance(this);
  }

  static bool get isInitialized =>
      SingletonMixin.isInitialized<PermissionsProvider>();

  static final bool _isAndroid =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  int _sdkInt = 0;
  bool _isLoading = false;
  Map<Permission, PermissionUiStatus> _statuses = {};

  int get sdkInt => _sdkInt;

  Future<void> _detectSdkInt() async {
    if (!_isAndroid) {
      _sdkInt = 0;
      return;
    }
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      _sdkInt = info.version.sdkInt;
    } catch (_) {
      _sdkInt = 0;
    }
  }

  List<PermissionEntry> get trackedPermissions {
    if (!_isAndroid) return const [];

    if (_sdkInt >= 31) {
      final list = <PermissionEntry>[
        const PermissionEntry(
          permission: Permission.bluetoothScan,
          kind: PermissionKind.bluetoothScan,
        ),
        const PermissionEntry(
          permission: Permission.bluetoothConnect,
          kind: PermissionKind.bluetoothConnect,
        ),
        const PermissionEntry(
          permission: Permission.bluetoothAdvertise,
          kind: PermissionKind.bluetoothAdvertise,
        ),
      ];
      if (_sdkInt >= 33) {
        list.add(
          const PermissionEntry(
            permission: Permission.notification,
            kind: PermissionKind.notification,
          ),
        );
      }
      return list;
    }

    return [
      const PermissionEntry(
        permission: Permission.locationWhenInUse,
        kind: PermissionKind.location,
      ),
    ];
  }

  List<Permission> get requiredForMesh {
    if (!_isAndroid) return const [];

    if (_sdkInt >= 31) {
      final list = <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ];
      if (_sdkInt >= 33) {
        list.add(Permission.notification);
      }
      return list;
    }

    return const [Permission.locationWhenInUse];
  }

  bool get allMeshPermissionsGranted =>
      requiredForMesh.every((p) => statusOf(p) == PermissionUiStatus.granted);

  bool get hasPlatformSupport => _isAndroid;

  Map<Permission, PermissionUiStatus> get statuses => _statuses;

  bool get isLoading => _isLoading;

  PermissionUiStatus statusOf(Permission p) =>
      _statuses[p] ?? PermissionUiStatus.unknown;

  Future<void> refreshAll() async {
    if (!_isAndroid) {
      _statuses = {};
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = <Permission, PermissionUiStatus>{};
    for (final entry in trackedPermissions) {
      result[entry.permission] = _mapStatus(await entry.permission.status);
    }
    _statuses = result;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> request(Permission permission) async {
    if (!_isAndroid) return;
    final status = await permission.request();
    _statuses[permission] = _mapStatus(status);
    notifyListeners();
  }

  Future<void> requestAllMissing() async {
    if (!_isAndroid) return;

    final missing = requiredForMesh
        .where((p) => statusOf(p) != PermissionUiStatus.granted)
        .toList();
    if (missing.isEmpty) return;

    await missing.request();
    await refreshAll();
  }

  Future<void> openAppSettingsPage() => openAppSettings();

  PermissionUiStatus _mapStatus(PermissionStatus s) {
    if (s.isGranted || s.isLimited || s.isProvisional) {
      return PermissionUiStatus.granted;
    }
    if (s.isPermanentlyDenied) return PermissionUiStatus.permanentlyDenied;
    if (s.isRestricted) return PermissionUiStatus.restricted;
    if (s.isDenied) return PermissionUiStatus.denied;
    return PermissionUiStatus.unknown;
  }
}
