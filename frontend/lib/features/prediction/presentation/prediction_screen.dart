import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import '../logic/prediction_provider.dart';
import 'widgets/prediction_form.dart';
import 'widgets/smart_result_view.dart';
import '../../../../shared/widgets/error_dialog.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  late PredictionProvider _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = context.read<PredictionProvider>();
      _provider.fetchMetadata();
      _setupErrorListener();
    });
  }

  void _setupErrorListener() {
    _provider.addListener(() {
      if (_provider.error != null && mounted) {
        _showErrorDialog();
      }
    });
  }

  void _showErrorDialog() {
    ErrorDialog.show(
      context,
      title: _getErrorTitle(_provider.error!.message),
      message: _provider.error!.message.tr(),
      referenceId: _provider.errorReferenceId,
      onRetry: () {
        Navigator.pop(context);
        _provider.reset();
      },
    );
  }

  String _getErrorTitle(String errorCode) {
    switch (errorCode) {
      case 'rate_limit_exceeded':
        return 'error_rate_limit'.tr();
      case 'authentication_failed':
        return 'error_auth'.tr();
      case 'request_timeout':
        return 'error_timeout'.tr();
      case 'network_error':
        return 'error_network'.tr();
      case 'server_error':
        return 'error_server'.tr();
      default:
        return 'error_title'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamic title based on current view
    final isResultView = provider.farmerChoice != null;
    final titleKey = isResultView ? 'result_title' : 'form_title';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleKey.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black.withOpacity(0.87),
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode 
            ? Theme.of(context).scaffoldBackgroundColor 
            : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: provider.farmerChoice != null
                  ? SmartResultView(
                      farmerChoice: provider.farmerChoice!,
                      topRecommendations: provider.topRecommendations,
                      aiInterpretation: provider.aiInterpretation,
                      onReset: provider.reset,
                    )
                  : const PredictionForm(),
            ),
          ),
          // Loading Overlay
          if (provider.isLoading)
            LoadingOverlay(
              isLoading: true,
              message: 'analyzing_farm_conditions'.tr(),
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
