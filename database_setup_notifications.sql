-- Database setup for Firebase Cloud Messaging notifications
-- This extends the existing Chatsusa database with notification support

-- Device tokens table for FCM
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
    device_info JSONB DEFAULT '{}',
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notification logs for tracking and cooldowns
CREATE TABLE IF NOT EXISTS notification_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recipient_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('chat_message', 'partner_notification', 'system')),
    message TEXT,
    success_count INTEGER DEFAULT 0,
    total_count INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notification preferences (optional - for future use)
CREATE TABLE IF NOT EXISTS notification_preferences (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    chat_notifications BOOLEAN DEFAULT true,
    partner_notifications BOOLEAN DEFAULT true,
    sound_enabled BOOLEAN DEFAULT true,
    vibration_enabled BOOLEAN DEFAULT true,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_active ON device_tokens(active) WHERE active = true;
CREATE INDEX IF NOT EXISTS idx_notification_logs_sender ON notification_logs(sender_user_id);
CREATE INDEX IF NOT EXISTS idx_notification_logs_recipient ON notification_logs(recipient_user_id);
CREATE INDEX IF NOT EXISTS idx_notification_logs_created_at ON notification_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_notification_logs_cooldown ON notification_logs(sender_user_id, recipient_user_id, type, created_at);

-- Row Level Security (RLS) policies
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- Device tokens policies
CREATE POLICY "Users can manage their own device tokens" ON device_tokens
    FOR ALL USING (auth.uid() = user_id);

-- Notification logs policies  
CREATE POLICY "Users can view their notification logs" ON notification_logs
    FOR SELECT USING (auth.uid() = sender_user_id OR auth.uid() = recipient_user_id);

CREATE POLICY "Users can create notification logs" ON notification_logs
    FOR INSERT WITH CHECK (auth.uid() = sender_user_id);

-- Notification preferences policies
CREATE POLICY "Users can manage their notification preferences" ON notification_preferences
    FOR ALL USING (auth.uid() = user_id);

-- Functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_device_tokens_updated_at 
    BEFORE UPDATE ON device_tokens 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at 
    BEFORE UPDATE ON notification_preferences 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to clean up old device tokens
CREATE OR REPLACE FUNCTION cleanup_old_device_tokens()
RETURNS void AS $$
BEGIN
    -- Deactivate tokens not used in 30 days
    UPDATE device_tokens 
    SET active = false 
    WHERE last_used_at < NOW() - INTERVAL '30 days' 
    AND active = true;
    
    -- Delete inactive tokens older than 90 days
    DELETE FROM device_tokens 
    WHERE active = false 
    AND updated_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old notification logs
CREATE OR REPLACE FUNCTION cleanup_old_notification_logs()
RETURNS void AS $$
BEGIN
    -- Keep only last 30 days of notification logs
    DELETE FROM notification_logs 
    WHERE created_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- Insert default notification preferences for existing users
INSERT INTO notification_preferences (user_id)
SELECT id FROM auth.users 
WHERE id NOT IN (SELECT user_id FROM notification_preferences)
ON CONFLICT (user_id) DO NOTHING;

-- Comments for documentation
COMMENT ON TABLE device_tokens IS 'Stores FCM device tokens for push notifications';
COMMENT ON TABLE notification_logs IS 'Logs all sent notifications for tracking and cooldown enforcement';
COMMENT ON TABLE notification_preferences IS 'User preferences for notification settings';

COMMENT ON COLUMN device_tokens.token IS 'FCM registration token for the device';
COMMENT ON COLUMN device_tokens.platform IS 'Platform type: android, ios, or web';
COMMENT ON COLUMN device_tokens.device_info IS 'Additional device information (model, OS version, etc.)';
COMMENT ON COLUMN device_tokens.last_used_at IS 'Last time this token was successfully used';

COMMENT ON COLUMN notification_logs.type IS 'Type of notification: chat_message, partner_notification, or system';
COMMENT ON COLUMN notification_logs.success_count IS 'Number of devices that successfully received the notification';
COMMENT ON COLUMN notification_logs.total_count IS 'Total number of devices the notification was sent to';

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Success message
SELECT 'Notification system database setup completed successfully!' as status;