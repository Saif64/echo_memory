import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

      home: const DifficultyScreen(),
    );
  }
}

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
        _loseLife();
      }
    }
  }

  void _loseLife() {
    setState(() {
      lives--;
      currentStreak = 0;
      if (lives <= 0) {
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
                    MaterialPageRoute(
                      builder: (context) => const DifficultyScreen(),
                    ),
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
    return GestureDetector(
      onTap: showPattern ? null : () => _checkSelection(color),
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
