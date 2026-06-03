import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import '../../core/theme/dark_theme.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _reminderEnabled = true;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: AppColors.surface,
            hourMinuteColor: AppColors.surfaceElevated,
            dialBackgroundColor: AppColors.surfaceElevated,
            hourMinuteTextColor: AppColors.textPrimary,
            dialHandColor: AppColors.accent,
            dayPeriodColor: AppColors.surfaceElevated,
            dayPeriodTextColor: AppColors.textPrimary,
            entryModeIconColor: AppColors.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    setState(() => _saving = true);
    await context.read<TaskService>().addTask(
          title,
          _reminderEnabled ? _reminderTime.hour : 9,
          _reminderEnabled ? _reminderTime.minute : 0,
        );

    if (mounted) Navigator.pop(context);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour == 0
        ? 12
        : t.hour > 12
            ? t.hour - 12
            : t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'New Task',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.accent, fontSize: 17)),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Add',
              style: TextStyle(
                color: _saving ? AppColors.textSecondary : AppColors.accent,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _titleController,
                autofocus: true,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 17),
                decoration: const InputDecoration(
                  hintText: 'Task name',
                  hintStyle:
                      TextStyle(color: AppColors.textSecondary, fontSize: 17),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _save(),
              ),
            ),

            const SizedBox(height: 24),

            // Reminder section
            const Text(
              'REMINDER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Enable Reminder',
                        style: TextStyle(color: AppColors.textPrimary)),
                    trailing: Switch(
                      value: _reminderEnabled,
                      onChanged: (v) => setState(() => _reminderEnabled = v),
                    ),
                  ),
                  if (_reminderEnabled) ...[
                    const Divider(
                        height: 0.5,
                        color: AppColors.separator,
                        indent: 16,
                        endIndent: 16),
                    ListTile(
                      title: const Text('Time',
                          style: TextStyle(color: AppColors.textPrimary)),
                      trailing: GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatTime(_reminderTime),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'You\'ll get a daily reminder at this time to complete your task and keep the streak alive.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
