import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://bxklukqkpcqpubdlthxp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ4a2x1a3FrcGNxcHViZGx0aHhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjUzNzc5MTQsImV4cCI6MjA0MDk1MzkxNH0.KKtH5F1iPEVixCyj2br3B5IXbek89ukXWx0Dz1LIhcE',
  );
}
