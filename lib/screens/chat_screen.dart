import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../models/chat_user.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
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
  Timer? _typingTimer;
  bool _isLoading = false;
  bool _canNotifyPartner = true;
  bool _showScrollToBottomButton = false;

  ChatUser? _currentUser;
  ChatUser? _chatPartner;
  String? _partnerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _initializeChat();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
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
      _setupMessageListener();

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

  Future<void> _loadMessages() async {
    try {
      if (_partnerId == null) return;

      final messages = await ChatService.instance.getMessages(
        otherUserId: _partnerId!,
        limit: 50,
        offset: 0,
      );

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages.reversed);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Load messages error: $e');
    }
  }

  void _setupMessageListener() {
    if (_partnerId == null) return;

    _messageSubscription = ChatService.instance
        .listenToMessages(otherUserId: _partnerId!)
        .listen((message) {
      if (mounted) {
        setState(() {
          // Check if message already exists
          if (!_messages.any((m) => m.id == message.id)) {
            _messages.add(message);
          }
        });
        _scrollToBottom();

        // Mark as read if from partner
        if (message.senderId == _partnerId) {
          ChatService.instance.markMessageAsRead(message.id);
        }
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
      await ChatService.instance.sendTextMessage(
        content: content,
        receiverId: _partnerId!,
      );

      // Send notification to partner
      await NotificationService.instance.sendChatMessageNotification(
        recipientUserId: _partnerId!,
        messageContent: content,
        messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      debugPrint('Send message error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _sendImage() async {
    if (_partnerId == null) return;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await ChatService.instance.sendMediaMessage(
          filePath: image.path,
          fileName: image.name,
          messageType: 'image',
          receiverId: _partnerId!,
        );
      }
    } catch (e) {
      debugPrint('Send image error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    }
  }

  Future<void> _notifyPartner() async {
    if (_partnerId == null || !_canNotifyPartner) return;

    try {
      final success =
          await NotificationService.instance.sendPartnerNotification(
        recipientUserId: _partnerId!,
        customMessage: 'Check the compass!',
      );

      if (success) {
        setState(() => _canNotifyPartner = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Notification sent!')),
          );
        }

        // Reset cooldown after 5 minutes
        Future.delayed(const Duration(minutes: 5), () {
          if (mounted) {
            setState(() => _canNotifyPartner = true);
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification on cooldown (5 min)')),
          );
        }
      }
    } catch (e) {
      debugPrint('Notify partner error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _triggerPanicMode() {
    // Auto-lock when app goes to background
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _chatPartner != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_chatPartner!.displayName ?? 'Chat'),
                  Text(
                    _chatPartner!.status == 'online' ? '● Online' : '● Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _chatPartner!.status == 'online'
                              ? Colors.green
                              : Colors.grey,
                        ),
                  ),
                ],
              )
            : const Text('Loading...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _canNotifyPartner ? _notifyPartner : null,
            tooltip: 'Notify Partner',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () async {
                  await AuthService.instance.signOut();
                  if (mounted && context.mounted) {
                    context.go('/');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tab bar
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Chat'),
                    Tab(text: 'Memories'),
                    Tab(text: 'Recordings'),
                  ],
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Chat tab
                      Column(
                        children: [
                          Expanded(
                            child: _messages.isEmpty
                                ? const Center(
                                    child: Text('No messages yet'),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    itemCount: _messages.length,
                                    itemBuilder: (context, index) {
                                      final message = _messages[index];
                                      final isFromMe =
                                          message.senderId == _currentUser?.id;

                                      return Align(
                                        alignment: isFromMe
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isFromMe
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.content,
                                                style: TextStyle(
                                                  color: isFromMe
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat('HH:mm')
                                                    .format(message.createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isFromMe
                                                      ? Colors.white70
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          // Message input
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.image),
                                  onPressed: _sendImage,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      hintText: 'Type a message...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      // Typing indicator logic here
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _sendMessage,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Memories tab
                      const MemoriesScreen(),
                      // Recordings tab
                      const RecordingsScreen(),
                    ],
                  ),
                ),
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
}
