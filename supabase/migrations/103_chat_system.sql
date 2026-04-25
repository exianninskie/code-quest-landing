-- Migration 103: The Whispers Chat System
-- Adds live presence tracking and global chat table

-- 1. Add presence tracking column to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_chapter_title TEXT DEFAULT 'Exploring...';

-- 2. Create Messages Table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    sender_chapter TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Enable RLS
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- 4. Policies
CREATE POLICY "Messages are viewable by everyone" ON public.messages
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own messages" ON public.messages
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 5. Enable Realtime
-- Use the publication name commonly used by Supabase: supabase_realtime
-- First check if the publication exists, then add the table
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
    ELSE
        CREATE PUBLICATION supabase_realtime FOR TABLE public.messages;
    END IF;
END $$;
