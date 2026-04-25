-- ─────────────────────────────────────────────────────────
-- Migration 015: Remove streak tracking & simplify activity
-- ─────────────────────────────────────────────────────────

-- 1. Remove streak columns from profiles
ALTER TABLE public.profiles 
DROP COLUMN IF EXISTS current_streak,
DROP COLUMN IF EXISTS longest_streak;

-- 2. Simplify and rename the activity update function
-- We keep the old name 'update_user_streak' for a moment or create a new one
-- to ensure the app doesn't break during the transition.
-- Better yet, we just update the existing function to be simple.

CREATE OR REPLACE FUNCTION public.update_user_streak(user_id_param UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.profiles
    SET last_active_at = NOW()
    WHERE id = user_id_param;
END;
$$;

-- Alias it for better naming in the future if we want
CREATE OR REPLACE FUNCTION public.update_user_last_active(user_id_param UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    PERFORM public.update_user_streak(user_id_param);
END;
$$;
