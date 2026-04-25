-- ─────────────────────────────────────────────────────────
-- Migration 106: Grant "Button Chaser" badge to old users
-- For all users who joined before 2026-04-24
-- ─────────────────────────────────────────────────────────

UPDATE public.profiles 
SET button_chaser_unlocked = true 
WHERE created_at < '2026-04-24T00:00:00+08:00';
