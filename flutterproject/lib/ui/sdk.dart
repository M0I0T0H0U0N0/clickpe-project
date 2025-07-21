// lib/sdk.dart
import 'dart:convert';
import 'connection.dart';

class DataEvent {
  final String type; // 'sms' or 'call'
  final Map<String, dynamic> payload;

  DataEvent({required this.type, required this.payload});

  Map<String, dynamic> toJson() {
    return {
      'event_type': type,
      'payload': jsonEncode(payload),
    };
  }
}

class DataCollectionSDK {
  final List<DataEvent> _buffer = [];
  final List<Map<String, String>> _transactionalSmsList = [];

  static const int _batchSize = 50;

  static const List<String> _transactionalKeywords = [
    'otp',
    'transaction',
    'debited',
    'credited',
    'spent',
    'paid',
    'purchase',
    'payment',
  ];

  void initialize() {
    _buffer.clear();
    _transactionalSmsList.clear();
    print('[SDK] Initialized. Buffer cleared.');
  }

  // Now async to await sending data
  Future<void> trackSms(Map<String, String> sms) async {
    final body = sms['body']?.toLowerCase() ?? '';

    if (_isTransactional(body)) {
      print('[SDK] Transactional SMS detected: "${sms['body']}"');
      _transactionalSmsList.add(sms);

      final event = {
        'event_type': 'sms',
        'payload': jsonEncode(sms),
      };

      final success = await sendSingleEvent(event);
      if (!success) {
        print('[SDK] Failed to send transactional SMS immediately.');
      }
    } else {
      print('[SDK] Non-transactional SMS buffered');
      _addToBuffer(DataEvent(type: 'sms', payload: Map<String, dynamic>.from(sms)));
      if (_buffer.length >= _batchSize) {
        await _flushBuffer();
      }
    }
  }

  Future<void> trackCall(Map<String, String> call) async {
    print('[SDK] Call log buffered');
    _addToBuffer(DataEvent(type: 'call', payload: Map<String, dynamic>.from(call)));
    if (_buffer.length >= _batchSize) {
      await _flushBuffer();
    }
  }

  List<DataEvent> get bufferedData => List.unmodifiable(_buffer);

  List<Map<String, String>> get transactionalSmsList => List.unmodifiable(_transactionalSmsList);

  void _addToBuffer(DataEvent event) {
    _buffer.add(event);
    print('[SDK] Buffer size: ${_buffer.length}/$_batchSize');
  }

  bool _isTransactional(String body) {
    return _transactionalKeywords.any((keyword) => body.contains(keyword));
  }

  Future<void> _flushBuffer() async {
    if (_buffer.isEmpty) return;

    final batch = _buffer.map((event) => event.toJson()).toList();

    final success = await sendEventsBatch(batch);
    if (success) {
      print('[SDK] Buffer flushed successfully. Clearing buffer.');
      _buffer.clear();
    } else {
      print('[SDK] Failed to flush buffer. Will retry later.');
    }
  }
}