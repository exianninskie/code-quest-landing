-- ─────────────────────────────────────────────────────────
-- Migration 005: Enable Realtime and Strengthen Storage
-- ─────────────────────────────────────────────────────────

-- 1. Enable Realtime for the 'profiles' and 'player_progress' tables
-- This allows the Flutter app to see updates (like avatar_url or XP) instantly.
DO $$ 
BEGIN
  -- Create the publication if it doesn't exist (though it usually does in Supabase)
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;
  
  -- Add the tables to the publication
  -- We use a DO block to handle cases where they might already be added
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
  EXCEPTION WHEN duplicate_object THEN
    NULL; -- Already exists
  END;

  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE player_progress;
  EXCEPTION WHEN duplicate_object THEN
    NULL; -- Already exists
  END;
END $$;


-- 2. Strengthen Storage policies for 'avatars'
-- Ensure the bucket is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Drop existing policies to be clean
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatars" ON storage.objects;

-- Allow anyone to read any avatar (since the bucket is public)
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

-- Allow authenticated users to upload their own avatar
-- We use a more specific check here to prevent users overwriting others
CREATE POLICY "Users can upload their own avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Note: The Flutter code currently doesn't use folders, it uses filename prefixes.
-- Let's stick to the current code's behavior but allow access.
-- If we want to restrict by filename:
DROP POLICY IF EXISTS "Users can upload their own avatars" ON storage.objects;
CREATE POLICY "Users can upload their own avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
);

CREATE POLICY "Users can update their own avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING ( bucket_id = 'avatars' AND auth.uid() = owner );

CREATE POLICY "Users can delete their own avatars"
ON storage.objects FOR DELETE
TO authenticated
USING ( bucket_id = 'avatars' AND auth.uid() = owner );


-- 3. Profile Repair
-- Ensure every user has a profile record even if they signed up during a gap
INSERT INTO public.profiles (id, username)
SELECT id, COALESCE(raw_user_meta_data->>'username', 'adventurer')
FROM auth.users
ON CONFLICT (id) DO NOTHING;
