import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface NotificationRequest {
  recipient_user_id: string
  sender_user_id: string
  message?: string
  type?: 'chat_message' | 'partner_notification'
  chat_message_id?: string
}

interface FCMMessage {
  message: {
    token: string
    notification: {
      title: string
      body: string
    }
    data: {
      type: string
      sender_id: string
      message_id?: string
      click_action: string
    }
    android: {
      notification: {
        icon: string
        color: string
        channel_id: string
      }
    }
    apns: {
      payload: {
        aps: {
          sound: string
          badge: number
        }
      }
    }
  }
}

// Firebase Admin SDK credentials
const FIREBASE_CONFIG = {
  type: "service_account",
  project_id: "compass-d098d",
  private_key_id: "f5dbec20a5e0a55060246184878217cef10908b4",
  private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDObrhgmrOPAvr1\ntcOuoXlWUH0+bCBT5L22vS0+uew7HjqLUrt5u8SNvaRrSfs1TmP1PcqOIv21Grmd\n7wzM1wE6yFmBMRKB40I3kKjPneZJreVrj7Cc/cu8lCeGFmcqI8ptcSipH6GAq+S5\nT3OrjEikGBVK3ZkFj/EPRnJl81AICEEsRTnlNu82lw72bFaOlvPUTZSUnnb5kOl6\ny4qgcLRtguVSylS79rBLUuJKpz5RgffIptL4hkRtEFgreg/n1qgemm6t/0qkFIY6\nP1dvuYDxo6e/ssn99bFGy1dl5esekHLB/2q+H9xxmhROovZTAEI+Ej66OaPRKEoJ\n18b2koTjAgMBAAECggEAMQVz/WTfXQe9JtpKJM8trESi6U7uAl4geyPDedDW+1b7\nWhiEcq0XSP2O7Pd9kzQRYqyQzF4c14QILiwVYxNvtFDdiGNp3LRmBiHxJJR/mmGU\nSI2vyCgw2JBqLlpll0k2ifTETh030gF/6E2oz0UZ/vXFIKks7Hg5K4J0Kie0iqNW\nAATRKq1/jj8oHJViWpU7uFZFsE3QvgAeffG9uPZGa8xUSGWnkp02iBsbn+7TmD3b\nzqJY1FWdxdfR3gxBXpaNsQAnb4eFWR7AqirbXRWGwmJjNx26JJrGrUdaUs/uGgVm\nAPRFFWIDOxJGJ2gx8oBFWYIWOJbQkWe1EVSXsleb6QKBgQDmLBJsVKUbUbOUfp35\ngxNk7g4jyDKMEonodpPWYmVYMeWDlfjawQqyt/bau7eXDUoWpO0O+n8+gZ27xahd\nPDgKGXmm9jUZsn0uRJmOghfywWPy7DNIFrnU0YH+zLtMoc03yLKrJBEEMrsiu+/O\n9JggBCaSDRcu0/4U5uK+K7MilQKBgQDlmLPgmtbpKs1/C4/O0zs1lkFQvvD5mDzV\nluAd/+YphMCZLRXn7DQJMzP2qg22xuqupgz5jm2hxN1KCdUx29Vr8Hhl8twfdsu0\nhVs2KzgNaJoE+aUW+kAiIuh3Z7MIyIlDQipiot+K/5lCxZrFJ7nOiTchvBHoDEb4\nNTR6joPjlwKBgQCeHVBakpsI9UsDiydCK8S65L1Z30C58FJEGpDcCKPNvhkIF5Hn\n1AxhUPaGs8UeQsbOX2VpkLKwYaHVR6asxZ1Jcs6a3y8DBBXyHrXNq5h/7lGWoqNn\nthTaGUHPoxxXPB8ZXwk9f30hASiEZ84IwQVvmOpWEiAGzyIPgbvpH2PjMQKBgQDC\ntP9GqMk8r7nZ1do9EdGSnjwB2AvP/5UHpY2mo09zQkt7G0sKhbuTWcLlmk1LBeIb\n/mHeeTTsDWGE2lXclIunoCTagFzAqiQSkU1K4NgGNwD22ydwFwWwbV4rdNvVxQry\n6Pe88lcVL7GveJjKPehLCP6iMzYUTeUZtTUuAhJDPQKBgHnqlhhT1ME6d0/Knbml\nZjnFAQ9POGMZ7BJJ3Nc4QMkWf2DDAhSR8udq5Ow+eGQiQRSlpLg9FR4alOiBwwZC\nNt/V6ryvqYWrXSo3sWd8Au2qwdTjgN5crAqLgEma3cJLMnxKwqYSU/nZLxRby3Km\n9e0lsALxSMlCZ/zJX8KHkStx\n-----END PRIVATE KEY-----\n",
  client_email: "firebase-adminsdk-fbsvc@compass-d098d.iam.gserviceaccount.com",
  client_id: "103090482129787103870",
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40compass-d098d.iam.gserviceaccount.com",
  universe_domain: "googleapis.com"
}

