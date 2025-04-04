import 'package:echo_memory/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A reusable pattern display widget that handles long sequences properly
/// with enhanced scrolling capabilities and visual indicators
class ImprovedPatternDisplay extends StatefulWidget {
  final List<Color> sequence;
  final String title;
  final bool animateItems;
  final bool autoScroll;
  final int
  currentIndex; // Optional - can be used to highlight the current item

  const ImprovedPatternDisplay({
    Key? key,
    required this.sequence,
    this.title = 'Remember this pattern!',
    this.animateItems = true,
    this.autoScroll = false,
    this.currentIndex = -1,
  }) : super(key: key);

  @override
  State<ImprovedPatternDisplay> createState() => _ImprovedPatternDisplayState();
}

class _ImprovedPatternDisplayState extends State<ImprovedPatternDisplay> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftIndicator = false;
  bool _showRightIndicator = false;

  @override
  void initState() {
    super.initState();

    // Add listener to detect scroll position for indicators
    _scrollController.addListener(_updateScrollIndicators);

    // Schedule check for overflow after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForOverflow();
    });
  }

  @override
  void didUpdateWidget(ImprovedPatternDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check for overflow again if sequence changes
    if (oldWidget.sequence.length != widget.sequence.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForOverflow();
      });
    }

    // Auto-scroll to end if new items were added
    if (widget.autoScroll &&
        oldWidget.sequence.length < widget.sequence.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToEnd();
      });
    }

    // Scroll to current index if specified
    if (widget.currentIndex >= 0 &&
        widget.currentIndex < widget.sequence.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.currentIndex);
      });
    }
  }

  void _checkForOverflow() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _showRightIndicator = _scrollController.position.maxScrollExtent > 0;
      _showLeftIndicator = _scrollController.offset > 0;
    });
  }

  void _updateScrollIndicators() {
    final showLeft = _scrollController.offset > 0;
    final showRight =
        _scrollController.position.maxScrollExtent > 0 &&
        _scrollController.offset < _scrollController.position.maxScrollExtent;

    if (showLeft != _showLeftIndicator || showRight != _showRightIndicator) {
      setState(() {
        _showLeftIndicator = showLeft;
        _showRightIndicator = showRight;
      });
    }
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    // Estimate the position based on index and item size
    final itemWidth =
        ResponsiveUtils.isTablet
            ? ResponsiveUtils.heightPercent(6) + ResponsiveUtils.widthPercent(2)
            : ResponsiveUtils.heightPercent(7) +
                ResponsiveUtils.widthPercent(2);

    final scrollTo = index * itemWidth;

    // Ensure it doesn't exceed bounds
    final targetScroll = scrollTo.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetScroll,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If there are no items, show a placeholder
    if (widget.sequence.isEmpty) {
      return _buildEmptyPlaceholder();
    }

    return Column(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn().scale(),
        SizedBox(height: ResponsiveUtils.heightPercent(3)),
        _buildScrollableSequence(),
      ],
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Column(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveUtils.heightPercent(3)),
        Container(
          width: ResponsiveUtils.widthPercent(70),
          height: ResponsiveUtils.heightPercent(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Pattern will appear here',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: ResponsiveUtils.fontSize(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableSequence() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height:
                  ResponsiveUtils.isTablet
                      ? ResponsiveUtils.heightPercent(8)
                      : ResponsiveUtils.heightPercent(9),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.widthPercent(4),
                ),
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        _showLeftIndicator ? Colors.transparent : Colors.white,
                        Colors.white,
                        Colors.white,
                        _showRightIndicator ? Colors.transparent : Colors.white,
                      ],
                      stops: [0.0, 0.05, 0.95, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          widget.sequence.asMap().entries.map((entry) {
                            return _buildColorBox(
                              entry.value,
                              entry.key,
                              isHighlighted: widget.currentIndex == entry.key,
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            // Left scroll indicator
            if (_showLeftIndicator)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: ResponsiveUtils.widthPercent(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white.withOpacity(0.7),
                      size: ResponsiveUtils.fontSize(24),
                    ),
                  ),
                ),
              ),

            // Right scroll indicator
            if (_showRightIndicator)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: ResponsiveUtils.widthPercent(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white.withOpacity(0.7),
                      size: ResponsiveUtils.fontSize(24),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildColorBox(Color color, int index, {bool isHighlighted = false}) {
    final boxSize =
        ResponsiveUtils.isTablet
            ? ResponsiveUtils.heightPercent(6)
            : ResponsiveUtils.heightPercent(7);

    final boxDecoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
      ],
      border: isHighlighted ? Border.all(color: Colors.white, width: 3) : null,
    );

    Widget box = Container(
      width: boxSize,
      height: boxSize,
      margin: EdgeInsets.all(ResponsiveUtils.widthPercent(1)),
      decoration: boxDecoration,
    );

    // Only animate if specified
    if (widget.animateItems) {
      return box
          .animate()
          .fadeIn(delay: (index * 200).ms)
          .scale(delay: (index * 200).ms);
    }

    return box;
  }
}
