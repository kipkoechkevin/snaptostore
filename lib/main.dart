import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/core.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

try {
  // ✅ Load environment variables
  await dotenv.load(fileName: ".env");
  
  // ✅ Validate configuration
  EnvConfig.validate();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // ✅ Initialize Supabase with environment variables
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  
  runApp(
    const ProviderScope(
      child: SnaptoStoreApp(),
    ),
  );
} catch (e) {
  // ✅ Better error handling
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Configuration Error'),
              const SizedBox(height: 8),
              Text(e.toString()),
              const SizedBox(height: 16),
              const Text('Please check your .env file'),
            ],
          ),
        ),
      ),
    ),
  );
}
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
    home: const AuthWrapper(),
  );
}
}