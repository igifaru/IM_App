import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../../../core/location/services/administrative_service.dart';
import '../../../core/error/failures.dart';
import '../../../shared/models/prediction_history.dart';
import '../../../shared/models/smart_consultant_models.dart';

class PredictionProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  static const String _historyKey = 'prediction_history';

  final Map<String, List<String>> cropCategories = {
    'cat_cereals': ['Maize', 'Paddy rice', 'Sorghum', 'Wheat', 'Other cereals'],
    'cat_legumes': ['Bush bean', 'Climbing bean', 'Dry peas', 'Groundnut', 'Soybean'],
    'cat_roots': ['Irish potato', 'Sweet potato', 'Cocoyam (Taro)', 'Yams', 'Cassava'],
    'cat_banana': ['Banana (Cooking)', 'Banana (Dessert)', 'Banana (Beer)'],
    'cat_other': ['Vegetables', 'Fruits', 'Other crops'],
  };

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, List<String>> _metadata = {};
  Map<String, List<String>> get metadata => _metadata;

  String? _recommendedCrop;
  String? get recommendedCrop => _recommendedCrop;

  double _confidenceScore = 0.0;
  double get confidenceScore => _confidenceScore;

  bool _lowConfidence = false;
  bool get lowConfidence => _lowConfidence;

  String? _confidenceDisclaimer;
  String? get confidenceDisclaimer => _confidenceDisclaimer;

  String? _advice;
  String? get advice => _advice;

  // Smart Consultant fields
  FarmerChoice? _farmerChoice;
  FarmerChoice? get farmerChoice => _farmerChoice;

  List<CropRecommendation> _topRecommendations = [];
  List<CropRecommendation> get topRecommendations => _topRecommendations;

  AIInterpretation? _aiInterpretation;
  AIInterpretation? get aiInterpretation => _aiInterpretation;

  Failure? _error;
  Failure? get error => _error;

  String? _errorReferenceId;
  String? get errorReferenceId => _errorReferenceId;

  List<PredictionHistory> _history = [];
  List<PredictionHistory> get history => _history;

  // Form Fields
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSector;
  String? selectedSeason;
  String? selectedSlope;
  String? selectedSeeds;
  String? selectedCrop;  // New field for crop selection
  bool inorganicFert = false;
  bool organicFert = false;
  bool usedLime = false;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  static const String _themeKey = 'theme_mode';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedTheme = prefs.getString(_themeKey);
    if (storedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == storedTheme,
        orElse: () => ThemeMode.system,
      );
    }
    
    await adminService.load();
    await fetchMetadata();
    await loadHistory();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode.toString());
    notifyListeners();
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
        'crops': List<String>.from(data['crops']),  // Add crops from backend
      };
      
      // Set defaults if available
      if (_metadata['provinces']!.isNotEmpty) selectedProvince = _metadata['provinces']![0];
      if (_metadata['districts']!.isNotEmpty) selectedDistrict = _metadata['districts']![0];
      if (_metadata['seasons']!.isNotEmpty) selectedSeason = _metadata['seasons']![0];
      if (_metadata['slopes']!.isNotEmpty) selectedSlope = _metadata['slopes']![0];
      if (_metadata['seeds']!.isNotEmpty) selectedSeeds = _metadata['seeds']![0];
      // Don't set default for crop - let user choose

    } on RateLimitException catch (e) {
      _error = ServerFailure('rate_limit_exceeded');
      _errorReferenceId = _generateErrorReference();
    } on AuthenticationException catch (e) {
      _error = ServerFailure('authentication_failed');
      _errorReferenceId = _generateErrorReference();
    } on TimeoutException catch (e) {
      _error = ServerFailure('request_timeout');
      _errorReferenceId = _generateErrorReference();
    } on NetworkException catch (e) {
      _error = ServerFailure('network_error');
      _errorReferenceId = _generateErrorReference();
    } catch (e) {
      _error = ServerFailure(e.toString());
      _errorReferenceId = _generateErrorReference();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPrediction(String lang) async {
    if (selectedProvince == null || selectedDistrict == null || selectedSeason == null || 
        selectedSlope == null || selectedSeeds == null || selectedCrop == null) {
      _error = InputFailure("fill_all_fields");
      _errorReferenceId = _generateErrorReference();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _errorReferenceId = null;
    _recommendedCrop = null;
    _confidenceScore = 0.0;
    _lowConfidence = false;
    _confidenceDisclaimer = null;
    _farmerChoice = null;
    _topRecommendations = [];
    _aiInterpretation = null;
    notifyListeners();

    try {
      final predictionData = {
        'province': selectedProvince,
        'district': selectedDistrict,
        'season': selectedSeason,
        'slope': selectedSlope,
        'seeds': selectedSeeds,
        'crop': selectedCrop,
        'inorganic_fert': inorganicFert ? 1 : 0,
        'organic_fert': organicFert ? 1 : 0,
        'used_lime': usedLime ? 1 : 0,
      };

      // Use smart consultant endpoint
      final response = await _apiClient.smartConsultantPredict(predictionData, lang);
      
      // Parse farmer's choice
      _farmerChoice = FarmerChoice.fromJson(response['farmer_choice']);
      
      // Parse top recommendations
      _topRecommendations = (response['top_recommendations'] as List)
          .map((r) => CropRecommendation.fromJson(r))
          .toList();
      
      // Parse AI interpretation
      _aiInterpretation = AIInterpretation.fromJson(response['ai_interpretation']);
      
      // For backward compatibility, set the old fields
      _recommendedCrop = _topRecommendations.isNotEmpty ? _topRecommendations[0].crop : _farmerChoice?.crop;
      _confidenceScore = _farmerChoice?.confidenceScore ?? 0.0;
      _lowConfidence = _farmerChoice?.status == 'poor';
      _advice = _aiInterpretation?.text ?? '';

      final history = PredictionHistory(
        id: const Uuid().v4(),
        cropName: _farmerChoice?.crop ?? 'Unknown',
        advice: _aiInterpretation?.text ?? '',
        timestamp: DateTime.now(),
        inputs: predictionData,
      );
      
      _history.insert(0, history);
      await saveHistory();
      _isLoading = false;
      notifyListeners();
    } on RateLimitException catch (e) {
      _error = ServerFailure('rate_limit_exceeded');
      _errorReferenceId = _generateErrorReference();
      _isLoading = false;
      notifyListeners();
    } on AuthenticationException catch (e) {
      _error = ServerFailure('authentication_failed');
      _errorReferenceId = _generateErrorReference();
      _isLoading = false;
      notifyListeners();
    } on ValidationException catch (e) {
      _error = InputFailure(e.message);
      _errorReferenceId = _generateErrorReference();
      _isLoading = false;
      notifyListeners();
    } on TimeoutException catch (e) {
      _error = ServerFailure('request_timeout');
      _errorReferenceId = _generateErrorReference();
      _isLoading = false;
      notifyListeners();
    } on NetworkException catch (e) {
      _error = ServerFailure('network_error');
      _errorReferenceId = _generateErrorReference();
      _isLoading = false;
      notifyListeners();
    } on ServerException catch (e) {
      _error = ServerFailure(e.message);
      _errorReferenceId = _generateErrorReference();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = ServerFailure(e.toString());
      _errorReferenceId = _generateErrorReference();
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateErrorReference() {
    return 'ERR-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}';
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
    _confidenceScore = 0.0;
    _lowConfidence = false;
    _confidenceDisclaimer = null;
    _advice = null;
    _farmerChoice = null;
    _topRecommendations = [];
    _aiInterpretation = null;
    _error = null;
    _errorReferenceId = null;
    notifyListeners();
  }
}
