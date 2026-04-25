import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient('https://rbqnbwklgwenqcfnqwes.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8');
  try {
    print('--- Profiles Data ---');
    final profiles = await supabase.from('profiles').select('id, username, avatar_url');
    for (var p in profiles) {
      print('User: ${p['username']} (ID: ${p['id']})');
      print('  Avatar URL: ${p['avatar_url']}');
    }
    
    print('\n--- Storage Buckets ---');
    final buckets = await supabase.storage.listBuckets();
    for (var b in buckets) {
      print('Bucket: ${b.name} (Public: ${b.public})');
      if (b.name == 'avatars') {
         final files = await supabase.storage.from('avatars').list();
         print('  Files in avatars bucket: ${files.length}');
         for (var f in files) {
           print('    - ${f.name} (Created: ${f.createdAt})');
         }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
