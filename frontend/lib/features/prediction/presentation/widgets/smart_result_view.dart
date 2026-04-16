import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/models/smart_consultant_models.dart';

class SmartResultView extends StatelessWidget {
  final FarmerChoice farmerChoice;
  final List<CropRecommendation> topRecommendations;
  final AIInterpretation? aiInterpretation;
  final VoidCallback onReset;

  const SmartResultView({
    Key? key,
    required this.farmerChoice,
    required this.topRecommendations,
    this.aiInterpretation,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with icon
          _buildHeader(context),
          
          const SizedBox(height: 24),
          
          // Section 1: Your Choice
          _buildFarmerChoiceSection(context),
          
          const SizedBox(height: 20),
          
          // Section 2: Top Recommendations
          _buildTopRecommendationsSection(context),
          
          const SizedBox(height: 20),
          
          // Section 3: AI Interpretation
          if (aiInterpretation != null)
            _buildAIInterpretationSection(context),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          _buildActionButtons(context),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.agriculture,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Consultant Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-Powered Crop Recommendations',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerChoiceSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getStatusBorderColor(farmerChoice.statusColor).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(farmerChoice.statusColor, isDark),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 22,
                  color: _getStatusBorderColor(farmerChoice.statusColor),
                ),
                const SizedBox(width: 12),
                Text(
                  'your_choice'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatusIndicator(farmerChoice.statusColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmerChoice.crop.tr(),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusBorderColor(farmerChoice.statusColor).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(farmerChoice.confidenceScore * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusBorderColor(farmerChoice.statusColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusText(farmerChoice.status).tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          farmerChoice.validationMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRecommendationsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.15),
                  Colors.orange.withOpacity(0.15),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 22,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 12),
                Text(
                  'top_recommendations'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Recommendations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: topRecommendations.map((rec) => 
                _buildRecommendationCard(context, rec)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, CropRecommendation rec) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildRankBadge(rec.rank),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.crop.tr(),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(rec.confidenceScore * 100).toStringAsFixed(0)}% ${'confidence'.tr()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  rec.reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInterpretationSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  size: 22,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'ai_interpretation'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              aiInterpretation!.text,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(
              'new_prediction'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String statusColor) {
    IconData icon;
    Color color;
    
    switch (statusColor) {
      case 'green':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'yellow':
        icon = Icons.warning_amber;
        color = Colors.orange;
        break;
      case 'red':
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32, color: color),
    );
  }

  Widget _buildRankBadge(int rank) {
    String emoji;
    Color color;
    Color bgColor;
    
    switch (rank) {
      case 1:
        emoji = '🥇';
        color = Colors.amber[700]!;
        bgColor = Colors.amber.withOpacity(0.2);
        break;
      case 2:
        emoji = '🥈';
        color = Colors.grey[600]!;
        bgColor = Colors.grey.withOpacity(0.2);
        break;
      case 3:
        emoji = '🥉';
        color = Colors.brown[400]!;
        bgColor = Colors.brown.withOpacity(0.2);
        break;
      default:
        emoji = '$rank';
        color = Colors.grey;
        bgColor = Colors.grey.withOpacity(0.2);
    }
    
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }

  Color _getStatusBackgroundColor(String statusColor, bool isDark) {
    switch (statusColor) {
      case 'green':
        return isDark ? Colors.green.withOpacity(0.15) : Colors.green.withOpacity(0.1);
      case 'yellow':
        return isDark ? Colors.orange.withOpacity(0.15) : Colors.orange.withOpacity(0.1);
      case 'red':
        return isDark ? Colors.red.withOpacity(0.15) : Colors.red.withOpacity(0.1);
      default:
        return isDark ? Colors.grey.withOpacity(0.15) : Colors.grey.withOpacity(0.1);
    }
  }

  Color _getStatusBorderColor(String statusColor) {
    switch (statusColor) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'good':
        return 'status_good';
      case 'moderate':
        return 'status_moderate';
      case 'poor':
        return 'status_poor';
      default:
        return status;
    }
  }
}
