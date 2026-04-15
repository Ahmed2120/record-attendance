# Project Features Log

## [2026-04-15] - Reminders & Daily To-Do List
- **Daily To-Do List**:
    - Integrated a task management system directly into the attendance day cards.
    - Features include adding tasks, checking them off with animations, and deleting them.
    - Added a **Progress Badge** (`n/m`) on the collapsed dashboard cards for quick visibility.
- **Notes for Tomorrow (Handoff)**:
    - Implemented "Remind me tomorrow" logic in the note editor.
    - Allows users to instantly convert their unfinished work notes into To-Do items for the next day.
- **Persistent Storage**:
    - Added a new SQLite table `todo_items` to ensure tasks are preserved across sessions.
    - Decoupled tasks from attendance records so they can be added to future dates.
- **Premium UI & Localization**:
    - Designed with glassmorphic inputs and smooth state transitions.
    - Fully localized into English and Arabic.

## [2026-04-05] - Dashboard UI Refinement
- **Current Day Display**: Updated the attendance list to show "Check In" and "Check Out" placeholders (with "-") for the current day even if no record has been created yet. This replaces the previous empty/upcoming state for Today, providing a clearer indication of pending actions.
- **Theme Switching Fix**: Resolved a "double-tap" bug where the dark mode switch required two taps to activate from system theme mode.
- **Month Selector Theme Reactivity**: Fixed a bug where month selector colors remained stale in dark mode until a month was selected, by making the widget responsive to theme changes.

## [2026-04-04] - Initial Setup & Design
- Created Flutter project with Riverpod, Sqflite, and Localization.
- Established Design System (AppColors, AppTheme).
- Implemented Onboarding View with custom illustrations.
- Implemented Splash Screen with animations.
- Implemented Dashboard UI matching Figma (Overlap Header Image).
- Localized all UI text to English and Arabic.
- Configured Dark & Light mode support.

## [2026-04-04] - Core Logic Implementation
- Implemented SQLite Database (Sqflite) for persistence.
- Added Lateness calculation (9:00 AM base).
- Added Working Hours calculation for each session.
- Implemented monthly summary statistics (Total Hours & Lateness).

## [2026-04-04] - Company Setup & Settings Enhancement
- Implemented **Company Setup** screen for initial configuration.
- Added **Settings** page with a- **Premium Settings UI**: Redesigned items with card based layout and dark mode support.
- **Home Page Redesign**: 
    - Full month visibility: All days are now shown in the dashboard.
    - Absent State: Days without records are clearly marked as "Absent".
    - Expandable Notes: Notes are now collapsed by default and expand with a premium animation.
    - Note Editing: Implemented direct note editing for the current day from the dashboard.
    - Dark mode support for the new design.
- **Date Formatting Refactor**: Centralized all date and time formatting logic into `DateConverter` utility.
- Moved **App Version** to the very bottom, centered, outside of cards.

## [2026-04-04] - Premium UI & Logic Refinement
- **Three-State Dashboard Logic**:
    - **Recorded**: Standard interactive state with time logs and expandable notes.
    - **Absent**: Redesigned for past days with missing records, using a red-accented border and "Not Recorded" label.
    - **Upcoming**: Non-interactive minimalist state for future dates (opacity-reduced), preventing accidental records on future days.
- **Empty Month State**: Implemented a placeholder with an illustration for months with no attendance data.
- **Premium Typography**: Integrated the **Tajawal** font family across the entire application.
- **Current Day Absence Grace Period**:
    - Implemented logic to delay "Absent" status for the current day until **2 hours after the scheduled checkout time**.
    - Prevents premature "Absent" markings while still highlighting today's card at 100% opacity.
    - Fixed card expansion logic to ensure records are always viewable/editable regardless of grace period status.
- Ensured consistent dark mode colors across all new states.

## [2026-04-05] - Native Persistent Attendance Notifications
- **Multi-Stage Reminders**: Background notifications trigger at -30m, -15m, and 0m offsets for check-in/out.
- **Native Implementation**: Developed via Kotlin (`AlarmManager`) and Swift (`UNUserNotificationCenter`) for maximum reliability.
- **Interactive Action Buttons**: Directly record attendance from the notification tray.
- **Persistence & Timeout**: "Ongoing" notifications with an automatic 1-hour timeout as requested.
- **Smart Status Sync**: Automatically skips reminders if the action was already performed.
- **Localization**: Full English and Arabic support for native alerts.
## [2026-04-10] - System-Level Identity Localization
- **Multi-Platform Localization**: Fully localized the application name for both Android and iOS operating systems in Arabic and English.
- **Dynamic OS Labels**: Configured Android `strings.xml` and iOS `InfoPlist.strings` so that the app name under the icon automatically switches between "Record Your Attendance" and "سجل حضورك" based on the device's system language.
- **Manifest Integration**: Tied the Android application label to the string resource system for future-proof localization management.

## [2026-04-12] - Test Notifications Configuration
- Added highly requested "Test Notification" buttons to the settings view for Check In and Check Out native notifications.
- Enhanced Android MethodChannel to receive and broadcast intent triggers for immediate on-demand native notifications.

## [2026-04-13] - Vacation Days & Weekly Holidays Support
- **Weekly Holidays (Weekends)**:
    - Introduced system-wide support for recurring weekly holidays (weekends).
    - Defaulted weekly holidays to **Friday and Saturday**.
    - Added a selection UI in Settings to customize these days (e.g., Sunday only, or none).
- **Vacation Days (Specific Dates)**:
    - Added a new SQLite table `vacations` to store specific holiday dates.
    - Implemented a management UI with a date picker to add special vacation days.
- **Intelligent Attendance Logic**:
    - **No Absence Marking**: Days identified as holidays or vacations are no longer marked as "Absent" in the Dashboard. They now display a "Vacation" status with a beach-access icon.
    - **Grace for Lateness**: Users who check in on a holiday/vacation day are automatically recorded with **0 minutes late**, regardless of the actual check-in time.
- **UI & Localization**:
    - Created `VacationsView` and `WeeklyHolidaysView` with premium card-based designs.
    - Fully localized all new features and day names into Arabic and English.
