import 'package:flutter/material.dart';
import '../models/recording.dart';
import '../services/recording_service.dart';
import '../services/auth_service.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RecordingService _recordingService;
  late AuthService _authService;
  String? _partnerId;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recordingService = RecordingService();
    _authService = AuthService.instance;
    _initializePartner();
  }

  Future<void> _initializePartner() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Get partner ID from shared preferences or context
        // For now, using a hardcoded partner ID
        setState(() {
          _partnerId =
              '550e8400-e29b-41d4-a716-446655440002'; // Example partner ID
        });
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('Error initializing partner: $e');
    }
  }

  Future<void> _updateUnreadCount() async {
    if (_partnerId == null) return;
    try {
      final count = await _recordingService.getUnreadRecordingsCount(
          partnerId: _partnerId!);
      setState(() {
        _unreadCount = count;
      });
    } catch (e) {
      debugPrint('Error updating unread count: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.mic),
                  SizedBox(width: 8),
                  Text('My Recordings'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 8),
                  const Text('Partner Recordings'),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _partnerId == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyRecordingsTab(),
                _buildPartnerRecordingsTab(),
              ],
            ),
    );
  }

  Widget _buildMyRecordingsTab() {
    return StreamBuilder<List<Recording>>(
      stream: _recordingService.streamMyRecordings(partnerId: _partnerId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final recordings = snapshot.data ?? [];

        if (recordings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mic_none,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No recordings yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: recordings.length,
          itemBuilder: (context, index) {
            final recording = recordings[index];
            return _buildRecordingTile(recording, isOwner: true);
          },
        );
      },
    );
  }

  Widget _buildPartnerRecordingsTab() {
    return StreamBuilder<List<Recording>>(
      stream: _recordingService.streamPartnerRecordings(partnerId: _partnerId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final recordings = snapshot.data ?? [];

        if (recordings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No recordings from partner',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: recordings.length,
          itemBuilder: (context, index) {
            final recording = recordings[index];
            return _buildRecordingTile(recording, isOwner: false);
          },
        );
      },
    );
  }

  Widget _buildRecordingTile(Recording recording, {required bool isOwner}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: recording.recordingType == 'audio'
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.purple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            recording.recordingType == 'audio' ? Icons.mic : Icons.videocam,
            color: recording.recordingType == 'audio'
                ? Colors.blue
                : Colors.purple,
          ),
        ),
        title: Text(
          recording.title ?? 'Recording',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recording.formattedDuration,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              recording.formattedCreatedAt,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (!isOwner && !recording.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Unread',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!isOwner && !recording.isRead)
              PopupMenuItem(
                child: const Text('Mark as Read'),
                onTap: () async {
                  await _recordingService.markRecordingAsRead(recording.id);
                  _updateUnreadCount();
                },
              ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () async {
                await _recordingService.deleteRecording(recording.id);
              },
            ),
          ],
        ),
        onTap: () {
          // Play recording
          _showRecordingPlayer(recording);
        },
      ),
    );
  }

  void _showRecordingPlayer(Recording recording) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recording.title ?? 'Recording'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${recording.recordingType}'),
            Text('Duration: ${recording.formattedDuration}'),
            Text('Size: ${recording.formattedFileSize}'),
            if (recording.description != null) ...[
              const SizedBox(height: 8),
              Text('Description: ${recording.description}'),
            ],
            const SizedBox(height: 16),
            Center(
              child: Icon(
                recording.recordingType == 'audio' ? Icons.mic : Icons.videocam,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Recording player would be displayed here',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
