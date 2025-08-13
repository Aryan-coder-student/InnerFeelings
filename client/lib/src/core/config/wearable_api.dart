import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '/src/core/models/wearable_data.dart';

class WearableApi {
  final Health health = Health();

  Future<WearableData?> fetchWearableData() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
    ];

    // Request permissions
    bool granted = await health.requestAuthorization(types);
    if (!granted) {
      throw Exception('Health permissions not granted');
    }

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    // Fetch data
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
      startTime: midnight,
      endTime: now,
      types: types,
    );

    double? heartRate;
    double? sleepHours;
    double? oxygenLevel;
    int? steps;

    for (var data in healthData) {
      if (data.value is NumericHealthValue) {
        final value = (data.value as NumericHealthValue).numericValue;
        switch (data.type) {
          case HealthDataType.HEART_RATE:
            heartRate = value.toDouble();
            break;
          case HealthDataType.SLEEP_ASLEEP:
            sleepHours = value.toDouble() / 3600; // Convert seconds to hours
            break;
          case HealthDataType.BLOOD_OXYGEN:
            oxygenLevel = value.toDouble();
            break;
          case HealthDataType.STEPS:
            steps = value.toInt();
            break;
          default:
            break;
        }
      }
    }

    return WearableData(
      heartRate: heartRate,
      sleepHours: sleepHours,
      oxygenLevel: oxygenLevel,
      steps: steps,
      timestamp: now,
    );
  }
}
