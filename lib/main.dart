import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

// Set system UI overlay style
SystemChrome.setSystemUIOverlayStyle(
  const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ),
);

// Initialize Supabase (replace with your actual values)
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);

runApp(
  const ProviderScope(
    child: SnaptoStoreApp(),
  ),
);
}

class SnaptoStoreApp extends ConsumerWidget {
const SnaptoStoreApp({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final themeState = ref.watch(themeProvider);
  
  return MaterialApp(
    title: 'SnaptoStore',
    theme: AppTheme.lightTheme(themeState.colorScheme),
    debugShowCheckedModeBanner: false,
    home: const SplashScreen(),
  );
}
}