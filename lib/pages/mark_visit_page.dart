import 'package:ats/pages/pages.dart' show PermissionsPage;
import 'package:ats/providers/providers.dart'
    show MarkVisitPageProvider, SendResultViewModel, UserRoleViewModel;
import 'package:ats/services/services.dart' show S;
import 'package:ats/widgets/widgets.dart'
    show
        AttendedStudentsCardWidget,
        ConnectedPeersCardWidget,
        ConnectionsCardWidget,
        ErrorCardWidget,
        LogCardWidget,
        MainDrawerWidget,
        MarkVisitActionButtonWidget,
        RoleSelectorWidget;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarkVisitPage extends StatefulWidget {
  const MarkVisitPage({super.key});

  @override
  State<MarkVisitPage> createState() => _MarkVisitPageState();
}

class _MarkVisitPageState extends State<MarkVisitPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(S.of(context).mark_visit_page_title),
      ),
      drawer: const MainDrawerWidget(),
      body: Consumer<MarkVisitPageProvider>(
        builder: (context, provider, child) {
          if (!provider.canStart) {
            return _ServiceStoppedView(
              icon: Icons.lock_outline,
              isError: true,
              title:
                  'Нет разрешений для работы BLE Mesh.\nВыдайте разрешения, чтобы продолжить.',
              buttonIcon: Icons.security,
              buttonLabel: 'Открыть разрешения',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PermissionsPage()),
                );
              },
            );
          }

          if (!provider.isMeshServiceRunning()) {
            return _ServiceStoppedView(
              icon: Icons.cloud_off,
              title: 'BLE Mesh сервис не работает!\nЗапустите его.',
              buttonIcon: Icons.refresh,
              buttonLabel: 'Запустить сервис',
              onPressed: () => provider.startService(),
            );
          }

          return _buildBody(context, provider);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MarkVisitPageProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight,
              maxHeight: availableHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Верхний контент
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 16),

                        // Отображение ошибки
                        if (provider.errorMessage != null)
                          ErrorCardWidget(
                            errorMessage: provider.errorMessage!,
                            onRetry: () {
                              provider.clearError();
                            },
                          ),

                        if (provider.errorMessage != null)
                          const SizedBox(height: 16),

                        // Счетчик прямых BLE подключений
                        FutureBuilder(
                          future: provider.getDirectConnectionsCount(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            return ConnectionsCardWidget(
                              directConnectionsCount: snapshot.hasData
                                  ? snapshot.data!
                                  : 0,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Выбор роли
                        RoleSelectorWidget(
                          currentRole: provider.role,
                          onRoleSelected: (role) {
                            provider.setRole(role);
                            provider.addLog(
                              '${S.of(context).mark_visit_role_selected}: ${role == UserRoleViewModel.teacher ? S.of(context).mark_visit_role_teacher : S.of(context).mark_visit_role_student}',
                            );
                            if (role == UserRoleViewModel.teacher) {
                              provider.addLog(
                                S.of(context).mark_visit_instruction_poll,
                              );
                            } else {
                              provider.addLog(
                                S.of(context).mark_visit_instruction_attendance,
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // Кнопка действия
                        MarkVisitActionButtonWidget(
                          role: provider.role,
                          isPollActive: provider.isPollActive,
                          hasError: provider.errorMessage != null,
                          onPressed: () =>
                              _handlePrimaryButtonClick(context, provider),
                        ),

                        // Статус опроса
                        if (provider.role == UserRoleViewModel.teacher &&
                            provider.isPollActive)
                          const SizedBox(height: 16),
                        if (provider.role == UserRoleViewModel.teacher &&
                            provider.isPollActive)
                          const _PollStatusCard(),

                        // Список отметившихся
                        if (provider.role == UserRoleViewModel.teacher &&
                            provider.attendedStudents.isNotEmpty)
                          const SizedBox(height: 16),
                        if (provider.role == UserRoleViewModel.teacher &&
                            provider.attendedStudents.isNotEmpty)
                          AttendedStudentsCardWidget(
                            students: provider.attendedStudents,
                          ),

                        // Информация о подключениях
                        // if (provider.connectedPeers.isNotEmpty)
                        //   const SizedBox(height: 16),
                        // if (provider.connectedPeers.isNotEmpty)
                        //   ConnectedPeersCardWidget(
                        //     peers: provider.connectedPeers,
                        //   ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Лог событий с новыми параметрами
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LogCardWidget(
                        logMessages: provider.logMessages,
                        autoScrollLog: provider.autoScrollLog,
                        onClearLog: () {
                          provider.clearLogs();
                          provider.addLog(
                            '🗑️ ${S.of(context).mark_visit_log_cleared}',
                          );
                        },
                        onToggleAutoScroll: () {
                          provider.setAutoScrollLog(!provider.autoScrollLog);
                          provider.addLog(
                            provider.autoScrollLog
                                ? '📌 ${S.of(context).mark_visit_auto_scroll_enabled}'
                                : '📌 ${S.of(context).mark_visit_auto_scroll_disabled}',
                          );
                        },
                      ),
                    ),
                  ),

                  // Peer ID отображение
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '🆔 ${S.of(context).mark_visit_my_peer_id}: ${provider.userId}',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePrimaryButtonClick(
    BuildContext context,
    MarkVisitPageProvider provider,
  ) async {
    if (provider.errorMessage != null) {
      provider.setError(
        '${S.of(context).bluetooth_permissions_required}: ${provider.errorMessage}',
      );
      return;
    }

    if (provider.role == UserRoleViewModel.teacher) {
      provider.addLog('📢 ${S.of(context).poll_started}');
    } else {
      provider.addLog('📤 ${S.of(context).attendance_marked_mesh_sent}...');
    }

    provider
        .sendMessage('HELLO')
        .then(
          (value) => {
            provider.addLog(switch (value) {
              SendResultViewModel.notImplemented => 'Не реализовано',
              SendResultViewModel.success => 'Успешно',
              SendResultViewModel.error => 'Ошибка',
            }),
          },
        );
  }
}

class _PollStatusCard extends StatelessWidget {
  const _PollStatusCard();

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('⏳ ${S.of(context).mark_visit_poll_active}'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _ServiceStoppedView extends StatelessWidget {
  const _ServiceStoppedView({
    required this.title,
    required this.icon,
    required this.buttonLabel,
    required this.onPressed,
    this.buttonIcon = Icons.refresh,
    this.isError = false,
  });

  final String title;
  final IconData icon;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: isError ? scheme.error : scheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(buttonIcon),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
