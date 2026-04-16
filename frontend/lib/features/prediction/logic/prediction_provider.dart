import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/location/services/administrative_service.dart';
import '../../../core/error/failures.dart';
import '../../../shared/models/prediction_history.dart';

class PredictionProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  static const String _historyKey = 'prediction_history';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, List<String>> _metadata = {};
  Map<String, List<String>> get metadata => _metadata;

  String? _recommendedCrop;
  String? get recommendedCrop => _recommendedCrop;

  String? _advice;
  String? get advice => _advice;

  Failure? _error;
  Failure? get error => _error;

  List<PredictionHistory> _history = [];
  List<PredictionHistory> get history => _history;

  // Form Fields
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSector;
  String? selectedSeason;
  String? selectedSlope;
  String? selectedSeeds;
  bool inorganicFert = false;
  bool organicFert = false;
  bool usedLime = false;

  Future<void> init() async {
    await adminService.load();
    await fetchMetadata();
    await loadHistory();
  }

  Future<void> fetchMetadata() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiClient.getMetadata();
      _metadata = {
        'provinces': List<String>.from(data['provinces']),
        'districts': List<String>.from(data['districts']),
        'seasons': List<String>.from(data['seasons']),
        'slopes': List<String>.from(data['slopes']),
        'seeds': List<String>.from(data['seeds']),
      };
      
      // Set defaults if available
      if (_metadata['provinces']!.isNotEmpty) selectedProvince = _metadata['provinces']![0];
      if (_metadata['districts']!.isNotEmpty) selectedDistrict = _metadata['districts']![0];
      if (_metadata['seasons']!.isNotEmpty) selectedSeason = _metadata['seasons']![0];
      if (_metadata['slopes']!.isNotEmpty) selectedSlope = _metadata['slopes']![0];
      if (_metadata['seeds']!.isNotEmpty) selectedSeeds = _metadata['seeds']![0];

    } catch (e) {
      _error = ServerFailure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPrediction(String lang) async {
    if (selectedProvince == null || selectedDistrict == null || selectedSeason == null || 
        selectedSlope == null || selectedSeeds == null) {
      _error = InputFailure("fill_all_fields");
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _recommendedCrop = null;
    notifyListeners();

    try {
      final predictionData = {
        'province': selectedProvince,
        'district': selectedDistrict,
        'season': selectedSeason,
        'slope': selectedSlope,
        'seeds': selectedSeeds,
        'inorganic_fert': inorganicFert ? 1 : 0,
        'organic_fert': organicFert ? 1 : 0,
        'used_lime': usedLime ? 1 : 0,
      };

      final response = await _apiClient.predict(predictionData, lang);
      _recommendedCrop = response['prediction'];
      _advice = response['advice'] ?? response['prediction'];

      final history = PredictionHistory(
        id: const Uuid().v4(),
        cropName: _recommendedCrop ?? 'Unknown',
        advice: _advice ?? '',
        timestamp: DateTime.now(),
        inputs: predictionData,
      );
      
      _history.insert(0, history);
      await saveHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = ServerFailure(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString(_historyKey);
    if (historyString != null) {
      _history = PredictionHistory.decode(historyString);
      notifyListeners();
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = PredictionHistory.encode(_history);
    await prefs.setString(_historyKey, encodedData);
  }

  Future<void> deleteHistoryItem(String id) async {
    _history.removeWhere((item) => item.id == id);
    await saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await saveHistory();
    notifyListeners();
  }

  void reset() {
    _recommendedCrop = null;
    _advice = null;
    _error = null;
    notifyListeners();
  }
}
