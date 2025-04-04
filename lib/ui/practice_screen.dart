import 'dart:async';
import 'dart:math';

import 'package:echo_memory/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Import the SoundManager (assume it's moved to a separate file)
import '../core/improvements/pattern_display.dart';
import '../main.dart';

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
      if (mounted) {
        setState(() {
          showPattern = false;
        });
      }
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
    // Initialize responsive utils
    ResponsiveUtils.init(context);

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
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? _buildPortraitLayout()
                  : _buildLandscapeLayout();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Stack(
      children: [
        _buildBackButton(),
        _buildModeIndicator(),
        Center(
          child: Padding(
            padding: ResponsiveUtils.padding(horizontal: 4, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showPattern || revealPattern)
                  _buildPatternDisplay()
                else
                  _buildGameStatus(),
                SizedBox(height: ResponsiveUtils.heightPercent(4)),
                _buildColorButtons(),
                SizedBox(height: ResponsiveUtils.heightPercent(4)),
                if (!showPattern) _buildRevealButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Stack(
      children: [
        _buildBackButton(),
        _buildModeIndicator(),
        Padding(
          padding: ResponsiveUtils.padding(horizontal: 4, vertical: 8, top: 12),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showPattern || revealPattern)
                        _buildPatternDisplay()
                      else
                        _buildGameStatus(),
                      SizedBox(height: ResponsiveUtils.heightPercent(4)),
                      if (!showPattern) _buildRevealButton(),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 5, child: Center(child: _buildColorButtons())),
            ],
          ),
        ),
      ],
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

  Widget _buildModeIndicator() {
    return Positioned(
      right: ResponsiveUtils.widthPercent(2),
      top: ResponsiveUtils.heightPercent(2),
      child: Container(
        padding: ResponsiveUtils.padding(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              Icons.school,
              color: Colors.white,
              size: ResponsiveUtils.fontSize(20),
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(1)),
            Text(
              'Practice Mode',
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

  Widget _buildPatternDisplay() {
    return ImprovedPatternDisplay(
      sequence: sequence,
      title: showPattern ? 'Remember this pattern!' : 'Pattern Revealed',
      animateItems: true,
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
          'Sequence Length: $sequenceLength',
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
        final buttonSize = ResponsiveUtils.getGameButtonSize();

        return Container(
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
                colors.map((color) {
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
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 3,
                          color: Colors.white.withOpacity(0.8),
                        ),
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
                }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRevealButton() {
    return GestureDetector(
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
        padding: ResponsiveUtils.padding(horizontal: 3, vertical: 1.5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility,
              color: Colors.white,
              size: ResponsiveUtils.fontSize(24),
            ),
            SizedBox(width: ResponsiveUtils.widthPercent(1)),
            Text(
              'Hold to See Pattern',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
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
}
