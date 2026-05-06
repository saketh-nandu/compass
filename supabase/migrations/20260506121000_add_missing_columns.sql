-- ============================================================================
-- ADD MISSING COLUMNS TO EXISTING TABLES
-- ============================================================================
-- This migration adds missing columns to tables that already exist
-- ============================================================================

-- Add is_read and read_at columns to messages table if they don't exist
ALTER TABLE messages
ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITH TIME ZONE;

-- Add is_read and read_at columns to recordings table if they don't exist
ALTER TABLE recordings
ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITH TIME ZONE;

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON messages(is_read);
CREATE INDEX IF NOT EXISTS idx_recordings_is_read ON recordings(is_read);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
