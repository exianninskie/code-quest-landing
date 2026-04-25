-- ─────────────────────────────────────────────────────────
-- Migration 003: 30 Puzzles for Chapter 2 (Strings) - INVINCIBLE VERSION
-- ─────────────────────────────────────────────────────────

DO $MAIN$ 
DECLARE 
  true_ch_id UUID;
  chapter_count INT;
BEGIN 
  -- 1. Ensure only one Chapter 2 exists
  SELECT count(*) INTO chapter_count FROM chapters WHERE concept = 'strings';
  IF chapter_count > 1 THEN
    DELETE FROM chapters WHERE concept = 'strings';
  END IF;

  -- 2. Create/Find Chapter 2
  IF NOT EXISTS (SELECT 1 FROM chapters WHERE concept = 'strings') THEN
    INSERT INTO chapters (title, story, concept, position, image_url)
    VALUES ($$The Weaver's Loom$$, $$You find a loom where threads are woven into tapestry.$$, $$strings$$, 2, $$images/chapter_weaver_loom.png$$)
    RETURNING id INTO true_ch_id;
  ELSE
    SELECT id INTO true_ch_id FROM chapters WHERE concept = 'strings' LIMIT 1;
  END IF;

  -- 3. Reset Puzzles
  DELETE FROM puzzles WHERE chapter_id = true_ch_id;

  -- 4. Insert all 30 using $$ for everything to avoid quote errors
  INSERT INTO puzzles (chapter_id, story_context, question, code_snippet, options, correct_answer, explanation, xp_reward, difficulty, position, hint) VALUES
  -- ─── 10 Basic Puzzles (1-10) ───
  (true_ch_id, $$A silken thread stretches before you.$$, $$How do you find the number of characters in a string?$$, $$var word = "Quest";$$, ARRAY[$$word.length$$, $$word.count()$$, $$word.size$$, $$word.chars$$], $$word.length$$, $$In Dart, the .length property returns the number of characters.$$, 10, $$basic$$, 1, $$Length is a property, not a function! No parentheses needed.$$),
  (true_ch_id, $$Combine two magical threads.$$, $$What is the simplest way to join "Fire" and "Ball"?$$, $$var s1 = "Fire"; var s2 = "Ball";$$, ARRAY[$$s1 + s2$$, $$s1 & s2$$, $$s1.join(s2)$$, $$s1 . s2$$], $$s1 + s2$$, $$The + operator concatenates (joins) two strings together.$$, 10, $$basic$$, 2, $$Think of adding them together like numbers.$$),
  (true_ch_id, $$A label for a mysterious potion.$$, $$Which is a valid Dart String declaration?$$, $$...$$, ARRAY[$$var s = "Potion";$$, $$var s = Potion;$$, $$var s = 'Potion';$$, $$Both 1 and 3$$], $$Both 1 and 3$$, $$Dart allows both single and double quotes for Strings.$$, 10, $$basic$$, 3, $$Quotes are essential for text data.$$),
  (true_ch_id, $$The weaver asks for an empty strand.$$, $$How do you check if a string has no characters?$$, $$var s = "";$$, ARRAY[$$s.isEmpty$$, $$s == 0$$, $$s.length == -1$$, $$s.isClear$$], $$s.isEmpty$$, $$The .isEmpty property returns true if the length is 0.$$, 10, $$basic$$, 4, $$There is a built-in property specifically for this.$$),
  (true_ch_id, $$Read the first character of the scroll.$$, $$How do you access the first character of "Dart"?$$, $$var s = "Dart";$$, ARRAY[$$s[0]$$, $$s[1]$$, $$s.first$$, $$s.get(0)$$], $$s[0]$$, $$String indexing starts at 0 in Dart.$$, 10, $$basic$$, 5, $$Remember, we count from zero in programming!$$),
  (true_ch_id, $$A character escape trial.$$, $$How do you add a newline character to a string?$$, $$...$$, ARRAY[$$\n$$, $$/n$$, $$<br>$$, $$\newline$$], $$\n$$, $$\n is the escape sequence for a newline (line break).$$, 10, $$basic$$, 6, $$The backslash is the escape character.$$),
  (true_ch_id, $$Is the thread empty or just full of space?$$, $$What is the result of " ".isEmpty?$$, $$var s = " ";$$, ARRAY[$$false$$, $$true$$, $$null$$, $$Error$$], $$false$$, $$A string with a space is NOT empty; its length is 1.$$, 10, $$basic$$, 7, $$Empty means zero length!$$),
  (true_ch_id, $$The Weaver compares two threads.$$, $$Is "A" equal to "a" in Dart?$$, $$var equal = ("A" == "a");$$, ARRAY[$$false$$, $$true$$, $$null$$, $$Error$$], $$false$$, $$Dart strings are case-sensitive.$$, 10, $$basic$$, 8, $$Capitalization matters in the Weaver's realm.$$),
  (true_ch_id, $$Escaping the single quote.$$, $$How do you write "I'm a coder" using single quotes?$$, $$...$$, ARRAY[$$'I\'m a coder'$$, $$'I'm a coder'$$, $$'I m a coder'$$, $$'I.m a coder'$$], $$'I\'m a coder'$$, $$Use \ to escape a single quote inside a single-quoted string.$$, 10, $$basic$$, 9, $$The backslash tells Dart to ignore the quote's normal ending role.$$),
  (true_ch_id, $$The power of multi-line wisdom.$$, $$How do you start a multi-line string in Dart?$$, $$...$$, ARRAY[$$""" (triple quotes)$$, $$" (double quotes)$$, $$/// (triple slash)$$, $$` (backtick)$$], $$""" (triple quotes)$$, $$Triple quotes (""" or ''') allow strings to span multiple lines.$$, 10, $$basic$$, 10, $$Three is better than one for long stories.$$),

  -- ─── 10 Intermediate Puzzles (11-20) ───
  (true_ch_id, $$Shouting into the void.$$, $$How do you make "hello" become "HELLO"?$$, $$var s = "hello";$$, ARRAY[$$s.toUpperCase()$$, $$s.toUpper()$$, $$toUpperCase(s)$$, $$s.caps()$$], $$s.toUpperCase()$$, $$The toUpperCase() method returns the uppercase version of a string.$$, 15, $$intermediate$$, 11, $$It sounds like a command.$$),
  (true_ch_id, $$Whispering secrets.$$, $$How do you make "DART" become "dart"?$$, $$var s = "DART";$$, ARRAY[$$s.toLowerCase()$$, $$s.small()$$, $$s.toLower()$$, $$s.case(lower)$$], $$s.toLowerCase()$$, $$The toLowerCase() method returns the lowercase version.$$, 15, $$intermediate$$, 12, $$The opposite of upper case.$$),
  (true_ch_id, $$The search for a keyword.$$, $$How to check if "The Weaver" contains "Weaver"?$$, $$var s = "The Weaver";$$, ARRAY[$$s.contains("Weaver")$$, $$s.has("Weaver")$$, $$s.find("Weaver")$$, $$s.includes("Weaver")$$], $$s.contains("Weaver")$$, $$The contains() method checks if a substring exists.$$, 15, $$intermediate$$, 13, $$Does it contain the word?$$),
  (true_ch_id, $$Cutting the thread.$$, $$Get "Hello" from "Hello World".$$, $$var s = "Hello World";$$, ARRAY[$$s.substring(0, 5)$$, $$s.slice(0, 5)$$, $$s.cut(5)$$, $$s.substring(5)$$], $$s.substring(0, 5)$$, $$substring(start, end) extracts parts of a string.$$, 15, $$intermediate$$, 14, $$Start at 0, take 5 characters.$$),
  (true_ch_id, $$Cleaning up the messy yarn.$$, $$Remove spaces from "  Dart  ".$$, $$var s = "  Dart  ";$$, ARRAY[$$s.trim()$$, $$s.clean()$$, $$s.strip()$$, $$s.removeSpaces()$$], $$s.trim()$$, $$The trim() method removes leading and trailing white space.$$, 15, $$intermediate$$, 15, $$Give it a haircut!$$),
  (true_ch_id, $$Check the beginning of the spell.$$, $$Does "Magic" start with "M"?$$, $$var s = "Magic";$$, ARRAY[$$s.startsWith("M")$$, $$s.beginsWith("M")$$, $$s.at(0) == "M"$$, $$Both 1 and 3$$], $$Both 1 and 3$$, $$startsWith() is the semantic way, but indexing works too.$$, 15, $$intermediate$$, 16, $$Check the first character.$$),
  (true_ch_id, $$Check the end of the journey.$$, $$Does "Done" end with "e"?$$, $$var s = "Done";$$, ARRAY[$$s.endsWith("e")$$, $$s.last == "e"$$, $$s.finish("e")$$, $$None$$], $$s.endsWith("e")$$, $$The endsWith() method checks the end of a string.$$, 15, $$intermediate$$, 17, $$What is at the finish line?$$),
  (true_ch_id, $$Padding for protection.$$, $$Make "5" become "005".$$, $$var s = "5";$$, ARRAY[$$s.padLeft(3, '0')$$, $$s.pad(3, '0')$$, $$s.fill(3, '0')$$, $$s.left("0", 3)$$], $$s.padLeft(3, '0')$$, $$padLeft adds characters to the start until length is met.$$, 15, $$intermediate$$, 18, $$Add "0"s to the left side.$$),
  (true_ch_id, $$Magical injection.$$, $$How to print the variable `xp` inside a string?$$, $$var xp = 10;$$, ARRAY[$$"XP: $xp"$$, $$"XP: {xp}"$$, $$"XP: " + xp$$, $$1 and 3$$], $$1 and 3$$, $$Interpolation ($) or concatenation (+) both work.$$, 15, $$intermediate$$, 19, $$Use the dollar sign for magic.$$),
  (true_ch_id, $$Injection with calculations.$$, $$Print the length of variable `name`.$$, $$var name = "Arin";$$, ARRAY[$$"${name.length}"$$, $$"$name.length"$$, $$"$(name.length)"$$, $$None$$], $$"${name.length}"$$, $$Use ${} for expressions or property access inside strings.$$, 15, $$intermediate$$, 20, $$Curly braces are needed for dots.$$),

  -- ─── 10 Advanced Puzzles (21-30) ───
  (true_ch_id, $$Dividing the silken tapestry.$$, $$Split "A,B,C" into a list of strings.$$, $$var s = "A,B,C";$$, ARRAY[$$s.split(",")$$, $$s.divide(",")$$, $$s.tolist(",")$$, $$s.explode(",")$$], $$s.split(",")$$, $$split() breaks a string into a List based on a pattern.$$, 20, $$advanced$$, 21, $$Break it apart by the comma.$$),
  (true_ch_id, $$Joining the list threads.$$, $$Join ['a', 'b'] with a dash -.$$, $$var list = ["a", "b"];$$, ARRAY[$$list.join("-")$$, $$list.connect("-")$$, $$list + "-"$$, $$join(list, "-")$$], $$list.join("-")$$, $$join() combines list elements into a single string.$$, 20, $$advanced$$, 22, $$Opposite of split.$$),
  (true_ch_id, $$The Pattern Matcher.$$, $$Does "123" contain any digits?$$, $$var reg = RegExp(r"\d+");$$, ARRAY[$$reg.hasMatch("123")$$, $$reg.match("123")$$, $$reg.test("123")$$, $$reg == "123"$$], $$reg.hasMatch("123")$$, $$RegExp is used for complex pattern matching.$$, 20, $$advanced$$, 23, $$Regular expressions are powerful patterns.$$),
  (true_ch_id, $$The Raw Reality.$$, $$Which keeps the literal \n without a newline?$$, $$...$$, ARRAY[$$r"Hello\n"$$, $$"Hello\n"$$, $$'''Hello\n'''$$, $$magic"Hello\n"$$], $$r"Hello\n"$$, $$A raw string (prefixed with r) ignores escape characters.$$, 20, $$advanced$$, 24, $$The "r" prefix is for "Raw".$$),
  (true_ch_id, $$Swap the Loom threads.$$, $$Change all "a" to "o" in "banana".$$, $$var s = "banana";$$, ARRAY[$$s.replaceAll("a", "o")$$, $$s.replace("a", "o")$$, $$s.swap("a", "o")$$, $$s.change("a", "o")$$], $$s.replaceAll("a", "o")$$, $$replaceAll replacement all occurrences in a string.$$, 20, $$advanced$$, 25, $$Replace them all!$$),
  (true_ch_id, $$The First Replacement.$$, $$Change only the first "a" to "o" in "banana".$$, $$var s = "banana";$$, ARRAY[$$s.replaceFirst("a", "o")$$, $$s.replace(0, "o")$$, $$s.sub("a", "o")$$, $$None of these$$], $$s.replaceFirst("a", "o")$$, $$replaceFirst only changes the very first match.$$, 20, $$advanced$$, 26, $$Just the first one.$$),
  (true_ch_id, $$ASCII Knowledge.$$, $$What is the code unit of "A" (ASCII 65)?$$, $$var s = "A";$$, ARRAY[$$s.codeUnitAt(0)$$, $$s.ascii()$$, $$s.int()$$, $$s.toBytes()$$], $$s.codeUnitAt(0)$$, $$codeUnitAt(index) returns the character code at a position.$$, 20, $$advanced$$, 27, $$The numeric code for the character.$$),
  (true_ch_id, $$Deep Runes.$$, $$What property gives the UTF-32 code points?$$, $$var s = "Hi";$$, ARRAY[$$s.runes$$, $$s.utf32$$, $$s.points$$, $$s.values$$], $$s.runes$$, $$A String is a sequence of UTF-16 code units; .runes gives UTF-32.$$, 20, $$advanced$$, 28, $$Ancient runes for modern characters.$$),
  (true_ch_id, $$The Efficient Builder.$$, $$Best way to build a string in a loop?$$, $$...$$, ARRAY[$$StringBuffer$$, $$StringBuffer()$$, $$String.join()$$, $$print()$$], $$StringBuffer$$, $$StringBuffer is more memory-efficient for building strings incrementally.$$, 20, $$advanced$$, 29, $$Don't add strings in a loop, build them!$$),
  (true_ch_id, $$The Final Transformation.$$, $$How to convert "100" to an Actual integer?$$, $$var s = "100";$$, ARRAY[$$int.parse(s)$$, $$s.toInt()$$, $$(int)s$$, $$int(s)$$], $$int.parse(s)$$, $$int.parse() converts a string representation of a number to an int.$$, 20, $$advanced$$, 30, $$Parse the text into a number.$$)
  ;

END $MAIN$;
