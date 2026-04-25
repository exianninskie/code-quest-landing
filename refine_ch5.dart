import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient('https://rbqnbwklgwenqcfnqwes.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJicW5id2tsZ3dlbnFjZm5xd2VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2ODcxMzgsImV4cCI6MjA5MTI2MzEzOH0.vDZEIdmEvTZ02VwmLpyAVBNXofFXoMtRKmC2tYGDEi8');
  try {
    print('--- Cleaning Chapter 5 duplicates ---');
    // Delete all chapters with concept 'functions' or position 5
    // Cascade should handle the puzzles
    await supabase.from('chapters').delete().eq('concept', 'functions');
    
    print('--- Inserting Chapter 5: The Wizard\'s Spellbook ---');
    final chapterResponse = await supabase.from('chapters').insert({
      'title': 'The Wizard\'s Spellbook',
      'story': 'Ancient wizards didn\'t rewrite spells; they encapsulated them into reusable incantations. To master the craft, you must learn to forge your own functions!',
      'concept': 'functions',
      'position': 5,
      'image_url': 'https://rbqnbwklgwenqcfnqwes.supabase.co/storage/v1/object/public/assets/chapter_spellbook.png'
    }).select().single();
    
    final chapterId = chapterResponse['id'];
    
    final puzzles = [
      {
        'chapter_id': chapterId,
        'story_context': 'The Wizard holds a glowing orb. "A spell is just a name for a block of code!"',
        'question': 'What is the keyword used to define a function in Dart?',
        'code_snippet': '...',
        'options': ['void', 'func', 'function', 'define'],
        'correct_answer': 'void',
        'explanation': 'In Dart, you start with the return type (like void) or use a specific syntax, but "void" is the most common for actions.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 1
      },
      {
        'chapter_id': chapterId,
        'story_context': 'Naming a spell is the first step of magic.',
        'question': 'Which name follows the standard convention for a function that casts fire?',
        'code_snippet': '...',
        'options': ['castFire()', 'CastFire()', 'cast_fire()', 'CASTFIRE()'],
        'correct_answer': 'castFire()',
        'explanation': 'Functions usually use lowerCamelCase in Dart and many other languages.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 2
      },
      {
        'chapter_id': chapterId,
        'story_context': '"To make a spell real, you must speak its name," says the Wizard.',
        'question': 'How do you execute (call) a function named shout()?',
        'code_snippet': '...',
        'options': ['shout', 'shout()', 'call shout', 'run shout'],
        'correct_answer': 'shout()',
        'explanation': 'You call a function by adding parentheses () after its name.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 3
      },
      {
        'chapter_id': chapterId,
        'story_context': 'A healing spell requires a target.',
        'question': 'What do we call the inputs inside the parentheses of a function?',
        'code_snippet': 'void heal(Target t) { ... }',
        'options': ['Parameters', 'Strings', 'Variables', 'Results'],
        'correct_answer': 'Parameters',
        'explanation': 'Values passed into a function are called parameters (or arguments).',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 4
      },
      {
        'chapter_id': chapterId,
        'story_context': '"Sometimes a spell gives something back," the Wizard notes.',
        'question': 'Which keyword sends a value out of a function?',
        'code_snippet': '...',
        'options': ['return', 'give', 'output', 'send'],
        'correct_answer': 'return',
        'explanation': 'The return keyword exits a function and provides a result to the caller.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 5
      },
      {
        'chapter_id': chapterId,
        'story_context': 'A simple math spell to add two numbers.',
        'question': 'What is the return type of int add(int a, int b)?',
        'code_snippet': '...',
        'options': ['int', 'void', 'double', 'String'],
        'correct_answer': 'int',
        'explanation': 'The word before the function name determines what type of data it returns.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 6
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The "Nothing" Spell.',
        'question': 'What does void mean as a return type?',
        'code_snippet': '...',
        'options': ['Returns nothing', 'Returns 0', 'Returns an error', 'Returns a boolean'],
        'correct_answer': 'Returns nothing',
        'explanation': 'void indicates that the function performs an action but doesn''t return a value.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 7
      },
      {
        'chapter_id': chapterId,
        'story_context': 'You find a scroll with () => print("Ping");.',
        'question': 'What is this short function syntax called?',
        'code_snippet': '...',
        'options': ['Arrow function', 'Bow function', 'Pointer function', 'Ghost function'],
        'correct_answer': 'Arrow function',
        'explanation': 'The => syntax is a shorthand for functions with a single return expression.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 8
      },
      {
        'chapter_id': chapterId,
        'story_context': 'An anonymous spirit appears.',
        'question': 'What is a function called when it has no name?',
        'code_snippet': '...',
        'options': ['Anonymous function', 'Silent function', 'Invisible function', 'Static function'],
        'correct_answer': 'Anonymous function',
        'explanation': 'Functions without names are called anonymous functions or lambda expressions.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 9
      },
      {
        'chapter_id': chapterId,
        'story_context': 'Checking the scope of a spell.',
        'question': 'A variable declared inside a function is...',
        'code_snippet': '...',
        'options': ['Local', 'Global', 'Static', 'Eternal'],
        'correct_answer': 'Local',
        'explanation': 'Variables inside a function are local to that function and can''t be seen outside.',
        'xp_reward': 10,
        'difficulty': 'basic',
        'position': 10
      },
      // Intermediate (11-20)
      {
        'chapter_id': chapterId,
        'story_context': 'Optional ingredients for a potion.',
        'question': 'How do you make a parameter optional in Dart?',
        'code_snippet': 'void potion(String name, [int power])',
        'options': ['Square brackets []', 'Curly braces {}', 'Parentheses ()', 'Angle brackets <>'],
        'correct_answer': 'Square brackets []',
        'explanation': 'Positional optional parameters are wrapped in [].',
        'xp_reward': 15,
        'difficulty': 'intermediate',
        'position': 11
      },
      {
        'chapter_id': chapterId,
        'story_context': 'Named ingredients for a complex ritual.',
        'question': 'Which syntax is used for named parameters?',
        'code_snippet': 'void ritual({required String id})',
        'options': ['Curly braces {}', 'Square brackets []', 'Colons :', 'Dashes -'],
        'correct_answer': 'Curly braces {}',
        'explanation': 'Named parameters are wrapped in {} and make function calls very readable.',
        'xp_reward': 15,
        'difficulty': 'intermediate',
        'position': 12
      },
      {
        'chapter_id': chapterId,
        'story_context': 'A default value for a spell.',
        'question': 'In void light(int intensity = 10), what happens if you call light()?',
        'code_snippet': '...',
        'options': ['Intensity is 10', 'Intensity is 0', 'Error', 'Intensity is null'],
        'correct_answer': 'Intensity is 10',
        'explanation': 'Default parameters provide a backup value if the argument is omitted.',
        'xp_reward': 15,
        'difficulty': 'intermediate',
        'position': 13
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Wizard asks about required.',
        'question': 'What does the required keyword do in a named parameter?',
        'code_snippet': '...',
        'options': ['Forces the caller to provide it', 'Makes it optional', 'Hides it', 'Locks it'],
        'correct_answer': 'Forces the caller to provide it',
        'explanation': 'required ensures that a named parameter is always passed during a call.',
        'xp_reward': 15,
        'difficulty': 'intermediate',
        'position': 14
      },
      {
        'chapter_id': chapterId,
        'story_context': 'Passing a spell as an argument.',
        'question': 'Can you pass a function as a parameter to another function?',
        'code_snippet': '...',
        'options': ['Yes', 'No', 'Only in JS', 'Only in C++'],
        'correct_answer': 'Yes',
        'explanation': 'Functions are "first-class objects" in Dart and can be passed around like variables.',
        'xp_reward': 20,
        'difficulty': 'intermediate',
        'position': 15
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Higher-Order Spell.',
        'question': 'A function that takes or returns another function is called...?',
        'code_snippet': '...',
        'options': ['Higher-order function', 'Super function', 'Meta function', 'Root function'],
        'correct_answer': 'Higher-order function',
        'explanation': 'Higher-order functions enable powerful patterns like mapping and filtering.',
        'xp_reward': 15,
        'difficulty': 'intermediate',
        'position': 16
      },
      {
        'chapter_id': chapterId,
        'story_context': 'Returning a function.',
        'question': 'What happens here: var spell = () => () => print("Magic!");?',
        'code_snippet': '...',
        'options': ['spell()() prints Magic!', 'spell() prints Magic!', 'Error', 'Nothing'],
        'correct_answer': 'spell()() prints Magic!',
        'explanation': 'Since spell returns a function, you must call it twice to reach the print statement.',
        'xp_reward': 20,
        'difficulty': 'intermediate',
        'position': 17
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The static keyword.',
        'question': 'What is a function that belongs to a Class rather than an instance?',
        'code_snippet': '...',
        'options': ['Static function', 'Instance function', 'Member function', 'Local function'],
        'correct_answer': 'Static function',
        'explanation': 'Static methods are called on the class itself, not on an object created from it.',
        'xp_reward': 15,
        'difficulty': 'intermediate',
        'position': 18
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The getter/setter spell.',
        'question': 'A function that looks like a variable is...?',
        'code_snippet': '...',
        'options': ['Getter', 'Pointer', 'Link', 'Shadow'],
        'correct_answer': 'Getter',
        'explanation': 'Getters and setters allow you to run code when accessing or changing a property.',
        'xp_reward': 15,
        'difficulty': 'intermediate',
        'position': 19
      },
      {
        'chapter_id': chapterId,
        'story_context': 'Infinite power!',
        'question': 'What is the "main" function in a Dart app?',
        'code_snippet': '...',
        'options': ['The entry point', 'A helper', 'A constant', 'The exit'],
        'correct_answer': 'The entry point',
        'explanation': 'The main() function is where execution starts for every Dart program.',
        'xp_reward': 15,
        'difficulty': 'intermediate',
        'position': 20
      },
      // Advanced (21-30)
      {
        'chapter_id': chapterId,
        'story_context': 'The Mirror Mirror Spell.',
        'question': 'What is it called when a function calls itself?',
        'code_snippet': '...',
        'options': ['Recursion', 'Mirroring', 'Looping', 'Reflecting'],
        'correct_answer': 'Recursion',
        'explanation': 'Recursion is when a function invokes itself to solve smaller versions of a problem.',
        'xp_reward': 25,
        'difficulty': 'advanced',
        'position': 21
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Base Case of Recursion.',
        'question': 'Why do recursive functions need a "base case"?',
        'code_snippet': '...',
        'options': ['To stop infinite calls', 'To start the recursion', 'To calculate results', 'To use less memory'],
        'correct_answer': 'To stop infinite calls',
        'explanation': 'Without a base case, a recursive function will call itself until it hits a Stack Overflow.',
        'xp_reward': 25,
        'difficulty': 'advanced',
        'position': 22
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Closure Spell.',
        'question': 'A function that "remembers" its surrounding scope is a...?',
        'code_snippet': '...',
        'options': ['Closure', 'Memory', 'Static', 'Scope'],
        'correct_answer': 'Closure',
        'explanation': 'Closures store their lexical environment even after the outer function has finished.',
        'xp_reward': 30,
        'difficulty': 'advanced',
        'position': 23
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Wizard creates a counter with a closure.',
        'question': 'var c = counter(); c(); c(); What is the second value of count?',
        'code_snippet': 'var count = 0; return () => count++;',
        'options': ['1', '0', '2', 'Error'],
        'correct_answer': '1',
        'explanation': 'The closure increments and "remembers" the same count variable across calls.',
        'xp_reward': 30,
        'difficulty': 'advanced',
        'position': 24
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Tail Recursion optimization.',
        'question': 'A recursive call that is the very last action of a function is...?',
        'code_snippet': '...',
        'options': ['Tail recursion', 'End recursion', 'Back recursion', 'Last call'],
        'correct_answer': 'Tail recursion',
        'explanation': 'Tail recursion can often be optimized by the compiler to use less stack space.',
        'xp_reward': 25,
        'difficulty': 'advanced',
        'position': 25
      },
      {
        'chapter_id': chapterId,
        'story_context': 'Currying the spell.',
        'question': 'Transforming add(a, b) into add(a)(b) is called...?',
        'code_snippet': '...',
        'options': ['Currying', 'Spicing', 'Splitting', 'Wrapping'],
        'correct_answer': 'Currying',
        'explanation': 'Currying is the technique of translating a function with multiple arguments into a sequence of functions with single arguments.',
        'xp_reward': 30,
        'difficulty': 'advanced',
        'position': 26
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Pure Function.',
        'question': 'A function that always returns the same output for the same input and has NO side effects is...?',
        'code_snippet': '...',
        'options': ['Pure', 'Static', 'Solid', 'Reliable'],
        'correct_answer': 'Pure',
        'explanation': 'Pure functions are predictable and easier to test because they don''t change state outside.',
        'xp_reward': 25,
        'difficulty': 'advanced',
        'position': 27
      },
      {
        'chapter_id': chapterId,
        'story_context': 'Memoization Spell.',
        'question': 'Storing the result of expensive function calls for reuse is...?',
        'code_snippet': '...',
        'options': ['Memoization', 'Caching', 'Saving', 'Recalling'],
        'correct_answer': 'Memoization',
        'explanation': 'Memoization improves performance by caching results indexed by input arguments.',
        'xp_reward': 30,
        'difficulty': 'advanced',
        'position': 28
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Asynchronous Spell.',
        'question': 'Which keyword allows a function to use await?',
        'code_snippet': '...',
        'options': ['async', 'wait', 'future', 'later'],
        'correct_answer': 'async',
        'explanation': 'The async keyword marks a function as returning a Future and allows it to use await.',
        'xp_reward': 25,
        'difficulty': 'advanced',
        'position': 29
      },
      {
        'chapter_id': chapterId,
        'story_context': 'The Wizard\'s Final Test!',
        'question': 'What is the return type of func() if it is async and returns a String?',
        'code_snippet': '...',
        'options': ['Future<String>', 'String', 'void', 'dynamic'],
        'correct_answer': 'Future<String>',
        'explanation': 'Async functions always wrap their actual return type in a Future.',
        'xp_reward': 50,
        'difficulty': 'advanced',
        'position': 30
      }
    ];
    
    print('--- Inserting ${puzzles.length} puzzles ---');
    await supabase.from('puzzles').insert(puzzles);
    
    print('--- Chapter 5 Refined Successfully! ---');
  } catch (e) {
    print('Error during refinement: $e');
  }
}
