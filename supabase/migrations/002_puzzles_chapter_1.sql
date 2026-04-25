-- ─────────────────────────────────────────────────────────
-- Migration 002: 30 Puzzles for Chapter 1 (Variables)
-- ─────────────────────────────────────────────────────────

-- Ensure the difficulty column exists
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='puzzles' AND column_name='difficulty') THEN
    ALTER TABLE puzzles ADD COLUMN difficulty TEXT NOT NULL DEFAULT 'basic';
  END IF;
END $$;

-- First, clear existing puzzles for Chapter 1
DO $$ 
DECLARE 
  ch1_id UUID;
BEGIN 
  SELECT id INTO ch1_id FROM chapters WHERE concept = 'variables' LIMIT 1;
  DELETE FROM puzzles WHERE chapter_id = ch1_id;

  -- 10 Basic Puzzles
  INSERT INTO puzzles (chapter_id, story_context, question, code_snippet, options, correct_answer, explanation, xp_reward, difficulty, position) VALUES
  (ch1_id, 'A floating quill awaits your command.', 'How do you tell the quill to store a name?', 'var name = "Alaric";', ARRAY['var name = "Alaric";', 'name = Alaric;', 'int name = 123;', 'const name;'], 'var name = "Alaric";', 'Use "var" or a type name to declare a variable.', 10, 'basic', 1),
  (ch1_id, 'The Library Keeper hands you a golden key.', 'What is the correct way to store a number of keys?', 'var keys = 1;', ARRAY['var keys = 1;', 'keys := 1;', 'String keys = 1;', 'key : 1;'], 'var keys = 1;', 'Numbers are assigned directly to variables without quotes.', 10, 'basic', 2),
  (ch1_id, 'You find a scroll labeled "Magic Power".', 'Assign the value 100 to the "mana" variable.', 'var mana = 100;', ARRAY['var mana = 100;', 'mana == 100;', 'mana : 100;', '100 -> mana;'], 'var mana = 100;', 'The "=" operator assigns a value to a variable.', 10, 'basic', 3),
  (ch1_id, 'A dragon asks for your age.', 'Which data type is best for storing age (e.g., 25)?', 'int age = 25;', ARRAY['int', 'double', 'String', 'bool'], 'int', 'Integers (int) are used for whole numbers.', 10, 'basic', 4),
  (ch1_id, 'The gate is either open or closed.', 'Which type stores true or false?', 'bool isOpen = true;', ARRAY['bool', 'int', 'String', 'void'], 'bool', 'Booleans (bool) specifically store true or false.', 10, 'basic', 5),
  (ch1_id, 'You need to label a jar of fairy dust.', 'Which variable name is valid?', 'var fairy_dust = "";', ARRAY['fairy dust', '2fairy', 'fairy_dust', 'fairy-dust'], 'fairy_dust', 'Variable names use underscores, not spaces or dashes.', 10, 'basic', 6),
  (ch1_id, 'Record the weight of a phoenix feather.', 'Which type allows for decimals?', 'double w = 0.5;', ARRAY['double', 'int', 'String', 'bool'], 'double', 'Doubles are used for numbers with decimals.', 10, 'basic', 7),
  (ch1_id, 'Some things never change.', 'How to declare a variable that cannot be reassigned?', 'final id = 123;', ARRAY['final id = 123;', 'var id = 123;', 'id = 123;', 'var id;'], 'final id = 123;', '"final" prevents a variable from being changed later.', 10, 'basic', 8),
  (ch1_id, 'A potion heals you.', 'Increase your health (hp) by 10.', 'hp = hp + 10;', ARRAY['hp = hp + 10;', 'hp == 10;', 'hp + 10;', 'hp = 10;'], 'hp = hp + 10;', 'To update a variable, you assign it a new value.', 10, 'basic', 9),
  (ch1_id, 'Speak the magic word.', 'What is a piece of text called in coding?', 'String word = "Abracadabra";', ARRAY['String', 'Number', 'Boolean', 'Variable'], 'String', 'Textual data is called a String.', 10, 'basic', 10),

  -- 10 Intermediate Puzzles
  (ch1_id, 'The Mirror of Reflection.', 'If x = 10 and y = x, what is y?', 'var x = 10; var y = x;', ARRAY['10', 'x', '0', 'null'], '10', 'Variables can be assigned the value of other variables.', 15, 'intermediate', 11),
  (ch1_id, 'Type safety trial.', 'Can you store "Sword" in an int variable?', 'int item = "Sword";', ARRAY['No', 'Yes', 'Depends', 'Only in JS'], 'No', 'Dart is type-safe; you cannot put a String in an int.', 15, 'intermediate', 12),
  (ch1_id, 'The Unchanging Scroll.', 'What happens if you try to change a "const" value?', 'const x = 5; x = 10;', ARRAY['Error', 'x becomes 10', 'x stays 5', 'It works'], 'Error', 'Const values are fixed at compile-time and cannot change.', 15, 'intermediate', 13),
  (ch1_id, 'Joining forces.', 'What is the result of "Hello" + " Arin"?', 'var s = "Hello" + " Arin";', ARRAY['"Hello Arin"', '"HelloArin"', '"Hello+Arin"', 'Error'], '"Hello Arin"', 'Adding strings (concatenation) joins them together.', 15, 'intermediate', 14),
  (ch1_id, 'Shortcut to power.', 'How else can you write: level = level + 1?', 'level++;', ARRAY['level++;', 'level + 1;', 'level =+ 1;', 'level is 1;'], 'level++;', 'The "++" operator increments a number by 1.', 15, 'intermediate', 15),
  (ch1_id, 'The $ sign magic.', 'How to print: "Gold: 50" if gold = 50?', 'var gold = 50;', ARRAY['"Gold: $gold"', '"Gold: + gold"', '"Gold: #gold"', '"Gold: {gold}"'], '"Gold: $gold"', 'String interpolation uses $ to insert variables.', 15, 'intermediate', 16),
  (ch1_id, 'The Not-Gate.', 'What is !true?', 'bool x = !true;', ARRAY['false', 'true', 'null', '0'], 'false', 'The "!" operator flips a boolean value.', 15, 'intermediate', 17),
  (ch1_id, 'Calculation quest.', 'What is the result of 4 / 2?', 'var a = 4; var b = 2; var c = a / b;', ARRAY['2', '6', '8', '42'], '2', 'The "/" operator performs division.', 15, 'intermediate', 18),
  (ch1_id, 'Variable scope mystery.', 'If a variable is born in a box, can it leave?', '{ var x = 1; }\nprint(x);', ARRAY['No', 'Yes', 'Only if declared public', 'Maybe'], 'No', 'Variables are limited to the scope (braces) where they are defined.', 15, 'intermediate', 19),
  (ch1_id, 'The Initial State.', 'What is the value of: var name; before it is set?', 'var name;', ARRAY['null', '0', 'empty String', 'Error'], 'null', 'In Dart, variables are null by default unless initialized.', 15, 'intermediate', 20),

  -- 10 Advanced Puzzles
  (ch1_id, 'The Strictly Same trial.', 'Is 7 equal to "7"?', 'var result = (7 == "7");', ARRAY['False', 'True', 'Null', 'Error'], 'False', 'An integer and a string are never equal in Dart.', 20, 'advanced', 21),
  (ch1_id, 'Complex String magic.', 'How to print the length of "name" inside a string?', 'var name = "Arin";', ARRAY['"${name.length}"', '"$name.length"', '"$(name.length)"', '"name.length"'], '"${name.length}"', 'Use ${} for expressions inside strings.', 20, 'advanced', 22),
  (ch1_id, 'Final vs Const.', 'Which one is determined ONLY at runtime?', 'final x = DateTime.now();', ARRAY['final', 'const', 'var', 'dynamic'], 'final', 'Final is set once at runtime; const is compile-time.', 20, 'advanced', 23),
  (ch1_id, 'The Nullable Path.', 'How to allow an int to be null?', 'int? score;', ARRAY['int? score;', 'int score?;', 'null int score;', 'score: int?'], 'int? score;', 'The "?" marks a type as nullable.', 20, 'advanced', 24),
  (ch1_id, 'Dynamic shapeshifting.', 'Which type can change its data type?', 'dynamic x = 1; x = "Hi";', ARRAY['dynamic', 'var', 'Object', 'void'], 'dynamic', 'Dynamic types can change their type at any time.', 20, 'advanced', 25),
  (ch1_id, 'Var strictness.', 'var x = 10; x = "Text"; -- What happens?', 'var x = 10; x = "Text";', ARRAY['Error', 'x changes to "Text"', 'x stays 10', 'Nothing'], 'Error', '"var" infers a type (int) and stays strict.', 20, 'advanced', 26),
  (ch1_id, 'The "late" prophecy.', 'How to promise a variable will be set later?', 'late String x;', ARRAY['late', 'async', 'promise', 'final'], 'late', 'The "late" keyword promises a value before use.', 20, 'advanced', 27),
  (ch1_id, 'The Object Root.', 'What class do all non-null classes inherit from?', 'Object x = 1;', ARRAY['Object', 'Base', 'Root', 'Class'], 'Object', 'Everything in Dart is an Object.', 20, 'advanced', 28),
  (ch1_id, 'Modulo Riddle.', 'What is the remainder of 15 divided by 4?', 'var x = 15 % 4;', ARRAY['3', '1', '0', '4'], '3', 'Modulo (%) returns the remainder (15 / 4 = 3 remainder 3).', 20, 'advanced', 29),
  (ch1_id, 'The Final Battle.', 'If x is "final", can you set it in a constructor?', 'class A {\n  final int x;\n  A(this.x);\n}', ARRAY['Yes', 'No', 'Only if static', 'If x is null'], 'Yes', 'Final fields can be initialized in class constructors.', 20, 'advanced', 30);
END $$;
