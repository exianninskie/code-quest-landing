-- ─────────────────────────────────────────────────────────
-- Migration 001: Initial schema for Code Quest (RESTORATION VERSION)
-- Run this in: Supabase Dashboard → SQL Editor → New query
-- ─────────────────────────────────────────────────────────

-- Enable UUID generation
create extension if not exists "uuid-ossp";

-- Cleanup existing schema (WARNING: This deletes ALL data to ensure a clean restoration!)
drop table if exists player_progress cascade;
drop table if exists puzzles cascade;
drop table if exists chapters cascade;
drop table if exists profiles cascade;
drop function if exists handle_new_user() cascade;
drop function if exists increment_user_xp(uuid, int) cascade;


-- ─── Profiles ───────────────────────────────────────────
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text not null,
  avatar_url  text,
  total_xp    int  not null default 0,
  created_at  timestamptz not null default now()
);

-- Trigger: auto-create profile row when a new user signs up
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'adventurer')
  )
  on conflict (id) do nothing;
  return new;
exception when others then
  -- Log error or just allow the user creation to continue
  return new;
end;
$$;

-- Re-setup trigger
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ─── Chapters ────────────────────────────────────────────
create table chapters (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  story       text not null,
  concept     text not null,
  position    int  not null,
  image_url   text,
  created_at  timestamptz not null default now()
);


-- ─── Puzzles ─────────────────────────────────────────────
create table puzzles (
  id              uuid primary key default uuid_generate_v4(),
  chapter_id      uuid not null references chapters(id) on delete cascade,
  story_context   text not null,
  question        text not null,
  code_snippet    text not null,
  options         text[] not null,
  correct_answer  text not null,
  explanation     text not null,
  xp_reward       int  not null default 10,
  difficulty      text not null default 'basic',
  position        int  not null,       -- Order within the chapter
  created_at      timestamptz not null default now()
);


-- ─── Player progress ────────────────────────────────────
create table player_progress (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  puzzle_id    uuid not null references puzzles(id) on delete cascade,
  completed    boolean not null default false,
  xp_earned    int  not null default 0,
  completed_at timestamptz,
  unique (user_id, puzzle_id)
);


-- ─── RPC: Increment XP ──────────────────────────────────
create or replace function increment_user_xp(
  user_id_param uuid,
  xp_amount     int
)
returns void as $$
begin
  update public.profiles
  set    total_xp = total_xp + xp_amount
  where  id = user_id_param;
end;
$$ language plpgsql security definer;


-- ─── Row Level Security (RLS) ────────────────────────────
alter table profiles        enable row level security;
alter table player_progress enable row level security;
alter table chapters        enable row level security;
alter table puzzles         enable row level security;

create policy "Profiles are viewable by everyone" on profiles for select using (true);
create policy "Users can update their own profile" on profiles for update using (auth.uid() = id);
create policy "Users can view their own progress" on player_progress for select using (auth.uid() = user_id);
create policy "Users can insert their own progress" on player_progress for insert with check (auth.uid() = user_id);
create policy "Users can update their own progress" on player_progress for update using (auth.uid() = user_id);
create policy "Chapters are viewable by everyone" on chapters for select using (true);
create policy "Puzzles are viewable by everyone" on puzzles for select using (true);


-- ─── Seed: Chapters ─────────────────────────────────────
insert into chapters (title, story, concept, position, image_url) values
(
  'The Enchanted Library',
  'You arrive at a vast library. Ancient tomes line the walls, each labelled and sorted. The Keeper whispers: "Everything here is stored in a named container — a variable."',
  'variables',
  1,
  'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&q=80&w=800'
),
(
  'The Weaver''s Loom',
  'You find a loom where threads are woven into tapestry. Every thread is a character, and together they form a String — the language of the realm.',
  'strings',
  2,
  'https://images.unsplash.com/photo-1544377193-33dcf4d68fb5?auto=format&fit=crop&q=80&w=800'
),
(
  'The Whispering Forest',
  'Two paths diverge in the dark wood. A stone tablet glows: "Only those who carry a sword may pass through the eastern gate." This is your first conditional.',
  'conditionals',
  3,
  'https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&q=80&w=800'
),
(
  'The Eternal Staircase',
  'You find a staircase that never ends — unless you know how to use a loop. Repeat, repeat, until the condition breaks.',
  'loops',
  4,
  'https://images.unsplash.com/photo-1519750157634-b6d493a0f77c?auto=format&fit=crop&q=80&w=800'
);


-- ─── Seed: 30 Puzzles for Chapter 1 (Variables) ─────────
DO $$ 
DECLARE 
  ch1_id UUID;
