-- Migration 018: Repair schema for Puzzles and Chapters
-- Adds missing columns used by newer chapters and the debugging quest.

DO $$
BEGIN
    -- 1. Add 'type' column to puzzles if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'puzzles' AND column_name = 'type') THEN
        ALTER TABLE puzzles ADD COLUMN type TEXT NOT NULL DEFAULT 'multipleChoice';
    END IF;

    -- 2. Add 'hint' column to puzzles if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'puzzles' AND column_name = 'hint') THEN
        ALTER TABLE puzzles ADD COLUMN hint TEXT DEFAULT '';
    END IF;

    -- 3. Add 'is_unlocked_by_default' to chapters if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'chapters' AND column_name = 'is_unlocked_by_default') THEN
        ALTER TABLE chapters ADD COLUMN is_unlocked_by_default BOOLEAN DEFAULT FALSE;
    END IF;

    -- 4. Ensure total_xp cannot be negative
    IF NOT EXISTS (SELECT 1 FROM information_schema.constraint_column_usage WHERE table_name = 'profiles' AND constraint_name = 'total_xp_non_negative') THEN
        ALTER TABLE profiles ADD CONSTRAINT total_xp_non_negative CHECK (total_xp >= 0);
    END IF;
END $$;
