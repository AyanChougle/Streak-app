# 🔥 Streak Tracker

A minimal, dark-themed Flutter app for tracking daily habits and maintaining streaks. Inspired by iPhone Reminders' simplicity.

---

## Screenshots

```
Home Screen          Task Detail          Stats
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ My Tasks    │     │ Drink Water │     │ Stats       │
│ 2 of 3 done │     │             │     │             │
│             │     │  🔥 12      │     │ ✅ 🏆 ⚡    │
│ ☑ Drink     │     │  day streak │     │ 47  12  3   │
│   Water 🔥12│     │             │     │             │
│ ☑ Exercise  │     │ [Calendar]  │     │ Last 7 days │
│   🔥 5      │     │             │     │ ▓▓▓▓▓▓░    │
│ ☐ Read 🔥 0 │     │ 9:00 AM ⏰  │     │             │
│             │     │             │     │ Top Streaks │
│ + New Task  │     │ [Delete]    │     │ 1. Water 🔥12│
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the App

```bash
flutter run
```

### 3. (Optional) Regenerate Hive Adapters

The `.g.dart` files are pre-generated. If you modify the models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Tech Stack

| Layer | Package |
|---|---|
| State Management | `provider ^6.1.1` |
| Local Database | `hive + hive_flutter` |
| Notifications | `flutter_local_notifications` |
| Calendar | `table_calendar` |
| Fonts | `google_fonts` (Inter) |
| UUID | `uuid` |

---

## Architecture

```
lib/
├── core/
│   ├── theme/
│   │   └── dark_theme.dart        # Color palette, TextTheme, AppColors
│   └── utils/
│       └── date_helper.dart       # Streak calc, date comparison utils
├── models/
│   ├── task.dart                  # Hive model: Task
│   ├── task.g.dart                # Generated adapter
│   ├── streak_history.dart        # Hive model: StreakHistory
│   └── streak_history.g.dart      # Generated adapter
├── services/
│   ├── storage_service.dart       # Hive read/write layer
│   ├── notification_service.dart  # flutter_local_notifications wrapper
│   └── task_service.dart          # Business logic + ChangeNotifier
├── screens/
│   ├── home/home_screen.dart      # Task list, progress bar
│   ├── add_task/add_task_screen.dart
│   ├── task_detail/task_detail_screen.dart  # Edit + calendar
│   ├── stats/stats_screen.dart    # Aggregate stats + bar chart
│   └── settings/settings_screen.dart
├── widgets/
│   ├── task_tile.dart             # Animated checkbox + streak badge
│   ├── streak_badge.dart          # 🔥 N animated badge
│   └── add_task_button.dart
└── main.dart                      # Init + bottom nav shell
```

---

## Key Features

### Streak Logic
- Streak increments when task is marked complete
- Streak resets to 0 if a day is missed (last completion > 1 day ago)
- `DateHelper.calculateStreak()` recalculates from history
- Undo completion decrements streak by 1

### Daily Reset
- `TaskService._performDailyReset()` schedules a `Future.delayed` until midnight
- Resets `completedToday = false` for all tasks
- Rechecks if any streaks should reset (missed yesterday)
- Reschedules itself recursively for the next midnight

### Notifications
- One notification per task, scheduled daily at reminder time
- Uses `zonedSchedule` with `matchDateTimeComponents: DateTimeComponents.time` for daily repeat
- Cancels/reschedules on task edit or delete

---

## Color Palette

| Token | Hex | Usage |
|---|---|---|
| Background | `#000000` | Scaffold |
| Surface | `#1C1C1E` | Cards, tiles |
| Surface Elevated | `#2C2C2E` | Secondary surfaces |
| Text Primary | `#FFFFFF` | Main text |
| Text Secondary | `#8E8E93` | Subtitles, hints |
| Accent | `#0A84FF` | Interactive, CTA |
| Streak Orange | `#FF9F0A` | Streak badges |
| Destructive | `#FF453A` | Delete actions |
| Success | `#32D74B` | Completed state border |
| Separator | `#38383A` | Dividers |

---

## Permissions Required

### Android
- `POST_NOTIFICATIONS` (Android 13+)
- `SCHEDULE_EXACT_ALARM`
- `RECEIVE_BOOT_COMPLETED` (reschedule after reboot)

### iOS
- `NSUserNotificationUsageDescription` (add to Info.plist)

---

## Adding iOS Notification Support

Add to `ios/Runner/Info.plist`:

```xml
<key>NSUserNotificationUsageDescription</key>
<string>Streak Tracker sends you daily reminders to complete your habits.</string>
```

---

## Data Models

### Task
```dart
Task {
  id: String (UUID)
  title: String
  reminderHour: int
  reminderMinute: int
  streak: int           // current streak count
  completedToday: bool  // resets at midnight
  lastCompletedDate: DateTime?
  reminderEnabled: bool
}
```

### StreakHistory
```dart
StreakHistory {
  taskId: String
  completedDates: List<DateTime>  // one entry per day completed
}
```

---

## Future Improvements

- [ ] Widget (home screen glanceable streak count)
- [ ] iCloud/Google sync
- [ ] Custom streak icons per task
- [ ] Weekly/monthly summary notifications
- [ ] Export data as CSV
- [ ] Streak freeze (grace day mechanic)
