-- Migration 104: Chat Deletion Policies
-- Allows users to delete their own messages and provides a global delete policy for clearing history

-- 1. Policy for users to delete their own messages
CREATE POLICY "Users can delete their own messages" ON public.messages
    FOR DELETE USING (auth.uid() = user_id);

-- 2. Policy for clearing all chat history
-- In this sandbox environment, we allow all authenticated users to delete any message
-- This supports the "Clear all chat history" feature requested by Ninskie
CREATE POLICY "Authenticated users can clear chat history" ON public.messages
    FOR DELETE USING (auth.role() = 'authenticated');
