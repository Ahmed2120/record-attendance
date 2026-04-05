import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_converter.dart';
import '../../providers/month_provider.dart';
import '../../../../core/providers/theme_provider.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    // Explicitly watch theme to ensure rebuild on mode change
    ref.watch(themeProvider);
    final locale = Localizations.localeOf(context).languageCode;
    
    // Generate 12 months for the current year
    final now = DateTime.now();
    final List<DateTime> months = List.generate(
      12, 
      (index) => DateTime(now.year, index + 1, 1)
    );

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final monthDate = months[index];
          final isSelected = monthDate.month == selectedMonth.month && monthDate.year == selectedMonth.year;
          
          return GestureDetector(
            onTap: () {
              ref.read(selectedMonthProvider.notifier).state = monthDate;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateConverter.getFormattedMonthName(monthDate, locale),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : (Theme.of(context).brightness == Brightness.dark 
                           ? Colors.white.withOpacity(0.5) 
                           : Colors.black.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      height: 3,
                      width: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
