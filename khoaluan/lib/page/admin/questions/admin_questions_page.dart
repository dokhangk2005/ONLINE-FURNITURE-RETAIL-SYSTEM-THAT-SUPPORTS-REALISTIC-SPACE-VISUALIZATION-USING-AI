import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/l10n.dart';
import '../../../model/support_conversation.dart';
import '../../../services/api_service.dart';
import '../../../services/support_realtime_service.dart';

class AdminQuestionsPage extends StatefulWidget {
  const AdminQuestionsPage({super.key});

  @override
  State<AdminQuestionsPage> createState() => _AdminQuestionsPageState();
}

class _AdminQuestionsPageState extends State<AdminQuestionsPage> {
  static const _primary = Color(0xff4E73DF);

  final ApiService _api = ApiService();
  final SupportRealtimeService _realtime = SupportRealtimeService.instance;
  final TextEditingController _searchController = TextEditingController();
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
  String _filterStatus = 'WaitingAdmin';
  String? _loadError;
  bool _isLoading = true;
  bool _isLoadingConversation = false;
  bool _isSending = false;
  bool _isUpdating = false;
  bool _showListOnCompact = true;
  bool _typingSent = false;
  bool _customerIsTyping = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSearch);
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
    _searchController.removeListener(_refreshSearch);
    _messageController.removeListener(_handleTypingInput);
    _searchController.dispose();
    _messageController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  void _refreshSearch() {
    if (mounted) setState(() {});
  }

  Future<void> _loadConversations() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final conversations = await _api.fetchAdminSupportConversations();
      if (!mounted) return;
      setState(() {
        _conversations = _sort(conversations);
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
      _customerIsTyping = false;
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
        _upsert(opened);
        _isLoadingConversation = false;
      });
      unawaited(_markRead(summary.conversationId));
      _scrollToEnd();
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
      // Realtime or the next refresh will reconcile the unread counter.
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
      final message = await _api.sendSupportMessage(
        conversation.conversationId,
        text,
        clientMessageId: _uuid.v4(),
      );
      if (!mounted) return;
      _messageController.clear();
      _onMessageReceived(message);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _assignToMe() async {
    final conversation = _selectedConversation;
    if (conversation == null || _isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      await _api.assignSupportConversation(conversation.conversationId);
      final refreshed = await _api.fetchSupportConversation(
        conversation.conversationId,
      );
      if (!mounted) return;
      setState(() {
        _selectedConversation = refreshed;
        _upsert(refreshed);
      });
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _toggleClosed() async {
    final conversation = _selectedConversation;
    if (conversation == null || _isUpdating) return;
    final isClosed = conversation.status.toLowerCase() == 'closed';
    setState(() => _isUpdating = true);
    try {
      await _api.updateSupportConversationStatus(
        conversation.conversationId,
        isClosed ? 'Open' : 'Closed',
      );
      final refreshed = await _api.fetchSupportConversation(
        conversation.conversationId,
      );
      if (!mounted) return;
      setState(() {
        _selectedConversation = refreshed;
        _upsert(refreshed);
      });
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _onConversationUpdated(SupportConversationModel update) {
    if (!mounted) return;
    setState(() {
      _upsert(update);
      final selected = _selectedConversation;
      if (selected?.conversationId == update.conversationId) {
        _selectedConversation = _merge(selected!, update);
      }
    });
  }

  void _onMessageReceived(SupportMessageModel message) {
    if (!mounted ||
        _selectedConversation?.conversationId != message.conversationId) {
      return;
    }
    final selected = _selectedConversation!;
    final messages = [...selected.messages];
    final index = messages.indexWhere(
      (item) => item.messageId == message.messageId,
    );
    if (index >= 0) {
      messages[index] = message;
    } else {
      messages.add(message);
    }
    messages.sort((a, b) {
      final date = a.sentAt.compareTo(b.sentAt);
      return date != 0 ? date : a.messageId.compareTo(b.messageId);
    });
    final updated = _copyConversation(
      selected,
      messages: messages,
      lastMessage: message,
      updatedAt: message.sentAt,
      unreadCount: 0,
    );
    final isCustomer = message.senderRole.toLowerCase() == 'customer';
    setState(() {
      _selectedConversation = updated;
      _upsert(updated);
      if (isCustomer) _customerIsTyping = false;
    });
    if (isCustomer) {
      _typingExpiryTimer?.cancel();
      unawaited(_markRead(message.conversationId));
    }
    _scrollToEnd();
  }

  void _onMessagesRead(SupportMessagesReadModel receipt) {
    if (!mounted ||
        _selectedConversation?.conversationId != receipt.conversationId) {
      return;
    }
    final selected = _selectedConversation!;
    final messages = selected.messages.map((message) {
      final readByOther =
          message.senderRole.toLowerCase() != receipt.readerRole.toLowerCase();
      if (!readByOther || message.sentAt.isAfter(receipt.readAt)) {
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
      _upsert(updated);
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
        typing.senderRole.toLowerCase() != 'customer') {
      return;
    }
    _typingExpiryTimer?.cancel();
    setState(() => _customerIsTyping = typing.isTyping);
    if (typing.isTyping) {
      _typingExpiryTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _customerIsTyping = false);
      });
    }
  }

  List<SupportConversationModel> get _visibleConversations {
    final query = _searchController.text.trim().toLowerCase();
    return _conversations.where((conversation) {
      final matchesStatus =
          _filterStatus == 'All' ||
          conversation.status.toLowerCase() == _filterStatus.toLowerCase();
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;
      final searchText = [
        conversation.customerName,
        conversation.customerEmail,
        conversation.topic,
        conversation.lastMessage?.messageText ?? '',
      ].join(' ').toLowerCase();
      return searchText.contains(query);
    }).toList();
  }

  int _statusCount(String status) => status == 'All'
      ? _conversations.length
      : _conversations
            .where((item) => item.status.toLowerCase() == status.toLowerCase())
            .length;

  void _upsert(SupportConversationModel conversation) {
    final conversations = [..._conversations];
    final index = conversations.indexWhere(
      (item) => item.conversationId == conversation.conversationId,
    );
    if (index >= 0) {
      conversations[index] = _merge(conversations[index], conversation);
    } else {
      conversations.add(conversation);
    }
    _conversations = _sort(conversations);
  }

  List<SupportConversationModel> _sort(
    List<SupportConversationModel> conversations,
  ) {
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  SupportConversationModel _merge(
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

  void _scrollToEnd() {
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xffF6F8FC),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(),
            const SizedBox(height: 16),
            _buildToolbar(),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 850;
                  if (compact) {
                    return _showListOnCompact
                        ? _buildInbox(compact: true)
                        : _buildChat(compact: true);
                  }
                  return Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xffDFE6F1)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 365,
                          child: _buildInbox(compact: false),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: _buildChat(compact: false)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.adminSupportInboxTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff2E384D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.adminSupportInboxDescription,
                style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        _buildConnectionStatus(),
        const SizedBox(width: 8),
        IconButton(
          tooltip: context.l10n.refresh,
          onPressed: _loadConversations,
          icon: const Icon(Icons.refresh_rounded, color: _primary),
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
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: color.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterButton('WaitingAdmin', context.l10n.needsAdminReply),
                _filterButton('WaitingCustomer', context.l10n.awaitingCustomer),
                _filterButton('Open', context.l10n.supportActive),
                _filterButton('Closed', context.l10n.supportClosed),
                _filterButton('All', context.l10n.allSupportConversations),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 250,
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.l10n.searchSupportConversation,
              prefixIcon: const Icon(Icons.search_rounded, size: 19),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xffDDE4EF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xffDDE4EF)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterButton(String status, String label) {
    final selected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _filterStatus = status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _primary : const Color(0xffD9E1ED),
            ),
          ),
          child: Text(
            '$label (${_statusCount(status)})',
            style: TextStyle(
              color: selected ? Colors.white : Colors.blueGrey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInbox({required bool compact}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xffFBFCFE),
        borderRadius: compact ? BorderRadius.circular(15) : BorderRadius.zero,
        border: compact ? Border.all(color: const Color(0xffDFE6F1)) : null,
      ),
      child: _buildInboxContent(),
    );
  }

  Widget _buildInboxContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: Colors.grey),
              const SizedBox(height: 8),
              Text(_loadError!, textAlign: TextAlign.center),
              TextButton(
                onPressed: _loadConversations,
                child: Text(context.l10n.retryMessage),
              ),
            ],
          ),
        ),
      );
    }
    final conversations = _visibleConversations;
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 46,
              color: Colors.blueGrey.shade300,
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.noAdminSupportConversations,
              style: TextStyle(color: Colors.blueGrey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 66),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final selected =
              conversation.conversationId ==
              _selectedConversation?.conversationId;
          return Material(
            color: selected ? const Color(0xffEAF0FF) : Colors.transparent,
            child: InkWell(
              onTap: () => _openConversation(conversation),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: selected
                          ? _primary
                          : const Color(0xffE8EDF5),
                      foregroundColor: selected
                          ? Colors.white
                          : Colors.blueGrey.shade600,
                      child: Text(
                        _initials(conversation.customerName),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
                                  conversation.customerName.isEmpty
                                      ? context.l10n.anonymous
                                      : conversation.customerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff243247),
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
                          const SizedBox(height: 3),
                          Text(
                            _topicLabel(conversation.topic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conversation.lastMessage?.messageText ??
                                      context.l10n.noMessagesYet,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade600,
                                    fontSize: 12,
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
                                    horizontal: 5,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: _primary,
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

  Widget _buildChat({required bool compact}) {
    final conversation = _selectedConversation;
    final border = compact ? Border.all(color: const Color(0xffDFE6F1)) : null;
    if (conversation == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: border,
          borderRadius: compact ? BorderRadius.circular(15) : BorderRadius.zero,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xffEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  color: _primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.adminChooseConversation,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xff334155),
                ),
              ),
            ],
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
        borderRadius: compact ? BorderRadius.circular(15) : BorderRadius.zero,
      ),
      child: Column(
        children: [
          _buildChatHeader(conversation, compact: compact),
          Expanded(
            child: _isLoadingConversation
                ? const Center(
                    child: CircularProgressIndicator(color: _primary),
                  )
                : _buildMessages(conversation),
          ),
          if (isClosed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              color: const Color(0xffF1F5F9),
              child: Text(
                context.l10n.adminClosedConversationHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildChatHeader(
    SupportConversationModel conversation, {
    required bool compact,
  }) {
    final isClosed = conversation.status.toLowerCase() == 'closed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffE3E9F2))),
      ),
      child: Row(
        children: [
          if (compact)
            IconButton(
              tooltip: context.l10n.backToConversations,
              onPressed: () => setState(() => _showListOnCompact = true),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xffEAF0FF),
            foregroundColor: _primary,
            child: Text(
              _initials(conversation.customerName),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.customerName.isEmpty
                      ? context.l10n.anonymous
                      : conversation.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff243247),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${conversation.customerEmail} · ${_statusLabel(conversation.status)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (conversation.assignedAdminId == null)
            OutlinedButton.icon(
              onPressed: _isUpdating ? null : _assignToMe,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: Text(context.l10n.assignToMe),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
              ),
            )
          else if (!compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xffEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                context.l10n.assignedAdmin(
                  conversation.assignedAdminName ?? context.l10n.adminSupport,
                ),
                style: const TextStyle(
                  color: _primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: isClosed
                ? context.l10n.reopenConversation
                : context.l10n.closeConversation,
            onPressed: _isUpdating ? null : _toggleClosed,
            icon: _isUpdating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isClosed ? Icons.lock_open_rounded : Icons.check_circle,
                    color: isClosed ? Colors.green : Colors.blueGrey,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(SupportConversationModel conversation) {
    if (conversation.messages.isEmpty) {
      return Center(child: Text(context.l10n.noMessagesYet));
    }
    return ListView.builder(
      controller: _messageScrollController,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      itemCount: conversation.messages.length,
      itemBuilder: (context, index) {
        final message = conversation.messages[index];
        final isAdmin = message.senderRole.toLowerCase() == 'admin';
        return Align(
          alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            margin: const EdgeInsets.only(bottom: 11),
            child: Column(
              crossAxisAlignment: isAdmin
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.senderName.isEmpty
                          ? conversation.customerName
                          : message.senderName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _primary,
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
                    color: isAdmin ? _primary : const Color(0xffF0F3F7),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isAdmin ? 14 : 4),
                      bottomRight: Radius.circular(isAdmin ? 4 : 14),
                    ),
                  ),
                  child: Text(
                    message.messageText,
                    style: TextStyle(
                      color: isAdmin ? Colors.white : const Color(0xff263548),
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
                        color: Colors.blueGrey.shade400,
                        fontSize: 10,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 5),
                      Icon(
                        message.readAt == null
                            ? Icons.check_rounded
                            : Icons.done_all_rounded,
                        size: 14,
                        color: message.readAt == null
                            ? Colors.blueGrey.shade400
                            : _primary,
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

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffE3E9F2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_customerIsTyping) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 7),
              child: Text(
                context.l10n.customerIsTyping,
                style: const TextStyle(
                  color: _primary,
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
                    hintText: context.l10n.adminSupportReplyHint,
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xffF4F6FA),
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
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                ),
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            context.l10n.adminReplyEmailNotice,
            style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade500),
          ),
        ],
      ),
    );
  }

  String _topicLabel(String topic) {
    final normalized = topic.trim().toLowerCase();
    if (normalized == 'product-advice' || normalized.contains('sản phẩm')) {
      return context.l10n.topicProductAdvice;
    }
    if (normalized == 'policies' || normalized.contains('bảo hành')) {
      return context.l10n.topicPolicies;
    }
    if (normalized == 'custom-design' || normalized.contains('thiết kế')) {
      return context.l10n.topicCustomDesign;
    }
    if (normalized == 'feedback' || normalized.contains('góp ý')) {
      return context.l10n.topicFeedback;
    }
    return topic;
  }

  String _statusLabel(String status) => switch (status.toLowerCase()) {
    'waitingadmin' => context.l10n.needsAdminReply,
    'waitingcustomer' => context.l10n.awaitingCustomer,
    'closed' => context.l10n.supportClosed,
    _ => context.l10n.supportActive,
  };

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
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
