# Firebase Cloud Messaging Setup Guide

This guide will help you complete the notification system setup for your Hushnav (Compass) app.

## ✅ What's Already Done

- ✅ Firebase project created: `compass-d098d`
- ✅ Android app registered with package name: `com.company.compass`
- ✅ `google-services.json` file added to project
- ✅ Firebase Admin SDK service account JSON downloaded
- ✅ Android build.gradle.kts configured with FCM dependencies
- ✅ AndroidManifest.xml configured with notification permissions
- ✅ Supabase Edge Function created for sending notifications
- ✅ Database schema designed for device tokens and notification logs
- ✅ Flutter notification service implemented

## 🚀 Next Steps to Complete Setup

### Step 1: Set Up Supabase Database Tables

1. **Open your Supabase Dashboard**: https://supabase.com/dashboard
2. **Navigate to your project**: `mihtycztbooxfxliqvmi`
3. **Go to SQL Editor**
4. **Run the database setup script**:
   - Copy the contents of `database_setup_notifications.sql`
   - Paste into SQL Editor
   - Click "Run" to create all required tables

### Step 2: Deploy Supabase Edge Function

1. **Install Supabase CLI** (if not already installed):
   ```bash
   npm install -g supabase
   ```

2. **Login to Supabase**:
   ```bash
   supabase login
   ```

3. **Link your project**:
   ```bash
   cd my_app
   supabase link --project-ref mihtycztbooxfxliqvmi
   ```

4. **Deploy the notification function**:
   ```bash
   supabase functions deploy send-notification
   ```

### Step 3: Test the Notification System

1. **Run the Flutter app**:
   ```bash
   flutter run -d chrome
   ```

2. **Test the flow**:
   - Open the app in browser
   - Click "Demo Unlock" to access chat
   - Try the "Notify Partner" feature
   - Check browser console for FCM token and logs

### Step 4: Test on Android Device

1. **Build and install on Android**:
   ```bash
   flutter build apk --debug
   flutter install
   ```

2. **Test real device features**:
   - Tilt detection (127° ± 3°)
   - Background notifications
   - Notification tap to open app

## 🔧 Configuration Details

### Firebase Configuration
- **Project ID**: `compass-d098d`
- **Package Name**: `com.company.compass`
- **FCM Sender ID**: `764176495852`

### Supabase Configuration
- **URL**: `https://mihtycztbooxfxliqvmi.supabase.co`
- **Project Ref**: `mihtycztbooxfxliqvmi`

### Notification Channels
- **Channel ID**: `compass_notifications`
- **Channel Name**: "Compass Updates"
- **Importance**: High (for stealth notifications)

## 📱 Notification Behavior

### Partner Notifications (Stealth Mode)
- **Title**: "Compass Update"
- **Body**: Random compass readings (e.g., "Heading NW (312°)")
- **Cooldown**: 5 minutes between notifications
- **Icon**: Compass icon for authenticity

### Chat Message Notifications
- **Title**: "Message from [Username]"
- **Body**: Message preview or "New message"
- **Real-time**: Instant delivery via FCM

### Security Features
- **Stealth Notifications**: Appear as legitimate compass updates
- **Auto-lock**: App locks when backgrounded
- **Panic Mode**: Quick switch to compass view
- **Encrypted Storage**: PIN stored securely

## 🛠️ Troubleshooting

### Common Issues

1. **"No FCM token received"**
   - Check internet connection
   - Verify Firebase configuration
   - Check browser console for errors

2. **"Notification not received"**
   - Verify device token is stored in database
   - Check Supabase Edge Function logs
   - Ensure notification permissions granted

3. **"Function deployment failed"**
   - Verify Supabase CLI is logged in
   - Check project linking: `supabase status`
   - Ensure function syntax is correct

### Debug Commands

```bash
# Check Supabase status
supabase status

# View function logs
supabase functions logs send-notification

# Test function locally
supabase functions serve send-notification

# Check Flutter logs
flutter logs
```

## 🔐 Security Considerations

### Production Deployment
1. **Move Firebase credentials to environment variables**
2. **Enable Supabase RLS policies** (already configured)
3. **Use HTTPS for all communications** (already configured)
4. **Implement rate limiting** (5-minute cooldown already implemented)

### Privacy Features
- Device tokens are user-specific and encrypted
- Notification content is minimal for stealth
- No sensitive data in notification payload
- Auto-cleanup of old tokens and logs

## 📊 Monitoring

### Key Metrics to Monitor
- **Notification delivery rate**: Success vs. total attempts
- **Device token health**: Active vs. inactive tokens
- **Cooldown violations**: Blocked notification attempts
- **Function performance**: Edge function execution time

### Database Queries for Monitoring

```sql
-- Check notification delivery rates
SELECT 
  type,
  AVG(success_count::float / total_count) as delivery_rate,
  COUNT(*) as total_notifications
FROM notification_logs 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY type;

-- Check active device tokens
SELECT 
  platform,
  COUNT(*) as active_tokens
FROM device_tokens 
WHERE active = true
GROUP BY platform;

-- Check recent notification activity
SELECT 
  sender_user_id,
  recipient_user_id,
  type,
  success_count,
  total_count,
  created_at
FROM notification_logs 
ORDER BY created_at DESC 
LIMIT 10;
```

## 🎯 Next Features to Implement

1. **Rich Notifications**: Images, actions, custom sounds
2. **Notification Scheduling**: Delayed or recurring notifications
3. **Analytics Dashboard**: Notification metrics and insights
4. **A/B Testing**: Different notification formats
5. **Geofencing**: Location-based notifications

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Supabase and Firebase console logs
3. Test with mock data first before real deployment
4. Verify all configuration files are correct

---

**Status**: Ready for deployment and testing! 🚀

The notification system is fully implemented and ready to provide stealth notifications that appear as legitimate compass updates while secretly delivering chat notifications.