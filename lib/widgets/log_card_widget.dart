import 'package:ats/services/services.dart' show S;
import 'package:flutter/material.dart';

class LogCardWidget extends StatefulWidget {
  final List<String> logMessages;
  final bool autoScrollLog;
  final VoidCallback onClearLog;
  final VoidCallback onToggleAutoScroll;

  const LogCardWidget({
    super.key,
    required this.logMessages,
    required this.autoScrollLog,
    required this.onClearLog,
    required this.onToggleAutoScroll,
  });

  @override
  State<LogCardWidget> createState() => _LogCardWidgetState();
}

class _LogCardWidgetState extends State<LogCardWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _wasAutoScrollEnabled = true;

  @override
  void didUpdateWidget(LogCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.autoScrollLog &&
        widget.logMessages.length > oldWidget.logMessages.length &&
        _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    // Если автопрокрутку только что включили - прокрутить в конец
    if (widget.autoScrollLog && !_wasAutoScrollEnabled && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }

    _wasAutoScrollEnabled = widget.autoScrollLog;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📱 ${S.of(context).mark_visit_log_events}', style: Theme.of(context).textTheme.titleSmall),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Кнопка переключения автопрокрутки
                    IconButton(
                      icon: Icon(widget.autoScrollLog ? Icons.lock_open : Icons.lock_outline, size: 18),
                      tooltip: widget.autoScrollLog ? S.of(context).mark_visit_disable_auto_scroll_action : S.of(context).mark_visit_enable_auto_scroll_action,
                      onPressed: widget.onToggleAutoScroll,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      style: IconButton.styleFrom(
                        foregroundColor: widget.autoScrollLog
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Кнопка очистки лога
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: S.of(context).mark_visit_clear_log,
                      onPressed: widget.logMessages.isNotEmpty ? widget.onClearLog : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    if (widget.logMessages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '${widget.logMessages.length}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 12, endIndent: 12),
          Expanded(
            child: widget.logMessages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        S.of(context).mark_visit_log_empty,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: widget.logMessages.length,
                    itemBuilder: (context, index) {
                      final log = widget.logMessages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Text(log, style: Theme.of(context).textTheme.bodySmall),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
