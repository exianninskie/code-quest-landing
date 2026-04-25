-- ─────────────────────────────────────────────────────────
-- Migration 105: Add "Button Chaser" badge to profiles
-- Easter egg badge for users who caught the chasing button
-- ─────────────────────────────────────────────────────────

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS button_chaser_unlocked BOOLEAN NOT NULL DEFAULT FALSE;
