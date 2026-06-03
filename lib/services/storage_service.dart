import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/streak_history.dart';

class StorageService {
  static const _taskBoxName = 'tasks';
  static const _historyBoxName = 'streak_history';

  late Box<Task> _taskBox;
  late Box<StreakHistory> _historyBox;

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>(_taskBoxName);
    _historyBox = await Hive.openBox<StreakHistory>(_historyBoxName);
  }

  // ─── Tasks ────────────────────────────────────────────────────────────────

  List<Task> getTasks() => _taskBox.values.toList();

  Future<void> saveTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
    await _historyBox.delete(id);
  }

  Task? getTask(String id) => _taskBox.get(id);

  // ─── Streak History ───────────────────────────────────────────────────────

  StreakHistory getHistory(String taskId) {
    return _historyBox.get(taskId) ?? StreakHistory(taskId: taskId);
  }

  Future<void> saveHistory(StreakHistory history) async {
    await _historyBox.put(history.taskId, history);
  }

  Future<void> addCompletionDate(String taskId, DateTime date) async {
    final history = getHistory(taskId);
    history.addDate(date);
    await _historyBox.put(taskId, history);
  }

  // ─── Misc ─────────────────────────────────────────────────────────────────

  ValueListenable<Box<Task>> get taskListenable => _taskBox.listenable();
}
