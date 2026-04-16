import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../prediction/logic/prediction_provider.dart';
import '../../../shared/widgets/common/custom_card.dart';
import '../../tips/presentation/tips_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../navigation/presentation/main_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('app_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(provider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildWeatherSection(context),
            _buildSeasonCard(context),
            _buildQuickActions(context),
            if (provider.history.isNotEmpty) _buildRecentHistory(context, provider),
            _buildTipsCard(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kigali, Rwanda',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '24°C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Partly Cloudy'.tr(),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.wb_cloudy_rounded, color: Colors.white, size: 60),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherMetric(Icons.water_drop_outlined, '72%', 'Humidity'),
                _buildWeatherMetric(Icons.air_rounded, '12 km/h', 'Wind'),
                _buildWeatherMetric(Icons.umbrella_outlined, '10%', 'Rain'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildSeasonCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: CustomCard(
        color: isDark ? Colors.amber[900]?.withOpacity(0.2) : Colors.amber[50],
        onTap: () {
          final mainState = context.findAncestorStateOfType<MainScreenState>();
          mainState?.setTab(3); // Switch to Calendar tab
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wb_sunny_rounded, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Season: B',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Planting window for Legumes ends soon',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_actions'.tr(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionItem(
                context,
                title: 'start_prediction'.tr(),
                icon: Icons.add_chart,
                color: Colors.green,
                onTap: () {
                  final mainState = context.findAncestorStateOfType<MainScreenState>();
                  mainState?.setTab(1); // Switch to Predict tab
                },
              ),
              const SizedBox(width: 16),
              _buildActionItem(
                context,
                title: 'history'.tr(),
                icon: Icons.history,
                color: Colors.blue,
                onTap: () {
                  final mainState = context.findAncestorStateOfType<MainScreenState>();
                  mainState?.setTab(2); // Switch to History tab
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, PredictionProvider provider) {
    final recent = provider.history.take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'recent_predictions'.tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                child: Text('view_all'.tr()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...recent.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              onTap: () {},
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.grass, color: Colors.green),
                ),
                title: Text(item.cropName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat.yMMMd().format(item.timestamp)),
                trailing: const Icon(Icons.chevron_right, size: 20),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CustomCard(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsScreen())),
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'expert_tips'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inama ku buhinzi bwawe',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ururimi', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'English', const Locale('en')),
            _buildLanguageOption(context, 'Français', const Locale('fr')),
            _buildLanguageOption(context, 'Kinyarwanda', const Locale('rw')),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, Locale locale) {
    final isSelected = context.locale == locale;
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
      onTap: () {
        context.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }
}
