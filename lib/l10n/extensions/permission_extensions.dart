import 'package:ats/providers/providers.dart'
    show PermissionKind, PermissionUiStatus;
import 'package:ats/services/services.dart' show S;
import 'package:flutter/widgets.dart' show BuildContext;

extension PermissionKindL10nExtension on PermissionKind {
  String title(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case PermissionKind.bluetoothScan:
        return s.permission_bluetoothScan_title;
      case PermissionKind.bluetoothConnect:
        return s.permission_bluetoothConnect_title;
      case PermissionKind.bluetoothAdvertise:
        return s.permission_bluetoothAdvertise_title;
      case PermissionKind.location:
        return s.permission_location_title;
      case PermissionKind.notification:
        return s.permission_notification_title;
    }
  }

  String description(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case PermissionKind.bluetoothScan:
        return s.permission_bluetoothScan_description;
      case PermissionKind.bluetoothConnect:
        return s.permission_bluetoothConnect_description;
      case PermissionKind.bluetoothAdvertise:
        return s.permission_bluetoothAdvertise_description;
      case PermissionKind.location:
        return s.permission_location_description;
      case PermissionKind.notification:
        return s.permission_notification_description;
    }
  }
}

extension PermissionUiStatusL10nExtension on PermissionUiStatus {
  String label(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case PermissionUiStatus.granted:
        return s.permission_status_granted;
      case PermissionUiStatus.denied:
        return s.permission_status_denied;
      case PermissionUiStatus.permanentlyDenied:
        return s.permission_status_permanentlyDenied;
      case PermissionUiStatus.restricted:
        return s.permission_status_restricted;
      case PermissionUiStatus.unknown:
        return s.permission_status_unknown;
    }
  }
}
