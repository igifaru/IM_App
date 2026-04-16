import 'dart:convert';
import 'package:flutter/services.dart';

class AdministrativeService {
  static AdministrativeService? _instance;
  Map<String, dynamic>? _data;
  bool _isLoaded = false;

  AdministrativeService._();
  static AdministrativeService get instance => _instance ??= AdministrativeService._();

  Future<void> load() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/administrative/data.json');
      _data = json.decode(jsonString) as Map<String, dynamic>;
      _isLoaded = true;
    } catch (e) {
      _data = {};
      _isLoaded = true;
    }
  }

  List<String> get provinces {
    if (_data == null) return [];
    return _data!.keys.toList()..sort();
  }

  List<String> getDistricts(String province) {
    if (_data == null || !_data!.containsKey(province)) return [];
    final districts = _data![province] as Map<String, dynamic>;
    return districts.keys.toList()..sort();
  }

  List<String> getSectors(String province, String district) {
    if (_data == null) return [];
    final provinceData = _data![province] as Map<String, dynamic>?;
    if (provinceData == null) return [];
    final districtData = provinceData[district] as Map<String, dynamic>?;
    if (districtData == null) return [];
    return districtData.keys.toList()..sort();
  }
}

final adminService = AdministrativeService.instance;
