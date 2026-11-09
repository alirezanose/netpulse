import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/network_service.dart';
import '../theme/app_theme.dart';

class NetworkInfoScreen extends StatefulWidget {
  const NetworkInfoScreen({super.key});

  @override
  State<NetworkInfoScreen> createState() => _NetworkInfoScreenState();
}

class _NetworkInfoScreenState extends State<NetworkInfoScreen> {
  final NetworkService _networkService = NetworkService();
  NetworkInfoData _info = NetworkInfoData.initial();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    setState(() => _isLoading = true);
    final data = await _networkService.getFullNetworkInfo();
    if (mounted) {
      setState(() {
        _info = data;
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        content: Text(
          '$label copied to clipboard',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NETWORK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _fetchInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
            )
          : RefreshIndicator(
              onRefresh: _fetchInfo,
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Minimalist Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppTheme.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _info.connectionType == 'Wi-Fi'
                                ? Icons.wifi
                                : _info.connectionType == 'Cellular Data'
                                    ? Icons.cell_tower
                                    : Icons.lan_outlined,
                            size: 24,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _info.connectionType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _info.isp,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'ROUTING & IP DETAILS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Public IP Tile
                  _buildDetailTile(
                    icon: Icons.public,
                    title: 'Public IP',
                    value: _info.publicIp,
                    subtitle: 'External internet address',
                    onCopy: () => _copyToClipboard(_info.publicIp, 'Public IP'),
                  ),
                  const SizedBox(height: 8),

                  // Local IP Tile
                  _buildDetailTile(
                    icon: Icons.router_outlined,
                    title: 'Gateway / Local IP',
                    value: _info.localIp,
                    subtitle: 'Private subnet address',
                    onCopy: () => _copyToClipboard(_info.localIp, 'Local IP'),
                  ),
                  const SizedBox(height: 8),

                  // Location Tile
                  _buildDetailTile(
                    icon: Icons.place_outlined,
                    title: 'Location',
                    value: _info.location,
                    subtitle: 'Carrier estimated region',
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'ACTIVE INTERFACES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_info.interfaces.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Center(
                        child: Text(
                          'No active network interfaces detected.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    ..._info.interfaces.map(
                      (iface) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.code, color: AppTheme.textMuted, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                iface,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 16, color: AppTheme.textMuted),
              tooltip: 'Copy',
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}
