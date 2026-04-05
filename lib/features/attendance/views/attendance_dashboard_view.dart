import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/utils/date_converter.dart';
import '../models/attendance_record.dart';
import '../providers/attendance_provider.dart';
import '../providers/month_provider.dart';
import '../../../core/providers/theme_provider.dart';
import 'widgets/attendance_list_item.dart';
import 'widgets/month_selector.dart';
import 'settings_view.dart';
import '../../../core/services/settings_service.dart';

class AttendanceDashboardView extends ConsumerWidget {
  const AttendanceDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final themeMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
    final recordsAsync = ref.watch(attendanceRecordsProvider(selectedMonth));
    final todayAsync = ref.watch(todayAttendanceProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Header
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor.withOpacity(0.8),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, l10n, theme, recordsAsync),
                const SizedBox(height: 20),
                
                // Body Card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildActionButtons(l10n, theme, todayAsync, ref, selectedMonth),
                        const SizedBox(height: 24),
                        MonthSelector(),
                        const SizedBox(height: 8),
                        Expanded(
                          child: recordsAsync.when(
                            data: (records) {
                              final now = DateTime.now();
                              final today = DateTime(now.year, now.month, now.day);
                              
                              // Check if we should show empty state
                              // If it's not the current month and there are no records, show empty state
                              final isCurrentMonth = selectedMonth.year == now.year && selectedMonth.month == now.month;
                              if (records.isEmpty && !isCurrentMonth) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.event_busy_rounded, size: 80, color: theme.primaryColor.withOpacity(0.2)),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.noRecordsFound,
                                        style: TextStyle(
                                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
                              final allDays = List.generate(daysInMonth, (i) => DateTime(selectedMonth.year, selectedMonth.month, i + 1));

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: allDays.length,
                                itemBuilder: (context, index) {
                                  final day = allDays[index];
                                  final record = records.firstWhere(
                                    (r) => DateConverter.isSameDay(r.checkInTime, day),
                                    orElse: () => AttendanceRecord(checkInTime: day, id: -1), // ID -1 means no record
                                  );

                                  final isAbsent = record.id == -1;
                                  final actualRecord = isAbsent ? null : record;

                                  final isToday = DateConverter.isSameDay(day, now);
                                  final isFuture = day.isAfter(today);
                                  
                                  // Grace period logic: Don't show absent if it's today and before (checkout + 2 hours)
                                  final checkoutDateTime = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    settings.checkOutTime.hour,
                                    settings.checkOutTime.minute,
                                  );
                                  final graceEndTime = checkoutDateTime.add(const Duration(hours: 2));
                                  final hideAbsence = isToday && actualRecord == null && now.isBefore(graceEndTime);
                                  
                                  return AttendanceListItem(
                                    record: actualRecord,
                                    date: day,
                                    isHighlighted: isToday,
                                    isFuture: isFuture || hideAbsence,
                                    onSaveNote: actualRecord != null ? (note) {
                                      ref.read(attendanceRecordsProvider(selectedMonth).notifier)
                                         .updateNote(actualRecord, note);
                                    } : null,
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => Center(child: Text('Error: $e')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Dashboard Image Illustration
          PositionedDirectional(
            top: isRtl ? 40 : 30, // Move slightly down in RTL to clear title
            end: isRtl ? -30 : -10, // Push further out in RTL
            child: SafeArea(
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: isRtl ? 0.15 : -0.15, // Rotate opposite direction for better flow in RTL
                  child: Image.asset(
                    isDark ? "assets/images/dashboard_header_dark.png" : 'assets/images/dashboard_header.png',
                    width: isRtl ? 170 : 200, // Slightly smaller in RTL
                    height: isRtl ? 170 : 200,
                    fit: BoxFit.contain,
                    opacity: const AlwaysStoppedAnimation(0.8),
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      width: 200,
                      height: 200,
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.white24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ThemeData theme, AsyncValue<List<dynamic>> recordsAsync) {
    int totalLateMinutes = 0;
    int totalWorkingMinutes = 0;

    recordsAsync.whenData((records) {
      for (var record in records) {
        totalLateMinutes += (record.lateMinutes as int);
        totalWorkingMinutes += (record.workingMinutes as int);
      }
    });

    final totalHours = (totalWorkingMinutes / 60).toStringAsFixed(1);
    final totalLateHrs = (totalLateMinutes / 60).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.myAttendance,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsView()),
                  );
                },
                icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // const SizedBox(width: 150),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildStatChip('${l10n.total}: $totalHours ${l10n.hr}', Colors.white.withOpacity(0.2)),
              const SizedBox(width: 8),
              _buildStatChip('${l10n.late}: $totalLateHrs ${l10n.hr}', Colors.redAccent.withOpacity(0.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(
    AppLocalizations l10n, 
    ThemeData theme, 
    AsyncValue<dynamic> todayAsync, 
    WidgetRef ref, 
    DateTime selectedMonth
  ) {
    return todayAsync.when(
      data: (todayRecord) {
        final canCheckIn = todayRecord == null;
        final canCheckOut = todayRecord != null && todayRecord.checkOutTime == null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: canCheckIn ? () => ref.read(attendanceRecordsProvider(selectedMonth).notifier).checkIn() : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: canCheckIn ? theme.primaryColor : Colors.grey.withOpacity(0.3),
                  ),
                  child: Text(
                    l10n.checkIn,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: canCheckIn ? Colors.white : Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: canCheckOut ? () => ref.read(attendanceRecordsProvider(selectedMonth).notifier).checkOut() : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: canCheckOut ? theme.primaryColor : Colors.grey,
                    side: BorderSide(color: canCheckOut ? theme.primaryColor.withOpacity(0.5) : Colors.grey.withOpacity(0.2), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    l10n.checkOut,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
