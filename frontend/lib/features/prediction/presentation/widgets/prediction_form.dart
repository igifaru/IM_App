import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../logic/prediction_provider.dart';
import '../../../../shared/widgets/location/administrative_map.dart';
import '../../../../shared/widgets/location/hierarchical_location_picker.dart';
import '../../../../shared/widgets/error_banner.dart';

class PredictionForm extends StatefulWidget {
  const PredictionForm({super.key});

  @override
  State<PredictionForm> createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();
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
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error Banner (if any)
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ErrorBanner(
                    message: provider.error!.message.tr(),
                    errorCode: provider.errorReferenceId,
                    onRetry: () {
                      provider.reset();
                      _scrollToTop();
                    },
                  ),
                ),

              // Location Section
              _buildSectionCard(
                context,
                title: 'location_section'.tr(),
                icon: Icons.location_on_rounded,
                children: [
                  _buildSectionHeader(context, 'map_header'.tr()),
                  const SizedBox(height: 12),
                  AdministrativeMap(
                    selectedProvince: provider.selectedProvince,
                    selectedDistrict: provider.selectedDistrict,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'location_details'.tr()),
                  const SizedBox(height: 12),
                  HierarchicalLocationPicker(
                    initialProvince: provider.selectedProvince,
                    initialDistrict: provider.selectedDistrict,
                    initialSector: provider.selectedSector,
                    onLocationChanged: (p, d, s) {
                      provider.selectedProvince = p;
                      provider.selectedDistrict = d;
                      provider.selectedSector = s;
                      provider.notifyListeners();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Agricultural Parameters Section
              _buildSectionCard(
                context,
                title: 'agricultural_section'.tr(),
                icon: Icons.agriculture_rounded,
                children: [
                  _buildDropdown(
                    context,
                    label: 'crop_label'.tr(),
                    value: provider.selectedCrop,
                    items: provider.metadata['crops'] ?? [],
                    onChanged: (v) {
                      provider.selectedCrop = v;
                      provider.notifyListeners();
                    },
                    icon: Icons.grass_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    context,
                    label: 'season_label'.tr(),
                    value: provider.selectedSeason,
                    items: provider.metadata['seasons'] ?? [],
                    onChanged: (v) {
                      provider.selectedSeason = v;
                      provider.notifyListeners();
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    context,
                    label: 'slope_label'.tr(),
                    value: provider.selectedSlope,
                    items: provider.metadata['slopes'] ?? [],
                    onChanged: (v) {
                      provider.selectedSlope = v;
                      provider.notifyListeners();
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    context,
                    label: 'seed_type_label'.tr(),
                    value: provider.selectedSeeds,
                    items: provider.metadata['seeds'] ?? [],
                    onChanged: (v) {
                      provider.selectedSeeds = v;
                      provider.notifyListeners();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Soil Amendments Section
              _buildSectionCard(
                context,
                title: 'soil_amendments_section'.tr(),
                icon: Icons.eco_rounded,
                children: [
                  _buildModernSwitch(
                    context,
                    'inorganic_label'.tr(),
                    provider.inorganicFert,
                    (v) {
                      provider.inorganicFert = v;
                      provider.notifyListeners();
                    },
                    Icons.science_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildModernSwitch(
                    context,
                    'organic_label'.tr(),
                    provider.organicFert,
                    (v) {
                      provider.organicFert = v;
                      provider.notifyListeners();
                    },
                    Icons.eco_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildModernSwitch(
                    context,
                    'lime_label'.tr(),
                    provider.usedLime,
                    (v) {
                      provider.usedLime = v;
                      provider.notifyListeners();
                    },
                    Icons.opacity_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              _buildSubmitButton(context, provider),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF232529).withOpacity(0.5)
            : Theme.of(context).primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Theme.of(context).primaryColor.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodySmall?.color,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,  // Optional icon parameter
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black.withOpacity(0.87);
    final hintColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.54);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hintColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDarkMode
              ? const Color(0xFF232529)
              : Colors.white,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode
                ? const Color(0xFF232529).withOpacity(0.7)
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                    size: 20,
                  )
                : Icon(
                    Icons.check_circle_outline_rounded,
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                    size: 20,
                  ),
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildModernSwitch(
    BuildContext context,
    String label,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black.withOpacity(0.87);
    final backgroundColor = value
        ? Theme.of(context).primaryColor.withOpacity(0.12)
        : isDarkMode
            ? const Color(0xFF232529).withOpacity(0.6)
            : Colors.grey.withOpacity(0.05);
    final borderColor = value
        ? Theme.of(context).primaryColor.withOpacity(0.4)
        : isDarkMode
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        secondary: Icon(
          icon,
          color: value ? Theme.of(context).primaryColor : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
          size: 22,
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.4),
        inactiveThumbColor: isDarkMode ? Colors.grey[400] : Colors.grey[400],
        inactiveTrackColor: isDarkMode
            ? Colors.grey[700]
            : Colors.black.withOpacity(0.1),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, PredictionProvider provider) {
    final isValid = provider.selectedProvince != null &&
        provider.selectedDistrict != null &&
        provider.selectedSeason != null &&
        provider.selectedSlope != null &&
        provider.selectedSeeds != null &&
        provider.selectedCrop != null;  // Add crop validation

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: !isValid || provider.isLoading
            ? null
            : () => provider.getPrediction(context.locale.languageCode),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (provider.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            else
              const Icon(Icons.auto_awesome_rounded, size: 22),
            const SizedBox(width: 12),
            Text(
              provider.isLoading ? 'predicting'.tr() : 'predict_button'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
