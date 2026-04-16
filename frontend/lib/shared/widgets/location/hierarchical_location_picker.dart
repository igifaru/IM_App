import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/location/services/administrative_service.dart';

class HierarchicalLocationPicker extends StatefulWidget {
  final String? initialProvince;
  final String? initialDistrict;
  final String? initialSector;
  final Function(String? province, String? district, String? sector) onLocationChanged;

  const HierarchicalLocationPicker({
    super.key,
    this.initialProvince,
    this.initialDistrict,
    this.initialSector,
    required this.onLocationChanged,
  });

  @override
  State<HierarchicalLocationPicker> createState() => _HierarchicalLocationPickerState();
}

class _HierarchicalLocationPickerState extends State<HierarchicalLocationPicker> {
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSector;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.initialProvince;
    _selectedDistrict = widget.initialDistrict;
    _selectedSector = widget.initialSector;
    _loadData();
  }

  Future<void> _loadData() async {
    await adminService.load();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildDropdown(
          label: 'province_label'.tr(),
          value: _selectedProvince,
          items: adminService.provinces,
          onChanged: (val) {
            setState(() {
              _selectedProvince = val;
              _selectedDistrict = null;
              _selectedSector = null;
            });
            widget.onLocationChanged(_selectedProvince, null, null);
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'district_label'.tr(),
          value: _selectedDistrict,
          items: _selectedProvince != null ? adminService.getDistricts(_selectedProvince!) : [],
          enabled: _selectedProvince != null,
          onChanged: (val) {
            setState(() {
              _selectedDistrict = val;
              _selectedSector = null;
            });
            widget.onLocationChanged(_selectedProvince, _selectedDistrict, null);
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'sector_label'.tr(),
          value: _selectedSector,
          items: (_selectedProvince != null && _selectedDistrict != null)
              ? adminService.getSectors(_selectedProvince!, _selectedDistrict!)
              : [],
          enabled: _selectedDistrict != null,
          onChanged: (val) {
            setState(() => _selectedSector = val);
            widget.onLocationChanged(_selectedProvince, _selectedDistrict, _selectedSector);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black.withOpacity(0.87);
    final hintColor = isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.54);
    final fillColor = isDarkMode
        ? const Color(0xFF232529).withOpacity(0.7)
        : Colors.grey[100];
    final disabledFillColor = isDarkMode
        ? const Color(0xFF232529).withOpacity(0.4)
        : Colors.grey[50];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: hintColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDarkMode ? const Color(0xFF232529) : Colors.white,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? fillColor : disabledFillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(
              Icons.location_on_rounded,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
              size: 20,
            ),
          ),
          hint: Text(
            enabled ? 'Select $label' : 'Select previous level first',
            style: TextStyle(color: hintColor),
          ),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
