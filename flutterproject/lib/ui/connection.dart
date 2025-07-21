// lib/connection.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// The backend API endpoint (replace with your actual URL)
const String backendUrl = 'http://10.0.2.2:8000/drinks/';

/// Sends a batch of events (list of maps) to the backend
Future<bool> sendEventsBatch(List<Map<String, dynamic>> events) async {
  try {
    final body = jsonEncode(events);
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('[Connection] Successfully sent batch of ${events.length} events.');
      return true;
    } else {
      print('[Connection] Failed to send batch. Status: ${response.statusCode}');
      print('[Connection] Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('[Connection] Exception while sending batch: $e');
    return false;
  }
}

/// Sends a single transactional SMS event immediately
Future<bool> sendSingleEvent(Map<String, dynamic> event) async {
  try {
    final body = jsonEncode(event);
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('[Connection] Successfully sent single event.');
      return true;
    } else {
      print('[Connection] Failed to send single event. Status: ${response.statusCode}');
      print('[Connection] Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('[Connection] Exception while sending single event: $e');
    return false;
  }
}
