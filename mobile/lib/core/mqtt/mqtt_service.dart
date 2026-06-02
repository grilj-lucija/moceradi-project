import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class MqttService {
  MqttService({required this.host, required this.port});

  final String host;
  final int port;

  static const _deviceIdKey = 'mqtt_device_id';
  static const _heartbeatInterval = Duration(seconds: 10);

  MqttServerClient? _client;
  Timer? _heartbeat;
  String? _userId;
  String? _deviceId;
  bool _connected = false;

  bool get isConnected => _connected;
  String? get deviceId => _deviceId;

  String _telemetryTopic(String userId, String deviceId) =>
      'health/telemetry/$userId/$deviceId';

  String _presenceTopic(String userId, String deviceId) =>
      'health/presence/$userId/$deviceId';

  Future<String> _ensureDeviceId() async {
    final cached = _deviceId;
    if (cached != null) return cached;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
    }
    _deviceId = id;
    return id;
  }

  Future<void> connect(String userId) async {
    if (host.isEmpty) return;
    if (_connected && _userId == userId) return;
    await disconnect();

    final deviceId = await _ensureDeviceId();
    _userId = userId;

    final client = MqttServerClient.withPort(host, deviceId, port)
      ..keepAlivePeriod = 30
      ..autoReconnect = true
      ..logging(on: false)
      ..setProtocolV311();

    final willPayload = jsonEncode({
      'userId': userId,
      'deviceId': deviceId,
      'status': 'offline',
    });

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(deviceId)
        .withWillTopic(_presenceTopic(userId, deviceId))
        .withWillMessage(willPayload)
        .withWillQos(MqttQos.atLeastOnce)
        .withWillRetain()
        .startClean();

    _client = client;

    try {
      await client.connect();
    } on Exception {
      client.disconnect();
      _client = null;
      _connected = false;
      return;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      _client = null;
      _connected = false;
      return;
    }

    _connected = true;
    _publishPresence('online');
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(
      _heartbeatInterval,
      (_) => _publishPresence('online'),
    );
  }

  void publishTelemetry(Map<String, dynamic> data) {
    final client = _client;
    final userId = _userId;
    final deviceId = _deviceId;
    if (client == null || userId == null || deviceId == null) return;
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final payload = jsonEncode({
      'userId': userId,
      'deviceId': deviceId,
      ...data,
    });
    final builder = MqttClientPayloadBuilder()..addString(payload);
    client.publishMessage(
      _telemetryTopic(userId, deviceId),
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }

  void _publishPresence(String status) {
    final client = _client;
    final userId = _userId;
    final deviceId = _deviceId;
    if (client == null || userId == null || deviceId == null) return;
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final payload = jsonEncode({
      'userId': userId,
      'deviceId': deviceId,
      'status': status,
      'ts': DateTime.now().toUtc().toIso8601String(),
    });
    final builder = MqttClientPayloadBuilder()..addString(payload);
    client.publishMessage(
      _presenceTopic(userId, deviceId),
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );
  }

  Future<void> disconnect() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    final client = _client;
    if (client != null) {
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        _publishPresence('offline');
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      client.disconnect();
    }
    _client = null;
    _connected = false;
  }
}
