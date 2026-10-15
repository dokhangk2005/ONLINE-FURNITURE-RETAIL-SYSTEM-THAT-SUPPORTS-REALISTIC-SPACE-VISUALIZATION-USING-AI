import 'package:flutter_test/flutter_test.dart';
import 'package:khoaluan/services/support_realtime_service.dart';

void main() {
  group('SupportRealtimeEventDecoder', () {
    test('đọc sự kiện tin nhắn SignalR', () {
      final message = SupportRealtimeEventDecoder.message([
        {
          'messageId': 81,
          'conversationId': 12,
          'senderId': 3,
          'senderName': 'Admin',
          'senderRole': 'Admin',
          'messageType': 'Text',
          'messageText': 'Xin chào bạn',
          'sentAt': '2026-08-16T08:00:00Z',
        },
      ]);

      expect(message, isNotNull);
      expect(message!.messageId, 81);
      expect(message.conversationId, 12);
      expect(message.messageText, 'Xin chào bạn');
    });

    test('đọc sự kiện đã xem SignalR', () {
      final receipt = SupportRealtimeEventDecoder.readReceipt([
        {
          'ConversationId': 12,
          'ReaderRole': 'Customer',
          'ReadAt': '2026-08-16T08:05:00Z',
        },
      ]);

      expect(receipt, isNotNull);
      expect(receipt!.conversationId, 12);
      expect(receipt.readerRole, 'Customer');
      expect(receipt.readAt.toUtc().hour, 8);
    });

    test('đọc sự kiện đang nhập SignalR', () {
      final typing = SupportRealtimeEventDecoder.typing([
        {
          'ConversationId': 12,
          'SenderId': 3,
          'SenderName': 'Admin',
          'SenderRole': 'Admin',
          'IsTyping': true,
        },
      ]);

      expect(typing, isNotNull);
      expect(typing!.conversationId, 12);
      expect(typing.senderId, 3);
      expect(typing.senderRole, 'Admin');
      expect(typing.isTyping, isTrue);
    });

    test('bỏ qua sự kiện SignalR sai định dạng', () {
      expect(SupportRealtimeEventDecoder.message(null), isNull);
      expect(
        SupportRealtimeEventDecoder.conversation(const ['invalid']),
        isNull,
      );
      expect(SupportRealtimeEventDecoder.readReceipt(const []), isNull);
      expect(SupportRealtimeEventDecoder.typing(const ['invalid']), isNull);
    });
  });
}
