import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Error banner widget for displaying inline error messages
class ErrorBanner extends StatelessWidget {
  final String message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetryButton;

  const ErrorBanner({
    Key? key,
    required this.message,
    this.errorCode,
    this.onRetry,
    this.onDismiss,
    this.showRetryButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.red.withOpacity(0.15)
        : Colors.red[50];
    final borderColor = isDarkMode
        ? Colors.red.withOpacity(0.3)
        : Colors.red[300];
    final textColor = isDarkMode
        ? Colors.red[300]
        : Colors.red[700];
    final iconColor = isDarkMode
        ? Colors.red[300]
        : Colors.red[700];

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
              Icon(Icons.error_outline, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, color: iconColor, size: 20),
                ),
            ],
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text('retry'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
