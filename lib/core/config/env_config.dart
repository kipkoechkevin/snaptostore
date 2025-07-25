import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
static String get removeBgApiKey => dotenv.env['REMOVEBG_API_KEY'] ?? '';

// Validation
static bool get isConfigured => 
    supabaseUrl.isNotEmpty && 
    supabaseAnonKey.isNotEmpty && 
    removeBgApiKey.isNotEmpty;
    
static void validate() {
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Supabase environment variables not configured. Please check your .env file.'
    );
  }
  
  if (removeBgApiKey.isEmpty) {
    print('Warning: Remove.bg API key not configured. Background removal will be disabled.');
  }
}
}