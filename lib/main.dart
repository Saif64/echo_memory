import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:echo_memory/core/utils/responsive_utils.dart';
import 'package:echo_memory/ui/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/improvements/pattern_display.dart';
import 'ui/daily_challenge_screen.dart';
import 'ui/practice_screen.dart';

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
    // Initialize responsive utilities
    ResponsiveUtils.init(context);

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
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? _buildPortraitLayout(context)
                  : _buildLandscapeLayout(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          SizedBox(height: ResponsiveUtils.heightPercent(6)),
          _buildNavigationCards(context),
          SizedBox(height: ResponsiveUtils.heightPercent(2)),
          _buildPrivacyPolicyButton(context),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: Center(child: _buildHeader())),
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveUtils.heightPercent(4)),
                _buildNavigationCards(context),
                SizedBox(height: ResponsiveUtils.heightPercent(2)),
                _buildPrivacyPolicyButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Text(
      'Echo Memory',
      style: TextStyle(
        fontSize: ResponsiveUtils.fontSize(48),
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
    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms);
  }

  Widget _buildNavigationCards(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavigationCard(
          context,
          'Challenge Mode',
          Icons.emoji_events,
          Colors.orange[400]!,
          'Test your skills with timed challenges',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DifficultyScreen()),
          ),
          delay: 600,
        ),
        SizedBox(height: ResponsiveUtils.heightPercent(2)),
        _buildNavigationCard(
          context,
          'Practice Mode',
          Icons.school,
          Colors.green[400]!,
          'Learn at your own pace without time limits',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PracticeGameScreen()),
          ),
          delay: 800,
        ),
        SizedBox(height: ResponsiveUtils.heightPercent(2)),
        _buildNavigationCard(
          context,
          'Daily Challenge',
          Icons.calendar_today,
          Colors.purple[400]!,
          'New challenge every day',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DailyChallengeScreen()),
          ),
          delay: 1000,
        ),
      ],
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
      width: ResponsiveUtils.getMinCardWidth(),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: ResponsiveUtils.padding(vertical: 2, horizontal: 3),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: ResponsiveUtils.fontSize(40),
                  color: Colors.white,
                ),
                SizedBox(height: ResponsiveUtils.heightPercent(1)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.heightPercent(0.8)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(16),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildPrivacyPolicyButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
          );
        },
        child: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(14),
          ),
        ),
      ),
    );
  }
}

