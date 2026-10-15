import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/model/support_conversation.dart';

void main() {
  test('đọc hội thoại hỗ trợ và nhiều tin nhắn theo đúng thứ tự API', () {
    final conversation = SupportConversationModel.fromJson({
      'conversationId': 12,
      'userId': 7,
      'customerName': 'Khách hàng',
      'customerEmail': 'customer@example.com',
      'assignedAdminId': 1,
      'assignedAdminName': 'Admin',
      'legacyQuestionId': 33,
      'topic': 'Bảo hành',
      'status': 'WaitingCustomer',
      'createdAt': '2026-08-16T01:00:00Z',
      'updatedAt': '2026-08-16T01:05:00Z',
      'unreadCount': 1,
      'lastMessage': {
        'messageId': 102,
        'conversationId': 12,
        'senderId': 1,
        'senderName': 'Admin',
        'senderRole': 'Admin',
        'messageType': 'Text',
        'messageText': 'Shop đã nhận yêu cầu.',
        'sentAt': '2026-08-16T01:05:00Z',
      },
      'messages': [
        {
          'messageId': 101,
          'conversationId': 12,
          'senderId': 7,
          'senderName': 'Khách hàng',
          'senderRole': 'Customer',
          'messageType': 'Text',
          'messageText': 'Tôi cần hỗ trợ.',
          'sentAt': '2026-08-16T01:00:00Z',
        },
        {
          'messageId': 102,
          'conversationId': 12,
          'senderId': 1,
          'senderName': 'Admin',
          'senderRole': 'Admin',
          'messageType': 'Text',
          'messageText': 'Shop đã nhận yêu cầu.',
          'sentAt': '2026-08-16T01:05:00Z',
        },
      ],
    });

    expect(conversation.conversationId, 12);
    expect(conversation.status, 'WaitingCustomer');
    expect(conversation.unreadCount, 1);
    expect(conversation.messages, hasLength(2));
    expect(conversation.messages.first.senderRole, 'Customer');
    expect(conversation.lastMessage?.messageText, 'Shop đã nhận yêu cầu.');
  });
}
