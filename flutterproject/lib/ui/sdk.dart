/// SDK: Collects SMS and Call Logs, detects transactional SMS,
/// and buffers non-transactional data.

class DataEvent {
  final String type; // 'sms' or 'call'
  final Map<String, dynamic> payload;

  DataEvent({required this.type, required this.payload});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'payload': payload,
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

  /// Clears any previous data and initializes the SDK
  void initialize() {
    _buffer.clear();
    _transactionalSmsList.clear();
    print('[SDK] Initialized. Buffer cleared.');
  }

  /// Detects if the SMS is transactional and stores appropriately
  void trackSms(Map<String, String> sms) {
    final body = sms['body']?.toLowerCase() ?? '';

    if (_isTransactional(body)) {
      print('[SDK] Transactional SMS detected: "${sms['body']}"');
      _transactionalSmsList.add(sms);
    } else {
      print('[SDK] Non-transactional SMS buffered');
      _addToBuffer(DataEvent(type: 'sms', payload: sms));
    }
  }

  /// Buffers all call logs
  void trackCall(Map<String, String> call) {
    print('[SDK] Call log buffered');
    _addToBuffer(DataEvent(type: 'call', payload: call));
  }

  /// Returns the buffered non-transactional events (call logs + sms)
  List<DataEvent> get bufferedData => List.unmodifiable(_buffer);

  /// Returns the list of transactional SMS
  List<Map<String, String>> get transactionalSmsList =>
      List.unmodifiable(_transactionalSmsList);

  void _addToBuffer(DataEvent event) {
    _buffer.add(event);
    print('[SDK] Buffer size: ${_buffer.length}/$_batchSize');
  }

  bool _isTransactional(String body) {
    return _transactionalKeywords.any((keyword) => body.contains(keyword));
  }
}
