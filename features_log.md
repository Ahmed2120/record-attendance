# Project Features Log

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
