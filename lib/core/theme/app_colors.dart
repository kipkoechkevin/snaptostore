import 'package:flutter/material.dart';
import '../constants/business_types.dart'; // ✅ Import shared enum

class AppColors {
// Primary Brand Colors
static const Color primary = Color(0xFF6B46C1); // Purple
static const Color primaryLight = Color(0xFF8B5CF6);
static const Color primaryDark = Color(0xFF553C9A);

// Secondary Colors
static const Color secondary = Color(0xFFEC4899); // Pink
static const Color secondaryLight = Color(0xFFF472B6);
static const Color secondaryDark = Color(0xDBE91E63);

// Accent Colors
static const Color accent = Color(0xFF10B981); // Green
static const Color accentLight = Color(0xFF34D399);
static const Color accentDark = Color(0xFF059669);

// Neutral Colors
static const Color background = Color(0xFFFAFAFA);
static const Color surface = Color(0xFFFFFFFF);
static const Color surfaceVariant = Color(0xFFF3F4F6);
static const Color surfaceDim = Color(0xFFE5E7EB);

// Text Colors
static const Color textPrimary = Color(0xFF1F2937);
static const Color textSecondary = Color(0xFF6B7280);
static const Color textTertiary = Color(0xFF9CA3AF);
static const Color textInverse = Color(0xFFFFFFFF);

// Status Colors
static const Color success = Color(0xFF10B981);
static const Color warning = Color(0xFFF59E0B);
static const Color error = Color(0xFFEF4444);
static const Color info = Color(0xFF3B82F6);

// Gradient Colors
static const primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
);

static const secondaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
);

// Business Type Colors
static const Color thriftBoss = Color(0xFF7C3AED);
static const Color boutiqueBoss = Color(0xFF06B6D4);
static const Color beautyBoss = Color(0xFFEC4899);
static const Color handmadeBoss = Color(0xFF10B981);
}

// Custom Color Scheme for easy customization
class BusinessColorScheme {
final String name;
final Color primary;
final Color secondary;
final Color accent;
final LinearGradient gradient;
final Color surface;
final BusinessType type;

const BusinessColorScheme({
  required this.name,
  required this.primary,
  required this.secondary,
  required this.accent,
  required this.gradient,
  required this.surface,
  required this.type,
});

// Helper method for opacity gradients
LinearGradient createOpacityGradient({
  double startOpacity = 0.1,
  double endOpacity = 0.05,
  AlignmentGeometry begin = Alignment.topLeft,
  AlignmentGeometry end = Alignment.bottomRight,
}) {
  return LinearGradient(
    begin: begin,
    end: end,
    colors: [
      primary.withOpacity(startOpacity),
      primary.withOpacity(endOpacity),
    ],
  );
}

// Predefined color schemes
static const BusinessColorScheme defaultScheme = BusinessColorScheme(
  name: 'Default',
  primary: AppColors.primary,
  secondary: Color(0xFFEDE9FE),
  accent: AppColors.accent,
  gradient: AppColors.primaryGradient,
  surface: AppColors.surface,
  type: BusinessType.general,
);

static const BusinessColorScheme thriftBoss = BusinessColorScheme(
  name: 'Thrift Boss',
  primary: Color(0xFF7C3AED),
  secondary: Color(0xFFDDD6FE),
  accent: Color(0xFFFBBF24),
  gradient: LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
  ),
  surface: AppColors.surface,
  type: BusinessType.thrift,
);

static const BusinessColorScheme boutiqueBoss = BusinessColorScheme(
  name: 'Boutique Boss',
  primary: Color(0xFF06B6D4),
  secondary: Color(0xFFCFFAFE),
  accent: Color(0xFF10B981),
  gradient: LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
  ),
  surface: AppColors.surface,
  type: BusinessType.boutique,
);

static const BusinessColorScheme beautyBoss = BusinessColorScheme(
  name: 'Beauty Boss',
  primary: Color(0xFFEC4899),
  secondary: Color(0xFFFCE7F3),
  accent: Color(0xFF8B5CF6),
  gradient: LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
  ),
  surface: AppColors.surface,
  type: BusinessType.beauty,
);

static const BusinessColorScheme handmadeBoss = BusinessColorScheme(
  name: 'Handmade Boss',
  primary: Color(0xFF10B981),
  secondary: Color(0xFFD1FAE5),
  accent: Color(0xFFF59E0B),
  gradient: LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  ),
  surface: AppColors.surface,
  type: BusinessType.handmade,
);

static List<BusinessColorScheme> get allSchemes => [
  defaultScheme,
  thriftBoss,
  boutiqueBoss,
  beautyBoss,
  handmadeBoss,
];
}