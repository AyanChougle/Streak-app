// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      reminderHour: fields[2] as int,
      reminderMinute: fields[3] as int,
      streak: fields[4] as int,
      completedToday: fields[5] as bool,
      lastCompletedDate: fields[6] as DateTime?,
      reminderEnabled: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.reminderHour)
      ..writeByte(3)
      ..write(obj.reminderMinute)
      ..writeByte(4)
      ..write(obj.streak)
      ..writeByte(5)
      ..write(obj.completedToday)
      ..writeByte(6)
      ..write(obj.lastCompletedDate)
      ..writeByte(7)
      ..write(obj.reminderEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
