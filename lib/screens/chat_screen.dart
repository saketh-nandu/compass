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
  bool _isUserScrolling = false;

  ChatUser? _currentUser;
  ChatUser? _otherUser;
  List<ChatUser> _availableUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    // Add scroll listener for auto-scroll functionality
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
    super.didChangeAppLifecycleState(state);

    // Auto-lock when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _triggerPanicMode();
    }
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      // Get current user profile
      _currentUser = await AuthService.instance.getCurrentUserProfile();

      // Load available users for chat
      await _loadAvailableUsers();

      // For now, select the first available user as chat partner
      // In a real app, this would come from navigation parameters or user selection
      if (_availableUsers.isNotEmpty) {
        _otherUser = _availableUsers.first;
      } else {
        // Create a demo user if no users exist
        _otherUser = ChatUser(
          id: 'demo-partner-id',
          username: 'partner_demo',
          nickname: 'Chat Partner',
          createdAt: DateTime.now(),
        );
      }

      if (_otherUser != null) {
        // Load existing messages
        await _loadMessages();

        // Listen for new messages
        _listenToMessages();

        // Listen for typing indicators
        _listenToTypingIndicators();

        // Update user status to online
        await ChatService.instance.updateUserStatus('online');
      }
    } catch (e) {
      debugPrint('Initialize chat error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final users = await ChatService.instance.getChatUsers();
      setState(() => _availableUsers = users);
    } catch (e) {
      debugPrint('Load available users error: $e');
    }
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (_otherUser == null) return;

    try {
      if (!loadMore) {
        _messageOffset = 0;
        _hasMoreMessages = true;
      }

      final messages = await ChatService.instance.getMessages(
        otherUserId: _otherUser!.id,
        limit: 50,
        offset: _messageOffset,
      );

      setState(() {
        if (loadMore) {
          _messages.insertAll(0, messages.reversed);
        } else {
          _messages.clear();
          _messages
              .addAll(messages.reversed); // Reverse to show newest at bottom
        }

        _messageOffset += messages.length;
        _hasMoreMessages = messages.length == 50;
      });

      if (!loadMore) {
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Load messages error: $e');
    }
  }

  void _listenToMessages() {
    if (_otherUser == null) return;

    _messageSubscription = ChatService.instance
        .listenToMessages(otherUserId: _otherUser!.id)
        .listen((message) {
      setState(() {
        // Check if message already exists to avoid duplicates
        final existingIndex = _messages.indexWhere((m) => m.id == message.id);
        if (existingIndex == -1) {
          _messages.add(message);
        }
      });

      // Auto-scroll to bottom only if user is not scrolling up
      if (!_isUserScrolling) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }

      // Mark as read if not from current user
      if (!message.isFromMe(_currentUser?.id ?? '')) {
        ChatService.instance.markMessageAsRead(message.id);
      }
    });
  }

  void _listenToTypingIndicators() {
    if (_otherUser == null) return;

    _typingSubscription = ChatService.instance
        .listenToTypingIndicators(otherUserId: _otherUser!.id)
        .listen((data) {
      final isTyping = data['is_typing'] == true;
      if (_isOtherUserTyping != isTyping) {
        setState(() => _isOtherUserTyping = isTyping);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final isAtBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;

    // Show/hide scroll to bottom button
    if (isAtBottom != !_showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = !isAtBottom;
      });
    }

    // Detect user scrolling
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      _isUserScrolling = true;
    } else {
      _isUserScrolling = false;
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    if (animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }

    setState(() {
      _showScrollToBottomButton = false;
      _isUserScrolling = false;
    });
  }

  void _triggerPanicMode() {
    // Immediately remove chat from navigation stack and return to home (compass)
    context.go('/');
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty || _otherUser == null) return;

    final content = _textController.text.trim();
    _textController.clear();

    // Stop typing indicator
    _stopTyping();

    try {
      final message = await ChatService.instance.sendTextMessage(
        content: content,
        receiverId: _otherUser!.id,
      );

      if (message != null) {
        setState(() {
          _messages.add(message);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      debugPrint('Send message error: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _sendMediaMessage(File file, String messageType) async {
    if (_otherUser == null) return;

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading media...')),
      );

      final message = await ChatService.instance.sendMediaMessage(
        filePath: file.path,
        fileName: file.path.split('/').last,
        messageType: messageType,
        receiverId: _otherUser!.id,
      );

      if (message != null) {
        setState(() {
          _messages.add(message);
        });
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
    if (_otherUser == null) return;

    setState(() => _isTyping = true);

    ChatService.instance.sendTypingIndicator(
      receiverId: _otherUser!.id,
      isTyping: true,
    );

    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), _stopTyping);
  }

  void _stopTyping() {
    if (!_isTyping || _otherUser == null) return;

    setState(() => _isTyping = false);

    ChatService.instance.sendTypingIndicator(
      receiverId: _otherUser!.id,
      isTyping: false,
    );

    _typingTimer?.cancel();
  }

  Future<void> _notifyPartner() async {
    if (!_canNotifyPartner || _otherUser == null) return;

    setState(() => _canNotifyPartner = false);

    try {
      final success =
          await NotificationService.instance.sendPartnerNotification(
        recipientUserId: _otherUser!.id,
        customMessage: 'Heading NW (312°)', // Compass-style message
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Partner notified with compass update'
                : 'Failed to notify partner'),
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

    // 5-minute cooldown
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

  void _showUserSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Chat Partner',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (_availableUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No users available'),
              )
            else
              ...(_availableUsers.map((user) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.avatarUrl != null
                          ? CachedNetworkImageProvider(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(user.name[0].toUpperCase())
                          : null,
                    ),
                    title: Text(user.name),
                    subtitle: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: user.isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(user.statusText),
                      ],
                    ),
                    selected: _otherUser?.id == user.id,
                    onTap: () {
                      Navigator.pop(context);
                      _selectUser(user);
                    },
                  ))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectUser(ChatUser user) async {
    if (_otherUser?.id == user.id) return;

    // Cancel existing subscriptions
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();

    setState(() {
      _otherUser = user;
      _messages.clear();
      _messageOffset = 0;
      _hasMoreMessages = true;
    });

    // Load messages and start listening for new user
    await _loadMessages();
    _listenToMessages();
    _listenToTypingIndicators();
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

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 8,
          children: [
            '😀',
            '😃',
            '😄',
            '😁',
            '😆',
            '😅',
            '😂',
            '🤣',
            '😊',
            '😇',
            '🙂',
            '🙃',
            '😉',
            '😌',
            '😍',
            '🥰',
            '😘',
            '😗',
            '😙',
            '😚',
            '😋',
            '😛',
            '😝',
            '😜',
            '🤪',
            '🤨',
            '🧐',
            '🤓',
            '😎',
            '🤩',
            '🥳',
            '😏',
            '😒',
            '😞',
            '😔',
            '😟',
            '😕',
            '🙁',
            '☹️',
            '😣',
            '😖',
            '😫',
            '😩',
            '🥺',
            '😢',
            '😭',
            '😤',
            '😠',
            '😡',
            '🤬',
            '🤯',
            '😳',
            '🥵',
            '🥶',
            '😱',
            '😨',
            '😰',
            '😥',
            '😓',
            '🤗',
            '🤔',
            '🤭',
            '🤫',
            '🤥',
            '😶',
            '😐',
            '😑',
            '😬',
            '🙄',
            '😯',
            '😦',
            '😧',
            '😮',
            '😲',
            '🥱',
            '😴',
            '🤤',
            '😪',
            '😵',
            '🤐',
            '🥴',
            '🤢',
            '🤮',
            '🤧',
            '😷',
            '🤒',
            '🤕',
            '🤑',
            '🤠',
            '😈',
            '👿',
            '👹',
            '👺',
            '🤡',
            '💩',
            '👻',
            '💀',
            '☠️',
            '👽',
            '👾',
            '🤖',
            '🎃',
            '😺',
            '😸',
            '😹',
            '😻',
            '😼',
            '😽',
            '🙀',
            '😿',
            '😾',
            '❤️',
            '🧡',
            '💛',
            '💚',
            '💙',
            '💜',
            '🖤',
            '🤍',
            '🤎',
            '💔',
            '❣️',
            '💕',
            '💞',
            '💓',
            '💗',
            '💖',
            '💘',
            '💝',
            '💟',
            '👍',
            '👎',
            '👌',
            '✌️',
            '🤞',
            '🤟',
            '🤘',
            '🤙',
            '👈',
            '👉',
            '👆',
            '🖕',
            '👇',
            '☝️',
            '👋',
            '🤚',
            '🖐️',
            '✋',
            '🖖',
            '👏',
            '🙌',
            '🤲',
            '🤝',
            '🙏',
            '✍️',
            '💅',
            '🤳',
            '💪',
            '🦾',
            '🦿',
            '🦵',
            '🦶',
            '👂',
            '🦻',
            '👃',
            '🧠',
            '🫀',
            '🫁',
            '🦷',
            '🦴',
            '👀',
            '👁️',
            '👅',
            '👄',
            '💋',
            '🩸'
          ]
              .map((emoji) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _sendEmojiMessage(emoji);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<void> _sendEmojiMessage(String emoji) async {
    if (_otherUser == null) return;

    try {
      final message = await ChatService.instance.sendTextMessage(
        content: emoji,
        receiverId: _otherUser!.id,
      );

      if (message != null) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Send emoji message error: $e');
    }
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
              Text(_otherUser?.name ?? 'Secure Chat'),
              if (_otherUser != null)
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
                          color:
                              _otherUser!.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _otherUser!.statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _otherUser!.isOnline
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
            icon: const Icon(Icons.people_outline),
            tooltip: 'Select Chat Partner',
            onPressed: _showUserSelection,
          ),
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          const MemoriesScreen(),
          _buildRecordingsTab(),
        ],
      ),
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
                    // Load more messages when scrolled to top
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

  Widget _buildMessageBubble(Message message) {
    final isMe = message.isFromMe(_currentUser?.id ?? '');

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
              if (message.hasMedia) _buildMediaContent(message),
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
    if (message.mediaUrl == null) return const SizedBox.shrink();

    switch (message.messageType) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: message.mediaUrl!,
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
              Text(message.mediaFilename ?? 'Audio'),
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
                  message.mediaFilename ?? 'File',
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
                // Copy to clipboard logic here
              },
            ),
            if (message.isFromMe(_currentUser?.id ?? ''))
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
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _showEmojiPicker,
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

  Widget _buildRecordingsTab() {
    return const RecordingsScreen();
  }
}
