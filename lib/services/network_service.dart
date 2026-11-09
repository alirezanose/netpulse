import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkInfoData {
  final String connectionType;
  final String localIp;
  final String publicIp;
  final String isp;
  final String location;
  final List<String> interfaces;

  NetworkInfoData({
    required this.connectionType,
    required this.localIp,
    required this.publicIp,
    required this.isp,
    required this.location,
    required this.interfaces,
  });

  factory NetworkInfoData.initial() {
    return NetworkInfoData(
      connectionType: 'Checking...',
      localIp: '127.0.0.1',
      publicIp: 'Fetching...',
      isp: 'Unknown ISP',
      location: 'Unknown',
      interfaces: [],
    );
  }
}

class PingResult {
  final String host;
  final int latencyMs;
  final bool isSuccess;
  final String? error;

  PingResult({
    required this.host,
    required this.latencyMs,
    required this.isSuccess,
    this.error,
  });
}

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  String mapConnectivity(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'Disconnected';
    }
    if (results.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi';
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return 'Cellular Data';
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    }
    if (results.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    }
    return 'Connected';
  }

  Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return mapConnectivity(results);
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<List<String>> getLocalInterfaces() async {
    final List<String> details = [];
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          details.add('${interface.name}: ${addr.address}');
        }
      }
    } catch (e) {
      debugPrint('Error getting interfaces: $e');
    }
    return details;
  }

  Future<String> getPrimaryLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
    } catch (e) {
      debugPrint('Error getting primary local IP: $e');
    }
    return '127.0.0.1';
  }

  Future<Map<String, String>> fetchPublicIpInfo() async {
    try {
      // Free IP API (HTTP) with fast response and rich metadata
      final response = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return {
            'publicIp': data['query'] ?? 'Unavailable',
            'isp': data['isp'] ?? data['org'] ?? 'Unknown ISP',
            'location': '${data['city']}, ${data['country']}',
          };
        }
      }
    } catch (_) {
      // Fallback to simple ipify
      try {
        final fallbackRes = await http
            .get(Uri.parse('https://api.ipify.org?format=json'))
            .timeout(const Duration(seconds: 4));
        if (fallbackRes.statusCode == 200) {
          final data = json.decode(fallbackRes.body);
          return {
            'publicIp': data['ip'] ?? 'Unavailable',
            'isp': 'Internet Service Provider',
            'location': 'Online',
          };
        }
      } catch (_) {}
    }

    return {
      'publicIp': 'Unavailable (Offline)',
      'isp': 'No ISP Detected',
      'location': 'Local Network',
    };
  }

  Future<NetworkInfoData> getFullNetworkInfo() async {
    final connectionType = await getConnectionType();
    final localIp = await getPrimaryLocalIp();
    final interfaces = await getLocalInterfaces();
    final publicInfo = await fetchPublicIpInfo();

    return NetworkInfoData(
      connectionType: connectionType,
      localIp: localIp,
      publicIp: publicInfo['publicIp'] ?? 'Unavailable',
      isp: publicInfo['isp'] ?? 'Unknown ISP',
      location: publicInfo['location'] ?? 'Unknown',
      interfaces: interfaces,
    );
  }

  Future<PingResult> pingHost(String host, {Duration timeout = const Duration(seconds: 3)}) async {
    final cleanHost = host.trim().replaceAll(RegExp(r'https?:\/\/'), '').split('/').first;

    // First attempt: native ping CLI on Linux/Android
    try {
      final result = await Process.run(
        'ping',
        ['-c', '1', '-W', '2', cleanHost],
      ).timeout(timeout);

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        // Regex to parse: time=24.5 ms
        final match = RegExp(r'time[=<]([\d\.]+)\s*ms').firstMatch(output);
        if (match != null) {
          final ms = double.tryParse(match.group(1) ?? '0')?.round() ?? 10;
          return PingResult(host: cleanHost, latencyMs: ms, isSuccess: true);
        }
      }
    } catch (_) {
      // If native ping fails or permission restricted, fall back to TCP socket ping
    }

    // Socket ping fallback (port 80 or 443)
    final stopwatch = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        cleanHost,
        cleanHost.contains('.') ? 80 : 53,
        timeout: timeout,
      );
      stopwatch.stop();
      await socket.close();
      return PingResult(
        host: cleanHost,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: true,
      );
    } catch (e) {
      stopwatch.stop();
      return PingResult(
        host: cleanHost,
        latencyMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, int>> measurePingAndJitter({String target = '1.1.1.1', int samples = 4}) async {
    final List<int> latencies = [];

    for (int i = 0; i < samples; i++) {
      final result = await pingHost(target, timeout: const Duration(seconds: 2));
      if (result.isSuccess) {
        latencies.add(result.latencyMs);
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }

    if (latencies.isEmpty) {
      return {'ping': 999, 'jitter': 0};
    }

    final avgPing = (latencies.reduce((a, b) => a + b) / latencies.length).round();

    // Jitter is the average absolute difference between consecutive latency measurements
    int jitter = 0;
    if (latencies.length > 1) {
      int sumDiff = 0;
      for (int i = 0; i < latencies.length - 1; i++) {
        sumDiff += (latencies[i + 1] - latencies[i]).abs();
      }
      jitter = (sumDiff / (latencies.length - 1)).round();
    }

    return {'ping': avgPing, 'jitter': jitter};
  }
}
