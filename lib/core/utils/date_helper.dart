class DateHelper {
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime yesterday() {
    final t = today();
    return t.subtract(const Duration(days: 1));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) => isSameDay(date, today());
  static bool isYesterday(DateTime date) => isSameDay(date, yesterday());

  /// Returns true if the streak should reset (last completion was not yesterday or today)
  static bool shouldResetStreak(DateTime? lastCompletedDate) {
    if (lastCompletedDate == null) return false;
    final last = DateTime(
        lastCompletedDate.year, lastCompletedDate.month, lastCompletedDate.day);
    final t = today();
    final diff = t.difference(last).inDays;
    // If last completion was 2+ days ago, streak resets
    return diff >= 2;
  }

  /// Calculate current streak from a list of completed dates
  static int calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    final sorted = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    final t = today();

    // If most recent date is not today or yesterday, streak is 0
    if (!isSameDay(sorted.first, t) && !isSameDay(sorted.first, yesterday())) {
      return 0;
    }

    int streak = 0;
    DateTime current = isSameDay(sorted.first, t) ? t : yesterday();

    for (final date in sorted) {
      if (isSameDay(date, current)) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else if (date.isBefore(current)) {
        break;
      }
    }

    return streak;
  }

  static String formatTime(int hour, int minute) {
    final h = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    final m = minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  static String friendlyDate(DateTime date) {
    final t = today();
    final diff = t.difference(DateTime(date.year, date.month, date.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
