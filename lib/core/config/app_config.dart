import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String get baseUrl {
    try {
      final url = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
      return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  static String get supabaseUrl {
    try {
      return dotenv.env['SUPABASE_URL'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get supabasePublishableKey {
    try {
      return dotenv.env['SUPABASE_API_KEY'] ??
          dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
          dotenv.env['SUPABASE_ANON_KEY'] ??
          '';
    } catch (_) {
      return '';
    }
  }

  static String get supabaseAnonKey => supabasePublishableKey;

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static const String supabaseRedirectUrl = 'footballmanagement://login-callback';
}
