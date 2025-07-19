// app/lib/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Placeholder lists for SMS and call logs
  List<Map<String, String>> smsList = [];
  List<Map<String, String>> callLogList = [];

  bool permissionGranted = false;

  @override
  void initState() {
    super.initState();
    // Permission and data loading will be implemented in Part 3
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS & Call Logs')),
      body: permissionGranted
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: smsList.length,
                    itemBuilder: (context, index) {
                      final sms = smsList[index];
                      return ListTile(
                        leading: const Icon(Icons.message),
                        title: Text(sms['body'] ?? ''),
                        subtitle: Text('From: ${sms['address'] ?? ''}'),
                      );
                    },
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: callLogList.length,
                    itemBuilder: (context, index) {
                      final call = callLogList[index];
                      return ListTile(
                        leading: const Icon(Icons.call),
                        title: Text(call['name'] ?? 'Unknown'),
                        subtitle: Text('Number: ${call['number'] ?? ''}'),
                      );
                    },
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'Permissions not granted.\nPlease grant SMS and Call Log permissions.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}