// Generate compass-style messages for stealth notifications
const COMPASS_MESSAGES = [
  "Heading NW (312°)",
  "Bearing SE (145°)",
  "Direction NE (67°)",
  "Course SW (234°)",
  "Azimuth N (8°)",
  "Heading E (89°)",
  "Bearing W (271°)",
  "Direction S (178°)",
  "Course NW (325°)",
  "Azimuth NE (45°)"
]

async function getAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  const payload = {
    iss: FIREBASE_CONFIG.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  // Create JWT header
  const header = {
    alg: 'RS256',
    typ: 'JWT',
  }

  // Encode header and payload
  const encodedHeader = btoa(JSON.stringify(header)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  const encodedPayload = btoa(JSON.stringify(payload)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')

  // Create signature
  const signingInput = `${encodedHeader}.${encodedPayload}`
  
  // Import private key
  const privateKey = await crypto.subtle.importKey(
    'pkcs8',
    new TextEncoder().encode(FIREBASE_CONFIG.private_key.replace(/\\n/g, '\n')),
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: 'SHA-256',
    },
    false,
    ['sign']
  )

  // Sign the JWT
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    privateKey,
    new TextEncoder().encode(signingInput)
  )

  const encodedSignature = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')

  const jwt = `${signingInput}.${encodedSignature}`

  // Exchange JWT for access token
  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })

  const tokenData = await tokenResponse.json()
  return tokenData.access_token
}

async function sendFCMNotification(token: string, notification: FCMMessage): Promise<boolean> {
  try {
    const accessToken = await getAccessToken()
    
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${FIREBASE_CONFIG.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(notification),
      }
    )

    const result = await response.json()
    
    if (!response.ok) {
      console.error('FCM Error:', result)
      return false
    }

    console.log('FCM Success:', result)
    return true
  } catch (error) {
    console.error('FCM Send Error:', error)
    return false
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Get request body
    const { recipient_user_id, sender_user_id, message, type = 'partner_notification', chat_message_id }: NotificationRequest = await req.json()

    // Validate required fields
    if (!recipient_user_id || !sender_user_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check cooldown for partner notifications (5 minutes)
    if (type === 'partner_notification') {
      const { data: recentNotification } = await supabaseClient
        .from('notification_logs')
        .select('created_at')
        .eq('sender_user_id', sender_user_id)
        .eq('recipient_user_id', recipient_user_id)
        .eq('type', 'partner_notification')
        .gte('created_at', new Date(Date.now() - 5 * 60 * 1000).toISOString())
        .single()

      if (recentNotification) {
        return new Response(
          JSON.stringify({ error: 'Cooldown active. Please wait 5 minutes between notifications.' }),
          { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // Get recipient's device tokens
    const { data: deviceTokens, error: tokenError } = await supabaseClient
      .from('device_tokens')
      .select('token, platform')
      .eq('user_id', recipient_user_id)
      .eq('active', true)

    if (tokenError || !deviceTokens || deviceTokens.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No active device tokens found for recipient' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get sender info for notification
    const { data: senderData } = await supabaseClient
      .from('users')
      .select('username, display_name')
      .eq('id', sender_user_id)
      .single()

    const senderName = senderData?.display_name || senderData?.username || 'Someone'

    // Prepare notification content based on type
    let notificationTitle: string
    let notificationBody: string
    let notificationData: any

    if (type === 'partner_notification') {
      // Stealth notification - appears as compass update
      const randomCompassMessage = COMPASS_MESSAGES[Math.floor(Math.random() * COMPASS_MESSAGES.length)]
      notificationTitle = "Compass Update"
      notificationBody = message || randomCompassMessage
      notificationData = {
        type: 'compass_notification',
        sender_id: sender_user_id,
        click_action: 'OPEN_CHAT'
      }
    } else {
      // Regular chat message notification
      notificationTitle = `Message from ${senderName}`
      notificationBody = message || 'New message'
      notificationData = {
        type: 'chat_message',
        sender_id: sender_user_id,
        message_id: chat_message_id,
        click_action: 'OPEN_CHAT'
      }
    }

    // Send notifications to all device tokens
    const results = await Promise.all(
      deviceTokens.map(async (deviceToken) => {
        const fcmMessage: FCMMessage = {
          message: {
            token: deviceToken.token,
            notification: {
              title: notificationTitle,
              body: notificationBody,
            },
            data: notificationData,
            android: {
              notification: {
                icon: 'ic_compass',
                color: '#2196F3',
                channel_id: 'compass_notifications',
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          },
        }

        return await sendFCMNotification(deviceToken.token, fcmMessage)
      })
    )

    // Log the notification
    await supabaseClient
      .from('notification_logs')
      .insert({
        sender_user_id,
        recipient_user_id,
        type,
        message: notificationBody,
        success_count: results.filter(r => r).length,
        total_count: results.length,
      })

    const successCount = results.filter(r => r).length

    return new Response(
      JSON.stringify({
        success: true,
        sent_to_devices: successCount,
        total_devices: results.length,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Function error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})