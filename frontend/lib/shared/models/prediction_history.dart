import 'dart:convert';

class PredictionHistory {
  final String id;
  final String cropName;
  final String advice;
  final DateTime timestamp;
  final Map<String, dynamic> inputs;

  PredictionHistory({
    required this.id,
    required this.cropName,
    required this.advice,
    required this.timestamp,
    required this.inputs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropName': cropName,
        'advice': advice,
        'timestamp': timestamp.toIso8601String(),
        'inputs': inputs,
      };

  factory PredictionHistory.fromJson(Map<String, dynamic> json) => PredictionHistory(
        id: json['id'],
        cropName: json['cropName'],
        advice: json['advice'],
        timestamp: DateTime.parse(json['timestamp']),
        inputs: json['inputs'] ?? {},
      );

  static String encode(List<PredictionHistory> history) => json.encode(
        history.map<Map<String, dynamic>>((e) => e.toJson()).toList(),
      );

  static List<PredictionHistory> decode(String historyMap) =>
      (json.decode(historyMap) as List<dynamic>)
          .map<PredictionHistory>((item) => PredictionHistory.fromJson(item))
          .toList();
}
