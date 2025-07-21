import 'package:flutter/material.dart';
import './permission_service.dart';
import './sdk.dart';

enum ViewMode { everything, important }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ViewMode _viewMode = ViewMode.everything;

  List<Map<String, String>> displayedSmsList = [];
  List<Map<String, String>> displayedCallLogs = [];

  List<Map<String, String>> transactionalSmsList = [];
  List<DataEvent> bufferedEvents = [];

  final sdk = DataCollectionSDK();
  final loader = PermissionsAndDataLoader();

  bool lastPermissionGranted = false;
  bool hasLoadedOnce = false; // NEW FLAG

  @override
  void initState() {
    super.initState();
    _handleEverythingMode(); // Initial load on app start
  }

  Future<void> _handleEverythingMode() async {
    sdk.initialize();
    final granted = await loader.requestPermissions();

    if (granted) {
      final smsList = await loader.loadSMS();
      final callLogList = await loader.loadCallLogs();

      // Feed to SDK
      for (var sms in smsList) {
        await sdk.trackSms(sms);
      }
      for (var call in callLogList) {
        await sdk.trackCall(call);
      }

      setState(() {
        lastPermissionGranted = true;
        displayedSmsList = smsList;
        displayedCallLogs = callLogList;
        transactionalSmsList = sdk.transactionalSmsList;
        bufferedEvents = sdk.bufferedData;
        hasLoadedOnce = true; // ✅ SET THE FLAG
      });
    } else {
      setState(() {
        lastPermissionGranted = false;
        transactionalSmsList = sdk.transactionalSmsList;
        bufferedEvents = sdk.bufferedData;
      });
    }
  }

  void _handleImportantMode() {
    setState(() {
      _viewMode = ViewMode.important;
      transactionalSmsList = sdk.transactionalSmsList;
      bufferedEvents = sdk.bufferedData;
    });
  }

  void _switchToEverything() {
    setState(() {
      _viewMode = ViewMode.everything;
    });

    // ✅ Only reload if not loaded before
    if (!hasLoadedOnce) {
      _handleEverythingMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('SMS & Call Logs'),
        backgroundColor: Colors.deepPurple,
        actions: [
          TextButton(
            onPressed: _switchToEverything,
            child: Text(
              'Everything',
              style: TextStyle(
                color: _viewMode == ViewMode.everything
                    ? Colors.white
                    : Colors.white70,
                fontWeight:
                    _viewMode == ViewMode.everything ? FontWeight.bold : null,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: _handleImportantMode,
            child: Text(
              'Important',
              style: TextStyle(
                color: _viewMode == ViewMode.important
                    ? Colors.white
                    : Colors.white70,
                fontWeight:
                    _viewMode == ViewMode.important ? FontWeight.bold : null,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _viewMode == ViewMode.everything
          ? _buildEverythingView()
          : _buildImportantView(),
    );
  }

  Widget _buildEverythingView() {
    if (!lastPermissionGranted && displayedSmsList.isEmpty) {
      return const Center(
        child: Text(
          'Permissions denied.\nNo previously loaded data found.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _sectionTitle('📩 SMS Messages'),
        ...displayedSmsList.map((sms) => _cardListTile(
              icon: Icons.sms,
              title: sms['body'] ?? '',
              subtitle: 'From: ${sms['address'] ?? ''}',
              color: Colors.blue[50],
            )),
        const SizedBox(height: 12),
        Divider(color: Colors.deepPurple.shade100, thickness: 1.2),
        const SizedBox(height: 12),
        _sectionTitle('📞 Call Logs'),
        ...displayedCallLogs.map((call) => _cardListTile(
              icon: Icons.call,
              title: call['name'] ?? 'Unknown',
              subtitle: 'Number: ${call['number'] ?? ''}',
              color: Colors.green[50],
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildImportantView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _sectionTitle('🔒 Transactional SMS'),
        ...transactionalSmsList.map((sms) => _cardListTile(
              icon: Icons.lock,
              title: sms['body'] ?? '',
              subtitle: 'From: ${sms['address'] ?? ''}',
              color: Colors.orange[50],
            )),
        const SizedBox(height: 12),
        Divider(color: Colors.deepPurple.shade100, thickness: 1.2),
        const SizedBox(height: 12),
        _sectionTitle('📦 Buffered Events (Non-Transactional SMS + Call Logs)'),
        ...bufferedEvents.map((event) => _cardListTile(
              icon: event.type == 'sms'
                  ? Icons.sms_outlined
                  : Icons.call_outlined,
              title: event.payload['body'] ??
                  event.payload['name'] ??
                  'Unknown',
              subtitle: event.payload['address'] ??
                  event.payload['number'] ??
                  '',
              color: Colors.purple[50],
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.shade700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _cardListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: color ?? Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
