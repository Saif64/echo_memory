import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the SoundManager (assume it's moved to a separate file)
import '../core/improvements/pattern_display.dart';
import '../core/utils/responsive_utils.dart';
import '../main.dart';

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
    // Initialize responsive utils
    ResponsiveUtils.init(context);

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
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Stack(
                children: [
                  _buildBackButton(),
                  _buildDateIndicator(),
                  orientation == Orientation.portrait
                      ? _buildPortraitContent()
                      : _buildLandscapeContent(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      left: ResponsiveUtils.widthPercent(2),
      top: ResponsiveUtils.heightPercent(2),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: ResponsiveUtils.fontSize(30),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildDateIndicator() {
    return Positioned(
      top: ResponsiveUtils.heightPercent(2),
      right: ResponsiveUtils.widthPercent(2),
      child: Container(
        padding: ResponsiveUtils.padding(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: ResponsiveUtils.fontSize(20),
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(1)),
            Text(
              todayDateStr,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitContent() {
    return Center(
      child:
          hasPlayedToday && !gameActive
              ? _buildAlreadyPlayedMessage()
              : gameOver
              ? _buildGameOverMessage()
              : _buildGameContent(isPortrait: true),
    );
  }

  Widget _buildLandscapeContent() {
    return Center(
      child:
          hasPlayedToday && !gameActive
              ? _buildAlreadyPlayedMessage()
              : gameOver
              ? _buildGameOverMessage()
              : _buildGameContent(isPortrait: false),
    );
  }

  Widget _buildAlreadyPlayedMessage() {
    return Container(
      padding: ResponsiveUtils.padding(vertical: 4, horizontal: 4),
      width: ResponsiveUtils.getMinCardWidth() * 1.1,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            size: ResponsiveUtils.fontSize(70),
            color: Colors.amber,
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(2)),
          Text(
            'Daily Challenge Complete',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(24),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(1.5)),
          Text(
            'You\'ve already completed today\'s challenge with a score of $highScore.',
            style: TextStyle(fontSize: ResponsiveUtils.fontSize(16)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(2)),
          Text(
            'Come back tomorrow for a new challenge!',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(3)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: ResponsiveUtils.padding(horizontal: 3, vertical: 1.2),
            ),
            child: Text(
              'Back to Menu',
              style: TextStyle(fontSize: ResponsiveUtils.fontSize(18)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildGameOverMessage() {
    return Container(
      padding: ResponsiveUtils.padding(vertical: 4, horizontal: 4),
      width: ResponsiveUtils.getMinCardWidth() * 1.1,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            size: ResponsiveUtils.fontSize(70),
            color: Colors.amber,
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(2)),
          Text(
            'Daily Challenge Complete',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(24),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(1.5)),
          Text(
            'Final Score: $score',
            style: TextStyle(fontSize: ResponsiveUtils.fontSize(20)),
            textAlign: TextAlign.center,
          ),
          if (score >= highScore && score > 0)
            Text(
              'New High Score! 🎉',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.orange[400],
              ),
            ),
          SizedBox(height: ResponsiveUtils.heightPercent(2)),
          Text(
            'Come back tomorrow for a new challenge!',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(3)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: ResponsiveUtils.padding(horizontal: 3, vertical: 1.2),
            ),
            child: Text(
              'Back to Menu',
              style: TextStyle(fontSize: ResponsiveUtils.fontSize(18)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildGameContent({required bool isPortrait}) {
    if (isPortrait) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (gameActive)
            Text(
              'Score: $score',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(32),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          SizedBox(height: ResponsiveUtils.heightPercent(2)),
          if (showPattern && gameActive)
            _buildPatternDisplay()
          else if (gameActive)
            _buildGameStatus()
          else
            _buildWelcomeMessage(),
          SizedBox(height: ResponsiveUtils.heightPercent(4)),
          if (gameActive && !showPattern) _buildColorButtons(),
        ],
      );
    } else {
      // Landscape layout
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: ResponsiveUtils.padding(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (gameActive)
                    Text(
                      'Score: $score',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(32),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  SizedBox(height: ResponsiveUtils.heightPercent(2)),
                  if (showPattern && gameActive)
                    _buildPatternDisplay()
                  else if (gameActive)
                    _buildGameStatus()
                  else
                    _buildWelcomeMessage(),
                ],
              ),
            ),
          ),
          if (gameActive && !showPattern)
            Expanded(flex: 5, child: _buildColorButtons()),
        ],
      );
    }
  }

  Widget _buildPatternDisplay() {
    return ImprovedPatternDisplay(sequence: sequence, animateItems: true);
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
          'Sequence Length: ${sequence.length}',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(18),
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          'Daily Challenge',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(36),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveUtils.heightPercent(1.5)),
        Container(
          width: ResponsiveUtils.getMinCardWidth(),
          child: Text(
            'Test your memory with a unique challenge each day',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(18),
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: ResponsiveUtils.heightPercent(2)),
        Container(
          padding: ResponsiveUtils.padding(vertical: 1.5, horizontal: 1.5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text(
                'Today\'s High Score',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(18),
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '$highScore',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(32),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveUtils.heightPercent(4)),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: ResponsiveUtils.padding(horizontal: 3, vertical: 1.5),
          ),
          child: Text(
            'Start Challenge',
            style: TextStyle(fontSize: ResponsiveUtils.fontSize(20)),
          ),
        ),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildColorButtons() {
    final buttonSize = ResponsiveUtils.getGameButtonSize();

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              ResponsiveUtils.isLandscape
                  ? ResponsiveUtils.widthPercent(50)
                  : ResponsiveUtils.widthPercent(90),
        ),
        child: Wrap(
          spacing: ResponsiveUtils.widthPercent(3),
          runSpacing: ResponsiveUtils.heightPercent(2),
          alignment: WrapAlignment.center,
          children:
              colors
                  .map((color) => _buildColorButton(color, buttonSize))
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildColorBox(Color color, int index) {
    final boxSize =
        ResponsiveUtils.isTablet
            ? ResponsiveUtils.heightPercent(5)
            : ResponsiveUtils.heightPercent(6);

    return Container(
      width: boxSize,
      height: boxSize,
      margin: EdgeInsets.all(ResponsiveUtils.widthPercent(0.8)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
        ],
      ),
    ).animate().fadeIn(delay: (index * 200).ms).scale(delay: (index * 200).ms);
  }

  Widget _buildColorButton(Color color, double size) {
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
        width: size,
        height: size,
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
