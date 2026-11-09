import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/test_result.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  List<TestResult> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await _storageService.getHistory();
    if (mounted) {
      setState(() {
        _history = List.from(data);
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    await _storageService.deleteResult(id);
    _loadHistory();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear History?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'All saved speed test records will be permanently removed.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearHistory();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxSpeed = 0.0;
    double avgSpeed = 0.0;
    int minPing = 0;

    if (_history.isNotEmpty) {
      maxSpeed = _history
          .map((e) => e.downloadSpeedMbps)
          .reduce((a, b) => a > b ? a : b);
      avgSpeed = _history
              .map((e) => e.downloadSpeedMbps)
              .reduce((a, b) => a + b) /
          _history.length;
      minPing = _history.map((e) => e.pingMs).reduce((a, b) => a < b ? a : b);
    }

    final dateFormat = DateFormat('dd MMM, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORY'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.textSecondary),
              tooltip: 'Clear History',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
            )
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: AppTheme.borderDark),
                      const SizedBox(height: 12),
                      const Text(
                        'No test records yet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Completed tests will appear here',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // Analytics Overview Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem('BEST', '${maxSpeed.toStringAsFixed(1)} M'),
                            _buildSummaryItem('AVG', '${avgSpeed.toStringAsFixed(1)} M'),
                            _buildSummaryItem('PING', '$minPing ms'),
                            _buildSummaryItem('SESSIONS', '${_history.length}'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'RECORDED TESTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // History List
                      ..._history.map((item) {
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline, color: AppTheme.danger),
                          ),
                          onDismissed: (_) => _deleteItem(item.id),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          item.connectionType == 'Wi-Fi'
                                              ? Icons.wifi
                                              : Icons.cell_tower,
                                          size: 14,
                                          color: AppTheme.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.connectionType.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.0,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      dateFormat.format(item.timestamp),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          item.downloadSpeedMbps.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Mbps',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${item.pingMs} ms',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('•', style: TextStyle(color: AppTheme.borderDark)),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${item.jitterMs} ms jitter',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${item.isp} (${item.ipAddress})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
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
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
