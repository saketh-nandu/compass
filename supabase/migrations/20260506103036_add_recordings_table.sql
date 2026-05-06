-- Add recordings table for voice/video recordings between users

CREATE TABLE IF NOT EXISTS recordings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  recording_url TEXT NOT NULL,
  recording_type TEXT DEFAULT 'audio' CHECK (recording_type IN ('audio', 'video')),
  duration_seconds INTEGER,
  file_size BIGINT,
  title TEXT,
  description TEXT,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for recordings
CREATE INDEX IF NOT EXISTS idx_recordings_sender_id ON recordings(sender_id);
CREATE INDEX IF NOT EXISTS idx_recordings_recipient_id ON recordings(recipient_id);
CREATE INDEX IF NOT EXISTS idx_recordings_created_at ON recordings(created_at);
CREATE INDEX IF NOT EXISTS idx_recordings_read_at ON recordings(read_at);
CREATE INDEX IF NOT EXISTS idx_recordings_conversation ON recordings(sender_id, recipient_id, created_at);

-- Enable Row Level Security
ALTER TABLE recordings ENABLE ROW LEVEL SECURITY;

-- RLS Policies for recordings table
CREATE POLICY "Users can view their recordings" ON recordings 
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = recipient_id);
CREATE POLICY "Users can insert their recordings" ON recordings 
  FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Users can update their recordings" ON recordings 
  FOR UPDATE USING (auth.uid() = sender_id);
CREATE POLICY "Users can delete their recordings" ON recordings 
  FOR DELETE USING (auth.uid() = sender_id);

-- Create trigger for updated_at
CREATE TRIGGER update_recordings_updated_at 
    BEFORE UPDATE ON recordings 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();