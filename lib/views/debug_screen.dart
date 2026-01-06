import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../core/colors.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.getEnvironmentInfo();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Configuration'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyConfigToClipboard(context, config),
            tooltip: 'Copy configuration',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Environment Configuration',
            Icons.settings,
            config.entries.map((entry) => _buildConfigItem(entry.key, entry.value)).toList(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Network Status',
            Icons.network_check,
            [
              _buildNetworkTest(),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Platform Information',
            Icons.info,
            [
              _buildConfigItem('Platform', Theme.of(context).platform.name),
              _buildConfigItem('Is Emulator', AppConfig.isEmulator.toString()),
              _buildConfigItem('Debug Mode', AppConfig.isDebugMode.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.toString(),
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTest() {
    return FutureBuilder<bool>(
      future: _testNetworkConnection(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              SizedBox(width: 120, child: Text('API Status')),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Testing connection...'),
            ],
          );
        }

        final isConnected = snapshot.data ?? false;
        return Row(
          children: [
            const SizedBox(width: 120, child: Text('API Status')),
            Icon(
              isConnected ? Icons.check_circle : Icons.error,
              color: isConnected ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              isConnected ? 'Connected' : 'Connection failed',
              style: TextStyle(
                color: isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _testNetworkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl.replaceAll('/api/v1', '')}/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _copyConfigToClipboard(BuildContext context, Map<String, dynamic> config) {
    final configText = config.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
    
    Clipboard.setData(ClipboardData(text: configText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}