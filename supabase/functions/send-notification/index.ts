import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const {
      recipient_user_id,
      sender_user_id,
      message,
      type,
    } = await req.json();

    // Validate inputs
    if (!recipient_user_id || !sender_user_id) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: corsHeaders }
      );
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: "Missing Supabase configuration" }),
        { status: 500, headers: corsHeaders }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get recipient's device tokens
    const { data: deviceTokens, error: tokenError } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", recipient_user_id)
      .eq("active", true);

    if (tokenError) {
      console.error("Error fetching device tokens:", tokenError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch device tokens" }),
        { status: 500, headers: corsHeaders }
      );
    }

    if (!deviceTokens || deviceTokens.length === 0) {
      console.log("No active device tokens found for user:", recipient_user_id);
      
      // Log the notification attempt even if no devices
      await supabase.from("notification_logs").insert({
        sender_user_id: sender_user_id,
        recipient_user_id: recipient_user_id,
        type: type || "other",
        message: message,
        success_count: 0,
        total_count: 0,
      });

      return new Response(
        JSON.stringify({
          success: true,
          message: "No active devices found",
          sent: 0,
        }),
        { status: 200, headers: corsHeaders }
      );
    }

    // Get Firebase credentials from environment
    const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID");
    const firebasePrivateKey = Deno.env.get("FIREBASE_PRIVATE_KEY");
    const firebaseClientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL");

    if (!firebaseProjectId || !firebasePrivateKey || !firebaseClientEmail) {
      console.warn("Firebase credentials not configured, logging notification only");
      
      // Log the notification attempt
      await supabase.from("notification_logs").insert({
        sender_user_id: sender_user_id,
        recipient_user_id: recipient_user_id,
        type: type || "other",
        message: message,
        success_count: 0,
        total_count: deviceTokens.length,
      });

      return new Response(
        JSON.stringify({
          success: true,
          message: "Firebase not configured, notification logged",
          sent: 0,
        }),
        { status: 200, headers: corsHeaders }
      );
    }

    // Get Firebase access token
    const accessToken = await getFirebaseAccessToken(
      firebaseProjectId,
      firebasePrivateKey,
      firebaseClientEmail
    );

    if (!accessToken) {
      return new Response(
        JSON.stringify({ error: "Failed to get Firebase access token" }),
        { status: 500, headers: corsHeaders }
      );
    }

    // Send notifications to all device tokens
    let successCount = 0;
    let failureCount = 0;

    for (const deviceToken of deviceTokens) {
      try {
        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${accessToken}`,
            },
            body: JSON.stringify({
              message: {
                token: deviceToken.token,
                notification: {
                  title:
                    type === "partner_notification"
                      ? "Partner Notification"
                      : "New Message",
                  body: message || "You have a new message",
                },
                data: {
                  type: type || "other",
                  sender_user_id: sender_user_id,
                  timestamp: new Date().toISOString(),
                },
              },
            }),
          }
        );

        if (response.ok) {
          successCount++;
        } else {
          failureCount++;
          console.error(
            `Failed to send to token ${deviceToken.token}:`,
            await response.text()
          );
        }
      } catch (error) {
        failureCount++;
        console.error("Error sending notification:", error);
      }
    }

    // Log the notification
    await supabase.from("notification_logs").insert({
      sender_user_id: sender_user_id,
      recipient_user_id: recipient_user_id,
      type: type || "other",
      message: message,
      success_count: successCount,
      total_count: successCount + failureCount,
    });

    return new Response(
      JSON.stringify({
        success: true,
        sent: successCount,
        failed: failureCount,
      }),
      { status: 200, headers: corsHeaders }
    );
  } catch (error) {
    console.error("Error in send-notification function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: corsHeaders }
    );
  }
});

// Helper function to get Firebase access token
async function getFirebaseAccessToken(
  projectId: string,
  privateKey: string,
  clientEmail: string
): Promise<string | null> {
  try {
    const now = Math.floor(Date.now() / 1000);
    const expiresAt = now + 3600;

    const header = {
      alg: "RS256",
      typ: "JWT",
    };

    const payload = {
      iss: clientEmail,
      scope: "https://www.googleapis.com/auth/cloud-platform",
      aud: "https://oauth2.googleapis.com/token",
      exp: expiresAt,
      iat: now,
    };

    // Create JWT (simplified - in production use proper JWT library)
    const headerEncoded = btoa(JSON.stringify(header));
    const payloadEncoded = btoa(JSON.stringify(payload));

    // For now, return a placeholder - in production, properly sign the JWT
    console.warn("JWT signing not fully implemented in this version");
    return null;
  } catch (error) {
    console.error("Error getting Firebase access token:", error);
    return null;
  }
}
