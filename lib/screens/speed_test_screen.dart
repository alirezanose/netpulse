import 'dart:async';
import 'package:flutter/material.dart';
import '../models/test_result.dart';
import '../services/network_service.dart';
import '../services/speed_test_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/live_bandwidth_chart.dart';
import '../widgets/speedometer_gauge.dart';
import '../widgets/stat_badge.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final NetworkService _networkService = NetworkService();
  final SpeedTestService _speedTestService = SpeedTestService();
  final StorageService _storageService = StorageService();

  NetworkInfoData _networkInfo = NetworkInfoData.initial();
  SpeedTestProgress _progress = SpeedTestProgress.initial();
  StreamSubscription? _testSubscription;
  bool _isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  @override
  void dispose() {
    _testSubscription?.cancel();
    _speedTestService.cancel();
    super.dispose();
  }

  Future<void> _loadNetworkInfo() async {
    setState(() => _isLoadingInfo = true);
    final info = await _networkService.getFullNetworkInfo();
    if (mounted) {
      setState(() {
        _networkInfo = info;
        _isLoadingInfo = false;
      });
    }
  }

  Future<void> _startTest() async {
    if (_progress.state == SpeedTestState.measuringPing ||
        _progress.state == SpeedTestState.downloading) {
      _speedTestService.cancel();
      _testSubscription?.cancel();
      setState(() {
        _progress = SpeedTestProgress.initial();
      });
      return;
    }

    // Step 1: Measuring Ping & Jitter
    setState(() {
      _progress = SpeedTestProgress(
        state: SpeedTestState.measuringPing,
        currentSpeedMbps: 0.0,
        averageSpeedMbps: 0.0,
        progress: 0.05,
        bytesReceived: 0,
        pingMs: 0,
        jitterMs: 0,
        speedHistory: [],
      );
    });

    final pingJitter = await _networkService.measurePingAndJitter(samples: 3);
    final ping = pingJitter['ping'] ?? 15;
    final jitter = pingJitter['jitter'] ?? 2;

    if (!mounted) return;

    // Step 2: Bandwidth Download Test
    _testSubscription = _speedTestService
        .runDownloadTest(pingMs: ping, jitterMs: jitter)
        .listen((update) {
      if (mounted) {
        setState(() {
          _progress = update;
        });

        // Step 3: Save to Storage when completed
        if (update.state == SpeedTestState.completed) {
          final result = TestResult(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            downloadSpeedMbps: update.averageSpeedMbps,
            pingMs: ping,
            jitterMs: jitter,
            connectionType: _networkInfo.connectionType,
            ipAddress: _networkInfo.publicIp,
            isp: _networkInfo.isp,
          );
          _storageService.saveResult(result);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.primary,
              content: Text(
                'Test Complete: ${update.averageSpeedMbps.toStringAsFixed(1)} Mbps',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    });
  }

  String _getStatusText() {
    switch (_progress.state) {
      case SpeedTestState.measuringPing:
        return 'Pinging...';
      case SpeedTestState.downloading:
        return 'Testing...';
      case SpeedTestState.completed:
        return 'Done';
      case SpeedTestState.cancelled:
        return 'Stopped';
      case SpeedTestState.error:
        return 'Failed';
      case SpeedTestState.idle:
        return 'Ready';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTesting = _progress.state == SpeedTestState.measuringPing ||
        _progress.state == SpeedTestState.downloading;

    final bytesInMB = (_progress.bytesReceived / (1024 * 1024)).toStringAsFixed(1);
    final isOffline = _networkInfo.connectionType == 'Disconnected';

    return Scaffold(
      appBar: AppBar(
        title: const Text('NETPULSE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh Network Info',
            onPressed: isTesting ? null : _loadNetworkInfo,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNetworkInfo,
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Minimalist Network Info Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      _networkInfo.connectionType == 'Wi-Fi'
                          ? Icons.wifi
                          : _networkInfo.connectionType == 'Cellular Data'
                              ? Icons.signal_cellular_alt
                              : Icons.lan_outlined,
                      color: AppTheme.textPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _networkInfo.connectionType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Text(
                            _isLoadingInfo ? 'Identifying...' : _networkInfo.isp,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOffline ? AppTheme.danger : AppTheme.success,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOffline ? 'OFFLINE' : 'ONLINE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isOffline ? AppTheme.danger : AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Speedometer Gauge
              SpeedometerGauge(
                speedMbps: _progress.state == SpeedTestState.completed
                    ? _progress.averageSpeedMbps
                    : _progress.currentSpeedMbps,
                statusText: _getStatusText(),
              ),

              const SizedBox(height: 14),

              // Metrics Row: Ping, Jitter
              Row(
                children: [
                  Expanded(
                    child: StatBadge(
                      icon: Icons.timer_outlined,
                      label: 'Ping',
                      value: _progress.pingMs == 0 ? '--' : '${_progress.pingMs}',
                      unit: 'ms',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatBadge(
                      icon: Icons.waves,
                      label: 'Jitter',
                      value: _progress.jitterMs == 0 ? '--' : '${_progress.jitterMs}',
                      unit: 'ms',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Metrics Row: Download, Data Usage
              Row(
                children: [
                  Expanded(
                    child: StatBadge(
                      icon: Icons.south_rounded,
                      label: 'Download',
                      value: _progress.averageSpeedMbps == 0.0
                          ? '--'
                          : _progress.averageSpeedMbps.toStringAsFixed(1),
                      unit: 'Mbps',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatBadge(
                      icon: Icons.data_usage_outlined,
                      label: 'Data Usage',
                      value: _progress.bytesReceived == 0 ? '--' : bytesInMB,
                      unit: 'MB',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Live Bandwidth Line Chart
              LiveBandwidthChart(
                speedHistory: _progress.speedHistory,
                height: 110,
              ),

              const SizedBox(height: 22),

              // Action Button (Start / Stop)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTesting ? AppTheme.surfaceMuted : AppTheme.primary,
                    foregroundColor: isTesting ? AppTheme.danger : Colors.white,
                    side: isTesting ? const BorderSide(color: AppTheme.border) : BorderSide.none,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isTesting) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.danger,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('CANCEL'),
                      ] else ...[
                        const Icon(Icons.arrow_forward, size: 18),
                        const SizedBox(width: 8),
                        const Text('START TEST'),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
