// Supabase Edge Function: send-partner-notification
// Deploy this to your Supabase project

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FIREBASE_SERVER_KEY = Deno.env.get('FIREBASE_SERVER_KEY')

serve(async (req) => {
  try {
    const { recipient_user_id, sender_user_id, custom_message } = await req.json()
    
    // Get recipient's device tokens from your database
    const { data: tokens, error } = await supabase
      .from('device_tokens')
      .select('token, platform')
      .eq('user_id', recipient_user_id)
    
    if (error) {
      throw error
    }
    
    // Send FCM notifications to all user's devices
    const notifications = tokens.map(async (tokenData) => {
      const fcmPayload = {
        to: tokenData.token,
        notification: {
          title: "Compass Update",
          body: custom_message || "Heading NW (312°)",
          icon: "ic_notification",
          color: "#5B7C99",
          sound: "default"
        },
        data: {
          type: "compass_notification",
          sender_id: sender_user_id,
          click_action: "FLUTTER_NOTIFICATION_CLICK"
        },
        android: {
          notification: {
            channel_id: "chat_messages",
            priority: "high"
          }
        }
      }
      
      const response = await fetch('https://fcm.googleapis.com/fcm/send', {
        method: 'POST',
        headers: {
          'Authorization': `key=${FIREBASE_SERVER_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(fcmPayload)
      })
      
      return response.json()
    })
    
    const results = await Promise.all(notifications)
    
    return new Response(JSON.stringify({ 
      success: true, 
      sent: results.length,
      results 
    }), {
      headers: { "Content-Type": "application/json" },
    })
  } catch (error) {
    return new Response(JSON.stringify({ 
      error: error.message 
    }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    })
  }
})