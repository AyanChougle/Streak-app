import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import '../../core/theme/dark_theme.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/add_task_button.dart';
import '../add_task/add_task_screen.dart';
import '../task_detail/task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, service, _) {
        final tasks = service.tasks;
        final completed = service.completedTodayCount;
        final total = service.totalTasks;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Large title app bar
              SliverAppBar(
                pinned: true,
                expandedHeight: 140,
                backgroundColor: AppColors.background,
                flexibleSpace: const FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Tasks',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () => _showAddTask(context),
                      child: const Icon(Icons.add_circle_outline_rounded,
                          color: AppColors.accent, size: 28),
                    ),
                  ),
                ],
              ),

              // Progress header
              if (total > 0)
                SliverToBoxAdapter(
                  child: _ProgressHeader(completed: completed, total: total),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Task list
              if (tasks.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(onAdd: () => _showAddTask(context)),
                )
              else ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = tasks[index];
                      return TaskTile(
                        task: task,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(taskId: task.id),
                          ),
                        ),
                      );
                    },
                    childCount: tasks.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: AddTaskButton(
                    onTap: () => _showAddTask(context),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }

  void _showAddTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressHeader({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed of $total completed',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a daily habit to start your streak',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Add Your First Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
