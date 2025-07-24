import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

// Validation
static bool get isConfigured => 
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
    
static void validate() {
  if (!isConfigured) {
    throw Exception(
      'Environment variables not configured. Please check your .env file.'
    );
  }
}
}