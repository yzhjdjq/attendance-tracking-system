import 'package:ats/services/services.dart' show S, AuthFailureReason;
import 'package:flutter/widgets.dart' show BuildContext;

extension AuthFailureReasonL10nExtension on AuthFailureReason {
  String message(BuildContext context) {
    final s = S.of(context);
    return switch (this) {
      AuthFailureReason.invalidCredentials =>
        s.authorize_error_invalid_credentials,
      AuthFailureReason.emptyLogin => s.authorize_error_empty_login,
      AuthFailureReason.emptyPassword => s.authorize_error_empty_password,
      AuthFailureReason.emptyFullName => s.authorize_error_empty_full_name,
      AuthFailureReason.unknown => s.authorize_error_unknown,
    };
  }
}
