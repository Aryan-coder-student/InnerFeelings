class WearableData {
  final double? heartRate;
  final double? sleepHours;
  final double? oxygenLevel;
  final int? steps;
  final DateTime timestamp;

  WearableData({
    this.heartRate,
    this.sleepHours,
    this.oxygenLevel,
    this.steps,
    required this.timestamp,
  });

  factory WearableData.fromJson(Map<String, dynamic> json) {
    return WearableData(
      heartRate: (json['heart_rate'] as num?)?.toDouble(),
      sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
      oxygenLevel: (json['oxygen_level'] as num?)?.toDouble(),
      steps: json['steps'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
