/// Supabase configuration for ArenaIQ.
/// Replace these with your actual Supabase project credentials.
class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  static const String supabaseUrl = 'https://your-project.supabase.co';

  // TODO: Replace with your Supabase anon key
  static const String supabaseAnonKey = 'your-anon-key';

  /// Returns true if Supabase credentials have been configured.
  static bool get isConfigured =>
      supabaseUrl != 'https://your-project.supabase.co' &&
      supabaseAnonKey != 'your-anon-key';
}
