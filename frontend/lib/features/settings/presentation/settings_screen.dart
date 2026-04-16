import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../prediction/logic/prediction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();
    final isDark = provider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('settings'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _sectionLabel(context, 'appearance'.tr()),
          const SizedBox(height: 12),
          _settingsTile(
            context,
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            iconColor: isDark ? Colors.amber : Colors.indigo,
            title: 'dark_mode'.tr(),
            subtitle: isDark ? 'dark_mode_on'.tr() : 'dark_mode_off'.tr(),
            trailing: Switch.adaptive(
              value: isDark,
              activeThumbColor: theme.primaryColor,
              activeTrackColor: theme.primaryColor.withValues(alpha: 0.5),
              onChanged: (_) => provider.toggleTheme(),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'language'.tr()),
          const SizedBox(height: 12),
          _buildLanguageOption(context, 'English', '🇬🇧', const Locale('en')),
          const SizedBox(height: 8),
          _buildLanguageOption(context, 'Français', '🇫🇷', const Locale('fr')),
          const SizedBox(height: 8),
          _buildLanguageOption(context, 'Kinyarwanda', '🇷🇼', const Locale('rw')),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: theme.hintColor)),
        trailing: trailing,
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, String flag, Locale locale) {
    final isSelected = context.locale == locale;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.setLocale(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.08) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Text(flag, style: const TextStyle(fontSize: 28)),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? theme.primaryColor : null,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: theme.primaryColor)
              : Icon(Icons.radio_button_unchecked, color: theme.hintColor),
        ),
      ),
    );
  }
}
