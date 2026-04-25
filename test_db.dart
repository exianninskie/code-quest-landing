import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient('https://rbqnbwklgwenqcfnqwes.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8');
  try {
    final chapters = await supabase.from('chapters').select('id, title, concept').order('position');
    print('Total chapters: ${chapters.length}');
    for (var c in chapters) {
      final puzzles = await supabase.from('puzzles').select('id').eq('chapter_id', c['id']);
      print('Chapter "${c['title']}" (Concept: ${c['concept']}) -> ${puzzles.length} puzzles');
    }
    
    // Also count total puzzles
    final allPuzzles = await supabase.from('puzzles').select('id');
    print('Total puzzles across all chapters: ${allPuzzles.length}');
  } catch (e) {
    print(e);
  }
}
