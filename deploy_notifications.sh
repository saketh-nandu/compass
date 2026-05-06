#!/bin/bash

# Notification System Deployment Script
# This script automates the deployment of the FCM notification system

set -e  # Exit on any error

echo "🚀 Deploying Hushnav Notification System..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Supabase CLI is installed
print_status "Checking Supabase CLI installation..."
if ! command -v supabase &> /dev/null; then
    print_error "Supabase CLI is not installed!"
    echo "Please install it with: npm install -g supabase"
    exit 1
fi
print_success "Supabase CLI found"

# Check if user is logged in to Supabase
print_status "Checking Supabase authentication..."
if ! supabase status &> /dev/null; then
    print_warning "Not logged in to Supabase"
    echo "Please run: supabase login"
    exit 1
fi
print_success "Supabase authentication verified"

# Link to Supabase project
print_status "Linking to Supabase project..."
SUPABASE_PROJECT_REF="mihtycztbooxfxliqvmi"

if [ ! -f ".supabase/config.toml" ]; then
    print_status "Linking project for the first time..."
    supabase link --project-ref $SUPABASE_PROJECT_REF
else
    print_success "Project already linked"
fi

# Deploy the Edge Function
print_status "Deploying send-notification Edge Function..."
if supabase functions deploy send-notification; then
    print_success "Edge Function deployed successfully!"
else
    print_error "Failed to deploy Edge Function"
    exit 1
fi

# Check if database setup is needed
print_status "Checking database setup..."
echo "Please run the following SQL in your Supabase dashboard:"
echo "1. Go to https://supabase.com/dashboard/project/$SUPABASE_PROJECT_REF/sql"
echo "2. Copy and run the contents of 'database_setup_notifications.sql'"
echo ""
print_warning "Database setup must be done manually in Supabase dashboard"

# Test the function
print_status "Testing Edge Function deployment..."
if supabase functions list | grep -q "send-notification"; then
    print_success "Edge Function is deployed and available"
else
    print_warning "Edge Function may not be properly deployed"
fi

# Flutter dependencies check
print_status "Checking Flutter dependencies..."
if flutter pub deps | grep -q "firebase_messaging"; then
    print_success "Firebase messaging dependency found"
else
    print_warning "Firebase messaging dependency may be missing"
    echo "Run: flutter pub get"
fi

# Final instructions
echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo ""
echo "Next steps:"
echo "1. 📊 Set up database tables:"
echo "   - Go to Supabase SQL Editor"
echo "   - Run database_setup_notifications.sql"
echo ""
echo "2. 📱 Test the app:"
echo "   - flutter run -d chrome"
echo "   - Try the 'Notify Partner' feature"
echo ""
echo "3. 🔧 Test on Android:"
echo "   - flutter build apk --debug"
echo "   - flutter install"
echo ""
echo "4. 📋 Monitor logs:"
echo "   - Supabase: supabase functions logs send-notification"
echo "   - Flutter: flutter logs"
echo ""
print_success "Notification system is ready! 🚀"

# Show function URL
FUNCTION_URL="https://$SUPABASE_PROJECT_REF.supabase.co/functions/v1/send-notification"
echo ""
echo "📡 Edge Function URL: $FUNCTION_URL"
echo "🔗 Supabase Dashboard: https://supabase.com/dashboard/project/$SUPABASE_PROJECT_REF"
echo ""
echo "For detailed setup instructions, see: NOTIFICATION_SETUP_GUIDE.md"