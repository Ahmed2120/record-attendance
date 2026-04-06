import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/settings_service.dart';
import '../providers/attendance_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  Future<void> _selectTime(BuildContext context, WidgetRef ref, bool isCheckIn) async {
    final settings = ref.read(settingsProvider);
    final initialTime = isCheckIn ? settings.checkInTime : settings.checkOutTime;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isCheckIn) {
        await ref.read(settingsProvider.notifier).updateCheckInTime(picked);
      } else {
        await ref.read(settingsProvider.notifier).updateCheckOutTime(picked);
      }
      // Refresh alarms for native
      await ref.read(notificationServiceProvider).refreshAlarms();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final isDarkMode = currentThemeMode == ThemeMode.dark || 
                      (currentThemeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
    final currentLocale = ref.watch(localeProvider);

    // Check if current month has records to disable editing
    final now = DateTime.now();
    final currentMonthRecords = ref.watch(attendanceRecordsProvider(DateTime(now.year, now.month)));
    
    final bool hasRecords = currentMonthRecords.when(
      data: (records) => records.isNotEmpty,
      loading: () => true, // Conservatively disable while loading
      error: (_, __) => false,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader(l10n.appearance),
                const SizedBox(height: 12),
                _buildSettingTile(
                  context,
                  l10n.darkMode,
                  trailing: Switch.adaptive(
                    value: isDarkMode,
                    activeColor: theme.primaryColor,
                    onChanged: (val) {
                      ref.read(themeProvider.notifier).toggleTheme(isDarkMode);
                    },
                  ),
                  icon: Icons.dark_mode_rounded,
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  context,
                  l10n.language,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LanguageToggleItem(
                        label: "EN",
                        isSelected: currentLocale?.languageCode == 'en' || currentLocale == null,
                        onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                      ),
                      const SizedBox(width: 8),
                      _LanguageToggleItem(
                        label: "AR",
                        isSelected: currentLocale?.languageCode == 'ar',
                        onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
                      ),
                    ],
                  ),
                  icon: Icons.language_rounded,
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader(l10n.companyHours),
                if (hasRecords)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.hoursDisabledMessage,
                              style: TextStyle(
                                fontSize: 13, 
                                color: Colors.orange.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                _buildSettingTile(
                  context,
                  l10n.checkInTime,
                  subtitle: settings.checkInTime.format(context),
                  onTap: hasRecords ? null : () => _selectTime(context, ref, true),
                  icon: Icons.login_rounded,
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  context,
                  l10n.checkOutTime,
                  subtitle: settings.checkOutTime.format(context),
                  onTap: hasRecords ? null : () => _selectTime(context, ref, false),
                  icon: Icons.logout_rounded,
                ),
              ],
            ),
          ),
          
          // App Version at the bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              children: [
                Text(
                  l10n.version,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "1.0.0",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, 
    String title, {
    String? subtitle, 
    Widget? trailing, 
    VoidCallback? onTap,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final bool isEnabled = onTap != null || trailing != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? null : Colors.grey.shade400,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right_rounded, color: theme.primaryColor.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageToggleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
