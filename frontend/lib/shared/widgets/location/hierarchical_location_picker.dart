import 'package:flutter/material.dart';
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
          label: 'Province',
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
          label: 'District',
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
          label: 'Sector',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.grey[100] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          hint: Text(enabled ? 'Select $label' : 'Select previous level first'),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
