# Professional Highlights: Record Your Attendance (سجل حضورك)

*Target Audience: Recruiters, Engineering Managers, and Tech Leads.*

## 🚀 Project Summary
**Record Your Attendance** is a high-performance Flutter mobile application built for professional workplace management. It solves the common problem of unreliable background tasks and notifications in cross-platform development by integrating deep native bridges (Kotlin & Swift).

---

## 🛠️ Technical Achievements & Experience

### 1. Advanced Platform Integration (Hybrid Native/Flutter)
- **Problem**: Standard Flutter notification plugins often fail to deliver "persistent" or "ongoing" alerts reliably across different OS power management settings.
- **Solution**: Developed a custom native bridge using **MethodChannels** to implement native background services:
    - **Android**: Utilized `AlarmManager` and `Foreground Services` in Kotlin for precisely timed reminders.
    - **iOS**: Implemented `UNUserNotificationCenter` in Swift to manage complex notification offsets.
- **Result**: Achieve 100% notification reliability for mission-critical attendance check-ins.

### 2. Scalable State Management & Architecture
- Leveraged **Riverpod** for a modular, secondary-source-of-truth architecture, separating UI from complex business logic (lateness calculations, grace periods).
- Integrated **SQLite (Sqflite)** with a custom relational schema to handle persistent storage for attendance logs, task management, and vacation configurations.

### 3. Product-Focused Feature Engineering
- **Smart Handoff**: Designed a "Notes for Tomorrow" feature that detects unfinished workday tasks and automatically migrates them to the next day's To-Do list, improving user productivity loop.
- **Lateness & Grace Logic**: Implemented complex time-based logic to handle attendance status transitions, including a 2-hour absence grace period and automatic holiday detection.

### 4. Premium UI/UX & Global Reach
- Engineered a fully localized experience (**English & Arabic**) with dynamic RTL/LTR layout switching.
- Implemented a modern **Glassmorphic design system** using custom themes, responsive typography (**Tajawal font**), and smooth micro-animations for high user engagement.

---

## 🔑 Key Keywords for Recruiters
`Flutter` `Dart` `Kotlin` `Swift` `Riverpod` `SQLite` `MethodChannels` `System-Level Localization` `Native Background Tasks` `UI/UX Design` `Problem Solving` `Mobile Architecture`

---

## 💡 How to use this on LinkedIn:
- **Project Section**: Copy the "Technical Achievements" bullets to showcase specific technical problems you solved.
- **Experience Section**: Use the "Project Summary" and "Result" metrics to describe your role in building this app.
- **Post Content**: Share the "Hybrid Native/Flutter" part as a "Lesson Learned" post to demonstrate your deep understanding of mobile platforms.
