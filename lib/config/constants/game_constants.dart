/// Game constants and configuration for Echo Memory
/// Centralized settings for timings, points, and difficulty
class GameConstants {
  GameConstants._();

  // Game Timing (in seconds)
  static const int patternDisplayDelay = 2;
  static const int orbFlashDuration = 500; // milliseconds
  static const int levelCompleteCelebration = 1500; // milliseconds

  // Difficulty Settings
  static const Map<String, DifficultySettings> difficulties = {
    'beginner': DifficultySettings(
      name: 'Beginner',
      description: 'Perfect for learning',
      initialSequence: 3,
      timeLimit: 12,
      pointMultiplier: 1,
      lives: 3,
      patternSpeed: 1.0,
    ),
    'expert': DifficultySettings(
      name: 'Expert',
      description: 'For experienced players',
      initialSequence: 4,
      timeLimit: 8,
      pointMultiplier: 2,
      lives: 2,
      patternSpeed: 0.8,
    ),
    'master': DifficultySettings(
      name: 'Master',
      description: 'Ultimate challenge',
      initialSequence: 5,
      timeLimit: 5,
      pointMultiplier: 3,
      lives: 1,
      patternSpeed: 0.6,
    ),
  };

  // New Game Modes
  static const Map<String, GameModeSettings> gameModes = {
    'challenge': GameModeSettings(
      name: 'Challenge Mode',
      description: 'Test your skills with timed challenges',
      icon: 'emoji_events',
      hasTimer: true,
      hasLives: true,
    ),
    'practice': GameModeSettings(
      name: 'Practice Mode',
      description: 'Learn at your own pace',
      icon: 'school',
      hasTimer: false,
      hasLives: false,
    ),
    'daily': GameModeSettings(
      name: 'Daily Challenge',
      description: 'New challenge every day',
      icon: 'calendar_today',
      hasTimer: true,
      hasLives: true,
    ),
    'speedBlitz': GameModeSettings(
      name: 'Speed Blitz',
      description: 'Ultra-fast patterns!',
      icon: 'flash_on',
      hasTimer: true,
      hasLives: true,
    ),
    'zen': GameModeSettings(
      name: 'Zen Mode',
      description: 'Relaxing infinite play',
      icon: 'self_improvement',
      hasTimer: false,
      hasLives: false,
    ),
  };

  // Scoring
  static const int basePointsPerColor = 10;
  static const int perfectSequenceBonus = 50;

  // Combo Thresholds
  static const int comboGoodThreshold = 3;
  static const int comboAmazingThreshold = 5;
  static const int comboFireThreshold = 7;
  static const int comboLegendaryThreshold = 10;

  // Combo Multipliers
  static const double comboGoodMultiplier = 1.5;
  static const double comboAmazingMultiplier = 2.0;
  static const double comboFireMultiplier = 3.0;
  static const double comboLegendaryMultiplier = 5.0;

  // Power-up Durations (in seconds)
  static const int slowMoDuration = 10;
  static const int timeFreezeDuration = 5;
  static const int doublePointsDuration = 15;

  // Power-up Costs (in points)
  static const int slowMoCost = 100;
  static const int hintCost = 150;
  static const int shieldCost = 200;
  static const int freezeCost = 250;
  static const int doublePointsCost = 300;

  // Animation Durations (in milliseconds)
  static const int buttonPressAnimation = 150;
  static const int rippleAnimation = 400;
  static const int scorePopAnimation = 600;
  static const int comboTextAnimation = 800;
  static const int celebrationAnimation = 2000;
  static const int screenShakeAnimation = 300;

  // UI Sizes
  static const double minOrbSize = 60.0;
  static const double maxOrbSize = 100.0;
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 16.0;
}

/// Settings for each difficulty level
class DifficultySettings {
  final String name;
  final String description;
  final int initialSequence;
  final int timeLimit;
  final int pointMultiplier;
  final int lives;
  final double patternSpeed;

  const DifficultySettings({
    required this.name,
    required this.description,
    required this.initialSequence,
    required this.timeLimit,
    required this.pointMultiplier,
    required this.lives,
    required this.patternSpeed,
  });
}

/// Settings for each game mode
class GameModeSettings {
  final String name;
  final String description;
  final String icon;
  final bool hasTimer;
  final bool hasLives;

  const GameModeSettings({
    required this.name,
    required this.description,
    required this.icon,
    required this.hasTimer,
    required this.hasLives,
  });
}
