import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum SpeedTestState {
  idle,
  measuringPing,
  downloading,
  completed,
  cancelled,
  error,
}

class SpeedTestProgress {
  final SpeedTestState state;
  final double currentSpeedMbps;
  final double averageSpeedMbps;
  final double progress; // 0.0 to 1.0
  final int bytesReceived;
  final int pingMs;
  final int jitterMs;
  final List<double> speedHistory;

  SpeedTestProgress({
    required this.state,
    required this.currentSpeedMbps,
    required this.averageSpeedMbps,
    required this.progress,
    required this.bytesReceived,
    required this.pingMs,
    required this.jitterMs,
    required this.speedHistory,
  });

  factory SpeedTestProgress.initial() {
    return SpeedTestProgress(
      state: SpeedTestState.idle,
      currentSpeedMbps: 0.0,
      averageSpeedMbps: 0.0,
      progress: 0.0,
      bytesReceived: 0,
      pingMs: 0,
      jitterMs: 0,
      speedHistory: [],
    );
  }
}

class SpeedTestService {
  final List<String> _downloadUrls = [
    'https://speed.cloudflare.com/__down?bytes=15000000', // 15 MB Cloudflare CDN
    'https://speed.cloudflare.com/__down?bytes=10000000', // 10 MB Cloudflare CDN
    'https://proof.ovh.net/files/10Mb.dat', // 10 MB OVH CDN
  ];

  http.Client? _client;
  bool _isCancelled = false;

  void cancel() {
    _isCancelled = true;
    _client?.close();
    _client = null;
  }

  Stream<SpeedTestProgress> runDownloadTest({
    required int pingMs,
    required int jitterMs,
  }) async* {
    _isCancelled = false;
    _client = http.Client();

    final List<double> history = [];
    int totalBytes = 0;
    final stopwatch = Stopwatch()..start();

    // Initial state: Downloading started
    yield SpeedTestProgress(
      state: SpeedTestState.downloading,
      currentSpeedMbps: 0.0,
      averageSpeedMbps: 0.0,
      progress: 0.0,
      bytesReceived: 0,
      pingMs: pingMs,
      jitterMs: jitterMs,
      speedHistory: history,
    );

    int urlIndex = 0;
    bool downloadSuccess = false;

    while (urlIndex < _downloadUrls.length && !downloadSuccess && !_isCancelled) {
      final url = _downloadUrls[urlIndex];
      try {
        final request = http.Request('GET', Uri.parse(url));
        request.headers['Cache-Control'] = 'no-cache';
        final response = await _client!.send(request);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final contentLength = response.contentLength ?? 15000000;
          int lastIntervalBytes = 0;
          int lastIntervalMs = 0;

          await for (var chunk in response.stream) {
            if (_isCancelled) break;

            totalBytes += chunk.length;
            lastIntervalBytes += chunk.length;

            final currentMs = stopwatch.elapsedMilliseconds;
            final elapsedWindowMs = currentMs - lastIntervalMs;

            // Update calculation every 150ms for smooth UI gauge movement
            if (elapsedWindowMs >= 150 && currentMs > 0) {
              // Instantaneous speed: (bits / seconds) / 1,000,000 = Mbps
              final windowSpeedMbps = (lastIntervalBytes * 8.0) / (elapsedWindowMs * 1000.0);
              
              // Overall average speed
              final avgSpeedMbps = (totalBytes * 8.0) / (currentMs * 1000.0);
              
              final progress = (totalBytes / contentLength).clamp(0.0, 1.0);

              history.add(windowSpeedMbps);
              if (history.length > 50) history.removeAt(0);

              yield SpeedTestProgress(
                state: SpeedTestState.downloading,
                currentSpeedMbps: windowSpeedMbps,
                averageSpeedMbps: avgSpeedMbps,
                progress: progress,
                bytesReceived: totalBytes,
                pingMs: pingMs,
                jitterMs: jitterMs,
                speedHistory: List.unmodifiable(history),
              );

              lastIntervalBytes = 0;
              lastIntervalMs = currentMs;
            }
          }

          downloadSuccess = true;
        } else {
          urlIndex++;
        }
      } catch (e) {
        debugPrint('Download test failed on url $url: $e');
        urlIndex++;
      }
    }

    stopwatch.stop();

    if (_isCancelled) {
      yield SpeedTestProgress(
        state: SpeedTestState.cancelled,
        currentSpeedMbps: 0.0,
        averageSpeedMbps: 0.0,
        progress: 0.0,
        bytesReceived: totalBytes,
        pingMs: pingMs,
        jitterMs: jitterMs,
        speedHistory: history,
      );
      return;
    }

    if (!downloadSuccess && totalBytes == 0) {
      yield SpeedTestProgress(
        state: SpeedTestState.error,
        currentSpeedMbps: 0.0,
        averageSpeedMbps: 0.0,
        progress: 0.0,
        bytesReceived: 0,
        pingMs: pingMs,
        jitterMs: jitterMs,
        speedHistory: history,
      );
      return;
    }

    // Final calculations
    final finalAvgSpeed = stopwatch.elapsedMilliseconds > 0
        ? (totalBytes * 8.0) / (stopwatch.elapsedMilliseconds * 1000.0)
        : 0.0;

    yield SpeedTestProgress(
      state: SpeedTestState.completed,
      currentSpeedMbps: finalAvgSpeed,
      averageSpeedMbps: finalAvgSpeed,
      progress: 1.0,
      bytesReceived: totalBytes,
      pingMs: pingMs,
      jitterMs: jitterMs,
      speedHistory: List.unmodifiable(history),
    );
  }
}
