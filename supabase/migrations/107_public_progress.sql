-- Migration 107: Make player progress public for Soullink Profiles
-- This allows users to see each other's unlocked chapters and badges.

-- 1. Drop the restrictive select policy
DROP POLICY IF EXISTS "Users can view their own progress" ON player_progress;

-- 2. Create the open select policy
CREATE POLICY "Progress is viewable by everyone" ON player_progress
FOR SELECT USING (true);

-- 3. Ensure other policies remain restrictive for mutations
-- (Already exist: "Users can insert their own progress" and "Users can update their own progress")
