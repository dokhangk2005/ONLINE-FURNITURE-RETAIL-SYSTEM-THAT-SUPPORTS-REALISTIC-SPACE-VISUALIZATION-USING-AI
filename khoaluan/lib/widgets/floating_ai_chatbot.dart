import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/l10n.dart';
import '../l10n/generated/app_localizations.dart';

class ChatMessage {
  final String text;
  final bool isAi;
  final DateTime time;
  final String? retryQuery;
  final List<ChatbotProductLink> productLinks;

  ChatMessage({
    required this.text,
    required this.isAi,
    required this.time,
    this.retryQuery,
    this.productLinks = const [],
  });
}

class FloatingAiChatbot extends StatefulWidget {
  const FloatingAiChatbot({super.key});

  @override
  State<FloatingAiChatbot> createState() => _FloatingAiChatbotState();
}

class _FloatingAiChatbotState extends State<FloatingAiChatbot>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isOpen = false;
  bool _isLoading = false;
  final List<ChatMessage> _messages = [];

  List<String> _quickPrompts = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (l10n == null) return;
    _quickPrompts = [
      l10n.chatPromptSofa,
      l10n.chatPromptDining,
      l10n.chatPromptDesk,
      l10n.chatPromptVoucher,
      l10n.chatPromptCustom,
    ];
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(text: l10n.chatWelcome, isAi: true, time: DateTime.now()),
      );
    } else if (_messages.length == 1 && _messages.first.isAi) {
      _messages[0] = ChatMessage(
        text: l10n.chatWelcome,
        isAi: true,
        time: _messages.first.time,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text, {bool addUserMessage = true}) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      if (addUserMessage) {
        _messages.add(
          ChatMessage(text: query, isAi: false, time: DateTime.now()),
        );
      }
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final reply = await _apiService.askGeminiChatbot(query);
      setState(() {
        _messages.add(
          ChatMessage(
            text: reply.text,
            isAi: true,
            time: DateTime.now(),
            productLinks: reply.productLinks,
          ),
        );
        _isLoading = false;
      });
    } on ChatbotBusyException {
      setState(() {
        _messages.add(
          ChatMessage(
            text: context.l10n.chatServiceBusy,
            isAi: true,
            time: DateTime.now(),
            retryQuery: query,
          ),
        );
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: context.l10n.chatConnectionError,
            isAi: true,
            time: DateTime.now(),
            retryQuery: query,
          ),
        );
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (localization == null) return const SizedBox.shrink();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 500;

    if (!_isOpen) {
      return Positioned(
        bottom: 24,
        right: 24,
        child: Tooltip(
          message: context.l10n.furnitureAiAssistant,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => setState(() => _isOpen = true),
              customBorder: const CircleBorder(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment(-0.3, -0.35),
                    radius: 1.05,
                    colors: [Color(0xFF38BDF8), Color(0xFF075BC7)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF075BC7).withValues(alpha: 0.34),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.chair_alt_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBAE6FD),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final double chatWidth = isSmallScreen ? (size.width - 32) : 380;
    final double chatHeight = isSmallScreen ? (size.height - 100) : 540;

    return Positioned(
      bottom: 24,
      right: isSmallScreen ? 16 : 24,
      child: Material(
        color: Colors.transparent,
        elevation: 16,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: chatWidth,
          height: chatHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF075BC7).withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF075BC7), Color(0xFF38BDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.furnitureAiAssistant,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFBAE6FD),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                context.l10n.chatReadyStatus,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isOpen = false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Message list
              Expanded(
                child: Container(
                  color: const Color(0xFFF4F9FF),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildLoadingBubble();
                      }
                      final msg = _messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
                ),
              ),

              // Quick prompt suggestions
              if (_messages.length < 5 && !_isLoading)
                Container(
                  height: 38,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    itemCount: _quickPrompts.length,
                    itemBuilder: (context, idx) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => _sendMessage(
                            _quickPrompts[idx].replaceAll('💡 ', ''),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF4FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Text(
                              _quickPrompts[idx],
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF07509F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Input field
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(fontSize: 13),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: context.l10n.chatInputHint,
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _sendMessage(_controller.text),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF075BC7), Color(0xFF38BDF8)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isAi
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (msg.isAi) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, top: 2),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF075BC7), Color(0xFF38BDF8)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isAi ? Colors.white : const Color(0xFF075BC7),
                border: msg.isAi
                    ? Border.all(color: const Color(0xFFDBEAFE))
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(msg.isAi ? 0 : 12),
                  bottomRight: Radius.circular(msg.isAi ? 12 : 0),
                ),
                boxShadow: [
                  if (msg.isAi)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageText(msg),
                  if (msg.retryQuery != null) ...[
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _sendMessage(
                              msg.retryQuery!,
                              addUserMessage: false,
                            ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(context.l10n.retryMessage),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!msg.isAi) ...[
            Container(
              margin: const EdgeInsets.only(left: 8, top: 2),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF075BC7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 14, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageText(ChatMessage message) {
    final normalStyle = TextStyle(
      color: message.isAi ? Colors.grey.shade800 : Colors.white,
      fontSize: 13.5,
      height: 1.4,
    );
    if (!message.isAi || message.productLinks.isEmpty) {
      return Text(message.text, style: normalStyle);
    }

    final links = [...message.productLinks]
      ..sort((a, b) => b.productName.length.compareTo(a.productName.length));
    final lowerText = message.text.toLowerCase();
    final spans = <InlineSpan>[];
    var cursor = 0;
    while (cursor < message.text.length) {
      ChatbotProductLink? matchedLink;
      var matchedIndex = message.text.length;
      for (final link in links) {
        final index = lowerText.indexOf(link.productName.toLowerCase(), cursor);
        if (index >= 0 && index < matchedIndex) {
          matchedIndex = index;
          matchedLink = link;
        }
      }

      if (matchedLink == null) {
        spans.add(TextSpan(text: message.text.substring(cursor)));
        break;
      }
      if (matchedIndex > cursor) {
        spans.add(TextSpan(text: message.text.substring(cursor, matchedIndex)));
      }
      final link = matchedLink;
      final end = matchedIndex + link.productName.length;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: InkWell(
            onTap: () => Navigator.of(
              context,
            ).pushNamed('/product-detail?id=${link.productId}'),
            borderRadius: BorderRadius.circular(3),
            child: Text(
              message.text.substring(matchedIndex, end),
              style: normalStyle.copyWith(
                color: const Color(0xFF075BC7),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF075BC7),
              ),
            ),
          ),
        ),
      );
      cursor = end;
    }

    return Text.rich(TextSpan(style: normalStyle, children: spans));
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF075BC7), Color(0xFF38BDF8)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 14,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF075BC7),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.chatThinking,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
