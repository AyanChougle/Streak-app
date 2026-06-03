import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../core/theme/dark_theme.dart';
import '../../widgets/streak_badge.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _editing = false;
  late TextEditingController _titleController;
  TimeOfDay? _editedTime;
  bool? _editedReminder;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(Task task) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: task.reminderHour, minute: task.reminderMinute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: AppColors.surface,
            hourMinuteColor: AppColors.surfaceElevated,
            dialBackgroundColor: AppColors.surfaceElevated,
            hourMinuteTextColor: AppColors.textPrimary,
            dialHandColor: AppColors.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _editedTime = picked);
  }

  Future<void> _saveEdits(Task task) async {
    final service = context.read<TaskService>();
    final updated = Task(
      id: task.id,
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : task.title,
      reminderHour: _editedTime?.hour ?? task.reminderHour,
      reminderMinute: _editedTime?.minute ?? task.reminderMinute,
      streak: task.streak,
      completedToday: task.completedToday,
      lastCompletedDate: task.lastCompletedDate,
      reminderEnabled: _editedReminder ?? task.reminderEnabled,
    );
    await service.updateTask(updated);
    setState(() => _editing = false);
  }

  Future<void> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Task',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Delete "${task.title}"? Your streak history will also be removed.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TaskService>().deleteTask(task.id);
      if (mounted) Navigator.pop(context);
    }
  }

  String _formatTime(int hour, int minute) {
    final h = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final m = minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, service, _) {
        Task? task;
        try {
          task = service.getTask(widget.taskId);
        } catch (_) {
          return const Scaffold(
            body: Center(child: Text('Task not found')),
          );
        }

        if (task == null) {
          return const Scaffold(
            body: Center(child: Text('Task not found')),
          );
        }

        if (_editing && _titleController.text.isEmpty) {
          _titleController.text = task.title;
        }

        final history = service.getHistory(task.id);
        final completedSet = history.completedDates
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Text(
              task.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              if (!_editing)
                TextButton(
                  onPressed: () => setState(() => _editing = true),
                  child: const Text('Edit',
                      style: TextStyle(color: AppColors.accent)),
                )
              else
                TextButton(
                  onPressed: () => _saveEdits(task!),
                  child: const Text('Save',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Streak hero
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    StreakBadge(streak: task.streak, large: true),
                    const SizedBox(height: 8),
                    Text(
                      task.streak == 1 ? 'day streak' : 'day streak',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatPill(
                            label: 'Total',
                            value: '${history.completedDates.length}'),
                        const SizedBox(width: 12),
                        _StatPill(
                            label: 'Best',
                            value: '${_calcBest(history.completedDates)}'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Edit fields
              if (_editing) ...[
                const Text(
                  'TITLE',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 17),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Reminder settings
              const Text(
                'REMINDER',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Reminder',
                          style: TextStyle(color: AppColors.textPrimary)),
                      value: _editedReminder ?? task.reminderEnabled,
                      onChanged: _editing
                          ? (v) => setState(() => _editedReminder = v)
                          : null,
                    ),
                    const Divider(
                        height: 0.5,
                        color: AppColors.separator,
                        indent: 16,
                        endIndent: 16),
                    ListTile(
                      title: const Text('Time',
                          style: TextStyle(color: AppColors.textPrimary)),
                      trailing: GestureDetector(
                        onTap: _editing ? () => _pickTime(task!) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _editedTime != null
                                ? _formatTime(
                                    _editedTime!.hour, _editedTime!.minute)
                                : task.reminderTimeFormatted,
                            style: TextStyle(
                              color: _editing
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Calendar
              const Text(
                'HISTORY',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now(),
                  focusedDay: DateTime.now(),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle:
                        const TextStyle(color: AppColors.textPrimary),
                    weekendTextStyle:
                        const TextStyle(color: AppColors.textSecondary),
                    outsideTextStyle:
                        const TextStyle(color: AppColors.separator),
                    todayDecoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: AppColors.accent),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.streakOrange,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: AppColors.accent),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: AppColors.accent),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    weekendStyle:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  eventLoader: (day) {
                    final d = DateTime(day.year, day.month, day.day);
                    return completedSet.contains(d) ? [true] : [];
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Delete button
              GestureDetector(
                onTap: () => _confirmDelete(task!),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.destructive.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: Text(
                      'Delete Task',
                      style: TextStyle(
                        color: AppColors.destructive,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  int _calcBest(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final sorted = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    int best = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }

    return best;
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
