#!/usr/bin/env python3
"""
Script to import CSV data into Supabase database
Reads messages_rows.csv and memories_rows.csv and generates SQL INSERT statements
"""

import csv
import json
from datetime import datetime
import uuid
import sys

# Set UTF-8 encoding for output
sys.stdout.reconfigure(encoding='utf-8')

def clean_text(text):
    """Clean text for SQL insertion"""
    if not text:
        return 'NULL'
    # Escape single quotes and handle special characters
    cleaned = text.replace("'", "''").replace('\n', '\\n').replace('\r', '\\r')
    return f"'{cleaned}'"

def parse_timestamp(timestamp_str):
    """Parse timestamp string to SQL format"""
    if not timestamp_str:
        return 'NULL'
    try:
        # Handle the format: 2026-02-16 04:25:16.783282+00
        dt = datetime.fromisoformat(timestamp_str.replace('+00', '+00:00'))
        return f"'{dt.isoformat()}'"
    except:
        return 'NULL'

def parse_reactions(reactions_str):
    """Parse reactions JSON string"""
    if not reactions_str or reactions_str == '':
        return "'[]'"
    try:
        # Parse the JSON array
        reactions = json.loads(reactions_str)
        return f"'{json.dumps(reactions)}'"
    except:
        return "'[]'"

def generate_messages_sql():
    """Generate SQL INSERT statements for messages"""
    print("-- Importing messages from CSV")
    print("INSERT INTO messages (id, sender_id, recipient_id, content, message_type, media_url, media_filename, file_size, edited, reactions, created_at, read_at, reply_to_id) VALUES")
    
    values = []
    with open('messages_rows.csv', 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            # Map CSV fields to database fields
            id_val = clean_text(row['id'])
            sender_id = clean_text(row['sender_id'])
            recipient_id = clean_text(row['receiver_id'])  # Note: CSV uses receiver_id
            content = clean_text(row['content'])
            message_type = clean_text(row['type'])
            media_url = clean_text(row['file_url']) if row['file_url'] else 'NULL'
            media_filename = clean_text(row['file_name']) if row['file_name'] else 'NULL'
            file_size = row['file_size'] if row['file_size'] else 'NULL'
            edited = 'true' if row['edited'] == 'true' else 'false'
            reactions = parse_reactions(row['reactions'])
            created_at = parse_timestamp(row['created_at'])
            read_at = parse_timestamp(row['read_at'])
            reply_to_id = clean_text(row['reply_to_id']) if row['reply_to_id'] else 'NULL'
            
            value = f"({id_val}, {sender_id}, {recipient_id}, {content}, {message_type}, {media_url}, {media_filename}, {file_size}, {edited}, {reactions}, {created_at}, {read_at}, {reply_to_id})"
            values.append(value)
    
    # Print in chunks to avoid too long SQL statements
    chunk_size = 100
    for i in range(0, len(values), chunk_size):
        chunk = values[i:i+chunk_size]
        if i == 0:
            print(',\n'.join(chunk))
        else:
            print(";\n\nINSERT INTO messages (id, sender_id, recipient_id, content, message_type, media_url, media_filename, file_size, edited, reactions, created_at, read_at, reply_to_id) VALUES")
            print(',\n'.join(chunk))
        
        if i + chunk_size >= len(values):
            print("ON CONFLICT (id) DO NOTHING;")
        else:
            print("ON CONFLICT (id) DO NOTHING")

def generate_memories_sql():
    """Generate SQL INSERT statements for memories"""
    print("\n\n-- Importing memories from CSV")
    print("INSERT INTO memories (id, user_id, title, description, media_url, media_type, category, likes, created_at, updated_at) VALUES")
    
    values = []
    with open('memories_rows.csv', 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            # Map CSV fields to database fields
            id_val = clean_text(row['id'])
            user_id = clean_text(row['user_id'])
            title = clean_text(row['title'])
            description = clean_text(row['description'])
            media_url = clean_text(row['media_url']) if row['media_url'] else 'NULL'
            media_type = clean_text(row['media_type']) if row['media_type'] else 'NULL'
            category = clean_text(row['category']) if row['category'] else "'general'"
            likes = row['likes'] if row['likes'] else '0'
            created_at = parse_timestamp(row['created_at'])
            updated_at = parse_timestamp(row['updated_at'])
            
            value = f"({id_val}, {user_id}, {title}, {description}, {media_url}, {media_type}, {category}, {likes}, {created_at}, {updated_at})"
            values.append(value)
    
    print(',\n'.join(values))
    print("ON CONFLICT (id) DO NOTHING;")

if __name__ == "__main__":
    print("-- SQL script to import CSV data into Compass app database")
    print("-- Generated automatically from messages_rows.csv and memories_rows.csv")
    print("-- Run this after creating the main database schema\n")
    
    generate_messages_sql()
    generate_memories_sql()
    
    print("\n\n-- Update message status for read messages")
    print("UPDATE messages SET status = 'read' WHERE read_at IS NOT NULL;")
    
    print("\n\n-- Create some sample memories linked to messages")
    print("""
INSERT INTO memories (user_id, message_id, title, description, category, tags, created_at)
SELECT 
  '550e8400-e29b-41d4-a716-446655440001',
  m.id,
  'Sweet Message',
  'A lovely message from our conversation',
  'chat',
  ARRAY['love', 'sweet'],
  m.created_at
FROM messages m 
WHERE m.content LIKE '%luv%' 
AND m.sender_id = '550e8400-e29b-41d4-a716-446655440002'
LIMIT 5
ON CONFLICT DO NOTHING;
""")