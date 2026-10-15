import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/l10n.dart';
import '../../model/support_conversation.dart';
import '../../services/api_service.dart';
import '../../services/support_realtime_service.dart';

class MyQuestionsTab extends StatefulWidget {
  const MyQuestionsTab({super.key});

  @override
  State<MyQuestionsTab> createState() => _MyQuestionsTabState();
}

class _MyQuestionsTabState extends State<MyQuestionsTab> {
  static const _blue = Color(0xff2563EB);
  static const _topics = <String>[
    'product-advice',
    'policies',
    'custom-design',
    'feedback',
  ];

  final ApiService _api = ApiService();
  final SupportRealtimeService _realtime = SupportRealtimeService.instance;
  final TextEditingController _newMessageController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();
  final Uuid _uuid = const Uuid();

  StreamSubscription<SupportConversationModel>? _conversationSubscription;
  StreamSubscription<SupportMessageModel>? _messageSubscription;
  StreamSubscription<SupportMessagesReadModel>? _readSubscription;
  StreamSubscription<SupportTypingModel>? _typingSubscription;
  Timer? _typingStopTimer;
  Timer? _typingExpiryTimer;

  List<SupportConversationModel> _conversations = const [];
  SupportConversationModel? _selectedConversation;
  String _selectedTopic = _topics.first;
  String? _loadError;
  bool _isLoading = true;
  bool _isLoadingConversation = false;
  bool _isSending = false;
  bool _isCreating = false;
  bool _showNewConversation = false;
  bool _showListOnCompact = true;
  bool _typingSent = false;
  bool _supportIsTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_handleTypingInput);
    _conversationSubscription = _realtime.conversationUpdates.listen(
      _onConversationUpdated,
    );
    _messageSubscription = _realtime.messages.listen(_onMessageReceived);
    _readSubscription = _realtime.readReceipts.listen(_onMessagesRead);
    _typingSubscription = _realtime.typingUpdates.listen(_onTypingChanged);
    unawaited(_realtime.connect());
    unawaited(_loadConversations());
  }

  @override
  void dispose() {
    final selectedId = _selectedConversation?.conversationId;
    if (selectedId != null) {
      unawaited(_realtime.setTyping(selectedId, false));
      unawaited(_realtime.leaveConversation(selectedId));
    }
    unawaited(_conversationSubscription?.cancel());
    unawaited(_messageSubscription?.cancel());
    unawaited(_readSubscription?.cancel());
    unawaited(_typingSubscription?.cancel());
    _typingStopTimer?.cancel();
    _typingExpiryTimer?.cancel();
    _messageController.removeListener(_handleTypingInput);
    _newMessageController.dispose();
    _messageController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final conversations = await _api.fetchMySupportConversations();
      if (!mounted) return;
      setState(() {
        _conversations = _sortConversations(conversations);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openConversation(SupportConversationModel summary) async {
    final previousId = _selectedConversation?.conversationId;
    if (previousId != null && previousId != summary.conversationId) {
      await _sendTyping(false);
      unawaited(_realtime.leaveConversation(previousId));
    }
    _typingExpiryTimer?.cancel();
    setState(() {
      _selectedConversation = summary;
      _isLoadingConversation = true;
      _showListOnCompact = false;
      _supportIsTyping = false;
    });

    try {
      await _realtime.joinConversation(summary.conversationId);
      final detail = await _api.fetchSupportConversation(
        summary.conversationId,
      );
      if (!mounted ||
          _selectedConversation?.conversationId != summary.conversationId) {
        return;
      }
      final opened = _copyConversation(detail, unreadCount: 0);
      setState(() {
        _selectedConversation = opened;
        _upsertConversation(opened);
        _isLoadingConversation = false;
      });
      unawaited(_markRead(summary.conversationId));
      _scrollMessagesToEnd();
    } catch (error) {
      if (!mounted ||
          _selectedConversation?.conversationId != summary.conversationId) {
        return;
      }
      setState(() => _isLoadingConversation = false);
      _showError(error);
    }
  }

  Future<void> _markRead(int conversationId) async {
    try {
      await _api.markSupportConversationRead(conversationId);
    } catch (_) {
      // The next refresh or realtime update will reconcile the unread state.
    }
  }

  Future<void> _createConversation() async {
    final text = _newMessageController.text.trim();
    if (text.length < 10) {
      _showError(context.l10n.supportFirstMessageValidation);
      return;
    }
    setState(() => _isCreating = true);
    try {
      final conversation = await _api.createSupportConversation(
        topic: _selectedTopic,
        messageText: text,
        clientMessageId: _uuid.v4(),
      );
      if (!mounted) return;
      _newMessageController.clear();
      setState(() {
        _showNewConversation = false;
        _isCreating = false;
        _upsertConversation(conversation);
      });
      await _openConversation(conversation);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      _showError(error);
    }
  }

  Future<void> _sendMessage() async {
    final conversation = _selectedConversation;
    final text = _messageController.text.trim();
    if (conversation == null || text.isEmpty || _isSending) return;
    if (text.length > 4000) {
      _showError(context.l10n.supportMessageTooLong);
      return;
    }

    setState(() => _isSending = true);
    await _sendTyping(false);
    try {
      final sent = await _api.sendSupportMessage(
        conversation.conversationId,
        text,
        clientMessageId: _uuid.v4(),
      );
      if (!mounted) return;
      _messageController.clear();
      _onMessageReceived(sent);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _onConversationUpdated(SupportConversationModel update) {
    if (!mounted) return;
    setState(() {
      _upsertConversation(update);
      final selected = _selectedConversation;
      if (selected?.conversationId == update.conversationId) {
        _selectedConversation = _mergeConversation(selected!, update);
      }
    });
  }

  void _onMessageReceived(SupportMessageModel message) {
    if (!mounted) return;
    final selected = _selectedConversation;
    if (selected?.conversationId != message.conversationId) return;

    final messages = [...selected!.messages];
    final existingIndex = messages.indexWhere(
      (item) => item.messageId == message.messageId,
    );
    if (existingIndex >= 0) {
      messages[existingIndex] = message;
    } else {
      messages.add(message);
    }
    messages.sort((a, b) {
      final time = a.sentAt.compareTo(b.sentAt);
      return time != 0 ? time : a.messageId.compareTo(b.messageId);
    });

    final updated = _copyConversation(
      selected,
      messages: messages,
      lastMessage: message,
      updatedAt: message.sentAt,
      unreadCount: 0,
    );
    final isAdmin = message.senderRole.toLowerCase() == 'admin';
    setState(() {
      _selectedConversation = updated;
      _upsertConversation(updated);
      if (isAdmin) _supportIsTyping = false;
    });
    if (isAdmin) {
      _typingExpiryTimer?.cancel();
      unawaited(_markRead(message.conversationId));
    }
    _scrollMessagesToEnd();
  }

  void _onMessagesRead(SupportMessagesReadModel receipt) {
    if (!mounted ||
        _selectedConversation?.conversationId != receipt.conversationId) {
      return;
    }
    final selected = _selectedConversation!;
    final messages = selected.messages.map((message) {
      final wasReadByOtherRole =
          message.senderRole.toLowerCase() != receipt.readerRole.toLowerCase();
      if (!wasReadByOtherRole || message.sentAt.isAfter(receipt.readAt)) {
        return message;
      }
      return SupportMessageModel(
        messageId: message.messageId,
        conversationId: message.conversationId,
        senderId: message.senderId,
        senderName: message.senderName,
        senderRole: message.senderRole,
        messageType: message.messageType,
        messageText: message.messageText,
        clientMessageId: message.clientMessageId,
        sentAt: message.sentAt,
        readAt: receipt.readAt,
      );
    }).toList();
    final updated = _copyConversation(selected, messages: messages);
    setState(() {
      _selectedConversation = updated;
      _upsertConversation(updated);
    });
  }

  void _handleTypingInput() {
    final conversation = _selectedConversation;
    if (conversation == null || conversation.status.toLowerCase() == 'closed') {
      return;
    }
    _typingStopTimer?.cancel();
    if (_messageController.text.trim().isEmpty) {
      unawaited(_sendTyping(false));
      return;
    }
    if (!_typingSent) unawaited(_sendTyping(true));
    _typingStopTimer = Timer(
      const Duration(milliseconds: 1200),
      () => unawaited(_sendTyping(false)),
    );
  }

  Future<void> _sendTyping(bool isTyping) async {
    final conversationId = _selectedConversation?.conversationId;
    if (conversationId == null || _typingSent == isTyping) return;
    _typingSent = isTyping;
    await _realtime.setTyping(conversationId, isTyping);
  }

  void _onTypingChanged(SupportTypingModel typing) {
    if (!mounted ||
        typing.conversationId != _selectedConversation?.conversationId ||
        typing.senderRole.toLowerCase() != 'admin') {
      return;
    }
    _typingExpiryTimer?.cancel();
    setState(() => _supportIsTyping = typing.isTyping);
    if (typing.isTyping) {
      _typingExpiryTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _supportIsTyping = false);
      });
    }
  }

  void _upsertConversation(SupportConversationModel conversation) {
    final conversations = [..._conversations];
    final index = conversations.indexWhere(
      (item) => item.conversationId == conversation.conversationId,
    );
    if (index >= 0) {
      conversations[index] = _mergeConversation(
        conversations[index],
        conversation,
      );
    } else {
      conversations.add(conversation);
    }
    _conversations = _sortConversations(conversations);
  }

  List<SupportConversationModel> _sortConversations(
    List<SupportConversationModel> conversations,
  ) {
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  SupportConversationModel _mergeConversation(
    SupportConversationModel current,
    SupportConversationModel update,
  ) {
    return SupportConversationModel(
      conversationId: update.conversationId,
      userId: update.userId,
      customerName: update.customerName,
      customerEmail: update.customerEmail,
      assignedAdminId: update.assignedAdminId,
      assignedAdminName: update.assignedAdminName,
      legacyQuestionId: update.legacyQuestionId,
      topic: update.topic,
      status: update.status,
      createdAt: update.createdAt,
      updatedAt: update.updatedAt,
      closedAt: update.closedAt,
      unreadCount: update.unreadCount,
      lastMessage: update.lastMessage ?? current.lastMessage,
      messages: update.messages.isEmpty ? current.messages : update.messages,
    );
  }

  SupportConversationModel _copyConversation(
    SupportConversationModel source, {
    List<SupportMessageModel>? messages,
    SupportMessageModel? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return SupportConversationModel(
      conversationId: source.conversationId,
      userId: source.userId,
      customerName: source.customerName,
      customerEmail: source.customerEmail,
      assignedAdminId: source.assignedAdminId,
      assignedAdminName: source.assignedAdminName,
      legacyQuestionId: source.legacyQuestionId,
      topic: source.topic,
      status: source.status,
      createdAt: source.createdAt,
      updatedAt: updatedAt ?? source.updatedAt,
      closedAt: source.closedAt,
      unreadCount: unreadCount ?? source.unreadCount,
      lastMessage: lastMessage ?? source.lastMessage,
      messages: messages ?? source.messages,
    );
  }

  void _scrollMessagesToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageScrollController.hasClients) return;
      _messageScrollController.animateTo(
        _messageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _showError(Object error) {
    if (!mounted) return;
    final message = error.toString().replaceFirst('Exception: ', '');
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.supportChatTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff172033),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.supportChatDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            _buildConnectionStatus(),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 660,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              if (compact) {
                return _showListOnCompact
                    ? _buildConversationList(compact: true)
                    : _buildChatPanel(compact: true);
              }
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xffDCE6F4)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D1E3A5F),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 310,
                      child: _buildConversationList(compact: false),
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    Expanded(child: _buildChatPanel(compact: false)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return ValueListenableBuilder<SupportRealtimeConnectionState>(
      valueListenable: _realtime.connectionState,
      builder: (context, state, _) {
        final (label, color) = switch (state) {
          SupportRealtimeConnectionState.connected => (
            context.l10n.supportOnline,
            Colors.green,
          ),
          SupportRealtimeConnectionState.connecting => (
            context.l10n.supportConnecting,
            Colors.orange,
          ),
          SupportRealtimeConnectionState.reconnecting => (
            context.l10n.supportReconnecting,
            Colors.orange,
          ),
          SupportRealtimeConnectionState.disconnected => (
            context.l10n.supportOffline,
            Colors.grey,
          ),
        };
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConversationList({required bool compact}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFD),
        borderRadius: compact ? BorderRadius.circular(18) : BorderRadius.zero,
        border: compact ? Border.all(color: const Color(0xffDCE6F4)) : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => setState(
                  () => _showNewConversation = !_showNewConversation,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                icon: Icon(
                  _showNewConversation
                      ? Icons.close
                      : Icons.add_comment_outlined,
                  size: 18,
                ),
                label: Text(context.l10n.newSupportConversation),
              ),
            ),
          ),
          if (_showNewConversation) _buildNewConversationForm(),
          const Divider(height: 1),
          Expanded(child: _buildConversationItems()),
        ],
      ),
    );
  }

  Widget _buildNewConversationForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffD6E3F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedTopic,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.supportTopic,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            items: _topics
                .map(
                  (topic) => DropdownMenuItem(
                    value: topic,
                    child: Text(
                      _topicLabel(topic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedTopic = value);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newMessageController,
            minLines: 2,
            maxLines: 4,
            maxLength: 4000,
            decoration: InputDecoration(
              hintText: context.l10n.supportFirstMessageHint,
              isDense: true,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isCreating ? null : _createConversation,
              style: FilledButton.styleFrom(backgroundColor: _blue),
              child: _isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.createSupportConversation),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItems() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _blue));
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
              TextButton(
                onPressed: _loadConversations,
                child: Text(context.l10n.retryMessage),
              ),
            ],
          ),
        ),
      );
    }
    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 44,
                color: Colors.blueGrey.shade300,
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.noSupportConversations,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: _conversations.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          final selected =
              conversation.conversationId ==
              _selectedConversation?.conversationId;
          return Material(
            color: selected ? const Color(0xffEAF2FF) : Colors.transparent,
            child: InkWell(
              onTap: () => _openConversation(conversation),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: selected
                          ? _blue
                          : const Color(0xffE3EBF5),
                      foregroundColor: selected
                          ? Colors.white
                          : Colors.blueGrey.shade600,
                      child: const Icon(Icons.support_agent, size: 21),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _topicLabel(conversation.topic),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff1E293B),
                                  ),
                                ),
                              ),
                              Text(
                                _shortTime(conversation.updatedAt),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blueGrey.shade500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conversation.lastMessage?.messageText ??
                                      context.l10n.noMessagesYet,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey.shade600,
                                  ),
                                ),
                              ),
                              if (conversation.unreadCount > 0)
                                Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: _blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    conversation.unreadCount > 99
                                        ? '99+'
                                        : '${conversation.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatPanel({required bool compact}) {
    final conversation = _selectedConversation;
    final border = compact ? Border.all(color: const Color(0xffDCE6F4)) : null;
    if (conversation == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: border,
          borderRadius: compact ? BorderRadius.circular(18) : BorderRadius.zero,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xffEDF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: _blue,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  context.l10n.noConversationSelected,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xff334155),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.chooseConversationHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey.shade500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isClosed = conversation.status.toLowerCase() == 'closed';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: border,
        borderRadius: compact ? BorderRadius.circular(18) : BorderRadius.zero,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xffE5ECF5))),
            ),
            child: Row(
              children: [
                if (compact)
                  IconButton(
                    tooltip: context.l10n.backToConversations,
                    onPressed: () => setState(() => _showListOnCompact = true),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                const CircleAvatar(
                  radius: 19,
                  backgroundColor: Color(0xffEAF2FF),
                  foregroundColor: _blue,
                  child: Icon(Icons.support_agent, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _topicLabel(conversation.topic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusLabel(conversation.status),
                        style: TextStyle(
                          color: isClosed
                              ? Colors.grey.shade600
                              : Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.retryMessage,
                  onPressed: () => _openConversation(conversation),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoadingConversation
                ? const Center(child: CircularProgressIndicator(color: _blue))
                : _buildMessages(conversation),
          ),
          if (isClosed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: const Color(0xffF1F5F9),
              child: Text(
                context.l10n.supportConversationClosed,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            )
          else
            _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessages(SupportConversationModel conversation) {
    if (conversation.messages.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noMessagesYet,
          style: TextStyle(color: Colors.blueGrey.shade500),
        ),
      );
    }
    return ListView.builder(
      controller: _messageScrollController,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      itemCount: conversation.messages.length,
      itemBuilder: (context, index) {
        final message = conversation.messages[index];
        final isMine = message.senderRole.toLowerCase() == 'customer';
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMine)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.senderName.isEmpty
                          ? context.l10n.adminSupport
                          : message.senderName,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMine ? _blue : const Color(0xffF0F4F8),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: Radius.circular(isMine ? 15 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 15),
                    ),
                  ),
                  child: Text(
                    message.messageText,
                    style: TextStyle(
                      color: isMine ? Colors.white : const Color(0xff243244),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _messageTime(message.sentAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 5),
                      Icon(
                        message.readAt == null
                            ? Icons.check_rounded
                            : Icons.done_all_rounded,
                        size: 14,
                        color: message.readAt == null
                            ? Colors.blueGrey.shade400
                            : _blue,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffE5ECF5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_supportIsTyping) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 7),
              child: Text(
                context.l10n.supportIsTyping,
                style: const TextStyle(
                  color: _blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 4000,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: context.l10n.supportMessageHint,
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xffF5F8FC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: context.l10n.sendSupportMessage,
                onPressed: _isSending ? null : _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blueGrey.shade200,
                  minimumSize: const Size(44, 44),
                ),
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _topicLabel(String topic) {
    final normalized = topic.trim().toLowerCase();
    if (normalized == 'product-advice' ||
        normalized.contains('sản phẩm') ||
        normalized.contains('cháº¥t liá»‡u')) {
      return context.l10n.topicProductAdvice;
    }
    if (normalized == 'policies' ||
        normalized.contains('bảo hành') ||
        normalized.contains('báº£o hÃ nh')) {
      return context.l10n.topicPolicies;
    }
    if (normalized == 'custom-design' ||
        normalized.contains('thiết kế') ||
        normalized.contains('thiáº¿t káº¿')) {
      return context.l10n.topicCustomDesign;
    }
    if (normalized == 'feedback' ||
        normalized.contains('góp ý') ||
        normalized.contains('gÃ³p Ã½')) {
      return context.l10n.topicFeedback;
    }
    return topic;
  }

  String _statusLabel(String status) {
    return switch (status.toLowerCase()) {
      'waitingadmin' => context.l10n.waitingForAdmin,
      'waitingcustomer' => context.l10n.waitingForCustomer,
      'closed' => context.l10n.supportClosed,
      _ => context.l10n.supportActive,
    };
  }

  String _shortTime(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }

  String _messageTime(DateTime date) {
    final local = date.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} · ${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
