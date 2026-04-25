import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient('https://rbqnbwklgwenqcfnqwes.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8');
  try {
    print('--- Puzzle Count Verification ---');
    final chapters = await supabase.from('chapters').select('id, title, concept').order('position');
    for (var c in chapters) {
      final List<dynamic> puzzles = await supabase.from('puzzles').select('id').eq('chapter_id', c['id']);
      print('Chapter: ${c['title']} (${c['concept']}) -> ${puzzles.length} puzzles');
    }
  } catch (e) {
    print('Error: $e');
  }
}
