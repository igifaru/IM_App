import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('expert_tips'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCategory(
            context,
            title: 'cat_cereals'.tr(),
            icon: Icons.grass,
            tips: [
              'tips_maize_timing'.tr(),
              'tips_spacing'.tr(),
              'tips_fertilizer'.tr(),
            ],
          ),
          _buildTipCategory(
            context,
            title: 'cat_legumes'.tr(),
            icon: Icons.eco,
            tips: [
              'tips_beans_soil'.tr(),
              'tips_rotation'.tr(),
            ],
          ),
          _buildTipCategory(
            context,
            title: 'cat_roots'.tr(),
            icon: Icons.waves,
            tips: [
              'tips_potato_hill'.tr(),
              'tips_blight'.tr(),
            ],
          ),
          _buildTipCategory(
            context,
            title: 'tips_general_title'.tr(),
            icon: Icons.verified_user,
            tips: [
              'tips_manure'.tr(),
              'tips_erosion'.tr(),
              'tips_lime'.tr(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCategory(BuildContext context, {required String title, required IconData icon, required List<String> tips}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Theme.of(context).cardColor : Colors.white;
    final borderColor = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200];

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor!),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: tips.map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    Expanded(child: Text(tip, style: const TextStyle(height: 1.4))),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
