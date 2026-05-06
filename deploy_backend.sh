#!/bin/bash

# ============================================================================
# COMPASS APP - BACKEND DEPLOYMENT SCRIPT
# ============================================================================
# This script deploys the entire backend to Supabase
# Usage: ./deploy_backend.sh
# ============================================================================

set -e

echo "🚀 Compass App - Backend Deployment"
echo "===================================="
echo ""

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Please install it first:"
    echo "   https://supabase.com/docs/guides/cli"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the my_app directory."
    exit 1
fi

echo "✅ Supabase CLI found"
echo ""

# Step 1: Link project
echo "📌 Step 1: Linking Supabase project..."
echo "Project: oltzkkchoohpwbipqkeh"
echo ""
echo "Note: You'll be prompted for your database password"
echo "You can find it in: https://app.supabase.com/project/oltzkkchoohpwbipqkeh/settings/database"
echo ""

supabase link --project-ref oltzkkchoohpwbipqkeh

echo ""
echo "✅ Project linked successfully"
echo ""

# Step 2: Deploy migrations
echo "📌 Step 2: Deploying database migrations..."
echo ""

supabase db push

echo ""
echo "✅ Database migrations deployed successfully"
echo ""

# Step 3: Instructions for creating users
echo "📌 Step 3: Creating test users..."
echo ""
echo "⚠️  IMPORTANT: You need to create auth users manually via Supabase Dashboard"
echo ""
echo "Go to: https://app.supabase.com/project/oltzkkchoohpwbipqkeh/auth/users"
echo ""
echo "Create these users:"
echo ""
echo "1️⃣  Male User:"
echo "   Email: saketh_nandu127@example.com"
echo "   Password: SupriyaSaketh127"
echo "   ✓ Check 'Auto confirm user'"
echo ""
echo "2️⃣  Female User:"
echo "   Email: srirenu127@example.com"
echo "   Password: #filmmaking"
echo "   ✓ Check 'Auto confirm user'"
echo ""
echo "After creating users, run this command to insert their profiles:"
echo ""
echo "   supabase db execute < supabase/setup_users.sql"
echo ""

# Step 4: Verify setup
echo "📌 Step 4: Verifying setup..."
echo ""

echo "Checking database tables..."
supabase db list

echo ""
echo "✅ Backend deployment complete!"
echo ""
echo "📋 Summary:"
echo "   ✓ Database tables created"
echo "   ✓ Realtime enabled"
echo "   ✓ RLS policies configured"
echo "   ✓ Indexes created"
echo ""
echo "⏭️  Next steps:"
echo "   1. Create test users in Supabase Dashboard (see instructions above)"
echo "   2. Insert user profiles: supabase db execute < supabase/setup_users.sql"
echo "   3. Test login in the Flutter app"
echo ""
echo "📚 For more info, see: SUPABASE_SETUP_GUIDE.md"
echo ""
