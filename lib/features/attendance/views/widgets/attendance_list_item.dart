import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_converter.dart';
import '../../models/attendance_record.dart';
import '../../providers/todo_provider.dart';
import 'todo_list_widget.dart';
import '../../providers/attendance_provider.dart';

class AttendanceListItem extends ConsumerStatefulWidget {
  final AttendanceRecord? record;
  final DateTime date;
  final bool isHighlighted;
  final bool isFuture;
  final Function(String)? onSaveNote;
  
  const AttendanceListItem({
    super.key, 
    this.record,
    required this.date,
    this.isHighlighted = false,
    this.isFuture = false,
    this.isHoliday = false,
    this.onSaveNote,
  });

  final bool isHoliday;

  @override
  ConsumerState<AttendanceListItem> createState() => _AttendanceListItemState();
}

class _AttendanceListItemState extends ConsumerState<AttendanceListItem> with SingleTickerProviderStateMixin {

  bool _isExpanded = false;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.record?.notes ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    
    final bool isAbsent = widget.record == null;
    final bool isToday = DateConverter.isSameDay(widget.date, DateTime.now());

    // Formatting times using DateConverter
    final String dayNumber = DateConverter.getFormattedDayNumber(widget.date);
    final String dayName = DateConverter.getFormattedDayName(widget.date, locale);
    
    String checkInStr = '-';
    String checkOutStr = '-';
    
    if (!isAbsent) {
      checkInStr = DateConverter.formatTimeWithLocale(widget.record!.checkInTime, locale);
      if (widget.record!.checkOutTime != null) {
        checkOutStr = DateConverter.formatTimeWithLocale(widget.record!.checkOutTime!, locale);
      }
    }

    final Color bgColor = widget.isHighlighted 
        ? theme.primaryColor 
        : (isDark ? theme.cardColor : Colors.white);
    
    final Color dateBoxColor = widget.isHighlighted 
        ? Colors.white.withOpacity(0.9) 
        : (isDark ? Colors.white10 : AppColors.secondary.withOpacity(0.1));
        
    final Color dateTextColor = widget.isHighlighted 
        ? theme.primaryColor 
        : (isDark ? Colors.white : theme.textTheme.bodyLarge!.color!);
        
    final Color titleColor = widget.isHighlighted 
        ? Colors.white 
        : (isDark ? Colors.white70 : theme.textTheme.bodyLarge!.color!);
        
    final Color valueColor = widget.isHighlighted 
        ? Colors.white.withOpacity(0.8) 
        : (isDark ? Colors.white60 : theme.textTheme.bodyMedium!.color!);

