import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/memory.dart';
import 'supabase_service.dart';

/// Memory service for managing standalone memories
///
/// Integrates with Supabase to store memories that match the CSV structure:
/// - Standalone memories with title, description, media
/// - Not linked to chat messages
/// - Categories and likes system
class MemoryService {
  static MemoryService? _instance;
  static MemoryService get instance => _instance ??= MemoryService._();

  MemoryService._();

  final SupabaseClient _client = SupabaseService.instance.client;

  /// Create a new memory
  Future<Memory?> createMemory({
    required String title,
    String? description,
    String? mediaPath,
    String? mediaType,
    String? category,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;

      String? mediaUrl;

      // Upload media if provided
      if (mediaPath != null && mediaPath.isNotEmpty) {
        final file = File(mediaPath);
        final fileName = file.path.split('/').last;
        final fileExt = fileName.split('.').last;
        final storagePath =
            '${currentUser.id}/${DateTime.now().millisecondsSinceEpoch}-${_generateRandomString(6)}.$fileExt';

        await _client.storage
            .from('chat-files') // Same bucket as messages
            .upload(storagePath, file);

        mediaUrl = _client.storage.from('chat-files').getPublicUrl(storagePath);
      }

      final memoryData = {
        'user_id': currentUser.id,
        'title': title,
        'description': description,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'category': category ?? 'general',
        'likes': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _client.from('memories').insert(memoryData).select().single();

      return Memory.fromJson(response);
    } catch (e) {
      debugPrint('Create memory error: $e');
      return null;
    }
  }

  /// Get all memories for current user
  Future<List<Memory>> getMemories({
    int limit = 50,
    int offset = 0,
    String? category,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      var query =
          _client.from('memories').select('*').eq('user_id', currentUser.id);

      // Filter by category if provided
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => Memory.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Get memories error: $e');
      return [];
    }
  }

  /// Delete a memory
  Future<bool> deleteMemory(String memoryId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return false;

      await _client
          .from('memories')
          .delete()
          .eq('id', memoryId)
          .eq('user_id', currentUser.id);

      return true;
    } catch (e) {
      debugPrint('Delete memory error: $e');
      return false;
    }
  }

  /// Update memory
  Future<Memory?> updateMemory({
    required String memoryId,
    String? title,
    String? description,
    String? category,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category;

      final response = await _client
          .from('memories')
          .update(updates)
          .eq('id', memoryId)
          .eq('user_id', currentUser.id)
          .select()
          .single();

      return Memory.fromJson(response);
    } catch (e) {
      debugPrint('Update memory error: $e');
      return null;
    }
  }

  /// Like/unlike a memory
  Future<Memory?> toggleMemoryLike(String memoryId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return null;

      // Get current memory
      final currentMemory = await _client
          .from('memories')
          .select('likes')
          .eq('id', memoryId)
          .eq('user_id', currentUser.id)
          .single();

      final currentLikes = currentMemory['likes'] as int? ?? 0;
      final newLikes =
          currentLikes > 0 ? 0 : 127; // Toggle between 0 and 127 (like in CSV)

      final response = await _client
          .from('memories')
          .update({
            'likes': newLikes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', memoryId)
          .eq('user_id', currentUser.id)
          .select()
          .single();

      return Memory.fromJson(response);
    } catch (e) {
      debugPrint('Toggle memory like error: $e');
      return null;
    }
  }

  /// Get all unique categories used in memories
  Future<List<String>> getAllCategories() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _client
          .from('memories')
          .select('category')
          .eq('user_id', currentUser.id)
          .not('category', 'is', null);

      final categories = <String>{};
      for (final row in response) {
        final category = row['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      debugPrint('Get all categories error: $e');
      return [];
    }
  }

  /// Search memories by title or description
  Future<List<Memory>> searchMemories({
    required String query,
    int limit = 50,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _client
          .from('memories')
          .select('*')
          .eq('user_id', currentUser.id)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => Memory.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Search memories error: $e');
      return [];
    }
  }

  /// Generate random string for file names
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[random % chars.length])
        .join();
  }
}
