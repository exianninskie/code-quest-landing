import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient('https://rbqnbwklgwenqcfnqwes.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8');
  try {
    final chapter = await supabase.from('chapters').select('id, title').eq('concept', 'functions').single();
    print('Chapter Found: ${chapter['title']}');
    
    final puzzles = await supabase.from('puzzles').select('question, correct_answer').eq('chapter_id', chapter['id']).order('position').limit(5);
    for (var p in puzzles) {
      print('- ${p['question']} (Answer: ${p['correct_answer']})');
    }
  } catch (e) {
    print(e);
  }
}
