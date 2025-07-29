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
// Flutterwave Configuration
static const String flutterwavePublicKey = String.fromEnvironment(
  'FLUTTERWAVE_PUBLIC_KEY',
  defaultValue: 'FLWPUBK_TEST-your-key-here',
);

static const String flutterwaveSecretKey = String.fromEnvironment(
  'FLUTTERWAVE_SECRET_KEY', 
  defaultValue: 'FLWSECK_TEST-your-key-here',
);

static const String flutterwaveEncryptionKey = String.fromEnvironment(
  'FLUTTERWAVE_ENCRYPTION_KEY',
  defaultValue: 'FLWSECK_TEST-your-encryption-key-here',
);

// RevenueCat Configuration
static const String revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: 'your-revenuecat-api-key-here',
);

static const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;

}
