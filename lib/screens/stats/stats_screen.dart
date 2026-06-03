import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import '../../core/theme/dark_theme.dart';
import '../../widgets/streak_badge.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, service, _) {
        final tasks = service.tasks;

        // Overall stats
        final totalCompletions = tasks.fold<int>(0, (sum, t) {
          return sum + service.getHistory(t.id).completedDates.length;
        });

        final longestStreak =
            tasks.fold<int>(0, (max, t) => t.streak > max ? t.streak : max);

        final activeTasks = tasks.where((t) => t.streak > 0).length;

        // Last 7 days completion
        final last7Days = List.generate(7, (i) {
          final date = DateTime.now().subtract(Duration(days: 6 - i));
          return DateTime(date.year, date.month, date.day);
        });

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
                    'Stats',
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
                    // Summary cards
                    Row(
                      children: [
                        Expanded(
                            child: _BigStatCard(
                                label: 'Total\nCompletions',
                                value: '$totalCompletions',
                                icon: '✅')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _BigStatCard(
                                label: 'Longest\nStreak',
                                value: '$longestStreak 🔥',
                                icon: '🏆')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _BigStatCard(
                                label: 'Active\nStreaks',
                                value: '$activeTasks',
                                icon: '⚡')),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Last 7 days
                    const Text(
                      'LAST 7 DAYS',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: last7Days.map((day) {
                          final dayName = _weekday(day.weekday);
                          final dayStr = '${day.month}/${day.day}';
                          final count = tasks.where((t) {
                            final h = service.getHistory(t.id);
                            return h.wasCompletedOn(day);
                          }).length;
                          final ratio =
                              tasks.isEmpty ? 0.0 : count / tasks.length;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(dayName,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      backgroundColor:
                                          AppColors.surfaceElevated,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              AppColors.accent),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$count/${tasks.length}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Top streaks
                    if (tasks.isNotEmpty) ...[
                      const Text(
                        'TOP STREAKS',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: (() {
                            final sorted = [...tasks]
                              ..sort((a, b) => b.streak.compareTo(a.streak));
                            return sorted
                                .take(5)
                                .toList()
                                .asMap()
                                .entries
                                .map((e) {
                              final i = e.key;
                              final t = e.value;
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: i == 0
                                            ? AppColors.streakOrange
                                                .withValues(alpha: 0.2)
                                            : AppColors.surfaceElevated,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            color: i == 0
                                                ? AppColors.streakOrange
                                                : AppColors.textSecondary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(t.title,
                                        style: const TextStyle(
                                            color: AppColors.textPrimary)),
                                    trailing: StreakBadge(streak: t.streak),
                                  ),
                                  if (i < sorted.length - 1 && i < 4)
                                    const Divider(
                                        height: 0.5,
                                        color: AppColors.separator,
                                        indent: 16,
                                        endIndent: 16),
                                ],
                              );
                            }).toList();
                          })(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _weekday(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }
}

class _BigStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _BigStatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
