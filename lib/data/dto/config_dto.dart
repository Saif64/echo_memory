/// Remote Config Data Transfer Objects for Echo Memory
/// Models for server-side configuration

import 'package:equatable/equatable.dart';

/// Remote config DTO
class RemoteConfigDTO extends Equatable {
  final Map<String, String> values;

  const RemoteConfigDTO({required this.values});

  factory RemoteConfigDTO.fromJson(Map<String, dynamic> json) {
    final values = <String, String>{};
    json.forEach((key, value) {
      values[key] = value.toString();
    });
    return RemoteConfigDTO(values: values);
  }

  // Helper getters for common config values
  int get maxLives => int.tryParse(values['max_lives'] ?? '20') ?? 20;
  int get lifeRegenMinutes => int.tryParse(values['life_regen_minutes'] ?? '30') ?? 30;
  int get dailyBonusCoins => int.tryParse(values['daily_bonus_coins'] ?? '50') ?? 50;
  bool get maintenanceMode => values['maintenance_mode'] == 'true';
  String? get maintenanceMessage => values['maintenance_message'];
  String? get forceUpdateVersion => values['force_update_version'];
  bool get adsEnabled => values['ads_enabled'] != 'false';

  /// Get a string value
  String getString(String key, {String defaultValue = ''}) {
    return values[key] ?? defaultValue;
  }

  /// Get an int value
  int getInt(String key, {int defaultValue = 0}) {
    return int.tryParse(values[key] ?? '') ?? defaultValue;
  }

  /// Get a bool value
  bool getBool(String key, {bool defaultValue = false}) {
    final value = values[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Get a double value
  double getDouble(String key, {double defaultValue = 0.0}) {
    return double.tryParse(values[key] ?? '') ?? defaultValue;
  }

  @override
  List<Object?> get props => [values];
}
