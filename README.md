# Record Your Attendance (سجل حضورك)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Kotlin](https://img.shields.io/badge/kotlin-%237F52FF.svg?style=for-the-badge&logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Swift](https://img.shields.io/badge/swift-%23F05138.svg?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/swift/)

**Record Your Attendance** is a premium, feature-rich Flutter application designed to streamline workplace time-tracking and daily productivity. It combines high-performance attendance logging with a professional task management system, all wrapped in a modern, glassmorphic UI.

---

## 🌟 Key Features

### 📅 Advanced Attendance Tracking
- **Smart Check-In/Out**: Intuitive logging system for daily shifts.
- **Lateness Calculation**: Automated tracking of late minutes based on configurable company start times.
- **Monthly Summary**: Real-time statistics for total working hours and lateness accumulation.
- **Grace Period Logic**: Intelligent UI that manages "Absent" status with a 2-hour grace period after checkout.

### 🔔 Native Platform Integration
- **Reliable Reminders**: Built using **Kotlin (AlarmManager)** and **Swift (UNUserNotificationCenter)** to ensure persistence and reliability where standard plugins often fail.
- **Interactive Notifications**: Record attendance directly from the notification tray without opening the app.
- **Multi-Stage Alerts**: Alerts triggered at -30, -15, and 0-minute offsets.

### 📋 Productivity & Task Management
- **Integrated To-Do List**: Task management embedded directly within attendance day cards.
- **Notes for Tomorrow**: A unique handoff feature that converts unfinished workday notes into actionable tasks for the next day.
- **Glassmorphic Inputs**: Premium data entry experience with smooth state transitions.

### 🏖️ Holidays & Vacations
- **Customizable Weekends**: Configure your weekly holidays (e.g., Friday/Saturday or Sunday).
- **Vacation Management**: Dedicated UI to add specific leave dates, ensuring they don't count as "Absent".
- **Holiday Grace**: Users working on holidays are automatically granted 0-minute lateness.

---

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev) (Modular and Testable)
- **Persistence**: [Sqflite](https://pub.dev/packages/sqflite) (Custom optimized SQL tables for Attendance, Tasks, and Vacations)
- **Native Bridges**: [MethodChannels](https://docs.flutter.dev/platform-channels) for deep integration with Android (Kotlin) and iOS (Swift).
- **Localization**: Full Support for **English** and **Arabic** (RTL), including dynamic system-level app name switching.
- **Typography**: [Tajawal](https://fonts.google.com/specimen/Tajawal) - A premium Arabic font family for visual excellence.

---

## 🎨 UI/UX Philosophy
- **Glassmorphism**: Modern, translucent UI elements for a premium feel.
- **Dynamic Theming**: Full Light and Dark mode support that adapts to system settings.
- **Smooth Animations**: Animated transitions for card expansions, task completions, and state changes.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / Xcode

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Ahmed2120/record_attendance.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## 📄 Documentation
For a detailed log of implemented features and architectural decisions, refer to the [Features Log](file:///c:/my_projects/record_attendance/features_log.md).

Developed with ❤️ focusing on Performance and Professional User Experience.
