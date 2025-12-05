import 'package:flutter/material.dart';

/// Futuristic space-themed dark theme for Project Manager
class ProjectManagerTheme {
  // Deep space colors
  static const Color deepSpace = Color(0xFF0A0E27);
  static const Color cosmicBlue = Color(0xFF1A1F3A);
  static const Color nebulaBlue = Color(0xFF2D3561);
  static const Color starLight = Color(0xFF7B8CDE);
  
  // Accent colors - vibrant tech/neon
  static const Color cyanGlow = Color(0xFF00F0FF);
  static const Color purpleNeon = Color(0xFF9D4EDD);
  static const Color pinkNeon = Color(0xFFFF006E);
  static const Color mintGlow = Color(0xFF06FFA5);
  static const Color yellowGlow = Color(0xFFFFBE0B);
  
  // Status colors
  static const Color successGreen = Color(0xFF00FF88);
  static const Color warningOrange = Color(0xFFFF8C42);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color infoBlue = Color(0xFF00D9FF);
  
  // Text colors
  static const Color textPrimary = Color(0xFFE8E9F3);
  static const Color textSecondary = Color(0xFFB8BBC8);
  static const Color textTertiary = Color(0xFF7B8CDE);
  
  // Background gradients
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      deepSpace,
      cosmicBlue,
      nebulaBlue,
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2749),
      Color(0xFF2D3561),
    ],
  );
  
  static LinearGradient glowGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.6),
        color.withOpacity(0.2),
      ],
    );
  }
  
  // Glassmorphism effect
  static BoxDecoration glassmorphism({
    double opacity = 0.1,
    double blur = 10,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.2),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ],
    );
  }
  
  // Neon glow effect
  static BoxDecoration neonGlow({
    required Color color,
    double blurRadius = 20,
    double spreadRadius = 2,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.6),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: blurRadius * 2,
          spreadRadius: spreadRadius * 2,
        ),
      ],
    );
  }
  
  // Animated shimmer colors for loading states
  static const List<Color> shimmerColors = [
    Color(0xFF2D3561),
    Color(0xFF3D4675),
    Color(0xFF2D3561),
  ];
  
  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return successGreen;
      case 'in progress':
      case 'active':
        return infoBlue;
      case 'testing':
        return yellowGlow;
      case 'on hold':
      case 'blocked':
        return warningOrange;
      case 'planning':
      case 'todo':
        return purpleNeon;
      default:
        return textSecondary;
    }
  }
  
  // Get project type color
  static Color getProjectTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'website':
      case 'web app':
        return cyanGlow;
      case 'mobile app':
      case 'app':
        return purpleNeon;
      case 'desktop app':
        return mintGlow;
      case 'api':
      case 'backend':
        return yellowGlow;
      case 'design':
        return pinkNeon;
      default:
        return starLight;
    }
  }
  
  // Text styles
  static const TextStyle heroText = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
    letterSpacing: -1,
  );
  
  static const TextStyle titleText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle subtitleText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    color: textTertiary,
  );
  
  // Get theme data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepSpace,
      primaryColor: cyanGlow,
      colorScheme: const ColorScheme.dark(
        primary: cyanGlow,
        secondary: purpleNeon,
        surface: cosmicBlue,
        error: errorRed,
      ),
      textTheme: const TextTheme(
        displayLarge: heroText,
        displayMedium: titleText,
        titleLarge: titleText,
        titleMedium: subtitleText,
        bodyLarge: bodyText,
        bodyMedium: bodyText,
        bodySmall: captionText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: titleText,
      ),
      cardTheme: CardThemeData(
        color: cosmicBlue,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