    // New: Handle border and opacity for different states
    final bool isPastAbsent = isAbsent && !widget.isFuture && !widget.isHoliday;
    final bool isHolidayAbsent = isAbsent && widget.isHoliday;
    // Don't dim if it's highlighted (today) even if it's "pending" (isFuture)
    final double cardOpacity = (widget.isFuture && !widget.isHighlighted) ? 0.6 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (!isDark && !widget.isHighlighted && !isPastAbsent && !widget.isFuture)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: widget.isHighlighted
              ? null
              : (isPastAbsent || widget.isFuture || isHolidayAbsent)
                  ? Border.all(
                      color: isPastAbsent 
                        ? Colors.redAccent.withOpacity(0.2) 
                        : isHolidayAbsent
                          ? theme.primaryColor.withOpacity(0.2)
                          : (isDark ? Colors.white10 : Colors.black12),
                      width: 1.5,
                      style: BorderStyle.solid,
                    )
                  : isDark
                      ? Border.all(color: Colors.white10)
                      : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: (widget.isFuture && isAbsent) ? null : () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Date Box
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: dateBoxColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dayNumber,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                color: dateTextColor,
                              ),
                            ),
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: dateTextColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Times, Absent or Future State
                      if (widget.isFuture && isAbsent && !widget.isHighlighted && !widget.isHoliday)
                        Expanded(
                          child: Text(
                            l10n.upcoming, 
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        )
                      else if (isHolidayAbsent)
                         Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.vacation,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isHighlighted ? Colors.white : theme.primaryColor,
                                ),
                              ),
                              Text(
                                l10n.weeklyHolidays, // Or more general "Holiday"
                                style: TextStyle(
                                  fontSize: 11,
                                  color: (widget.isHighlighted ? Colors.white : theme.primaryColor).withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isAbsent && !widget.isHighlighted)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.absent,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isHighlighted ? Colors.white : Colors.redAccent,
                                ),
                              ),
                              Text(
                                l10n.notRecorded,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: (widget.isHighlighted ? Colors.white : Colors.redAccent).withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Check In
                        Expanded(
                          child: _buildTimeColumn(l10n.checkIn, checkInStr, titleColor, valueColor),
                        ),
                        // Check Out
                        Expanded(
                          child: _buildTimeColumn(l10n.checkOut, checkOutStr, titleColor, valueColor),
                        ),
                      ],
                      // Status Icon / Toggle icon
                      if (!widget.isFuture || (ref.watch(todoProvider(widget.date)).value?.isNotEmpty ?? false))
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.isHighlighted ? Colors.white24 : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: widget.isHighlighted ? Colors.white : theme.primaryColor,
                          ),
                        ),
                      if (widget.isHoliday && !isAbsent)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Tooltip(
                            message: l10n.vacation,
                            child: Icon(
                              Icons.beach_access_rounded,
                              size: 20,
                              color: widget.isHighlighted ? Colors.white70 : theme.primaryColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                      
                      // Task Progress Badge (Mini)
                      ref.watch(todoProvider(widget.date)).whenData((todos) {
                        if (todos.isEmpty) return const SizedBox.shrink();
                        final done = todos.where((t) => t.isDone).length;
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: widget.isHighlighted ? Colors.white24 : theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: done == todos.length 
                              ? Icon(Icons.check_rounded, size: 12, color: widget.isHighlighted ? Colors.white : theme.primaryColor)
                              : Text(
                                  '$done',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isHighlighted ? Colors.white : theme.primaryColor,
                                  ),
                                ),
                          ),
                        );
                      }).value ?? const SizedBox.shrink(),
                    ],
                  ),
                  
                  // Expandable Content
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: (_isExpanded && (!(widget.isFuture && isAbsent) || (ref.watch(todoProvider(widget.date)).value?.isNotEmpty ?? false)))
                        ? Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(height: 1, color: Colors.white24),
                              ),
                              
                              // To-Do List Section
                              TodoListWidget(date: widget.date, isHighlighted: widget.isHighlighted),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(height: 1, color: Colors.white24),
                              ),

                              if (!isAbsent) ...[
                                // Lateness Status
                                Row(
                                  children: [
                                    Icon(
                                      widget.record!.lateMinutes > 0 ? Icons.error_outline : Icons.check_circle_outline,
                                      size: 16,
                                      color: widget.record!.lateMinutes > 0 
                                        ? (widget.isHighlighted ? Colors.white : Colors.redAccent)
                                        : (widget.isHighlighted ? Colors.white : Colors.green),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.record!.lateMinutes > 0 
                                        ? l10n.minutesLate(widget.record!.lateMinutes)
                                        : l10n.onTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: widget.isHighlighted ? Colors.white : theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Notes Section
                                if (isToday)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      TextField(
                                        controller: _noteController,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 13, 
                                          color: widget.isHighlighted ? Colors.white : null
                                        ),
                                        decoration: InputDecoration(
                                          hintText: l10n.addNote,
                                          hintStyle: TextStyle(color: widget.isHighlighted ? Colors.white60 : null),
                                          filled: true,
                                          fillColor: widget.isHighlighted ? Colors.white10 : Colors.black.withOpacity(0.03),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.all(12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              if (_noteController.text.trim().isEmpty) return;
                                              
                                              // Logic to move to next work day
                                              // For simplicity, we'll just move to "tomorrow"
                                              // In a real app, we'd check for weekends/vacations
                                              final tomorrow = widget.date.add(const Duration(days: 1));
                                              ref.read(todoProvider(tomorrow).notifier).addTodo(_noteController.text.trim());
                                              
                                              // Clear current note if desired, or keep it
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(l10n.moveToTomorrow),
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: theme.primaryColor,
                                                )
                                              );
                                            },
                                            icon: const Icon(Icons.next_plan_rounded, size: 16),
                                            label: Text(l10n.remindMeTomorrow),
                                            style: TextButton.styleFrom(
                                              foregroundColor: widget.isHighlighted ? Colors.white70 : theme.primaryColor.withOpacity(0.7),
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (widget.onSaveNote != null) {
                                                widget.onSaveNote!(_noteController.text);
                                              }
                                            },
                                            icon: const Icon(Icons.save_rounded, size: 16),
                                            label: Text(l10n.saveNote),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: widget.isHighlighted ? Colors.white24 : theme.primaryColor.withOpacity(0.1),
                                              foregroundColor: widget.isHighlighted ? Colors.white : theme.primaryColor,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.notes,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: titleColor.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.record!.notes.isEmpty ? l10n.noNotesYet : widget.record!.notes,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: valueColor,
                                          fontStyle: widget.record!.notes.isEmpty ? FontStyle.italic : null,
                                        ),
                                      ),
                                    ],
                                  ),
                              ] else
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    widget.isHoliday ? l10n.vacation : l10n.absent,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: valueColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String label, String value, Color labelColor, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: labelColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
