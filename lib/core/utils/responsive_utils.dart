import 'package:flutter/material.dart';

/// A utility class to handle responsive sizing across different devices
class ResponsiveUtils {
  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;
  static double safeBlockHorizontal = 0;
  static double safeBlockVertical = 0;
  static double safeAreaHorizontal = 0;
  static double safeAreaVertical = 0;
  static double devicePixelRatio = 0;
  static bool isTablet = false;
  static bool isPhone = false;
  static bool isLandscape = false;
  static bool isPortrait = true;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    isLandscape = screenWidth > screenHeight;
    isPortrait = !isLandscape;
    devicePixelRatio = _mediaQueryData.devicePixelRatio;

    // Determine if device is a tablet based on shortestSide
    // A common approach to detect tablets
    isTablet = _mediaQueryData.size.shortestSide >= 600;
    isPhone = !isTablet;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  /// Get responsive font size
  static double fontSize(double size) {
    // Base font size, adjusted by screen dimensions
    double baseSize = isTablet ? size * 1.2 : size;
    return baseSize * (isLandscape ? 0.85 : 1.0);
  }

  /// Get responsive size based on screen width percentage
  static double widthPercent(double percent) {
    return safeBlockHorizontal * percent;
  }

  /// Get responsive size based on screen height percentage
  static double heightPercent(double percent) {
    return safeBlockVertical * percent;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets padding({
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.fromLTRB(
      left > 0 ? widthPercent(left) : widthPercent(horizontal),
      top > 0 ? heightPercent(top) : heightPercent(vertical),
      right > 0 ? widthPercent(right) : widthPercent(horizontal),
      bottom > 0 ? heightPercent(bottom) : heightPercent(vertical),
    );
  }

  /// Get minimum dimensions for a card or container
  static double getMinCardWidth() {
    if (isLandscape) {
      return isTablet ? widthPercent(25) : widthPercent(30);
    } else {
      return isTablet ? widthPercent(40) : widthPercent(70);
    }
  }

  /// Get optimal card height
  static double getCardHeight() {
    if (isLandscape) {
      return isTablet ? heightPercent(30) : heightPercent(40);
    } else {
      return isTablet ? heightPercent(20) : heightPercent(15);
    }
  }

  /// Get game button size based on screen dimensions and orientation
  static double getGameButtonSize() {
    if (isLandscape) {
      return isTablet ? heightPercent(15) : heightPercent(20);
    } else {
      return isTablet ? widthPercent(15) : widthPercent(20);
    }
  }

  /// Get optimal game grid layout (rows and columns) based on orientation
  static int getGridCrossAxisCount() {
    if (isLandscape) {
      return isTablet ? 5 : 4;
    } else {
      return isTablet ? 4 : 2;
    }
  }
}
