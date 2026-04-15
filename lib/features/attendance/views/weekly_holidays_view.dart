import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/settings_service.dart';
import '../../../l10n/app_localizations.dart';

class WeeklyHolidaysView extends ConsumerWidget {
  const WeeklyHolidaysView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    final days = [
      {'id': DateTime.monday, 'label': l10n.monday},
      {'id': DateTime.tuesday, 'label': l10n.tuesday},
      {'id': DateTime.wednesday, 'label': l10n.wednesday},
      {'id': DateTime.thursday, 'label': l10n.thursday},
      {'id': DateTime.friday, 'label': l10n.friday},
      {'id': DateTime.saturday, 'label': l10n.saturday},
      {'id': DateTime.sunday, 'label': l10n.sunday},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.weeklyHolidays),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final dayId = day['id'] as int;
          final isHoliday = settings.weeklyHolidays.contains(dayId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                final newList = List<int>.from(settings.weeklyHolidays);
                if (isHoliday) {
                  newList.remove(dayId);
                } else {
                  newList.add(dayId);
                }
                ref.read(settingsProvider.notifier).updateWeeklyHolidays(newList);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isHoliday ? theme.primaryColor.withOpacity(0.05) : theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHoliday ? theme.primaryColor : theme.primaryColor.withOpacity(0.05),
                    width: isHoliday ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        day['label'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isHoliday ? FontWeight.bold : FontWeight.w500,
                          color: isHoliday ? theme.primaryColor : null,
                        ),
                      ),
                    ),
                    Checkbox.adaptive(
                      value: isHoliday,
                      activeColor: theme.primaryColor,
                      onChanged: (val) {
                         final newList = List<int>.from(settings.weeklyHolidays);
                        if (isHoliday) {
                          newList.remove(dayId);
                        } else {
                          newList.add(dayId);
                        }
                        ref.read(settingsProvider.notifier).updateWeeklyHolidays(newList);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
