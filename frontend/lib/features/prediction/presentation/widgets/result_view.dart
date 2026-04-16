import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/confidence_disclaimer.dart';

class ResultView extends StatelessWidget {
  final String crop;
  final double confidence;
  final bool lowConfidence;
  final String? disclaimer;
  final String advice;
  final VoidCallback onReset;

  const ResultView({
    super.key,
    required this.crop,
    required this.confidence,
    required this.lowConfidence,
    required this.disclaimer,
    required this.advice,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Success Icon with Animation
              _buildCropIcon(context, isDarkMode),
              const SizedBox(height: 28),

              // Result Label
              Text(
                'result_label'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.7) 
                      : Colors.black.withOpacity(0.54),
                  letterSpacing: 1.2,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Crop Name - Real data from backend
              Text(
                crop.tr(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Confidence Score Card - Real data from backend
              _buildConfidenceCard(context, isDarkMode),
              const SizedBox(height: 20),

              // Low Confidence Disclaimer (if applicable) - Real data from backend
              if (lowConfidence && disclaimer != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ConfidenceDisclaimer(
                    confidenceScore: confidence,
                    disclaimer: disclaimer!,
                    isLowConfidence: lowConfidence,
                  ),
                ),

              // Expert Advice Card - Real data from backend
              _buildAdviceCard(context, isDarkMode),
              const SizedBox(height: 28),

              // Action Buttons
              _buildActionButtons(context, isDarkMode),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropIcon(BuildContext context, bool isDarkMode) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.2),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.4),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.eco_rounded,
        size: 64,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildConfidenceCard(BuildContext context, bool isDarkMode) {
    // Real confidence score from backend (0.0 to 1.0)
    final confidencePercentage = (confidence * 100).toStringAsFixed(1);
    final confidenceColor = _getConfidenceColor(confidence);
    final confidenceLabel = _getConfidenceLabel(confidence);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: confidenceColor.withOpacity(isDarkMode ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: confidenceColor.withOpacity(isDarkMode ? 0.4 : 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'confidence_score'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.85) 
                      : Colors.black.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(isDarkMode ? 0.25 : 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: confidenceColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '$confidencePercentage%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: confidenceColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 10,
              backgroundColor: confidenceColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getConfidenceIcon(confidence),
                size: 18,
                color: confidenceColor,
              ),
              const SizedBox(width: 8),
              Text(
                confidenceLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: confidenceColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF232529).withOpacity(0.6)
            : Theme.of(context).primaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Theme.of(context).primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'advice_header'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.25)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Text(
              // Real advice from backend
              advice,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.8,
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.9) 
                    : Colors.black.withOpacity(0.85),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        // New Prediction Button - Professional styling
        Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline_rounded, size: 26),
                const SizedBox(width: 14),
                Text(
                  'new_prediction'.tr(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Go Back Button - Professional styling
        Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              backgroundColor: isDarkMode
                  ? Theme.of(context).primaryColor.withOpacity(0.08)
                  : Colors.white,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 26,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 14),
                Text(
                  'back_button'.tr(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for confidence visualization
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return const Color(0xFF2E7D32); // Green - High confidence
    } else if (confidence >= 0.6) {
      return const Color(0xFFFFA000); // Amber - Medium confidence
    } else {
      return const Color(0xFFD32F2F); // Red - Low confidence
    }
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.8) {
      return 'confidence_high'.tr();
    } else if (confidence >= 0.6) {
      return 'confidence_medium'.tr();
    } else {
      return 'confidence_low'.tr();
    }
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) {
      return Icons.check_circle_rounded;
    } else if (confidence >= 0.6) {
      return Icons.info_rounded;
    } else {
      return Icons.warning_rounded;
    }
  }
}
