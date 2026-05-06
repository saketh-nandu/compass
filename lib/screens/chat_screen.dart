import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../models/chat_user.dart';
import '../services/chat_service.dart';
import '../services/media_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/memory_service.dart';
import 'memories_screen.dart';
import 'recordings_screen.dart';
import 'shorts_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _isOtherUserTyping = false;
  bool _isLoading = false;
  bool _canNotifyPartner = true;
  int _messageOffset = 0;
  bool _hasMoreMessages = true;
  bool _showScrollToBottomButton = false;

  ChatUser? _currentUser;
  ChatUser? _chatPartner;
  String? _partnerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _initializeChat();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _tabController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _triggerPanicMode();
    }
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      _currentUser = await AuthService.instance.getCurrentUserProfile();

      // Get fixed chat partner
      _chatPartner = await ChatService.instance.getChatPartner();
      _partnerId = _chatPartner?.id;

      if (_partnerId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No chat partner assigned')),
          );
        }
        return;
      }

      // Load previous messages
      await _loadMessages();

      // Listen to new messages
      _listenToMessages();

      // Listen to typing indicators
      _listenToTypingIndicators();

      // Update user status to online
      await _updateUserStatus('online');
    } catch (e) {
      debugPrint('Initialize chat error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    try {
      if (_partnerId == null) return;

      final messages = await ChatService.instance.getMessages(
        otherUserId: _partnerId!,
        limit: 50,
        offset: loadMore ? _messageOffset : 0,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _messages.insertAll(0, messages.reversed);
            _messageOffset += messages.length;
          } else {
            _messages.clear();
            _messages.addAll(messages.reversed);
          }
          _hasMoreMessages = messages.length == 50;
        });
        if (!loadMore) _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Load messages error: $e');
    }
  }

  void _listenToMessages() {
    if (_partnerId == null) return;

    _messageSubscription = ChatService.instance
        .listenToMessages(otherUserId: _partnerId!)
        .listen((message) {
      if (mounted) {
        setState(() {
          if (!_messages.any((m) => m.id == message.id)) {
            _messages.add(message);
          }
        });
        _scrollToBottom();

        if (message.senderId == _partnerId) {
          ChatService.instance.markMessageAsRead(message.id);
        }
      }
    });
  }

  void _listenToTypingIndicators() {
    if (_partnerId == null) return;

    _typingSubscription = ChatService.instance
        .listenToTypingIndicators(otherUserId: _partnerId!)
        .listen((data) {
      if (mounted) {
        setState(() {
          _isOtherUserTyping = data['is_typing'] ?? false;
        });
      }
    });
  }

  Future<void> _updateUserStatus(String status) async {
    try {
      await ChatService.instance.updateUserStatus(status);
    } catch (e) {
      debugPrint('Update user status error: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 100) {
      if (!_showScrollToBottomButton) {
        setState(() => _showScrollToBottomButton = true);
      }
    } else {
      if (_showScrollToBottomButton) {
        setState(() => _showScrollToBottomButton = false);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty || _partnerId == null) return;

    final content = _textController.text;
    _textController.clear();

    try {
      final message = await ChatService.instance.sendTextMessage(
        content: content,
        receiverId: _partnerId!,
      );

      if (message != null) {
        setState(() => _messages.add(message));
        _scrollToBottom();

        // Send notification
        await NotificationService.instance.sendChatMessageNotification(
          recipientUserId: _partnerId!,
          messageContent: content,
          messageId: message.id,
        );
      }
    } catch (e) {
      debugPrint('Send message error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _sendMediaMessage(File file, String messageType) async {
    if (_partnerId == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading media...')),
      );

      final message = await ChatService.instance.sendMediaMessage(
        filePath: file.path,
        fileName: file.path.split('/').last,
        messageType: messageType,
        receiverId: _partnerId!,
      );

      if (message != null) {
        setState(() => _messages.add(message));
        _scrollToBottom();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      }
    } catch (e) {
      debugPrint('Send media message error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send media: $e')),
        );
      }
    }
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _startTyping();
    } else if (text.isEmpty && _isTyping) {
      _stopTyping();
    }
  }

  void _startTyping() {
    if (_partnerId == null) return;

    setState(() => _isTyping = true);

    ChatService.instance.sendTypingIndicator(
      receiverId: _partnerId!,
      isTyping: true,
    );

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), _stopTyping);
  }

  void _stopTyping() {
    if (!_isTyping || _partnerId == null) return;

    setState(() => _isTyping = false);

    ChatService.instance.sendTypingIndicator(
      receiverId: _partnerId!,
      isTyping: false,
    );

    _typingTimer?.cancel();
  }

  Future<void> _notifyPartner() async {
    if (!_canNotifyPartner || _partnerId == null) return;

    setState(() => _canNotifyPartner = false);

    try {
      final success =
          await NotificationService.instance.sendPartnerNotification(
        recipientUserId: _partnerId!,
        customMessage: 'Check the compass!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? '✓ Partner notified!' : 'Failed to notify partner'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Notify partner error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to notify partner: $e')),
        );
      }
    }

    Timer(const Duration(minutes: 5), () {
      if (mounted) {
        setState(() => _canNotifyPartner = true);
      }
    });
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera, 'image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, 'image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, 'video');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, String type) async {
    try {
      File? file;

      if (type == 'image') {
        file = await MediaService.instance.pickImage(source: source);
      } else if (type == 'video') {
        file = await MediaService.instance.pickVideo(source: source);
      }

      if (file != null) {
        await _sendMediaMessage(file, type);
      }
    } catch (e) {
      debugPrint('Pick media error: $e');
    }
  }

  Future<void> _saveMessageAsMemory(Message message) async {
    try {
      final memory = await MemoryService.instance.createMemory(
        title: 'Saved from chat',
        description: message.content,
        category: 'chat',
      );

      if (memory != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message saved to memories')),
        );
      }
    } catch (e) {
      debugPrint('Save memory error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save memory: $e')),
        );
      }
    }
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_add),
              title: const Text('Save to Memories'),
              onTap: () {
                Navigator.pop(context);
                _saveMessageAsMemory(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Text'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            if (message.senderId == _currentUser?.id)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Message'),
                onTap: () {
                  Navigator.pop(context);
                  ChatService.instance.deleteMessage(message.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'typing...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == _currentUser?.id;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(message),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.fileUrl != null) _buildMediaContent(message),
              if (message.content.isNotEmpty)
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: (isMe
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 16,
                      color: message.isRead
                          ? Colors.blue
                          : Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    if (message.fileUrl == null) return const SizedBox.shrink();

    switch (message.messageType) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: message.fileUrl!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        );

      case MessageType.video:
        return Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child:
                Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
          ),
        );

      case MessageType.audio:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.audiotrack),
              const SizedBox(width: 8),
              Text(message.fileName ?? 'Audio'),
            ],
          ),
        );

      case MessageType.file:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_file),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.fileName ?? 'File',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _showMediaPicker,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, size: 18),
                color: Theme.of(context).colorScheme.onPrimary,
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final file = await MediaService.instance.pickFile();
      if (file != null) {
        await _sendMediaMessage(file, 'file');
      }
    } catch (e) {
      debugPrint('Pick file error: $e');
    }
  }

  void _triggerPanicMode() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _triggerPanicMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_chatPartner?.displayName ?? 'Secure Chat'),
              if (_chatPartner != null)
                Row(
                  children: [
                    if (_isOtherUserTyping) ...[
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'typing...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ] else ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _chatPartner!.status == 'online'
                              ? Colors.green
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _chatPartner!.status == 'online' ? 'Online' : 'Offline',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _chatPartner!.status == 'online'
                                  ? Colors.green
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_active_outlined,
              color: _canNotifyPartner
                  ? null
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Notify Partner',
            onPressed: _canNotifyPartner ? _notifyPartner : null,
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Panic Mode (Long Press Title)',
            onPressed: _triggerPanicMode,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
            Tab(icon: Icon(Icons.photo_library), text: 'Memories'),
            Tab(icon: Icon(Icons.mic), text: 'Recordings'),
            Tab(icon: Icon(Icons.video_library), text: 'Shorts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          const MemoriesScreen(),
          const RecordingsScreen(),
          ShortsScreen(partnerId: _partnerId),
        ],
      ),
      floatingActionButton: _showScrollToBottomButton
          ? FloatingActionButton(
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward),
            )
          : null,
    );
  }

  Widget _buildChatTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a secure conversation',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels == 0 &&
                        _hasMoreMessages &&
                        !_isLoading) {
                      _loadMessages(loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isOtherUserTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isOtherUserTyping) {
                        return _buildTypingIndicator();
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
        ),
        _buildMessageInput(),
      ],
    );
  }
}
