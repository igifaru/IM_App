import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../shared/widgets/common/custom_card.dart';
import '../../../shared/widgets/common/custom_button.dart';

class ResultView extends StatelessWidget {
  final String crop;
  final String advice;
  final VoidCallback onReset;

  const ResultView({
    super.key,
    required this.crop,
    required this.advice,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildCropIcon(),
          const SizedBox(height: 24),
          Text(
            'result_label'.tr(),
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            crop,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 24),
          _buildAdviceCard(),
          const Spacer(),
          CustomButton(
            text: 'back_button'.tr(),
            onPressed: onReset,
            color: Colors.grey[700],
            icon: Icons.arrow_back,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCropIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2E7D32), width: 4),
      ),
      child: const Icon(
        Icons.grass,
        size: 64,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildAdviceCard() {
    return CustomCard(
      color: const Color(0xFFFFF8E1),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFFFFB300)),
              const SizedBox(width: 12),
              Text(
                'advice_header'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 1.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
