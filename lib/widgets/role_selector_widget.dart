import 'package:ats/providers/providers.dart' show UserRoleViewModel;
import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';

class RoleSelectorWidget extends StatelessWidget {
  static const double _borderRoundRadius = 12.0;

  final UserRoleViewModel currentRole;
  final Function(UserRoleViewModel) onRoleSelected;

  const RoleSelectorWidget({super.key, required this.currentRole, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRoundRadius)),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<UserRoleViewModel>(
            value: currentRole,
            isExpanded: true,
            borderRadius: BorderRadius.circular(_borderRoundRadius),
            itemHeight: _borderRoundRadius * 4,
            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSecondaryContainer),
            elevation: 16,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
            underline: Container(),
            onChanged: (role) {
              if (role != null) {
                onRoleSelected(role);
              }
            },
            items: UserRoleViewModel.values.map((role) {
              return DropdownMenuItem<UserRoleViewModel>(
                value: role,
                child: Row(
                  children: [
                    Expanded(child: Text(role == UserRoleViewModel.teacher ? '👨‍🏫 ${S.of(context).mark_visit_role_teacher}' : '👨‍🎓 ${S.of(context).mark_visit_role_student}')),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