// Existing Difficulty Screen with responsive updates
class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Re-initialize responsive utils
    ResponsiveUtils.init(context);

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
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? _buildPortraitLayout(context)
                  : _buildLandscapeLayout(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          SizedBox(height: ResponsiveUtils.heightPercent(4)),
          Text(
            'Select Your Challenge',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(24),
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
          SizedBox(height: ResponsiveUtils.heightPercent(3)),
          _buildDifficultyCards(context),
          SizedBox(height: ResponsiveUtils.heightPercent(3)),
          _buildBackButton(context),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              SizedBox(height: ResponsiveUtils.heightPercent(4)),
              Text(
                'Select Your Challenge',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(24),
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
              SizedBox(height: ResponsiveUtils.heightPercent(4)),
              _buildBackButton(context),
            ],
          ),
        ),
        Expanded(
          flex: 7,
          child: Center(
            child: SingleChildScrollView(child: _buildDifficultyCards(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Text(
      'Echo Memory',
      style: TextStyle(
        fontSize: ResponsiveUtils.fontSize(48),
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
    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms);
  }

  Widget _buildDifficultyCards(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        SizedBox(height: ResponsiveUtils.heightPercent(2)),
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
        SizedBox(height: ResponsiveUtils.heightPercent(2)),
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
      ],
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
      width: ResponsiveUtils.getMinCardWidth(),
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
            padding: ResponsiveUtils.padding(vertical: 2, horizontal: 3),
            child: Column(
              children: [
                Text(
                  difficulty,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.heightPercent(0.8)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(16),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        'Back to Main Menu',
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(18),
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Sound Manager class - unchanged
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

// Game Screen with responsive updates
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
                fontSize: ResponsiveUtils.fontSize(28),
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
                        fontSize: ResponsiveUtils.fontSize(24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.heightPercent(1)),
                    Text(
                      'Best Streak: $bestStreak',
                      style: TextStyle(fontSize: ResponsiveUtils.fontSize(18)),
                    ),
                    Text(
                      'Sequence Length: ${sequence.length}',
                      style: TextStyle(fontSize: ResponsiveUtils.fontSize(18)),
                    ),
                    SizedBox(height: ResponsiveUtils.heightPercent(2)),
                    if (score >= highScore && score > 0)
                      Text(
                        'New High Score! 🎉',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(20),
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
                child: Text(
                  'Main Menu',
                  style: TextStyle(fontSize: ResponsiveUtils.fontSize(16)),
                ),
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
                child: Text(
                  'Try Again',
                  style: TextStyle(fontSize: ResponsiveUtils.fontSize(16)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-initialize responsive utils
    ResponsiveUtils.init(context);

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
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Stack(
                children: [
                  _buildGameHeader(),
                  orientation == Orientation.portrait
                      ? _buildPortraitGameContent()
                      : _buildLandscapeGameContent(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader() {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: ResponsiveUtils.padding(horizontal: 2, vertical: 2),
              child: Container(
                padding: ResponsiveUtils.padding(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  widget.difficulty,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn().slideX(begin: -0.3, end: 0),

            Spacer(),

            Row(
              children: [
                for (int i = 0; i < lives; i++)
                  Icon(
                    Icons.favorite,
                    color: Colors.red[400],
                    size: ResponsiveUtils.fontSize(24),
                  ).animate().fadeIn(delay: (i * 200).ms).scale(),
                SizedBox(width: ResponsiveUtils.widthPercent(2)),
                Container(
                  padding: ResponsiveUtils.padding(horizontal: 2, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Score: $score',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(18),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn().slideX(begin: 0.3, end: 0),

            SizedBox(width: ResponsiveUtils.widthPercent(2)),
          ],
        ),
      ],
    );
  }

  Widget _buildPortraitGameContent() {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.padding(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!showPattern && isTimerRunning)
              Text(
                'Time Left: $_timeLeft',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(32),
                  fontWeight: FontWeight.bold,
                  color: _timeLeft <= 2 ? Colors.red[400] : Colors.white,
                ),
              ).animate().fadeIn().scale(),
            SizedBox(height: ResponsiveUtils.heightPercent(2)),
            if (showPattern) _buildPatternDisplay() else _buildGameStatus(),
            SizedBox(height: ResponsiveUtils.heightPercent(4)),
            _buildColorButtons(),
            if (!showPattern)
              Padding(
                padding: ResponsiveUtils.padding(top: 4),
                child: _buildStreakInfo(),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeGameContent() {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.padding(horizontal: 4, vertical: 2, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!showPattern && isTimerRunning)
                    Text(
                      'Time Left: $_timeLeft',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(28),
                        fontWeight: FontWeight.bold,
                        color: _timeLeft <= 2 ? Colors.red[400] : Colors.white,
                      ),
                    ).animate().fadeIn().scale(),
                  SizedBox(height: ResponsiveUtils.heightPercent(2)),
                  if (showPattern)
                    _buildPatternDisplay()
                  else
                    _buildGameStatus(),
                  SizedBox(height: ResponsiveUtils.heightPercent(2)),
                  if (!showPattern)
                    _buildStreakInfo().animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
            Expanded(flex: 5, child: _buildColorButtons()),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternDisplay() {
    return ImprovedPatternDisplay(
      sequence: sequence,
      title: 'Remember this pattern!',
      animateItems: true,
      autoScroll: sequence.length > 6, // Auto-scroll when pattern gets long
    );
  }

  Widget _buildGameStatus() {
    return Column(
      children: [
        Text(
          'Select color ${currentIndex + 1} of ${sequence.length}',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveUtils.heightPercent(1)),
        Text(
          'Current Streak: $currentStreak',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(18),
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildColorButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            maxWidth:
                ResponsiveUtils.isLandscape
                    ? ResponsiveUtils.widthPercent(50)
                    : ResponsiveUtils.widthPercent(95),
          ),
          child: Wrap(
            spacing: ResponsiveUtils.widthPercent(3),
            runSpacing: ResponsiveUtils.heightPercent(2),
            alignment: WrapAlignment.center,
            children: colors.map((color) => _buildColorButton(color)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStreakInfo() {
    return Column(
      children: [
        Text(
          'Best Streak: $bestStreak',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(18),
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        if (currentStreak > 1)
          Text(
            'Streak Bonus: x${currentStreak ~/ 2}',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(16),
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().scale(),
      ],
    );
  }

  Widget _buildColorBox(Color color, int index) {
    final boxSize =
        ResponsiveUtils.isTablet
            ? ResponsiveUtils.heightPercent(6)
            : ResponsiveUtils.heightPercent(7);

    return Container(
      width: boxSize,
      height: boxSize,
      margin: EdgeInsets.all(ResponsiveUtils.widthPercent(1)),
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
    final buttonSize = ResponsiveUtils.getGameButtonSize();

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
        width: buttonSize,
        height: buttonSize,
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

// Rest of the game screens would be updated similarly...
// Practice Mode and Daily Challenge would follow the same responsive patterns
