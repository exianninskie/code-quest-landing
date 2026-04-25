DO $$ 
DECLARE 
  ch1_id UUID;
BEGIN 
  -- Find the variables chapter
  SELECT id INTO ch1_id FROM chapters WHERE position = 1 LIMIT 1;
  
  -- Insert 29 epic puzzles
  INSERT INTO puzzles (chapter_id, story_context, question, code_snippet, type, options, correct_answer, explanation, xp_reward, position) VALUES 
  
  (ch1_id, 'The Keeper opens a rusty chest. "Numbers with no fractions are called integers!"', 'Which variable holds an integer?', 'goldCoins = 100\nweight = 12.5\nisHeavy = True', 'multipleChoice', array['goldCoins = 100', 'weight = 12.5', 'isHeavy = True'], 'goldCoins = 100', 'Integers are whole numbers without decimals.', 15, 2),
  
  (ch1_id, 'A mysterious scale tips. "Some numbers require precision," whispers the Keeper.', 'Which variable holds a floating-point (decimal) number?', 'speed = 45\naccuracy = 95.5\nname = "Arrow"', 'multipleChoice', array['speed = 45', 'accuracy = 95.5', 'name = "Arrow"'], 'accuracy = 95.5', 'Decimals are stored as floats or doubles.', 15, 3),
  
  (ch1_id, 'A magical toggle switch appears, glowing either light or dark.', 'Which of these is a Boolean variable?', 'hasMagic = True\npower = 9000\nspell = "Fireball"', 'multipleChoice', array['hasMagic = True', 'power = 9000', 'spell = "Fireball"'], 'hasMagic = True', 'Booleans only hold True or False values.', 15, 4),
  
  (ch1_id, '"To cast a spell, you must name it correctly," the ancient tome reads.', 'Which of the following is an INVALID variable name?', 'player_health = 100\n1stSpell = "Heal"\nmanaCost = 50', 'multipleChoice', array['player_health = 100', '1stSpell = "Heal"', 'manaCost = 50'], '1stSpell = "Heal"', 'Variable names cannot start with a number.', 20, 5),
  
  (ch1_id, 'You find a potion recipe. "The value can change over time!"', 'What is the final value of potions?', 'potions = 3\npotions = 5', 'multipleChoice', array['3', '5', '8'], '5', 'Variables take on the most recently assigned value.', 15, 6),
  
  (ch1_id, 'You combine two rare gems. "Math works wonderfully with variables."', 'What does totalGems equal?', 'redGems = 4\nblueGems = 3\ntotalGems = redGems + blueGems', 'multipleChoice', array['7', 'redGemsblueGems', '43'], '7', 'Integer variables add together using standard math.', 20, 7),
  
  (ch1_id, '"Letters can be forged together too," the blacksmith notes.', 'What is the value of fullName?', 'first = "Iron"\nlast = "Forge"\nfullName = first + last', 'multipleChoice', array['Iron', 'Forge', 'IronForge'], 'IronForge', 'Adding strings together is called concatenation.', 20, 8),
  
  (ch1_id, 'The Keeper writes something in stone. "This cannot be changed!"', 'What do we call a variable whose value cannot be reassigned?', '', 'multipleChoice', array['A String', 'A Constant', 'A Boolean'], 'A Constant', 'Constants (like const or final) are locked values.', 15, 9),
  
  (ch1_id, '"Beware," warns the Keeper, "capitalization matters in code!"', 'Are these two variables the SAME?', 'heroName = "Link"\nheroname = "Zelda"', 'multipleChoice', array['Yes, they are the same', 'No, they are different'], 'No, they are different', 'Variables are case-sensitive.', 15, 10),
  
  (ch1_id, 'You slay a goblin and gather its loot!', 'What is the final score?', 'score = 10\nscore = score + 5', 'multipleChoice', array['5', '10', '15'], '15', 'You can update a variable based on its own previous value.', 20, 11),
  
  (ch1_id, 'You discover an empty chest.', 'What is the value of a variable that hasn''t been given any data yet?', '', 'multipleChoice', array['0', 'False', 'Null / Undefined'], 'Null / Undefined', 'Empty variables hold a special lack-of-value state.', 15, 12),
  
  (ch1_id, 'An alchemy experiment goes wrong!', 'What happens when you run this code?', 'health = 100\nhealth = health + "Apples"', 'multipleChoice', array['health becomes 100Apples', 'Error: Type mismatch', 'health remains 100'], 'Error: Type mismatch', 'You generally cannot add text directly to an integer.', 20, 13),
  
  (ch1_id, 'The guild has a strict naming convention involving humps.', 'Which variable name uses camelCase?', '', 'multipleChoice', array['player_score = 10', 'PlayerScore = 10', 'playerScore = 10'], 'playerScore = 10', 'camelCase starts lowercase and capitalizes new words.', 15, 14),
  
  (ch1_id, 'The swamp relies on snake-like structures.', 'Which variable name uses snake_case?', '', 'multipleChoice', array['dragon_fire = 5', 'dragonFire = 5', 'DragonFire = 5'], 'dragon_fire = 5', 'snake_case uses underscores between lowercase words.', 15, 15),
  
  (ch1_id, 'You observe a knight swinging a sword repetitively. "Why use the number 5 everywhere?"', 'Why is it better to use a variable instead of a raw number?', '', 'multipleChoice', array['It uses less memory.', 'It makes code easier to read and update.', 'It makes the code run faster.'], 'It makes code easier to read and update.', 'Variables give meaning to raw numbers (avoiding magic numbers).', 20, 16),
  
  (ch1_id, '"Sometimes numbers are hidden in quotes," says the trickster.', 'Is this an integer or a string?', 'age = "25"', 'multipleChoice', array['Integer', 'String', 'Boolean'], 'String', 'Anything inside quotes is treated as text (String).', 15, 17),
  
  (ch1_id, 'You spend 15 coins at the merchant.', 'What is the final gold amount?', 'gold = 50\ngold = gold - 15', 'multipleChoice', array['35', '15', '65'], '35', 'You can directly subtract values in assignments.', 15, 18),
  
  (ch1_id, 'A curse halves your health!', 'What is the final hp?', 'hp = 100\nhp = hp / 2', 'multipleChoice', array['100', '2', '50'], '50', 'Variables handle division perfectly.', 15, 19),
  
  (ch1_id, 'The Keeper asks you to differentiate action from description.', 'Which symbol assigns a value to a variable?', '', 'multipleChoice', array['+', '=', '=='], '=', 'A single equals sign (=) assigns a value.', 15, 20),
  
  (ch1_id, 'A shortcut scroll drops from a monster.', 'What is shorthand for `score = score + 1`?', '', 'multipleChoice', array['score++', 'score =+ 1', 'score+1'], 'score++', 'The ++ operator increments a variable by 1.', 20, 21),
  
  (ch1_id, 'You toggle a magical shield.', 'What is the final state of shieldOn?', 'shieldOn = True\nshieldOn = !shieldOn', 'multipleChoice', array['True', 'False', 'Null'], 'False', 'The exclamation mark (!) toggles a Boolean to its opposite.', 25, 22),
  
  (ch1_id, '"Can variable types change?" you ask the wizard.', 'In a dynamically typed language (like Python), is this allowed?', 'weapon = "Sword"\nweapon = 99', 'multipleChoice', array['Yes', 'No'], 'Yes', 'Dynamic languages allow variables to hold different types over time.', 25, 23),
  
  (ch1_id, 'You look at two similar spellbooks.', 'Do these hold the same text?', 'spell1 = "Fire"\nspell2 = ''Fire''', 'multipleChoice', array['Yes', 'No'], 'Yes', 'Most languages treat single and double quotes identically for strings.', 15, 24),
  
  (ch1_id, 'You find a string containing a variable inside it.', 'What will `print($"Level: {level}")` output if level = 5?', '', 'multipleChoice', array['Level: {level}', 'Level: 5', 'Error'], 'Level: 5', 'This is String Interpolation, inserting variables into text.', 25, 25),
  
  (ch1_id, 'A local traveler refuses to share items with the global world.', 'A variable created inside a function that can''t be accessed outside is...', '', 'multipleChoice', array['Global', 'Local', 'Constant'], 'Local', 'Local variables only exist within their specific scope.', 20, 26),
  
  (ch1_id, 'You must swap the contents of two chests.', 'Which extra piece is needed?', 'chestA = 1\nchestB = 2\ntemp = chestA\nchestA = chestB\n_______', 'multipleChoice', array['chestB = 1', 'chestB = temp', 'chestB = chestA'], 'chestB = temp', 'A temporary variable is crucial to swap two values!', 30, 27),
  
  (ch1_id, 'You double your inventory stack!', 'What does stack equal?', 'stack = 16\nstack *= 2', 'multipleChoice', array['18', '32', '162'], '32', 'The *= operator multiplies the variable by the number.', 20, 28),
  
  (ch1_id, 'The trickster gives you one final equation.', 'What is the output?', 'x = "10"\ny = "10"\nresult = x + y', 'multipleChoice', array['20', '1010', 'Error'], '1010', 'Adding two strings results in sequence concatenation, not math!', 25, 29),
  
  (ch1_id, 'The Final Variable Boss Room!', 'What is the final value of x?', 'x = 5\nx = x + 3\nx = x * 2\nx = x - 6', 'multipleChoice', array['10', '16', '12'], '10', '5+3=8, 8*2=16, 16-6=10.', 50, 30);

END $$;
