import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient('https://rbqnbwklgwenqcfnqwes.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8');
  try {
    final chapters = await supabase.from('chapters').select('id, title, concept, position').order('position');
    print('--- All Chapters ---');
    for (var c in chapters) {
      print('ID: ${c['id']} | Title: ${c['title']} | Concept: ${c['concept']} | Pos: ${c['position']}');
    }
  } catch (e) {
    print(e);
  }
}
