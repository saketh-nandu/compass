-- ============================================================================
-- FIX RLS POLICIES FOR EXISTING TABLES
-- ============================================================================
-- This migration fixes RLS policies that reference non-existent columns
-- ============================================================================

-- Drop existing policies that reference chat_partner_id (if they exist)
DROP POLICY IF EXISTS "Users can view typing indicators for their chats" ON typing_indicators;

-- The following policies should already exist, so we skip them
-- CREATE POLICY "Users can view typing indicators"
--   ON typing_indicators FOR SELECT
--   USING (auth.uid() = user_id);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