BEGIN 
  SELECT id INTO ch1_id FROM chapters WHERE concept = 'variables' LIMIT 1;

  -- Basic Puzzles (1-10)
  INSERT INTO puzzles (chapter_id, story_context, question, code_snippet, options, correct_answer, explanation, xp_reward, difficulty, position) VALUES
  (ch1_id, 'The Keeper shows you a box with the name "gold".', 'How do you declare a variable named gold with value 50?', 'var gold = 50;', ARRAY['var gold = 50;', 'gold := 50;', 'int 50 = gold;', 'gold = var 50;'], 'var gold = 50;', 'Use "var" followed by the name and then the value.', 10, 'basic', 1),
  (ch1_id, 'A scroll requires a name.', 'Which stores a string value?', 'var name = "Arin";', ARRAY['var name = "Arin";', 'var name = 123;', 'var name = true;', 'var name = 5.5;'], 'var name = "Arin";', 'Strings are always wrapped in quotes.', 10, 'basic', 2),
  (ch1_id, 'You find a bag of gems.', 'Assign 10 to the gems variable.', 'var gems = 10;', ARRAY['var gems = 10;', 'gems == 10;', '10 -> gems;', 'gems : 10;'], 'var gems = 10;', 'The "=" operator is used for assignment.', 10, 'basic', 3),
  (ch1_id, 'A hero needs a health value.', 'Which is a whole number (int)?', 'var hp = 100;', ARRAY['var hp = 100;', 'var hp = "100";', 'var hp = 100.0;', 'var hp = true;'], 'var hp = 100;', 'Integers are whole numbers without decimals or quotes.', 10, 'basic', 4),
  (ch1_id, 'The gatekeeper asks if you have a key.', 'Which variable type stores true or false?', 'var hasKey = true;', ARRAY['bool', 'int', 'String', 'double'], 'bool', 'Booleans (bool) specifically store true or false values.', 10, 'basic', 5),
  (ch1_id, 'Variables must have good labels.', 'Which name is valid in many realms?', 'hero_name', ARRAY['hero name', '1stHero', 'hero_name', 'hero!name'], 'hero_name', 'Variable names cannot have spaces or start with numbers.', 10, 'basic', 6),
  (ch1_id, 'Store the cost of a magic potion.', 'Which is a double (decimal)?', 'var price = 15.5;', ARRAY['15.5', '15', '"15.5"', 'true'], '15.5', 'Doubles are used for decimal numbers.', 10, 'basic', 7),
  (ch1_id, 'Constants never change.', 'How do you declare a value that is fixed forever?', 'final pi = 3.14;', ARRAY['final pi = 3.14;', 'var pi = 3.14;', 'pi = 3.14;', 'changeable pi = 3.14;'], 'final pi = 3.14;', '"final" or "const" are used for immutable values.', 10, 'basic', 8),
  (ch1_id, 'Combine your power.', 'What is the sum of a (10) and b (5)?', 'var total = a + b;', ARRAY['15', '10.5', '50', '2'], '15', 'Arithmetic works normally with number variables.', 10, 'basic', 9),
  (ch1_id, 'Empty your pockets.', 'How do you declare an uninitialized variable?', 'var x;', ARRAY['var x;', 'var x = nothing;', 'null x;', 'x = var;'], 'var x;', 'You can declare a variable name without giving it a value immediately.', 10, 'basic', 10),

  -- Intermediate Puzzles (11-20)
  (ch1_id, 'A magical swap.', 'If x=5 and y=x, what is y?', 'var y = x;', ARRAY['5', 'x', 'null', '0'], '5', 'Assigning one variable to another copies its current value.', 15, 'intermediate', 11),
  (ch1_id, 'Type safety is key.', 'Can you assign "Text" to an int variable?', 'int score = "High";', ARRAY['Yes', 'No', 'Only on Sundays', 'If you use quotes'], 'No', 'You cannot store a String in an integer variable.', 15, 'intermediate', 12),
  (ch1_id, 'The power of final.', 'What happens if you try to change a final variable?', 'final x = 1; x = 2;', ARRAY['Error', 'x becomes 2', 'x stays 1', 'Computer explodes'], 'Error', 'Final variables can only be set once.', 15, 'intermediate', 13),
  (ch1_id, 'Combining strands.', 'What is "Hello" + " World"?', 'var msg = "Hello" + " World";', ARRAY['"Hello World"', '"HelloWorld"', '"Hello+World"', 'Error'], '"Hello World"', 'Adding strings together is called concatenation.', 15, 'intermediate', 14),
  (ch1_id, 'The hero grows.', 'How to increment level by 1?', 'level = level + 1;', ARRAY['level = level + 1;', 'level += 1;', 'level++;', 'All of the above'], 'All of the above', 'There are multiple ways to increase a number variable.', 15, 'intermediate', 15),
  (ch1_id, 'Interpolation magic.', 'How to put the name inside "Greetings, name"?', '"Greetings, $name"', ARRAY['"Greetings, $name"', '"Greetings, + name"', '"Greetings, " + name', '1 and 3 are correct'], '1 and 3 are correct', 'Dart uses $ for string interpolation or + for concatenation.', 15, 'intermediate', 16),
  (ch1_id, 'Boolean flip.', 'If it is NOT true, what is it?', '!true', ARRAY['false', 'true', 'null', 'Error'], 'false', 'The "!" operator negates a boolean value.', 15, 'intermediate', 17),
  (ch1_id, 'Multiplication trial.', 'var a = 2; var b = 3; var c = a * b;', ARRAY['6', '5', '8', '23'], '6', 'The "*" operator is used for multiplication.', 15, 'intermediate', 18),
  (ch1_id, 'Variable scope.', 'If level is declared inside a house, can we see it outside?', '...', ARRAY['No', 'Yes', 'Only if the door is open', 'Sometimes'], 'No', 'Variables are typically limited to the block they are declared in.', 15, 'intermediate', 19),
  (ch1_id, 'The value of nothing.', 'What is the default value of an uninitialized variable?', 'var x;', ARRAY['null', '0', 'undefined', 'empty'], 'null', 'In Dart, variables without values are null by default unless specified.', 15, 'intermediate', 20),

  -- Advanced Puzzles (21-30)
  (ch1_id, 'Comparing types.', 'Is 5 equal to "5"?', '5 == "5"', ARRAY['False', 'True', 'Depends', 'Error'], 'False', 'A number is not equal to a string containing that number.', 20, 'advanced', 21),
  (ch1_id, 'Complex interpolation.', 'How to print the length of name?', '"Length is ${name.length}"', ARRAY['"${name.length}"', '"$name.length"', '"{name.length}"', 'None'], '"${name.length}"', 'Use curly braces ${} for expressions inside strings.', 20, 'advanced', 22),
  (ch1_id, 'Const vs Final.', 'Which is evaluated at compile-time?', '...', ARRAY['const', 'final', 'both', 'neither'], 'const', 'Const is a compile-time constant, final is set only once at runtime.', 20, 'advanced', 23),
  (ch1_id, 'Strict typing.', 'How to declare a variable that CAN be null?', 'int? score;', ARRAY['int? score;', 'int score?;', 'null int score;', 'score: int?'], 'int? score;', 'The "?" marks a type as nullable.', 20, 'advanced', 24),
  (ch1_id, 'Dynamic chaos.', 'Which type can change its data type at runtime?', 'dynamic x = 1; x = "A";', ARRAY['dynamic', 'var', 'Object', 'Any'], 'dynamic', 'The "dynamic" type skips static type checking.', 20, 'advanced', 25),
  (ch1_id, 'Var inference.', 'Once var x = 5 is set, can x become "Text"?', 'var x = 5; x = "Hi";', ARRAY['No', 'Yes', 'Only if you ask nicely', 'Yes, because of var'], 'No', '"var" infers the type (int) and keeps it strictly.', 20, 'advanced', 26),
  (ch1_id, 'Late initialization.', 'How to declare a variable that will be set LATER?', 'late String name;', ARRAY['late', 'async', 'future', 'wait'], 'late', 'The "late" keyword tells Dart the value will be set before use.', 20, 'advanced', 27),
  (ch1_id, 'Object base.', 'What is the base class of all non-nullable types?', '...', ARRAY['Object', 'Base', 'Class', 'Root'], 'Object', 'Everything in Dart is an Object.', 20, 'advanced', 28),
  (ch1_id, 'Division remainder.', 'What is 10 % 3?', 'var mod = 10 % 3;', ARRAY['1', '3', '0', '0.33'], '1', 'The character "%" (modulo) gives the remainder of a division.', 20, 'advanced', 29),
  (ch1_id, 'Final frontier.', 'Can a final variable be part of a class?', 'class A { final int x; }', ARRAY['Yes', 'No', 'Only if static', 'If initialized in constructor'], 'Yes', 'Final fields are common in classes, often set in constructors.', 20, 'advanced', 30);
END $$;


-- ─── AUTH REPAIR: Sync profiles for existing users ───────
-- This ensures that users who already exist in auth.users 
-- get a profile record if they lost it during the reset.
insert into public.profiles (id, username)
select id, coalesce(raw_user_meta_data->>'username', 'adventurer')
from auth.users
on conflict (id) do nothing;