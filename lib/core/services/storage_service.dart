/// Storage service for Echo Memory
/// Handles all persistent data storage
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants/asset_paths.dart';
import '../../data/models/player_stats.dart';
import '../../data/models/power_up.dart';
import '../../data/models/achievement.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ============ High Scores ============

  Future<int> getHighScore() async {
    return _preferences.getInt(AssetPaths.keyHighScore) ?? 0;
  }

  Future<void> setHighScore(int score) async {
    await _preferences.setInt(AssetPaths.keyHighScore, score);
  }

  Future<int> getBestStreak() async {
    return _preferences.getInt(AssetPaths.keyBestStreak) ?? 0;
  }

  Future<void> setBestStreak(int streak) async {
    await _preferences.setInt(AssetPaths.keyBestStreak, streak);
  }

  // ============ Player Stats ============

  Future<PlayerStats> getPlayerStats() async {
    final json = _preferences.getString(AssetPaths.keyPlayerStats);
    if (json == null) return const PlayerStats();
    return PlayerStats.decode(json);
  }

  Future<void> setPlayerStats(PlayerStats stats) async {
    await _preferences.setString(AssetPaths.keyPlayerStats, stats.encode());
  }

  // ============ Power-Ups ============

  Future<PowerUpInventory> getPowerUps() async {
    final json = _preferences.getString(AssetPaths.keyPowerUps);
    if (json == null) return const PowerUpInventory();
    return PowerUpInventory.decode(json);
  }

  Future<void> setPowerUps(PowerUpInventory inventory) async {
    await _preferences.setString(AssetPaths.keyPowerUps, inventory.encode());
  }

  // ============ Achievements ============

  Future<AchievementProgress> getAchievements() async {
    final json = _preferences.getString(AssetPaths.keyAchievements);
    if (json == null) return const AchievementProgress();
    return AchievementProgress.decode(json);
  }

  Future<void> setAchievements(AchievementProgress progress) async {
    await _preferences.setString(AssetPaths.keyAchievements, progress.encode());
  }

  // ============ Daily Challenge ============

  Future<Map<String, dynamic>?> getDailyChallenge() async {
    final json = _preferences.getString(AssetPaths.keyDailyChallenge);
    if (json == null) return null;
    return jsonDecode(json);
  }

  Future<void> setDailyChallenge(Map<String, dynamic> data) async {
    await _preferences.setString(
      AssetPaths.keyDailyChallenge,
      jsonEncode(data),
    );
  }

  // ============ Settings ============

  Future<String> getSelectedTheme() async {
    return _preferences.getString(AssetPaths.keySelectedTheme) ?? 'aurora';
  }

  Future<void> setSelectedTheme(String theme) async {
    await _preferences.setString(AssetPaths.keySelectedTheme, theme);
  }

  Future<bool> getSoundEnabled() async {
    return _preferences.getBool(AssetPaths.keySoundEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _preferences.setBool(AssetPaths.keySoundEnabled, enabled);
  }

  Future<bool> getHapticEnabled() async {
    return _preferences.getBool(AssetPaths.keyHapticEnabled) ?? true;
  }

  Future<void> setHapticEnabled(bool enabled) async {
    await _preferences.setBool(AssetPaths.keyHapticEnabled, enabled);
  }

  // ============ Utility ============

  /// Clear all stored data (for debugging/reset)
  Future<void> clearAll() async {
    await _preferences.clear();
  }

  /// Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    final hasPlayed = _preferences.containsKey(AssetPaths.keyPlayerStats);
    return !hasPlayed;
  }
}
