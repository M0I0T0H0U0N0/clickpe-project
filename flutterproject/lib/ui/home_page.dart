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

  @override
  void initState() {
    super.initState();
    _handleEverythingMode(); // default view
  }

  Future<void> _handleEverythingMode() async {
    sdk.initialize();
    final granted = await loader.requestPermissions();

    if (granted) {
      final smsList = await loader.loadSMS();
      final callLogList = await loader.loadCallLogs();

      // Feed to SDK
      for (var sms in smsList) {
        sdk.trackSms(sms);
      }
      for (var call in callLogList) {
        sdk.trackCall(call);
      }

      setState(() {
        lastPermissionGranted = true;
        displayedSmsList = smsList;
        displayedCallLogs = callLogList;
        transactionalSmsList = sdk.transactionalSmsList;
        bufferedEvents = sdk.bufferedData;
      });
    } else {
      setState(() {
        lastPermissionGranted = false;
        // Keep previous data (if any)
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
    _handleEverythingMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS & Call Logs'),
        actions: [
          TextButton(
            onPressed: _switchToEverything,
            child: Text(
              'Everything',
              style: TextStyle(
                color: _viewMode == ViewMode.everything
                    ? Colors.white
                    : Colors.white70,
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
              ),
            ),
          ),
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
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        const Text(
          '📩 SMS Messages',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...displayedSmsList.map((sms) => ListTile(
              leading: const Icon(Icons.sms),
              title: Text(sms['body'] ?? ''),
              subtitle: Text('From: ${sms['address'] ?? ''}'),
            )),
        const Divider(),
        const Text(
          '📞 Call Logs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...displayedCallLogs.map((call) => ListTile(
              leading: const Icon(Icons.call),
              title: Text(call['name'] ?? 'Unknown'),
              subtitle: Text('Number: ${call['number'] ?? ''}'),
            )),
      ],
    );
  }

  Widget _buildImportantView() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        const Text(
          '🔒 Transactional SMS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...transactionalSmsList.map((sms) => ListTile(
              leading: const Icon(Icons.lock),
              title: Text(sms['body'] ?? ''),
              subtitle: Text('From: ${sms['address'] ?? ''}'),
            )),
        const Divider(),
        const Text(
          '📦 Buffered Events (Non-Transactional SMS + Call Logs)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...bufferedEvents.map((event) => ListTile(
              leading: Icon(event.type == 'sms'
                  ? Icons.sms_outlined
                  : Icons.call_outlined),
              title: Text(event.payload['body'] ??
                  event.payload['name'] ??
                  'Unknown'),
              subtitle: Text(event.payload['address'] ??
                  event.payload['number'] ??
                  ''),
            )),
      ],
    );
  }
}
