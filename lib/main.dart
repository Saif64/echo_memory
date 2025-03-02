import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart'; // For sound effects
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart'; // For storing daily challenge data

void main() {
  runApp(const EchoMemoryApp());
}

class EchoMemoryApp extends StatelessWidget {
  const EchoMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Echo Memory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// New Home Screen that provides navigation to different game modes
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[400]!, Colors.purple[400]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Echo Memory',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(5.0, 5.0),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                SizedBox(height: 60),
                _buildNavigationCard(
                  context,
                  'Challenge Mode',
                  Icons.emoji_events,
                  Colors.orange[400]!,
                  'Test your skills with timed challenges',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DifficultyScreen(),
                    ),
                  ),
                  delay: 600,
                ),
                SizedBox(height: 20),
                _buildNavigationCard(
                  context,
                  'Practice Mode',
                  Icons.school,
                  Colors.green[400]!,
                  'Learn at your own pace without time limits',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PracticeGameScreen(),
                    ),
                  ),
                  delay: 800,
                ),
                SizedBox(height: 20),
                _buildNavigationCard(
                  context,
                  'Daily Challenge',
                  Icons.calendar_today,
                  Colors.purple[400]!,
                  'New challenge every day',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyChallengeScreen(),
                    ),
                  ),
                  delay: 1000,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap, {
    required int delay,
  }) {
    return Container(
      width: 280,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.3, end: 0);
  }
}

