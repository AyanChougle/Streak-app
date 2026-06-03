import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/streak_history.dart';
import '../core/utils/date_helper.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class TaskService extends ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;
  final _uuid = const Uuid();

  List<Task> _tasks = [];

  TaskService(this._storage, this._notifications) {
    _loadTasks();
    _performDailyReset();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);

  int get completedTodayCount => _tasks.where((t) => t.completedToday).length;
  int get totalTasks => _tasks.length;

  double get todayProgress =>
      totalTasks == 0 ? 0 : completedTodayCount / totalTasks;

  void _loadTasks() {
    _tasks = _storage.getTasks();
    _recalculateStreaks();
    notifyListeners();
  }

  /// Recalculate streaks from history (in case of missed days)
  void _recalculateStreaks() {
    bool changed = false;
    for (final task in _tasks) {
      if (DateHelper.shouldResetStreak(task.lastCompletedDate)) {
        task.streak = 0;
        task.completedToday = false;
        changed = true;
      }
    }
    if (changed) {
      for (final task in _tasks) {
        _storage.saveTask(task);
      }
    }
  }

  /// At midnight, reset completedToday for the new day
  void _performDailyReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    Future.delayed(timeUntilMidnight, () {
      _resetForNewDay();
      _performDailyReset(); // Schedule next midnight reset
    });
  }

  void _resetForNewDay() {
    bool changed = false;
    for (final task in _tasks) {
      if (task.completedToday) {
        // If they completed it today, don't reset streak yet
        // Just reset the completedToday flag
        task.completedToday = false;
        changed = true;
      }
      // Check if streak should reset (missed yesterday)
      if (DateHelper.shouldResetStreak(task.lastCompletedDate)) {
        task.streak = 0;
        changed = true;
      }
      _storage.saveTask(task);
    }
    if (changed) notifyListeners();
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<void> addTask(String title, int hour, int minute) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      reminderHour: hour,
      reminderMinute: minute,
    );
    await _storage.saveTask(task);
    await _notifications.scheduleTaskReminder(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _storage.saveTask(task);
    await _notifications.scheduleTaskReminder(task);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _storage.deleteTask(id);
    await _notifications.cancelTaskReminder(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ─── Completion ───────────────────────────────────────────────────────────

  Future<void> toggleTaskCompletion(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final task = _tasks[idx];
    final now = DateTime.now();
    final today = DateHelper.today();

    if (!task.completedToday) {
      // Mark complete
      task.completedToday = true;
      task.lastCompletedDate = now;

      // Increment streak if last completed was yesterday or it's new
      final lastDate = task.lastCompletedDate;
      if (lastDate == null ||
          DateHelper.isYesterday(lastDate) ||
          DateHelper.isToday(lastDate)) {
        task.streak++;
      } else {
        // Missed days — streak already reset, start at 1
        task.streak = 1;
      }

      await _storage.addCompletionDate(id, today);
    } else {
      // Undo completion
      task.completedToday = false;
      task.streak = (task.streak - 1).clamp(0, 999);

      // Remove today from history
      final history = _storage.getHistory(id);
      history.completedDates
          .removeWhere((d) => DateHelper.isSameDay(d, today));
      await _storage.saveHistory(history);
    }

    task.lastCompletedDate = task.completedToday ? now : task.lastCompletedDate;
    await _storage.saveTask(task);
    notifyListeners();
  }

  // ─── History ──────────────────────────────────────────────────────────────

  StreakHistory getHistory(String taskId) => _storage.getHistory(taskId);

  Task? getTask(String id) => _tasks.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('Task not found'),
      );
}
