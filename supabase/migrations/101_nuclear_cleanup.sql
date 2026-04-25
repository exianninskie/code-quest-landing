-- Migration 101: Nuclear Cleanup and Grotto Deployment
-- Removes all chapters at position 5 or higher to clear legacy data, 
-- then deploys the Glitchy Grotto and its 30 puzzles.

DO $$
DECLARE
  ch5_id UUID;
BEGIN
  -- 1. Wipe out any potential legacy chapters from positions 5, 6, 7, etc.
  -- This permanently removes the "Alchemist", "Crystal Cavern", etc. that were in 016
  DELETE FROM chapters WHERE position >= 5;

  -- 2. Create Chapter 5: The Glitchy Grotto (Fresh)
  INSERT INTO chapters (title, story, concept, position, image_url, is_unlocked_by_default)
  VALUES (
    'The Glitchy Grotto',
    'A tear in the source code has opened a portal to the Glitchy Grotto. Here, the very foundations of logic are crumbling. You must find the missing fragments to restore order. Beware: every failure costs you XP!',
    'debugging',
    5,
    'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?auto=format&fit=crop&q=80&w=800',
    true
  )
  RETURNING id INTO ch5_id;

  -- 3. Insert 30 "Fill in the Blank" Puzzles (Debugging focus)
  INSERT INTO puzzles (chapter_id, story_context, question, code_snippet, type, options, correct_answer, explanation, xp_reward, difficulty, position, hint) VALUES
  (ch5_id, 'A script for a healing potion is failing.', 'Fill in the missing semicolon to terminate the statement.', 'var health = 100__', 'fillInTheBlank', ARRAY[]::text[], ';', 'Statements in many languages must end with a semicolon.', 20, 'basic', 1, ''),
  (ch5_id, 'The gatekeeper needs your name, but the string is broken.', 'Fix the closing quote for this string variable.', 'var name = "Galahad__', 'fillInTheBlank', ARRAY[]::text[], '"', 'Strings must be enclosed in matching quotes.', 20, 'basic', 2, ''),
  (ch5_id, 'A mathematical formula is missing its operator.', 'Add the assignment operator to store the value 42 in x.', 'var x __ 42;', 'fillInTheBlank', ARRAY[]::text[], '=', 'The = operator assigns a value to a variable.', 20, 'basic', 3, ''),
  (ch5_id, 'A loop is running forever! It needs a condition.', 'Complete the condition so it stops when i is 5.', 'for (var i = 0; i < __; i++)', 'fillInTheBlank', ARRAY[]::text[], '5', 'The loop condition determines when it should stop executing.', 20, 'basic', 4, ''),
  (ch5_id, 'The alchemist forgot to keyword their variable.', 'Fill in the keyword used to declare a variable that can be reassigned.', '____ level = 1;', 'fillInTheBlank', ARRAY[]::text[], 'var', 'The var keyword is used for standard variable declarations.', 20, 'basic', 5, ''),
  (ch5_id, 'A spells function is missing its body markers.', 'Add the opening brace for the function body.', 'void cast() __ }', 'fillInTheBlank', ARRAY[]::text[], '{', 'Function bodies are defined within curly braces { }.', 20, 'basic', 6, ''),
  (ch5_id, 'The conditional trial is missing its else.', 'What keyword provides an alternative path when if is false?', 'if (isDay) { } ____ { }', 'fillInTheBlank', ARRAY[]::text[], 'else', 'The else block executes when the if condition is false.', 20, 'basic', 7, ''),
  (ch5_id, 'A list of items is missing its separator.', 'Add the missing character to separate these two array items.', '[ "Sword"__ "Shield" ]', 'fillInTheBlank', ARRAY[]::text[], ',', 'Array elements must be separated by commas.', 20, 'basic', 8, ''),
  (ch5_id, 'The return of the king! But the function returns nothing.', 'Add the keyword that sends a value back from a function.', '____ true;', 'fillInTheBlank', ARRAY[]::text[], 'return', 'The return keyword exits a function and provides a result.', 20, 'basic', 9, ''),
  (ch5_id, 'A class is being built but its name is missing.', 'Complete the keyword to define this structure.', '_____ Hero { }', 'fillInTheBlank', ARRAY[]::text[], 'class', 'The class keyword defines a new object type.', 20, 'basic', 10, ''),
  (ch5_id, 'The inventory check is backwards.', 'Use the GREATER THAN operator to check if gold is more than 100.', 'if (gold __ 100)', 'fillInTheBlank', ARRAY[]::text[], '>', 'Positive logic checks for values above a threshold.', 20, 'intermediate', 11, ''),
  (ch5_id, 'A null check is missing.', 'What is the NULL keyword in many languages?', 'if (item == ____)', 'fillInTheBlank', ARRAY[]::text[], 'null', 'Null represents the absence of a value.', 20, 'intermediate', 12, ''),
  (ch5_id, 'The hero is taking double damage by mistake!', 'Fix the decrement operator to only subtract 1 from health.', 'health____;', 'fillInTheBlank', ARRAY[]::text[], '--', 'The -- operator decrements a value by exactly one.', 20, 'intermediate', 13, ''),
  (ch5_id, 'The string interpolation is broken.', 'Add the character used before a variable inside a string.', 'print("Hello, __name");', 'fillInTheBlank', ARRAY[]::text[], '$', 'In Dart and many modern languages, $ is used for string interpolation.', 20, 'intermediate', 14, ''),
  (ch5_id, 'A Boolean logic error is letting anyone pass.', 'Use the AND operator to require both a key AND a password.', 'if (hasKey ____ hasPassword)', 'fillInTheBlank', ARRAY[]::text[], '&&', 'The && operator requires both conditions to be true.', 20, 'intermediate', 15, ''),
  (ch5_id, 'The OR logic is confusing the guards.', 'Use the OR operator to allow entry if you have a badge OR a bribe.', 'if (hasBadge ____ hasBribe)', 'fillInTheBlank', ARRAY[]::text[], '||', 'The || operator requires at least one condition to be true.', 20, 'intermediate', 16, ''),
  (ch5_id, 'A variable that should never change was accidentally marked var.', 'Change it to the keyword for a constant that is set once.', '____ Pi = 3.14;', 'fillInTheBlank', ARRAY[]::text[], 'final', 'Final variables can only be assigned once.', 20, 'intermediate', 17, ''),
  (ch5_id, 'An async function is missing its wait keyword.', 'Add the keyword used to pause until a future completes.', 'var data = _____ fetch();', 'fillInTheBlank', ARRAY[]::text[], 'await', 'Await pauses execution until an asynchronous operation finishes.', 20, 'intermediate', 18, ''),
  (ch5_id, 'The constructor is named incorrectly.', 'In many languages, what is the keyword for the current instance?', '____.health = 100;', 'fillInTheBlank', ARRAY[]::text[], 'this', 'The this keyword refers to the current object instance.', 20, 'intermediate', 19, ''),
  (ch5_id, 'A division by zero error is looming.', 'Which operator provides the REMAINDER of division?', '10 __ 3', 'fillInTheBlank', ARRAY[]::text[], '%', 'The % operator returns the remainder.', 20, 'intermediate', 20, ''),
  (ch5_id, 'The list index is out of bounds.', 'What is the index of the FIRST item in an array?', 'items[__]', 'fillInTheBlank', ARRAY[]::text[], '0', 'Arrays are zero-indexed in most programming languages.', 20, 'advanced', 21, ''),
  (ch5_id, 'A type check is failing.', 'What keyword checks if an object is of a specific type?', 'if (hero ____ Warrior)', 'fillInTheBlank', ARRAY[]::text[], 'is', 'The is operator performs runtime type checking.', 20, 'advanced', 22, ''),
  (ch5_id, 'An infinite recursion is detected.', 'What is missing? A base case.', '...', 'fillInTheBlank', ARRAY[]::text[], 'base', 'Recursive functions must have a base case to terminate.', 20, 'advanced', 23, ''),
  (ch5_id, 'A private variable is leaked.', 'What character is often used as a prefix for private members in Dart?', 'var __secret = 1;', 'fillInTheBlank', ARRAY[]::text[], '_', 'The underscore prefix marks a variable as library-private.', 20, 'advanced', 24, ''),
  (ch5_id, 'A map/dictionary lookup is failing.', 'What character is used to access a property in many languages?', 'hero____name', 'fillInTheBlank', ARRAY[]::text[], '.', 'The dot operator is used to access properties and methods.', 20, 'advanced', 25, ''),
  (ch5_id, 'The promise/future chain is missing its completion handler.', 'What method is called when a future finishes successfully?', 'fetch().____((data) => ...)', 'fillInTheBlank', ARRAY[]::text[], 'then', 'The .then() method handles the result of a successful future.', 20, 'advanced', 26, ''),
  (ch5_id, 'An error is being ignored.', 'What block catches an exception?', 'try { } ____ (e) { }', 'fillInTheBlank', ARRAY[]::text[], 'catch', 'The catch block handles errors thrown in the try block.', 20, 'advanced', 27, ''),
  (ch5_id, 'A variable is allowed to be null when it shouldnt be.', 'Remove the character that makes a type nullable.', 'String__ name', 'fillInTheBlank', ARRAY[]::text[], '?', 'The ? suffix indicates a type is nullable.', 20, 'advanced', 28, ''),
  (ch5_id, 'A static method is being called on an instance.', 'To call a static method, use the class name.', '...', 'fillInTheBlank', ARRAY[]::text[], 'class', 'Static members belong to the class itself, not instances.', 20, 'advanced', 29, ''),
  (ch5_id, 'The final trial: A bitwise operator is misused.', 'What is the NOT bitwise operator?', '__flag', 'fillInTheBlank', ARRAY[]::text[], '~', 'The tilde ~ is the bitwise NOT operator.', 20, 'advanced', 30, '');
END $$;
