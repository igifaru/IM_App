import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Confidence disclaimer widget for low confidence predictions
class ConfidenceDisclaimer extends StatelessWidget {
  final double confidenceScore;
  final String? disclaimer;
  final bool isLowConfidence;

  const ConfidenceDisclaimer({
    Key? key,
    required this.confidenceScore,
    this.disclaimer,
    required this.isLowConfidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLowConfidence) {
      return const SizedBox.shrink();
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.amber.withOpacity(0.15)
        : Colors.amber[50];
    final borderColor = isDarkMode
        ? Colors.amber.withOpacity(0.3)
        : Colors.amber[300];
    final textColor = isDarkMode
        ? Colors.amber[300]
        : Colors.amber[700];
    final badgeColor = isDarkMode
        ? Colors.amber.withOpacity(0.2)
        : Colors.amber[100];
    final badgeTextColor = isDarkMode
        ? Colors.amber[200]
        : Colors.amber[900];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: textColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'low_confidence_warning'.tr(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            disclaimer ?? 'low_confidence_disclaimer'.tr(),
            style: TextStyle(
              color: textColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(confidenceScore * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
