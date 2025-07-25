import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../constants/business_types.dart';

// Theme State
class ThemeState {
final BusinessColorScheme colorScheme;
final bool isDarkMode;

const ThemeState({
  required this.colorScheme,
  this.isDarkMode = false,
});

ThemeState copyWith({
  BusinessColorScheme? colorScheme,
  bool? isDarkMode,
}) {
  return ThemeState(
    colorScheme: colorScheme ?? this.colorScheme,
    isDarkMode: isDarkMode ?? this.isDarkMode,
  );
}
}

// Theme Notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
ThemeNotifier() : super(const ThemeState(colorScheme: BusinessColorScheme.defaultScheme)) {
  _loadTheme();
}

Future<void> _loadTheme() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final businessTypeIndex = prefs.getInt('business_type') ?? 0;
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    
    final colorScheme = BusinessColorScheme.allSchemes[businessTypeIndex];
    
    state = ThemeState(
      colorScheme: colorScheme,
      isDarkMode: isDarkMode,
    );
  } catch (e) {
    // If error loading, keep default
  }
}

Future<void> updateColorScheme(BusinessColorScheme colorScheme) async {
  state = state.copyWith(colorScheme: colorScheme);
  await _saveTheme();
}

Future<void> setBusinessType(BusinessType businessType) async {
  final colorScheme = BusinessColorScheme.allSchemes.firstWhere(
    (scheme) => scheme.type == businessType,
    orElse: () => BusinessColorScheme.defaultScheme,
  );
  
  state = state.copyWith(colorScheme: colorScheme);
  await _saveTheme();
}

Future<void> toggleDarkMode() async {
  state = state.copyWith(isDarkMode: !state.isDarkMode);
  await _saveTheme();
}

Future<void> _saveTheme() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final businessTypeIndex = BusinessColorScheme.allSchemes.indexOf(state.colorScheme);
    await prefs.setInt('business_type', businessTypeIndex);
    await prefs.setBool('is_dark_mode', state.isDarkMode);
  } catch (e) {
    // Handle error
  }
}
}

// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
return ThemeNotifier();
});

// Current color scheme provider
final currentColorSchemeProvider = Provider<BusinessColorScheme>((ref) {
return ref.watch(themeProvider).colorScheme;
});