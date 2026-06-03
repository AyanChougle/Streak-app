import 'package:flutter/material.dart';
import '../core/theme/dark_theme.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool large;

  const StreakBadge({super.key, required this.streak, this.large = false});

  @override
  Widget build(BuildContext context) {
    final fontSize = large ? 20.0 : 15.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: streak > 0
            ? AppColors.streakOrange.withValues(alpha: 0.15)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: streak > 0
              ? AppColors.streakOrange.withValues(alpha: 0.3)
              : AppColors.separator,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: TextStyle(fontSize: fontSize * 0.9),
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Text(
              '$streak',
              key: ValueKey(streak),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: streak > 0
                    ? AppColors.streakOrange
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
