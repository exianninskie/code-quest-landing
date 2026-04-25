-- ─────────────────────────────────────────────────────────
-- Migration 006: Force-Fix Avatar and Verify UI
-- ─────────────────────────────────────────────────────────

-- 1. Set a placeholder avatar for all users to verify the UI rendering
-- This helps us determine if the issue is 'Display' or 'Upload'.
UPDATE public.profiles
SET avatar_url = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200'
WHERE avatar_url IS NULL;


-- 2. Ensure Realtime is enabled (Re-asserting for 005)
-- We also ensure the 'profiles' table has REPLICA IDENTITY FULL to help Realtime
ALTER TABLE public.profiles REPLICA IDENTITY FULL;


-- 3. Storage Policy Safety Check
-- Make sure the 'avatars' bucket is absolutely public and readable by all.
UPDATE storage.buckets SET public = true WHERE id = 'avatars';

DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );


-- 4. Fix potential UID mismatch/access
-- Grant all authenticated users select on profiles (already should be there)
GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;


-- 5. Fix the search_path issue for future-proofing
-- This ensures that uuid_generate_v4() is always found in the extensions schema.
ALTER DATABASE postgres SET search_path TO "$user", public, extensions;
