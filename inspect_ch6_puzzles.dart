import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient('https://rbqnbwklgwenqcfnqwes.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8');
  try {
    final puzzles = await supabase.from('puzzles').select('question').eq('chapter_id', 'ef141d0f-6692-4147-93b1-27571f2467fb').order('position').limit(5);
    print('--- Puzzles in The Crystal Cavern (Arrays) ---');
    for (var p in puzzles) {
      print('- ${p['question']}');
    }
  } catch (e) {
    print(e);
  }
}