// Existing Difficulty Screen - unchanged
class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[400]!, Colors.purple[400]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Echo Memory',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(5.0, 5.0),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                SizedBox(height: 60),
                Text(
                  'Select Your Challenge',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
                SizedBox(height: 40),
                _buildDifficultyCard(
                  context,
                  'Beginner',
                  Colors.green[400]!,
                  'Perfect for learning',
                  {
                    'initialSequence': 3,
                    'timeLimit': 10,
                    'pointMultiplier': 1,
                    'lives': 3,
                  },
                  delay: 600,
                ),
                SizedBox(height: 20),
                _buildDifficultyCard(
                  context,
                  'Expert',
                  Colors.orange[400]!,
                  'For experienced players',
                  {
                    'initialSequence': 4,
                    'timeLimit': 6,
                    'pointMultiplier': 2,
                    'lives': 2,
                  },
                  delay: 800,
                ),
                SizedBox(height: 20),
                _buildDifficultyCard(
                  context,
                  'Master',
                  Colors.red[400]!,
                  'Ultimate challenge',
                  {
                    'initialSequence': 5,
                    'timeLimit': 5,
                    'pointMultiplier': 3,
                    'lives': 1,
                  },
                  delay: 1000,
                ),
                SizedBox(height: 40),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back to Main Menu',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    String difficulty,
    Color color,
    String description,
    Map<String, int> settings, {
    required int delay,
  }) {
    return Container(
      width: 280,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        GameScreen(difficulty: difficulty, settings: settings),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              children: [
                Text(
                  difficulty,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.3, end: 0);
  }
}

// Sound Manager class to handle all sound effects
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _colorSounds = [
    'color_red.mp3',
    'color_green.mp3',
    'color_blue.mp3',
    'color_yellow.mp3',
    'color_black.mp3',
  ];

  bool _enabled = true;

  void toggleSound(bool enabled) {
    _enabled = enabled;
  }

  Future<void> playColorSound(int colorIndex) async {
    if (!_enabled) return;
    // In a real app, these would be actual sound files
    // Using different pitches for demonstration
    await _audioPlayer.play(AssetSource(_colorSounds[colorIndex]));
  }

  Future<void> playCorrectSound() async {
    if (!_enabled) return;
    await _audioPlayer.play(AssetSource('correct.mp3'));
  }

  Future<void> playWrongSound() async {
    if (!_enabled) return;
    await _audioPlayer.play(AssetSource('wrong.mp3'));
  }

  Future<void> playVictorySound() async {
    if (!_enabled) return;
    await _audioPlayer.play(AssetSource('victory.mp3'));
  }

  Future<void> playGameOverSound() async {
    if (!_enabled) return;
    await _audioPlayer.play(AssetSource('game_over.mp3'));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

// Original GameScreen - unchanged except for adding sound effects and haptic feedback
class GameScreen extends StatefulWidget {
  final String difficulty;
  final Map<String, int> settings;

  const GameScreen({
    super.key,
    required this.difficulty,
    required this.settings,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.black,
  ];
  List<Color> sequence = [];
  int currentIndex = 0;
  bool showPattern = true;
  Random random = Random();
  int score = 0;
  late Timer _timer;
  int _timeLeft = 0;
  bool isTimerRunning = false;
  int lives = 0;
  int highScore = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    lives = widget.settings['lives']!;
    _generateSequence();
  }

  @override
  void dispose() {
    if (isTimerRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _generateSequence() {
    setState(() {
      sequence = List.generate(
        widget.settings['initialSequence']!,
        (_) => colors[random.nextInt(colors.length)],
      );
      showPattern = true;
    });
    _startPatternDisplay();
  }

  void _startPatternDisplay() {
    Timer(const Duration(seconds: 2), () {
      setState(() {
        showPattern = false;
        _startTimer();
      });
    });
  }

  void _startTimer() {
    setState(() {
      _timeLeft = widget.settings['timeLimit']!;
      isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _loseLife();
          timer.cancel();
          isTimerRunning = false;
        }
      });
    });
  }

  void _checkSelection(Color color) {
    if (!showPattern) {
      if (sequence[currentIndex] == color) {
        // Play correct sound and light haptic feedback
        _soundManager.playCorrectSound();
        HapticFeedback.lightImpact();

        setState(() {
          currentIndex++;
          currentStreak++;
          if (currentStreak > bestStreak) {
            bestStreak = currentStreak;
          }
          score +=
              (10 *
                  widget.settings['pointMultiplier']! *
                  (currentStreak > 1 ? currentStreak ~/ 2 : 1));

          if (currentIndex == sequence.length) {
            if (isTimerRunning) {
              _timer.cancel();
              isTimerRunning = false;
            }
            _nextLevel();
          }
        });
      } else {
        // Play wrong sound and heavy haptic feedback
        _soundManager.playWrongSound();
        HapticFeedback.heavyImpact();

        _loseLife();
      }
    }
  }

  void _loseLife() {
    setState(() {
      lives--;
      currentStreak = 0;
      if (lives <= 0) {
        _soundManager.playGameOverSound();
        _gameOver();
      } else {
        if (isTimerRunning) {
          _timer.cancel();
          isTimerRunning = false;
        }
        currentIndex = 0;
        showPattern = true;
        _startPatternDisplay();
      }
    });
  }

  void _nextLevel() {
    // Play victory sound for completing a level
    _soundManager.playVictorySound();

    setState(() {
      sequence.add(colors[random.nextInt(colors.length)]);
      currentIndex = 0;
      showPattern = true;
    });
    _startPatternDisplay();
  }

  void _gameOver() {
    if (isTimerRunning) {
      _timer.cancel();
      isTimerRunning = false;
    }

    if (score > highScore) {
      highScore = score;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Game Over!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            content:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Final Score: $score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Best Streak: $bestStreak',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Sequence Length: ${sequence.length}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    if (score >= highScore && score > 0)
                      Text(
                        'New High Score! 🎉',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[400],
                        ),
                      ),
                  ],
                ).animate().fadeIn().scale(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: Text('Main Menu'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    currentIndex = 0;
                    score = 0;
                    lives = widget.settings['lives']!;
                    currentStreak = 0;
                    _generateSequence();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[300]!, Colors.purple[300]!],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    widget.difficulty,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ).animate().fadeIn().slideX(begin: -0.3, end: 0),
              ),
              Positioned(
                right: 20,
                top: 20,
                child: Row(
                  children: [
                    for (int i = 0; i < lives; i++)
                      Icon(
                        Icons.favorite,
                        color: Colors.red[400],
                        size: 24,
                      ).animate().fadeIn(delay: (i * 200).ms).scale(),
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: 0.3, end: 0),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!showPattern && isTimerRunning)
                    Text(
                      'Time Left: $_timeLeft',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft <= 2 ? Colors.red[400] : Colors.white,
                      ),
                    ).animate().fadeIn().scale(),
                  SizedBox(height: 20),
                  if (showPattern)
                    Column(
                      children: [
                        Text(
                          'Remember this pattern!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn().scale(),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              sequence.asMap().entries.map((entry) {
                                return _buildColorBox(entry.value, entry.key);
                              }).toList(),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          'Select color ${currentIndex + 1} of ${sequence.length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Current Streak: $currentStreak',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ).animate().fadeIn().scale(),
                  SizedBox(height: 40),
                  Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children:
                            colors
                                .map((color) => _buildColorButton(color))
                                .toList(),
                      ),
                    ),
                  ),
                  if (!showPattern)
                    Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Text(
                                'Best Streak: $bestStreak',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              if (currentStreak > 1)
                                Text(
                                  'Streak Bonus: x${currentStreak ~/ 2}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).animate().fadeIn().scale(),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox(Color color, int index) {
    return Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
        ],
      ),
    ).animate().fadeIn(delay: (index * 200).ms).scale(delay: (index * 200).ms);
  }

  Widget _buildColorButton(Color color) {
    // Find the index of the color to play the corresponding sound
    int colorIndex = colors.indexOf(color);

    return GestureDetector(
      onTap:
          showPattern
              ? null
              : () {
                _soundManager.playColorSound(colorIndex);
                _checkSelection(color);
              },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(width: 3, color: Colors.white.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: false)),
    ).animate().fadeIn().scale();
  }
}

