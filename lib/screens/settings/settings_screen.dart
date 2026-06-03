import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../services/task_service.dart';
import '../../core/theme/dark_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Notifications
                const Text(
                  'NOTIFICATIONS',
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
                        title: const Text('Enable Notifications',
                            style: TextStyle(color: AppColors.textPrimary)),
                        subtitle: const Text(
                            'Receive daily reminders for your tasks',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        value: _notificationsEnabled,
                        onChanged: (v) async {
                          setState(() => _notificationsEnabled = v);
                          if (v) {
                            await NotificationService().requestPermission();
                            // Re-schedule all
                            final tasks = context.read<TaskService>().tasks;
                            for (final task in tasks) {
                              await NotificationService()
                                  .scheduleTaskReminder(task);
                            }
                          } else {
                            await NotificationService().cancelAll();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // About
                const Text(
                  'ABOUT',
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
                  child: const Column(
                    children: [
                      ListTile(
                        title: Text('Version',
                            style: TextStyle(color: AppColors.textPrimary)),
                        trailing: Text('1.0.0',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                      Divider(
                          height: 0.5,
                          color: AppColors.separator,
                          indent: 16,
                          endIndent: 16),
                      ListTile(
                        title: Text('App',
                            style: TextStyle(color: AppColors.textPrimary)),
                        trailing: Text('Streak Tracker',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Danger zone
                const Text(
                  'DANGER ZONE',
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
                  child: ListTile(
                    onTap: () => _confirmReset(context),
                    title: const Text('Reset All Data',
                        style: TextStyle(color: AppColors.destructive)),
                    subtitle: const Text('Delete all tasks and streak history',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ),
                ),

                const SizedBox(height: 40),

                const Center(
                  child: Text(
                    '🔥 Keep the streak alive.',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset All Data',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will permanently delete all your tasks and streak history. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset',
                style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final service = context.read<TaskService>();
      final tasks = service.tasks.toList();
      for (final task in tasks) {
        await service.deleteTask(task.id);
      }
      await NotificationService().cancelAll();
    }
  }
}
