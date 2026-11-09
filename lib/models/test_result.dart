import 'dart:convert';

class TestResult {
  final String id;
  final DateTime timestamp;
  final double downloadSpeedMbps;
  final int pingMs;
  final int jitterMs;
  final String connectionType;
  final String ipAddress;
  final String isp;

  TestResult({
    required this.id,
    required this.timestamp,
    required this.downloadSpeedMbps,
    required this.pingMs,
    required this.jitterMs,
    required this.connectionType,
    required this.ipAddress,
    required this.isp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'downloadSpeedMbps': downloadSpeedMbps,
      'pingMs': pingMs,
      'jitterMs': jitterMs,
      'connectionType': connectionType,
      'ipAddress': ipAddress,
      'isp': isp,
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      downloadSpeedMbps: (map['downloadSpeedMbps'] as num?)?.toDouble() ?? 0.0,
      pingMs: (map['pingMs'] as num?)?.toInt() ?? 0,
      jitterMs: (map['jitterMs'] as num?)?.toInt() ?? 0,
      connectionType: map['connectionType'] ?? 'Unknown',
      ipAddress: map['ipAddress'] ?? '127.0.0.1',
      isp: map['isp'] ?? 'Unknown ISP',
    );
  }

  String toJson() => json.encode(toMap());

  factory TestResult.fromJson(String source) =>
      TestResult.fromMap(json.decode(source));
}
