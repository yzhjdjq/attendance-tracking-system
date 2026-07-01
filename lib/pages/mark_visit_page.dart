import 'package:ats/providers/providers.dart' show MarkVisitPageProvider, UserRoleViewModel;
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
          final uiState = provider;
          return _buildBody(context, provider, uiState);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MarkVisitPageProvider provider, dynamic uiState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight, maxHeight: availableHeight),
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
                        if (uiState.errorMessage != null)
                          ErrorCardWidget(
                            errorMessage: uiState.errorMessage!,
                            onRetry: () {
                              provider.clearError();
                            },
                          ),

                        if (uiState.errorMessage != null) const SizedBox(height: 16),

                        // Счетчик прямых BLE подключений
                        ConnectionsCardWidget(directConnectionsCount: uiState.directConnectionsCount),

                        const SizedBox(height: 16),

                        // Выбор роли
                        RoleSelectorWidget(
                          currentRole: uiState.role,
                          onRoleSelected: (role) {
                            provider.setRole(role);
                            provider.addLog(
                              '${S.of(context).mark_visit_role_selected}: ${role == UserRoleViewModel.teacher ? S.of(context).mark_visit_role_teacher : S.of(context).mark_visit_role_student}',
                            );
                            if (role == UserRoleViewModel.teacher) {
                              provider.addLog(S.of(context).mark_visit_instruction_poll);
                            } else {
                              provider.addLog(S.of(context).mark_visit_instruction_attendance);
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // Кнопка действия
                        MarkVisitActionButtonWidget(
                          role: uiState.role,
                          isPollActive: uiState.isPollActive,
                          hasError: uiState.errorMessage != null,
                          onPressed: () => _handlePrimaryButtonClick(context, provider),
                        ),

                        // Статус опроса
                        if (uiState.role == UserRoleViewModel.teacher && uiState.isPollActive)
                          const SizedBox(height: 16),
                        if (uiState.role == UserRoleViewModel.teacher && uiState.isPollActive) const _PollStatusCard(),

                        // Список отметившихся
                        if (uiState.role == UserRoleViewModel.teacher && uiState.attendedStudents.isNotEmpty)
                          const SizedBox(height: 16),
                        if (uiState.role == UserRoleViewModel.teacher && uiState.attendedStudents.isNotEmpty)
                          AttendedStudentsCardWidget(students: uiState.attendedStudents),

                        // Информация о подключениях
                        if (uiState.connectedPeers.isNotEmpty) const SizedBox(height: 16),
                        if (uiState.connectedPeers.isNotEmpty) ConnectedPeersCardWidget(peers: uiState.connectedPeers),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Лог событий с новыми параметрами
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LogCardWidget(
                        logMessages: uiState.logMessages,
                        autoScrollLog: uiState.autoScrollLog,
                        onClearLog: () {
                          provider.clearLogs();
                          provider.addLog('🗑️ ${S.of(context).mark_visit_log_cleared}');
                        },
                        onToggleAutoScroll: () {
                          provider.setAutoScrollLog(!uiState.autoScrollLog);
                          provider.addLog(
                            uiState.autoScrollLog ? '📌 ${S.of(context).mark_visit_auto_scroll_enabled}' : '📌 ${S.of(context).mark_visit_auto_scroll_disabled}',
                          );
                        },
                      ),
                    ),
                  ),

                  // Peer ID отображение
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '🆔 ${S.of(context).mark_visit_my_peer_id}: ${uiState.myPeerId}',
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

  Future<void> _handlePrimaryButtonClick(BuildContext context, MarkVisitPageProvider provider) async {
    if (provider.errorMessage != null) {
      provider.setError('${S.of(context).bluetooth_permissions_required}: ${provider.errorMessage}');
      return;
    }

    if (provider.role == UserRoleViewModel.teacher) {
      provider.addLog('📢 ${S.of(context).poll_started}');
    } else {
      provider.addLog('📤 ${S.of(context).attendance_marked_mesh_sent}...');
    }
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