// New Practice Mode Screen
class PracticeGameScreen extends StatefulWidget {
  @override
  _PracticeGameScreenState createState() => _PracticeGameScreenState();
}

class _PracticeGameScreenState extends State<PracticeGameScreen> {
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.black,
  ];
  List<Color> sequence = [];
  int currentIndex = 0;
  bool showPattern = true;
  bool revealPattern = false; // For showing pattern on demand
  Random random = Random();
  int sequenceLength = 3; // Starting sequence length
  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    _generateSequence();
  }

  void _generateSequence() {
    setState(() {
      sequence = List.generate(
        sequenceLength,
        (_) => colors[random.nextInt(colors.length)],
      );
      showPattern = true;
    });
    _startPatternDisplay();
  }

  void _startPatternDisplay() {
    Timer(const Duration(seconds: 3), () {
      setState(() {
        showPattern = false;
      });
    });
  }

  void _checkSelection(Color color) {
    if (!showPattern && !revealPattern) {
      if (sequence[currentIndex] == color) {
        // Play correct sound and light haptic feedback
        _soundManager.playCorrectSound();
        HapticFeedback.lightImpact();

        setState(() {
          currentIndex++;

          if (currentIndex == sequence.length) {
            _nextLevel();
          }
        });
      } else {
        // Play wrong sound and heavy haptic feedback
        _soundManager.playWrongSound();
        HapticFeedback.heavyImpact();

        _resetLevel();
      }
    }
  }

  void _resetLevel() {
    setState(() {
      currentIndex = 0;
      showPattern = true;
    });
    _startPatternDisplay();
  }

  void _nextLevel() {
    // Play victory sound for completing a level
    _soundManager.playVictorySound();

    setState(() {
      sequenceLength++;
      sequence = List.generate(
        sequenceLength,
        (_) => colors[random.nextInt(colors.length)],
      );
      currentIndex = 0;
      showPattern = true;
    });
    _startPatternDisplay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green[300]!, Colors.teal[300]!],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                left: 20,
                top: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Mode indicator
              Positioned(
                right: 20,
                top: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Practice Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showPattern || revealPattern)
                    Column(
                      children: [
                        Text(
                          showPattern
                              ? 'Remember this pattern!'
                              : 'Pattern Revealed',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn().scale(),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              sequence.asMap().entries.map((entry) {
                                return _buildColorBox(entry.value, entry.key);
                              }).toList(),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          'Select color ${currentIndex + 1} of ${sequence.length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sequence Length: $sequenceLength',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ).animate().fadeIn().scale(),
                  SizedBox(height: 40),
                  Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children:
                            colors
                                .map((color) => _buildColorButton(color))
                                .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Reveal Pattern Button
                  if (!showPattern)
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          revealPattern = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          revealPattern = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          revealPattern = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Hold to See Pattern',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn().scale(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox(Color color, int index) {
    return Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
        ],
      ),
    ).animate().fadeIn(delay: (index * 200).ms).scale(delay: (index * 200).ms);
  }

  Widget _buildColorButton(Color color) {
    // Find the index of the color to play the corresponding sound
    int colorIndex = colors.indexOf(color);

    return GestureDetector(
      onTap:
          (showPattern || revealPattern)
              ? null
              : () {
                _soundManager.playColorSound(colorIndex);
                _checkSelection(color);
              },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(width: 3, color: Colors.white.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }
}

// Daily Challenge Screen
class DailyChallengeScreen extends StatefulWidget {
  @override
  _DailyChallengeScreenState createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
  ];
  List<Color> sequence = [];
  int currentIndex = 0;
  bool showPattern = true;
  Random random = Random();
  int score = 0;
  bool hasPlayedToday = false;
  String todayDateStr = '';
  int highScore = 0;
  bool gameActive = false;
  bool gameOver = false;
  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    _loadDailyChallenge();
  }

  Future<void> _loadDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    todayDateStr = DateFormat('yyyy-MM-dd').format(today);

    final lastPlayedDate = prefs.getString('lastPlayedDate') ?? '';
    hasPlayedToday = lastPlayedDate == todayDateStr;
    highScore = prefs.getInt('dailyChallengeHighScore') ?? 0;

    // Generate a deterministic sequence based on today's date
    final seed = todayDateStr.hashCode;
    random = Random(seed);

    setState(() {
      // If not played today, allow to play
      if (!hasPlayedToday) {
        _startGame();
      }
    });
  }

  void _startGame() {
    setState(() {
      gameActive = true;
      gameOver = false;
      score = 0;
      _generateSequence();
    });
  }

  void _generateSequence() {
    setState(() {
      // Start with 3 colors and increase as score grows
      int length = 3 + (score ~/ 30);
      sequence = List.generate(
        length,
        (_) => colors[random.nextInt(colors.length)],
      );
      showPattern = true;
      currentIndex = 0;
    });
    _startPatternDisplay();
  }

  void _startPatternDisplay() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showPattern = false;
        });
      }
    });
  }

  void _checkSelection(Color color) {
    if (!showPattern && gameActive) {
      if (sequence[currentIndex] == color) {
        // Play correct sound and light haptic feedback
        _soundManager.playCorrectSound();
        HapticFeedback.lightImpact();

        setState(() {
          currentIndex++;

          if (currentIndex == sequence.length) {
            score += sequence.length * 10;
            _nextLevel();
          }
        });
      } else {
        // Play wrong sound and heavy haptic feedback
        _soundManager.playWrongSound();
        HapticFeedback.heavyImpact();

        _endGame();
      }
    }
  }

  void _nextLevel() {
    // Play victory sound for completing a level
    _soundManager.playVictorySound();

    _generateSequence();
  }

  Future<void> _endGame() async {
    _soundManager.playGameOverSound();

    setState(() {
      gameActive = false;
      gameOver = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPlayedDate', todayDateStr);

    if (score > highScore) {
      highScore = score;
      await prefs.setInt('dailyChallengeHighScore', highScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple[300]!, Colors.indigo[400]!],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                left: 20,
                top: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Daily indicator
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        todayDateStr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child:
                    hasPlayedToday && !gameActive
                        ? _buildAlreadyPlayedMessage()
                        : gameOver
                        ? _buildGameOverMessage()
                        : _buildGameContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyPlayedMessage() {
    return Container(
      padding: EdgeInsets.all(30),
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 70, color: Colors.amber),
          SizedBox(height: 20),
          Text(
            'Daily Challenge Complete',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            'You\'ve already completed today\'s challenge with a score of $highScore.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Come back tomorrow for a new challenge!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text('Back to Menu', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildGameOverMessage() {
    return Container(
      padding: EdgeInsets.all(30),
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 70, color: Colors.amber),
          SizedBox(height: 20),
          Text(
            'Daily Challenge Complete',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            'Final Score: $score',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          if (score >= highScore && score > 0)
            Text(
              'New High Score! 🎉',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[400],
              ),
            ),
          SizedBox(height: 20),
          Text(
            'Come back tomorrow for a new challenge!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text('Back to Menu', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildGameContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (gameActive)
          Text(
            'Score: $score',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        SizedBox(height: 20),
        if (showPattern && gameActive)
          Column(
            children: [
              Text(
                'Remember this pattern!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn().scale(),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    sequence.asMap().entries.map((entry) {
                      return _buildColorBox(entry.value, entry.key);
                    }).toList(),
              ),
            ],
          )
        else if (gameActive)
          Column(
            children: [
              Text(
                'Select color ${currentIndex + 1} of ${sequence.length}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Sequence Length: ${sequence.length}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ).animate().fadeIn().scale()
        else
          Column(
            children: [
              Text(
                'Daily Challenge',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Test your memory with a unique challenge each day',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'Today\'s High Score',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '$highScore',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text('Start Challenge', style: TextStyle(fontSize: 20)),
              ),
            ],
          ).animate().fadeIn().scale(),
        SizedBox(height: 40),
        if (gameActive && !showPattern)
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children:
                    colors.map((color) => _buildColorButton(color)).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColorBox(Color color, int index) {
    return Container(
      width: 50,
      height: 50,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
        ],
      ),
    ).animate().fadeIn(delay: (index * 200).ms).scale(delay: (index * 200).ms);
  }

  Widget _buildColorButton(Color color) {
    // Find the index of the color to play the corresponding sound
    int colorIndex = colors.indexOf(color);

    return GestureDetector(
      onTap:
          showPattern
              ? null
              : () {
                _soundManager.playColorSound(colorIndex);
                _checkSelection(color);
              },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(width: 3, color: Colors.white.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }
}
