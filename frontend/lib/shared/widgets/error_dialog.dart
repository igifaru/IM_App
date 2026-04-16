import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Error dialog widget for displaying error messages
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? referenceId;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetryButton;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.referenceId,
    this.onRetry,
    this.onDismiss,
    this.showRetryButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (referenceId != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'error_reference'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      referenceId!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (showRetryButton && onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text('retry'.tr()),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: Text('dismiss'.tr()),
        ),
      ],
    );
  }

  /// Show error dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? referenceId,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = true,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        referenceId: referenceId,
        onRetry: onRetry,
        onDismiss: onDismiss,
        showRetryButton: showRetryButton,
      ),
    );
  }
}
