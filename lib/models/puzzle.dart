// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'puzzle.freezed.dart';
part 'puzzle.g.dart';

// The type of puzzle determines the UI shown
enum PuzzleType {
  multipleChoice, // Pick the right answer from options
  fillInTheBlank, // Type the missing code
  orderTheCode, // Drag lines into the correct order
  spotTheBug, // Find the error in a code snippet
}

@freezed
class Puzzle with _$Puzzle {
  const factory Puzzle({
    @Default('') String id,
    @JsonKey(name: 'chapter_id') @Default('') String chapterId,
    @Default('Unknown Question') String question,
    @JsonKey(name: 'code_snippet') @Default('') String codeSnippet,
    @Default(PuzzleType.multipleChoice) PuzzleType type,
    @Default([]) List<String> options,
    @JsonKey(name: 'correct_answer') @Default('') String correctAnswer,
    @Default('') String explanation,
    @JsonKey(name: 'story_context') @Default('') String storyContext,
    @JsonKey(name: 'xp_reward') @Default(10) int xpReward,
    @Default(1) int position,
    @Default('') String hint,
  }) = _Puzzle;

  factory Puzzle.fromJson(Map<String, dynamic> json) => _$PuzzleFromJson(json);
}
