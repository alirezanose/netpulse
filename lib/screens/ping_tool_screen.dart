import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../theme/app_theme.dart';

class PingToolScreen extends StatefulWidget {
  const PingToolScreen({super.key});

  @override
  State<PingToolScreen> createState() => _PingToolScreenState();
}

class _PingEntry {
  final int sequence;
  final int latencyMs;
  final bool isSuccess;
  final DateTime time;

  _PingEntry({
    required this.sequence,
    required this.latencyMs,
    required this.isSuccess,
    required this.time,
  });
}

class _PingToolScreenState extends State<PingToolScreen> {
  final TextEditingController _hostController =
      TextEditingController(text: '1.1.1.1');
  final NetworkService _networkService = NetworkService();

  final List<_PingEntry> _logs = [];
  bool _isPinging = false;
  final int _targetCount = 5;

  final List<String> _quickHosts = [
    '1.1.1.1',
    '8.8.8.8',
    'google.com',
    'github.com',
  ];

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _startPing() async {
    final host = _hostController.text.trim();
    if (host.isEmpty) return;

    setState(() {
      _isPinging = true;
      _logs.clear();
    });

    for (int i = 1; i <= _targetCount; i++) {
      if (!_isPinging || !mounted) break;

      final res = await _networkService.pingHost(host);
      if (!mounted) break;

      setState(() {
        _logs.insert(
          0,
          _PingEntry(
            sequence: i,
            latencyMs: res.latencyMs,
            isSuccess: res.isSuccess,
            time: DateTime.now(),
          ),
        );
      });

      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) {
      setState(() {
        _isPinging = false;
      });
    }
  }

  void _stopPing() {
    setState(() {
      _isPinging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final successfulLogs = _logs.where((e) => e.isSuccess).toList();
    final int minPing = successfulLogs.isEmpty
        ? 0
        : successfulLogs.map((e) => e.latencyMs).reduce((a, b) => a < b ? a : b);
    final int maxPing = successfulLogs.isEmpty
        ? 0
        : successfulLogs.map((e) => e.latencyMs).reduce((a, b) => a > b ? a : b);
    final int avgPing = successfulLogs.isEmpty
        ? 0
        : (successfulLogs.map((e) => e.latencyMs).reduce((a, b) => a + b) /
                successfulLogs.length)
            .round();
    final double lossRate = _logs.isEmpty
        ? 0.0
        : ((_logs.length - successfulLogs.length) / _logs.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DIAGNOSTICS'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Host Input Form
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hostController,
                    enabled: !_isPinging,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Host or IP address',
                      hintText: 'e.g. 1.1.1.1',
                      prefixIcon: Icon(Icons.search, size: 20, color: AppTheme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isPinging ? _stopPing : _startPing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPinging ? AppTheme.surfaceMuted : AppTheme.primary,
                    foregroundColor: _isPinging ? AppTheme.danger : Colors.white,
                    side: _isPinging ? const BorderSide(color: AppTheme.border) : BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: Text(_isPinging ? 'STOP' : 'TEST'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Quick Selection Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickHosts.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(h),
                      backgroundColor: AppTheme.surface,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onPressed: _isPinging
                          ? null
                          : () {
                              _hostController.text = h;
                              setState(() {});
                            },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Statistics Summary Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('MIN', '$minPing', 'ms', AppTheme.textPrimary),
                  _buildStatItem('AVG', '$avgPing', 'ms', AppTheme.textPrimary),
                  _buildStatItem('MAX', '$maxPing', 'ms', AppTheme.textPrimary),
                  _buildStatItem('LOSS', '${lossRate.toStringAsFixed(0)}%', '',
                      lossRate > 0 ? AppTheme.danger : AppTheme.success),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TRANSMISSION LOG',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppTheme.textMuted,
                  ),
                ),
                if (_logs.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _logs.clear()),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Ping Log List
            Expanded(
              child: _logs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.network_ping, size: 40, color: AppTheme.borderDark),
                          const SizedBox(height: 8),
                          const Text(
                            'Select a host to test round-trip latency',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final entry = _logs[index];
                        final Color badgeBg = !entry.isSuccess
                            ? AppTheme.danger.withValues(alpha: 0.1)
                            : AppTheme.surfaceMuted;
                        final Color textColor = !entry.isSuccess
                            ? AppTheme.danger
                            : AppTheme.textPrimary;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '#${entry.sequence.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.isSuccess
                                      ? 'Reply from ${_hostController.text}'
                                      : 'Packet dropped',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: entry.isSuccess
                                        ? AppTheme.textPrimary
                                        : AppTheme.danger,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  entry.isSuccess ? '${entry.latencyMs} ms' : 'LOST',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(fontSize: 10, color: color),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
