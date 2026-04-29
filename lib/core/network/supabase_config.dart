import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://gzpbwccsfeqgyamluhtg.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd6cGJ3Y2NzZmVxZ3lhbWx1aHRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwODIxMTEsImV4cCI6MjA4MjY1ODExMX0.0CvBinkREcM22QR_dffBiSJCzoZ9R9EcA_OySn8GAjA';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static final client = Supabase.instance.client;
}