/// Echo Memory - Common Main Entry Point
/// Shared initialization logic for all environments

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/services/storage_service.dart';

void mainCommon() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log errors in debug mode, silently handle in release
    if (kDebugMode) {
      debugPrint('Flutter Error: ${details.exceptionAsString()}');
      debugPrint('Stack trace:\n${details.stack}');
    }
  };

  // Run the app with zone-guarded error handling
  runZonedGuarded(
    () async {
      // Initialize GetIt service locator
      await setupServiceLocator();

      // Initialize storage with error handling
      try {
        await StorageService().init();
      } catch (e) {
        debugPrint('Storage initialization failed: $e');
        // Continue anyway - storage will use defaults
      }

      // Set preferred orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      // Set system UI style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0D0D1A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      runApp(const EchoMemoryApp());
    },
    (error, stackTrace) {
      // Handle uncaught async errors
      if (kDebugMode) {
        debugPrint('Uncaught error: $error');
        debugPrint('Stack trace:\n$stackTrace');
      }
    },
  );
}
