# Flutter/Dart Proguard Rules

# Keep Flutter and plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Keep R references
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Shared Preferences
-keep class androidx.datastore.** { *; }
