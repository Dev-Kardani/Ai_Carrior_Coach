import 'dart:math' as math;

import 'package:ai_career_coach/core/utils/debug_logger.dart';
import 'package:ai_career_coach/core/utils/error_handler.dart';
import 'package:ai_career_coach/models/chat_message_model.dart';
import 'package:ai_career_coach/services/gemini_service.dart';
import 'package:ai_career_coach/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// AI career chat screen
class ChatScreen extends StatefulWidget {
  final String? initialTopicId;
  const ChatScreen({super.key, this.initialTopicId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _geminiService = GeminiService();
  final _supabaseService = SupabaseService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isSending = false;
  bool _isChatActive = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> _threads = [];
  String? _currentTopicId;
  String? _currentTopicTitle;
  bool _isLoadingThreads = false;

  @override
  void initState() {
    super.initState();
    _loadThreads();

    if (widget.initialTopicId != null) {
      _isChatActive = true;
      if (widget.initialTopicId != 'new') {
        _currentTopicId = widget.initialTopicId;
        _loadChatHistory(_currentTopicId!);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadThreads() async {
    setState(() => _isLoadingThreads = true);
    DebugLogger.info(
        'CHAT_DATA', 'FETCH_THREADS', 'Loading chat topic threads');
    try {
      final topics = await _supabaseService.getChatTopics();
      DebugLogger.success(
          'CHAT_DATA', 'FETCH_THREADS', 'Loaded ${topics.length} threads');
      setState(() {
        _threads = topics;
        _isLoadingThreads = false;
      });
    } catch (e) {
      DebugLogger.failed('CHAT_DATA', 'FETCH_THREADS', e.toString(), error: e);
      if (mounted) setState(() => _isLoadingThreads = false);
    }
  }

  Future<void> _loadChatHistory(String topicId) async {
    DebugLogger.info(
        'CHAT_DATA', 'FETCH_HISTORY', 'Loading messages for topic $topicId');
    try {
      final messages = await _supabaseService.getChatMessages(topicId);
      DebugLogger.success(
          'CHAT_DATA', 'FETCH_HISTORY', 'Loaded ${messages.length} messages');
      setState(() {
        _messages = messages.reversed.toList();
      });
    } catch (e) {
      DebugLogger.failed('CHAT_DATA', 'FETCH_HISTORY', e.toString(), error: e);
      if (mounted) {
        ErrorHandler.showError(context, 'Failed to load chat history');
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    DebugLogger.info(
        'CHAT', 'SEND_MESSAGE', 'Sending user message length: ${text.length}');

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMessage);
      _messageController.clear();
      _isSending = true;
      _isChatActive = true;
    });

    _scrollToBottom();

    try {
      if (_currentTopicId == null) {
        DebugLogger.info('CHAT', 'CREATE_TOPIC', 'Creating new chat topic');
        final topicTitle =
            text.length > 30 ? '${text.substring(0, 30)}...' : text;
        final topic = await _supabaseService.createChatTopic(topicTitle);
        setState(() {
          _currentTopicId = topic['id'];
          _currentTopicTitle = topicTitle;
        });
        _loadThreads(); // Refresh threads in background
        DebugLogger.success(
            'CHAT', 'CREATE_TOPIC', 'Created topic $_currentTopicId');
      }

      // Save user message to Supabase
      await _supabaseService.saveChatMessage(
        topicId: _currentTopicId!,
        text: text,
        isUser: true,
      );

      DebugLogger.info('CHAT', 'AI_REQUEST', 'Requesting response from Gemini');
      final resume = await _supabaseService.getLatestResume();
      final response = await _geminiService.sendChatMessage(
        message: text,
        history: _messages.reversed.toList(),
        resumeText: resume?.extractedText,
      );
      DebugLogger.success('CHAT', 'AI_RESPONSE',
          'Received AI response length: ${response.length}');

      final aiMessageId = _uuid.v4();

      // Save AI message to Supabase
      await _supabaseService.saveChatMessage(
        topicId: _currentTopicId!,
        text: response,
        isUser: false,
      );

      final aiMessage = ChatMessage(
        id: aiMessageId,
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.insert(0, aiMessage);
        _isSending = false;
      });

      _scrollToBottom();
    } catch (e) {
      DebugLogger.failed('CHAT', 'SEND_MESSAGE', e.toString(), error: e);
      if (mounted) {
        setState(() => _isSending = false);
        ErrorHandler.showError(context, ErrorHandler.formatError(e));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // Slate 50
      child: _isChatActive
          ? Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildChatAppBar(),
              body: _buildActiveChat(),
            )
          : _buildChatHub(),
    );
  }

  PreferredSizeWidget _buildChatAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE2E8F0), height: 1),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF64748B)),
        onPressed: () => setState(() => _isChatActive = false),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                size: 20, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentTopicTitle ?? 'CareerAI Assistant',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF64748B)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildChatHub() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (MediaQuery.of(context).size.width > 768)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Career Chat',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                          const SizedBox(height: 4),
                          const Text(
                            'Get personalized career guidance anytime.',
                            style: TextStyle(
                                color: Color(0xFF64748B), fontSize: 16),
                          ).animate().fadeIn(delay: 100.ms),
                        ],
                      ),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      DebugLogger.info('CHAT_UI', 'NEW_CHAT_CLICKED');
                      setState(() {
                        _isChatActive = true;
                        _messages = [];
                        _currentTopicId = null;
                        _currentTopicTitle = null;
                      });
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New Chat',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Prompts
              _buildQuickPrompts()
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),

              // Search
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style:
                      const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Color(0xFF94A3B8), size: 20),
                    hintText: 'Search conversations...',
                    border: InputBorder.none,
                    hintStyle:
                        TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),

              _isLoadingThreads
                  ? const Center(child: CircularProgressIndicator())
                  : _threads.isEmpty
                      ? _buildEmptyThreadsState()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _threads.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final thread = _threads[index];
                            if (_searchQuery.isNotEmpty &&
                                !thread['title']
                                    .toString()
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) &&
                                !thread['lastMessage']
                                    .toString()
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase())) {
                              return const SizedBox.shrink();
                            }
                            return _buildThreadCard(thread, index);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      'Help me prepare for a technical interview',
      'Review my career path options',
      'How to negotiate a higher salary',
      'What skills should I learn next?',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFFAF5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 20, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text(
                'Quick Prompts',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 600;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmall ? 1 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isSmall ? 6.5 : 4.5, // Slightly more height
              ),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      DebugLogger.info('CHAT_UI', 'QUICK_PROMPT_CLICKED',
                          'Prompt index: $index');
                      setState(() {
                        _isChatActive = true;
                        _messageController.text = prompts[index];
                      });
                      _sendMessage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E7FF)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompts[index],
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF334155)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 16, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildThreadCard(Map<String, dynamic> thread, int index) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          DebugLogger.info(
              'CHAT_UI', 'THREAD_CLICKED', 'Thread ${thread['id']}');
          setState(() {
            _isChatActive = true;
            _currentTopicId = thread['id'];
            _currentTopicTitle = thread['title'];
            _messages = []; // Clear current messages while loading
          });
          _loadChatHistory(thread['id']);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.message_rounded,
                    size: 18, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            thread['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                                fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(thread['created_at']),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thread['lastMessage'] ??
                          'Open conversation to continue...',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          '${thread['message_count'] ?? 0} messages',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFCBD5E1), size: 18),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (300 + (index * 50)).ms)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildEmptyThreadsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF94A3B8), size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'No conversations yet',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Start a new chat to get career advice.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChat() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildActiveEmptyState()
              : _buildMessageList(),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildActiveEmptyState() {
    final prompts = [
      "What skills are in demand for Product Designers in 2026?",
      "Help me prepare for a behavioral interview",
      "How should I structure my portfolio?",
      "What's the best way to network on LinkedIn?",
    ];

    return SingleChildScrollView(
        child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFF4F46E5), size: 32),
              ).animate().scale(delay: 200.ms),
              const SizedBox(height: 16),
              const Text(
                'Start a conversation',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 8),
              const Text(
                'Ask me anything about your career, resume, interviews, or job search strategy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 32),
              LayoutBuilder(builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 400;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmall ? 1 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                        isSmall ? 5.5 : 3.8, // Slightly more height
                  ),
                  itemCount: prompts.length,
                  itemBuilder: (context, index) {
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _messageController.text = prompts[index];
                          _sendMessage();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            prompts[index],
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF334155)),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (500 + index * 100).ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(24),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isSending && index == 0) {
          return _buildTypingIndicator();
        }
        final message = _isSending ? _messages[index - 1] : _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      size: 16, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        message.isUser ? const Color(0xFF4F46E5) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    border: message.isUser
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 16, color: Color(0xFF475569)),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 4,
                    minLines: 1,
                    style:
                        const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Ask me anything about your career...',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintStyle:
                          TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _messageController,
                builder: (context, value, _) {
                  final canSend = value.text.trim().isNotEmpty && !_isSending;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: canSend
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: canSend ? _sendMessage : null,
                      padding: const EdgeInsets.all(12),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    size: 16, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    _buildDot(0),
                    const SizedBox(width: 4),
                    _buildDot(0.2),
                    const SizedBox(width: 4),
                    _buildDot(0.4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildDot(double delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        // Create a bouncing effect using sine wave
        final offset = math.sin((value * math.pi * 2) - delay) * 4;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF94A3B8),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        // Loop is handled by re-triggering the build, but for simplicity in TweenBuilder
        // we might rely on the parent state or a custom infinitely animating widget
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Today';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final midnightDate = DateTime(date.year, date.month, date.day);
      final diff = midnight.difference(midnightDate).inDays;

      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      if (diff < 7) return DateFormat('EEEE').format(date);
      return DateFormat('MMM dd').format(date);
    } catch (e) {
      return 'Today';
    }
  }
}
