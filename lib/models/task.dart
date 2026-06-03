import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int reminderHour;

  @HiveField(3)
  int reminderMinute;

  @HiveField(4)
  int streak;

  @HiveField(5)
  bool completedToday;

  @HiveField(6)
  DateTime? lastCompletedDate;

  @HiveField(7)
  bool reminderEnabled;

  Task({
    required this.id,
    required this.title,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.streak = 0,
    this.completedToday = false,
    this.lastCompletedDate,
    this.reminderEnabled = true,
  });

  TimeOfDay get reminderTime => TimeOfDay(hour: reminderHour, minute: reminderMinute);

  String get reminderTimeFormatted {
    final h = reminderHour == 0
        ? 12
        : reminderHour > 12
            ? reminderHour - 12
            : reminderHour;
    final m = reminderMinute.toString().padLeft(2, '0');
    final ampm = reminderHour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  Task copyWith({
    String? id,
    String? title,
    int? reminderHour,
    int? reminderMinute,
    int? streak,
    bool? completedToday,
    DateTime? lastCompletedDate,
    bool? reminderEnabled,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      streak: streak ?? this.streak,
      completedToday: completedToday ?? this.completedToday,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }
}
