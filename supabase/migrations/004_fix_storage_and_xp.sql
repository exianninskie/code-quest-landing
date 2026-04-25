-- ─────────────────────────────────────────────────────────
-- Migration 004: Fix Storage and XP logic
-- ─────────────────────────────────────────────────────────

-- 1. Ensure the 'avatars' bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatars" ON storage.objects;

-- 3. Create Storage Policies
-- Allow anyone to view any avatar (Public bucket)
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

-- Allow authenticated users to upload new avatars
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
);

-- Allow users to update their own avatars
CREATE POLICY "Users can update their own avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING ( bucket_id = 'avatars' AND auth.uid() = owner );

-- Allow users to delete their own avatars
CREATE POLICY "Users can delete their own avatars"
ON storage.objects FOR DELETE
TO authenticated
USING ( bucket_id = 'avatars' AND auth.uid() = owner );


-- 4. XP Recalculation & Repair
-- Sometimes the frontend might miss an XP increment if the connection drops.
-- This function will scan all player_progress and set the profile total_xp correctly.
CREATE OR REPLACE FUNCTION recalculate_all_user_xp()
RETURNS void AS $$
BEGIN
  UPDATE profiles p
  SET total_xp = COALESCE((
    SELECT SUM(xp_earned)
    FROM player_progress
    WHERE user_id = p.id AND completed = true
  ), 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Run it once to fix any existing issues
SELECT recalculate_all_user_xp();


-- 5. Trigger for automated XP (Optional but recommended for reliability)
-- If we add this, we should remove the manual RPC call in the Flutter code 
-- to avoid double counting. Since I am already doing an RPC call in the code, 
-- I will NOT add the trigger yet to avoid side effects, unless requested.
-- However, I will update the RPC function to be more robust.

CREATE OR REPLACE FUNCTION increment_user_xp(
  user_id_param uuid,
  xp_amount     int
)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET    total_xp = total_xp + xp_amount
  where  id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
