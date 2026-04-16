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
            title: 'Cereals (Ibinyampeke)',
            icon: Icons.grass,
            tips: [
              'Plant maize at the beginning of the rainy season.',
              'Ensure proper spacing (25-30cm) for optimal growth.',
              'Apply top-dressing fertilizer when maize is knee-high.'
            ],
          ),
          _buildTipCategory(
            context,
            title: 'Legumes (Ibinyamavuta)',
            icon: Icons.eco,
            tips: [
              'Beans prefer well-drained soil.',
              'Use improved climbing bean seeds for higher yields.',
              'Rotate legumes with cereals to restore soil nitrogen.'
            ],
          ),
          _buildTipCategory(
            context,
            title: 'Roots & Tubers (Ibirayi/Imyumbati)',
            icon: Icons.waves,
            tips: [
              'Irish potatoes need hilling (earthing up) twice.',
              'Protect crops from late blight using recommended sprays.',
              'Harvest cassava only when mature for better taste.'
            ],
          ),
          _buildTipCategory(
            context,
            title: 'General Best Practices',
            icon: Icons.verified_user,
            tips: [
              'Always use organic manure alongside inorganic fertilizers.',
              'Control erosion by planting agroforestry trees or creating terraces.',
              'Apply lime to acidic soils at least 2 weeks before planting.'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCategory(BuildContext context, {required String title, required IconData icon, required List<String> tips}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.green),
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
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
