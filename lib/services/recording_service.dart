import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recording.dart';
import 'storage_service.dart';

class RecordingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService.instance;

  /// Upload a recording with file
  Future<Recording?> uploadRecording({
    required File recordingFile,
    required String recipientId,
    required String recordingType, // 'audio' or 'video'
    String? title,
    String? description,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Upload file to storage
      String? recordingUrl;
      if (recordingType == 'audio') {
        recordingUrl = await _storageService.uploadAudioRecording(
          audioFile: recordingFile,
          userId: userId,
          chatPartnerId: recipientId,
        );
      } else if (recordingType == 'video') {
        recordingUrl = await _storageService.uploadVideoRecording(
          videoFile: recordingFile,
          userId: userId,
          chatPartnerId: recipientId,
        );
      }

      if (recordingUrl == null) {
        throw Exception('Failed to upload recording file to storage');
      }

      // Get file size
      final fileSize = recordingFile.lengthSync();

      // Create recording record in database
      final response = await _supabase
          .from('recordings')
          .insert({
            'sender_id': userId,
            'recipient_id': recipientId,
            'recording_url': recordingUrl,
            'recording_type': recordingType,
            'file_size': fileSize,
            'title': title,
            'description': description,
          })
          .select()
          .single();

      return Recording.fromJson(response);
    } catch (e) {
      debugPrint('Upload recording error: $e');
      return null;
    }
  }

  /// Get my recordings (sent by me)
  Future<List<Recording>> getMyRecordings({
    required String partnerId,
    int limit = 50,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('recordings')
          .select()
          .eq('sender_id', userId)
          .eq('recipient_id', partnerId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((r) => Recording.fromJson(r)).toList();
    } catch (e) {
      debugPrint('Get my recordings error: $e');
      return [];
    }
  }

  /// Get partner recordings (received from partner)
  Future<List<Recording>> getPartnerRecordings({
    required String partnerId,
    int limit = 50,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('recordings')
          .select()
          .eq('sender_id', partnerId)
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((r) => Recording.fromJson(r)).toList();
    } catch (e) {
      debugPrint('Get partner recordings error: $e');
      return [];
    }
  }

  /// Mark recording as read
  Future<void> markRecordingAsRead(String recordingId) async {
    try {
      await _supabase.from('recordings').update(
          {'read_at': DateTime.now().toIso8601String()}).eq('id', recordingId);
    } catch (e) {
      debugPrint('Mark recording as read error: $e');
    }
  }

  /// Get unread recordings count from partner
  Future<int> getUnreadRecordingsCount({
    required String partnerId,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('recordings')
          .select('id')
          .eq('sender_id', partnerId)
          .eq('recipient_id', userId)
          .isFilter('read_at', true);

      return (response as List).length;
    } catch (e) {
      debugPrint('Get unread recordings count error: $e');
      return 0;
    }
  }

  /// Delete a recording
  Future<void> deleteRecording(String recordingId) async {
    try {
      await _supabase.from('recordings').delete().eq('id', recordingId);
    } catch (e) {
      debugPrint('Delete recording error: $e');
    }
  }

  /// Stream recordings for real-time updates
  Stream<List<Recording>> streamMyRecordings({
    required String partnerId,
  }) {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      return _supabase
          .from('recordings')
          .stream(primaryKey: ['id']).map((data) {
        final filtered = (data as List)
            .where((r) =>
                r['sender_id'] == userId && r['recipient_id'] == partnerId)
            .toList();
        return filtered.map((r) => Recording.fromJson(r)).toList();
      });
    } catch (e) {
      debugPrint('Stream my recordings error: $e');
      return Stream.value([]);
    }
  }

  /// Stream partner recordings for real-time updates
  Stream<List<Recording>> streamPartnerRecordings({
    required String partnerId,
  }) {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      return _supabase
          .from('recordings')
          .stream(primaryKey: ['id']).map((data) {
        final filtered = (data as List)
            .where((r) =>
                r['sender_id'] == partnerId && r['recipient_id'] == userId)
            .toList();
        return filtered.map((r) => Recording.fromJson(r)).toList();
      });
    } catch (e) {
      debugPrint('Stream partner recordings error: $e');
      return Stream.value([]);
    }
  }
}
