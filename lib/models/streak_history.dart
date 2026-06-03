import 'package:hive/hive.dart';

part 'streak_history.g.dart';

@HiveType(typeId: 1)
class StreakHistory extends HiveObject {
  @HiveField(0)
  String taskId;

  @HiveField(1)
  List<DateTime> completedDates;

  StreakHistory({
    required this.taskId,
    List<DateTime>? completedDates,
  }) : completedDates = completedDates ?? [];

  bool wasCompletedOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return completedDates.any((cd) =>
        cd.year == d.year && cd.month == d.month && cd.day == d.day);
  }

  void addDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (!wasCompletedOn(d)) {
      completedDates.add(d);
    }
  }
}
