// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StreakHistoryAdapter extends TypeAdapter<StreakHistory> {
  @override
  final int typeId = 1;

  @override
  StreakHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakHistory(
      taskId: fields[0] as String,
      completedDates: (fields[1] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, StreakHistory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.completedDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
