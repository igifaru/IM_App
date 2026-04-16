import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../logic/prediction_provider.dart';
import '../../../../shared/widgets/location/administrative_map.dart';
import '../../../../shared/widgets/location/hierarchical_location_picker.dart';

class PredictionForm extends StatelessWidget {
  const PredictionForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'form_title'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 24),

            // Interactive Map Visualization
            AdministrativeMap(
              selectedProvince: provider.selectedProvince,
              selectedDistrict: provider.selectedDistrict,
            ),
            const SizedBox(height: 32),
            
            // Hierarchical Location Picker
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
            
            const SizedBox(height: 24),
            _buildDropdown(
              label: 'season_label'.tr(),
              value: provider.selectedSeason,
              items: provider.metadata['seasons'] ?? [],
              onChanged: (v) => provider.selectedSeason = v,
            ),
            _buildDropdown(
              label: 'slope_label'.tr(),
              value: provider.selectedSlope,
              items: provider.metadata['slopes'] ?? [],
              onChanged: (v) => provider.selectedSlope = v,
            ),
            _buildDropdown(
              label: 'seed_type_label'.tr(),
              value: provider.selectedSeeds,
              items: provider.metadata['seeds'] ?? [],
              onChanged: (v) => provider.selectedSeeds = v,
            ),
            
            const SizedBox(height: 16),
            Text(
              'fertilizers_label'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            _buildSwitch('inorganic_label'.tr(), provider.inorganicFert, (v) {
              provider.inorganicFert = v;
              provider.notifyListeners();
            }),
            _buildSwitch('organic_label'.tr(), provider.organicFert, (v) {
              provider.organicFert = v;
              provider.notifyListeners();
            }),
            _buildSwitch('lime_label'.tr(), provider.usedLime, (v) {
              provider.usedLime = v;
              provider.notifyListeners();
            }),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: provider.isLoading ? null : () => provider.getPrediction(context.locale.languageCode),
              child: Text('predict_button'.tr()),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2E7D32),
      contentPadding: EdgeInsets.zero,
    );
  }
}
