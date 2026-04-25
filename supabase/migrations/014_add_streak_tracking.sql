-- ─────────────────────────────────────────────────────────
-- Migration 014: Add streak tracking to profiles
-- ─────────────────────────────────────────────────────────

-- 1. Add columns to profiles table
ALTER TABLE public.profiles 
ADD COLUMN last_active_at TIMESTAMPTZ,
ADD COLUMN current_streak INT NOT NULL DEFAULT 0,
ADD COLUMN longest_streak INT NOT NULL DEFAULT 0;

-- 2. Create function to update streak
CREATE OR REPLACE FUNCTION public.update_user_streak(user_id_param UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    last_active DATE;
    today DATE := CURRENT_DATE;
BEGIN
    -- Get last activity date
    SELECT (last_active_at AT TIME ZONE 'UTC')::DATE INTO last_active
    FROM public.profiles
    WHERE id = user_id_param;

    IF last_active IS NULL THEN
        -- First time active
        UPDATE public.profiles
        SET 
            last_active_at = NOW(),
            current_streak = 1,
            longest_streak = GREATEST(longest_streak, 1)
        WHERE id = user_id_param;
    ELSIF last_active = today THEN
        -- Already active today, just update the timestamp
        UPDATE public.profiles
        SET last_active_at = NOW()
        WHERE id = user_id_param;
    ELSIF last_active = today - INTERVAL '1 day' THEN
        -- Active yesterday, increment streak
        UPDATE public.profiles
        SET 
            last_active_at = NOW(),
            current_streak = current_streak + 1,
            longest_streak = GREATEST(longest_streak, current_streak + 1)
        WHERE id = user_id_param;
    ELSE
        -- Missed a day, reset streak to 1
        UPDATE public.profiles
        SET 
            last_active_at = NOW(),
            current_streak = 1,
            longest_streak = GREATEST(longest_streak, 1)
        WHERE id = user_id_param;
    END IF;
END;
$$;
