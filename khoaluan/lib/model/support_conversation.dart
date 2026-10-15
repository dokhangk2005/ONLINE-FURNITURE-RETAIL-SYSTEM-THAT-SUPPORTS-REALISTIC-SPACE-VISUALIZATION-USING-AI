class SupportConversationModel {
  const SupportConversationModel({
    required this.conversationId,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.topic,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
    required this.messages,
    this.assignedAdminId,
    this.assignedAdminName,
    this.legacyQuestionId,
    this.closedAt,
    this.lastMessage,
  });

  final int conversationId;
  final int userId;
  final String customerName;
  final String customerEmail;
  final int? assignedAdminId;
  final String? assignedAdminName;
  final int? legacyQuestionId;
  final String topic;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final int unreadCount;
  final SupportMessageModel? lastMessage;
  final List<SupportMessageModel> messages;

  factory SupportConversationModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] ?? json['Messages'];
    return SupportConversationModel(
      conversationId: _int(json['conversationId'] ?? json['ConversationId']),
      userId: _int(json['userId'] ?? json['UserId']),
      customerName: (json['customerName'] ?? json['CustomerName'] ?? '')
          .toString(),
      customerEmail: (json['customerEmail'] ?? json['CustomerEmail'] ?? '')
          .toString(),
      assignedAdminId: _nullableInt(
        json['assignedAdminId'] ?? json['AssignedAdminId'],
      ),
      assignedAdminName:
          (json['assignedAdminName'] ?? json['AssignedAdminName'])?.toString(),
      legacyQuestionId: _nullableInt(
        json['legacyQuestionId'] ?? json['LegacyQuestionId'],
      ),
      topic: (json['topic'] ?? json['Topic'] ?? '').toString(),
      status: (json['status'] ?? json['Status'] ?? 'WaitingAdmin').toString(),
      createdAt: _date(json['createdAt'] ?? json['CreatedAt']),
      updatedAt: _date(json['updatedAt'] ?? json['UpdatedAt']),
      closedAt: _nullableDate(json['closedAt'] ?? json['ClosedAt']),
      unreadCount: _int(json['unreadCount'] ?? json['UnreadCount']),
      lastMessage: _messageOrNull(json['lastMessage'] ?? json['LastMessage']),
      messages: rawMessages is List
          ? rawMessages
                .whereType<Map>()
                .map(
                  (item) => SupportMessageModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class SupportMessageModel {
  const SupportMessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderName,
    required this.senderRole,
    required this.messageType,
    required this.messageText,
    required this.sentAt,
    this.senderId,
    this.clientMessageId,
    this.readAt,
  });

  final int messageId;
  final int conversationId;
  final int? senderId;
  final String senderName;
  final String senderRole;
  final String messageType;
  final String messageText;
  final String? clientMessageId;
  final DateTime sentAt;
  final DateTime? readAt;

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      messageId: _int(json['messageId'] ?? json['MessageId']),
      conversationId: _int(json['conversationId'] ?? json['ConversationId']),
      senderId: _nullableInt(json['senderId'] ?? json['SenderId']),
      senderName: (json['senderName'] ?? json['SenderName'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? json['SenderRole'] ?? '').toString(),
      messageType: (json['messageType'] ?? json['MessageType'] ?? 'Text')
          .toString(),
      messageText: (json['messageText'] ?? json['MessageText'] ?? '')
          .toString(),
      clientMessageId: (json['clientMessageId'] ?? json['ClientMessageId'])
          ?.toString(),
      sentAt: _date(json['sentAt'] ?? json['SentAt']),
      readAt: _nullableDate(json['readAt'] ?? json['ReadAt']),
    );
  }
}

class SupportMessagesReadModel {
  const SupportMessagesReadModel({
    required this.conversationId,
    required this.readerRole,
    required this.readAt,
  });

  final int conversationId;
  final String readerRole;
  final DateTime readAt;

  factory SupportMessagesReadModel.fromJson(Map<String, dynamic> json) {
    return SupportMessagesReadModel(
      conversationId: _int(json['conversationId'] ?? json['ConversationId']),
      readerRole: (json['readerRole'] ?? json['ReaderRole'] ?? '').toString(),
      readAt: _date(json['readAt'] ?? json['ReadAt']),
    );
  }
}

class SupportTypingModel {
  const SupportTypingModel({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.isTyping,
  });

  final int conversationId;
  final int senderId;
  final String senderName;
  final String senderRole;
  final bool isTyping;

  factory SupportTypingModel.fromJson(Map<String, dynamic> json) {
    return SupportTypingModel(
      conversationId: _int(json['conversationId'] ?? json['ConversationId']),
      senderId: _int(json['senderId'] ?? json['SenderId']),
      senderName: (json['senderName'] ?? json['SenderName'] ?? '').toString(),
      senderRole: (json['senderRole'] ?? json['SenderRole'] ?? '').toString(),
      isTyping: json['isTyping'] == true || json['IsTyping'] == true,
    );
  }
}

SupportMessageModel? _messageOrNull(dynamic value) {
  if (value is Map) {
    return SupportMessageModel.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

int _int(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  return value is num ? value.toInt() : int.tryParse('$value');
}

DateTime _date(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? '') ??
    DateTime.fromMillisecondsSinceEpoch(0);

DateTime? _nullableDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());
