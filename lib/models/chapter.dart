// ─────────────────────────────────
// lib/models/chapter.dart
// ─────────────────────────────────
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'puzzle.dart';

part 'chapter.freezed.dart';
part 'chapter.g.dart';

@freezed
class Chapter with _$Chapter {
  const factory Chapter({
    @Default('') String id,
    @Default('Unknown Title') String title,
    @Default('') String story,
    @Default('misc') String concept,
    @Default(0) int position,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'is_unlocked_by_default') @Default(false) bool isUnlockedByDefault,
    @Default([]) List<Puzzle> puzzles,
  }) = _Chapter;

  factory Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);
}
