#!/bin/bash

# ============================================================================
# CREATE TEST USERS VIA SUPABASE CLI
# ============================================================================
# This script creates test users directly via CLI
# Usage: ./create_users_cli.sh
# ============================================================================

set -e

echo "🚀 Creating test users via Supabase CLI..."
echo ""

# Create Male User
echo "📌 Creating male user..."
supabase auth admin create-user \
  --email saketh_nandu127@example.com \
  --password SupriyaSaketh127 \
  --autoconfirm

echo "✅ Male user created: saketh_nandu127@example.com"
echo ""

# Create Female User
echo "📌 Creating female user..."
supabase auth admin create-user \
  --email srirenu127@example.com \
  --password '#filmmaking' \
  --autoconfirm

echo "✅ Female user created: srirenu127@example.com"
echo ""

# Insert user profiles
echo "📌 Inserting user profiles..."
supabase db execute < supabase/setup_users.sql

echo "✅ User profiles inserted"
echo ""

echo "🎉 All users created successfully!"
echo ""
echo "Test credentials:"
echo "  Male: saketh_nandu127@example.com / SupriyaSaketh127"
echo "  Female: srirenu127@example.com / #filmmaking"
echo ""
