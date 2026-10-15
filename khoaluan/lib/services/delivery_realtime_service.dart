import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import 'api_service.dart';
import 'auth_service.dart';

class DeliveryRealtimeEvent {
  const DeliveryRealtimeEvent({
    required this.orderId,
    required this.orderCode,
    required this.orderStatus,
    required this.message,
  });

  final int orderId;
  final String orderCode;
  final String orderStatus;
  final String message;

  factory DeliveryRealtimeEvent.fromJson(Map<String, dynamic> json) {
    final rawOrderId = json['orderId'] ?? json['OrderId'];
    return DeliveryRealtimeEvent(
      orderId: rawOrderId is num
          ? rawOrderId.toInt()
          : int.tryParse(rawOrderId?.toString() ?? '') ?? 0,
      orderCode: (json['orderCode'] ?? json['OrderCode'] ?? '').toString(),
      orderStatus: (json['orderStatus'] ?? json['OrderStatus'] ?? '')
          .toString(),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
    );
  }
}

class DeliveryRealtimeService {
  DeliveryRealtimeService._();

  static final DeliveryRealtimeService instance = DeliveryRealtimeService._();

  HubConnection? _connection;
  Future<void>? _connecting;
  bool _initialized = false;
  String? _connectionToken;
  String? _lastEventKey;
  DateTime? _lastEventAt;
  final _events = StreamController<DeliveryRealtimeEvent>.broadcast();

  Stream<DeliveryRealtimeEvent> get events => _events.stream;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    AuthService.currentUser.addListener(_handleAuthenticationChanged);
    unawaited(_synchronizeAuthentication());
  }

  void _handleAuthenticationChanged() {
    unawaited(_synchronizeAuthentication());
  }

  Future<void> _synchronizeAuthentication() async {
    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      await disconnect();
      return;
    }
    if (_connectionToken != null && _connectionToken != token) {
      await disconnect();
    }
    await connect();
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

  Future<void> _connectInternal() async {
    final token = AuthService.token;
    if (token == null || token.isEmpty) return;
    if (_connection?.state == HubConnectionState.Connected) return;

    final connection = HubConnectionBuilder()
        .withUrl(
          '${ApiService.apiBaseUrl}/hubs/delivery',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => AuthService.token ?? '',
          ),
        )
        .withAutomaticReconnect(retryDelays: <int>[0, 2000, 5000, 10000, 30000])
        .build();
    connection.on('DeliveryUpdated', (arguments) {
      if (arguments == null || arguments.isEmpty || arguments.first is! Map) {
        return;
      }
      final event = DeliveryRealtimeEvent.fromJson(
        Map<String, dynamic>.from(arguments.first! as Map),
      );
      final now = DateTime.now();
      final eventKey =
          '${event.orderId}|${event.orderStatus}|${event.message.trim()}';
      if (_lastEventKey == eventKey &&
          _lastEventAt != null &&
          now.difference(_lastEventAt!) < const Duration(seconds: 5)) {
        return;
      }
      _lastEventKey = eventKey;
      _lastEventAt = now;
      _events.add(event);
    });
    _connection = connection;
    _connectionToken = token;
    try {
      await connection.start();
    } catch (_) {
      // Automatic reconnect handles transient transport failures.
    }
  }

  Future<void> disconnect() async {
    final connection = _connection;
    _connection = null;
    _connectionToken = null;
    if (connection != null) {
      try {
        await connection.stop();
      } catch (_) {}
    }
  }
}
