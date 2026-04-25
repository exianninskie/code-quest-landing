import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient('https://rbqnbwklgwenqcfnqwes.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8');
  try {
    final puzzles = await supabase.from('puzzles').select('question, correct_answer').eq('chapter_id', 'ee2e33a7-d03a-422c-bbf2-d64075fdb08d').order('position').limit(5);
    print('--- Puzzles in The Alchemist\'s Workshop (ee2e33a7) ---');
    for (var p in puzzles) {
      print('- ${p['question']}');
    }
  } catch (e) {
    print(e);
  }
}
