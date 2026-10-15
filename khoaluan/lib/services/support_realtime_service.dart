import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../model/support_conversation.dart';
import 'api_service.dart';
import 'auth_service.dart';

enum SupportRealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class SupportRealtimeEventDecoder {
  const SupportRealtimeEventDecoder._();

  static SupportConversationModel? conversation(List<Object?>? arguments) {
    final data = _firstMap(arguments);
    return data == null ? null : SupportConversationModel.fromJson(data);
  }

  static SupportMessageModel? message(List<Object?>? arguments) {
    final data = _firstMap(arguments);
    return data == null ? null : SupportMessageModel.fromJson(data);
  }

  static SupportMessagesReadModel? readReceipt(List<Object?>? arguments) {
    final data = _firstMap(arguments);
    return data == null ? null : SupportMessagesReadModel.fromJson(data);
  }

  static SupportTypingModel? typing(List<Object?>? arguments) {
    final data = _firstMap(arguments);
    return data == null ? null : SupportTypingModel.fromJson(data);
  }

  static Map<String, dynamic>? _firstMap(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty || arguments.first is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(arguments.first! as Map);
  }
}

class SupportRealtimeService {
  SupportRealtimeService._();

  static final SupportRealtimeService instance = SupportRealtimeService._();

  final ValueNotifier<SupportRealtimeConnectionState> connectionState =
      ValueNotifier(SupportRealtimeConnectionState.disconnected);
  final StreamController<SupportConversationModel> _conversationController =
      StreamController.broadcast();
  final StreamController<SupportMessageModel> _messageController =
      StreamController.broadcast();
  final StreamController<SupportMessagesReadModel> _readController =
      StreamController.broadcast();
  final StreamController<SupportTypingModel> _typingController =
      StreamController.broadcast();
  final Set<int> _joinedConversationIds = <int>{};

  HubConnection? _connection;
  Future<void>? _connecting;
  Timer? _retryTimer;
  String? _connectionToken;
  bool _initialized = false;

  Stream<SupportConversationModel> get conversationUpdates =>
      _conversationController.stream;
  Stream<SupportMessageModel> get messages => _messageController.stream;
  Stream<SupportMessagesReadModel> get readReceipts => _readController.stream;
  Stream<SupportTypingModel> get typingUpdates => _typingController.stream;
  bool get isConnected =>
      connectionState.value == SupportRealtimeConnectionState.connected;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    AuthService.currentUser.addListener(_handleAuthenticationChanged);
    unawaited(_synchronizeAuthentication());
  }

  Future<void> connect() {
    final activeConnection = _connecting;
    if (activeConnection != null) return activeConnection;
    final operation = _connectInternal();
    _connecting = operation;
    return operation.whenComplete(() {
      if (identical(_connecting, operation)) _connecting = null;
    });
  }

  Future<void> joinConversation(int conversationId) async {
    if (conversationId <= 0) return;
    _joinedConversationIds.add(conversationId);
    await connect();
    if (!isConnected) return;
    await _connection!.invoke(
      'JoinConversation',
      args: <Object>[conversationId],
    );
  }

  Future<void> leaveConversation(int conversationId) async {
    _joinedConversationIds.remove(conversationId);
    if (!isConnected) return;
    await _connection!.invoke(
      'LeaveConversation',
      args: <Object>[conversationId],
    );
  }

  Future<void> setTyping(int conversationId, bool isTyping) async {
    if (conversationId <= 0 || !isConnected) return;
    try {
      await _connection!.invoke(
        'SetTyping',
        args: <Object>[conversationId, isTyping],
      );
    } catch (_) {
      // Typing is an ephemeral enhancement; message delivery remains intact.
    }
  }

  Future<void> disconnect({bool clearJoinedConversations = true}) async {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (clearJoinedConversations) _joinedConversationIds.clear();
    final connection = _connection;
    _connection = null;
    _connectionToken = null;
    if (connection != null) {
      try {
        await connection.stop();
      } catch (_) {
        // The transport may already be closed.
      }
    }
    connectionState.value = SupportRealtimeConnectionState.disconnected;
  }

  Future<void> _connectInternal() async {
    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      await disconnect();
      return;
    }

    if (_connectionToken != null && _connectionToken != token) {
      await disconnect(clearJoinedConversations: false);
    }
    if (isConnected && _connectionToken == token) return;

    _retryTimer?.cancel();
    _retryTimer = null;
    _connectionToken = token;
    final connection = _connection ??= _buildConnection();
    if (connection.state == HubConnectionState.Connected) {
      connectionState.value = SupportRealtimeConnectionState.connected;
      return;
    }
    if (connection.state == HubConnectionState.Reconnecting) {
      connectionState.value = SupportRealtimeConnectionState.reconnecting;
      return;
    }
    if (connection.state == HubConnectionState.Connecting) {
      connectionState.value = SupportRealtimeConnectionState.connecting;
      return;
    }
    connectionState.value = SupportRealtimeConnectionState.connecting;
    try {
      await connection.start();
      connectionState.value = SupportRealtimeConnectionState.connected;
      await _rejoinConversations();
    } catch (_) {
      connectionState.value = SupportRealtimeConnectionState.disconnected;
      _scheduleRetry();
    }
  }

  HubConnection _buildConnection() {
    final options = HttpConnectionOptions(
      accessTokenFactory: () async => AuthService.token ?? '',
    );
    final connection = HubConnectionBuilder()
        .withUrl('${ApiService.apiBaseUrl}/hubs/support', options: options)
        .withAutomaticReconnect(retryDelays: <int>[0, 2000, 5000, 10000, 30000])
        .build();

    connection.on('ConversationUpdated', (arguments) {
      final event = SupportRealtimeEventDecoder.conversation(arguments);
      if (event != null) _conversationController.add(event);
    });
    connection.on('MessageReceived', (arguments) {
      final event = SupportRealtimeEventDecoder.message(arguments);
      if (event != null) _messageController.add(event);
    });
    connection.on('MessagesRead', (arguments) {
      final event = SupportRealtimeEventDecoder.readReceipt(arguments);
      if (event != null) _readController.add(event);
    });
    connection.on('TypingChanged', (arguments) {
      final event = SupportRealtimeEventDecoder.typing(arguments);
      if (event != null) _typingController.add(event);
    });
    connection.onclose(({error}) {
      connectionState.value = SupportRealtimeConnectionState.disconnected;
      _scheduleRetry();
    });
    connection.onreconnecting(({error}) {
      connectionState.value = SupportRealtimeConnectionState.reconnecting;
    });
    connection.onreconnected(({connectionId}) {
      connectionState.value = SupportRealtimeConnectionState.connected;
      unawaited(_rejoinConversations());
    });
    return connection;
  }

  Future<void> _rejoinConversations() async {
    final connection = _connection;
    if (connection == null || !isConnected) return;
    for (final conversationId in _joinedConversationIds) {
      await connection.invoke(
        'JoinConversation',
        args: <Object>[conversationId],
      );
    }
  }

  void _scheduleRetry() {
    if (AuthService.token == null || _retryTimer != null) return;
    _retryTimer = Timer(const Duration(seconds: 5), () {
      _retryTimer = null;
      unawaited(connect());
    });
  }

  void _handleAuthenticationChanged() {
    unawaited(_synchronizeAuthentication());
  }

  Future<void> _synchronizeAuthentication() async {
    final token = AuthService.token;
    if (token == null) {
      await disconnect();
      return;
    }
    if (_connectionToken != token) {
      await disconnect(clearJoinedConversations: false);
    }
    await connect();
  }
}
