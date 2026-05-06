import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recording.dart';

class RecordingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload a recording
  Future<Recording> uploadRecording({
    required String recordingUrl,
    required String recipientId,
    required String recordingType,
    int? durationSeconds,
    int? fileSize,
    String? title,
    String? description,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('recordings')
          .insert({
            'sender_id': userId,
            'recipient_id': recipientId,
            'recording_url': recordingUrl,
            'recording_type': recordingType,
            'duration_seconds': durationSeconds,
            'file_size': fileSize,
            'title': title,
            'description': description,
          })
          .select()
          .single();

      return Recording.fromJson(response);
    } catch (e) {
      throw Exception('Failed to upload recording: $e');
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
      throw Exception('Failed to fetch my recordings: $e');
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
      throw Exception('Failed to fetch partner recordings: $e');
    }
  }

  /// Mark recording as read
  Future<void> markRecordingAsRead(String recordingId) async {
    try {
      await _supabase.from('recordings').update(
          {'read_at': DateTime.now().toIso8601String()}).eq('id', recordingId);
    } catch (e) {
      throw Exception('Failed to mark recording as read: $e');
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
      throw Exception('Failed to get unread recordings count: $e');
    }
  }

  /// Delete a recording
  Future<void> deleteRecording(String recordingId) async {
    try {
      await _supabase.from('recordings').delete().eq('id', recordingId);
    } catch (e) {
      throw Exception('Failed to delete recording: $e');
    }
  }

  /// Upload recording file to storage
  Future<String> uploadRecordingFile({
    required String filePath,
    required String fileName,
    required String recordingType,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final storagePath = 'recordings/$userId/$recordingType/$fileName';

      // Note: In a real implementation, you would read the file from filePath
      // For now, we'll just return a placeholder URL
      final publicUrl = storagePath;
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload recording file: $e');
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
      throw Exception('Failed to stream my recordings: $e');
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
      throw Exception('Failed to stream partner recordings: $e');
    }
  }
}
