import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    'https://rbqnbwklgwenqcfnqwes.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8'
  );
  try {
    // find chapter 1
    final chapterResponse = await supabase.from('chapters').select('id').eq('concept', 'variables').limit(1).single();
    final String chapterId = chapterResponse['id'];

    // Add Puzzle 2
    await supabase.from('puzzles').insert({
        'chapter_id': chapterId,
        'story_context': 'The Keeper now introduces you to integers. "Which of these holds a whole number?"',
        'question': 'Which variable holds a whole number?',
        'code_snippet': 'heroName = "Arin"\nheroAge  = 17\nhasSword = True',
        'type': 'multipleChoice',
        'options': ['heroAge = 17', 'heroName = "Arin"', 'hasSword = True'],
        'correct_answer': 'heroAge = 17',
        'explanation': 'heroAge stores 17, which is a whole number (an Integer). There are no quotes or decimals.',
        'xp_reward': 20,
        'position': 2
    });
    print("Added Puzzle 2!");
  } catch (e) {
    print(e);
  }
}
