import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

/// YouTube Shorts model
class YouTubeShort {
  final String id;
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;
  final String videoUrl;

  YouTubeShort({
    required this.id,
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
    required this.videoUrl,
  });

  factory YouTubeShort.fromJson(Map<String, dynamic> json) {
    final videoId = json['id']['videoId'] as String;
    return YouTubeShort(
      id: json['id']['videoId'] as String,
      videoId: videoId,
      title: json['snippet']['title'] as String? ?? 'Untitled',
      description: json['snippet']['description'] as String? ?? '',
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'] as String? ??
          'https://via.placeholder.com/320x180',
      channelTitle: json['snippet']['channelTitle'] as String? ?? 'Unknown',
      publishedAt: DateTime.parse(json['snippet']['publishedAt'] as String? ??
          DateTime.now().toIso8601String()),
      videoUrl: 'https://www.youtube.com/watch?v=$videoId',
    );
  }
}

/// YouTube Service for fetching YouTube Shorts
class YouTubeService {
  static YouTubeService? _instance;
  static YouTubeService get instance => _instance ??= YouTubeService._();

  YouTubeService._();

  final String _apiKey = AppConfig.youtubeApiKey;
  final String _baseUrl = AppConfig.youtubeApiBaseUrl;

  /// Search for YouTube Shorts
  /// Returns a list of YouTube Shorts based on search query
  Future<List<YouTubeShort>> searchShorts({
    required String query,
    int maxResults = 20,
  }) async {
    try {
      if (_apiKey.isEmpty || _apiKey == 'your-youtube-api-key-here') {
        debugPrint('YouTube API key not configured');
        return [];
      }

      final url = Uri.parse(
        '$_baseUrl/search'
        '?part=snippet'
        '&q=$query'
        '&type=video'
        '&videoDuration=short'
        '&maxResults=$maxResults'
        '&key=$_apiKey'
        '&order=relevance'
        '&relevanceLanguage=en',
      );

      debugPrint('Fetching YouTube Shorts from: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('YouTube API request timed out');
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final items = json['items'] as List<dynamic>? ?? [];

        final shorts = items
            .map((item) => YouTubeShort.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('Found ${shorts.length} YouTube Shorts');
        return shorts;
      } else {
        debugPrint(
            'YouTube API error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to fetch YouTube Shorts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Search shorts error: $e');
      return [];
    }
  }

  /// Get trending YouTube Shorts
  Future<List<YouTubeShort>> getTrendingShorts({int maxResults = 20}) async {
    return searchShorts(
      query: 'shorts trending',
      maxResults: maxResults,
    );
  }

  /// Get YouTube Shorts by category
  Future<List<YouTubeShort>> getShortsByCategory({
    required String category,
    int maxResults = 20,
  }) async {
    return searchShorts(
      query: category,
      maxResults: maxResults,
    );
  }

  /// Get YouTube Shorts by channel
  Future<List<YouTubeShort>> getShortsByChannel({
    required String channelName,
    int maxResults = 20,
  }) async {
    return searchShorts(
      query: 'channel:$channelName shorts',
      maxResults: maxResults,
    );
  }
}
