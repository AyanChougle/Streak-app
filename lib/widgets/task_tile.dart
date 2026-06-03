import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../core/theme/dark_theme.dart';
import 'streak_badge.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskTile({super.key, required this.task, this.onTap});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    if (widget.task.completedToday) _checkController.value = 1;
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    final service = context.read<TaskService>();
    await service.toggleTaskCompletion(widget.task.id);

    if (widget.task.completedToday) {
      _checkController.forward().then((_) => _checkController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: task.completedToday
              ? Border.all(
                  color: AppColors.success.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: _handleTap,
                child: ScaleTransition(
                  scale: _checkScale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.completedToday
                          ? AppColors.accent
                          : Colors.transparent,
                      border: Border.all(
                        color: task.completedToday
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        width: 2,
                      ),
                    ),
                    child: task.completedToday
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title + reminder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: task.completedToday
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: task.completedToday
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textSecondary,
                      ),
                    ),
                    if (task.reminderEnabled) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Reminder: ${task.reminderTimeFormatted}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Streak badge
              StreakBadge(streak: task.streak),
            ],
          ),
        ),
      ),
    );
  }
}
