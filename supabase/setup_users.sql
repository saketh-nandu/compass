-- ============================================================================
-- SETUP TEST USERS IN SUPABASE
-- ============================================================================
-- Run this script after the main migration to create test users
-- You can run this via: supabase db push
-- ============================================================================

-- Insert Male User Profile
INSERT INTO users (id, username, email, full_name, gender, status)
SELECT 
  auth.uid(),
  'saketh_nandu127',
  'saketh_nandu127@example.com',
  'Saketh Nandu',
  'male',
  'offline'
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE username = 'saketh_nandu127'
);

-- Insert Female User Profile
INSERT INTO users (id, username, email, full_name, gender, status)
SELECT 
  auth.uid(),
  'srirenu127',
  'srirenu127@example.com',
  'Supriya',
  'female',
  'offline'
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE username = 'srirenu127'
);

-- Create notification preferences for male user
INSERT INTO notification_preferences (user_id, message_notifications, typing_notifications, sound_enabled, vibration_enabled)
SELECT id, TRUE, TRUE, TRUE, TRUE
FROM users
WHERE username = 'saketh_nandu127'
ON CONFLICT (user_id) DO NOTHING;

-- Create notification preferences for female user
INSERT INTO notification_preferences (user_id, message_notifications, typing_notifications, sound_enabled, vibration_enabled)
SELECT id, TRUE, TRUE, TRUE, TRUE
FROM users
WHERE username = 'srirenu127'
ON CONFLICT (user_id) DO NOTHING;
