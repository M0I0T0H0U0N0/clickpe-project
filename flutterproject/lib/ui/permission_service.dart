import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:call_log/call_log.dart';

class PermissionsAndDataLoader {
  final Telephony _telephony = Telephony.instance;

  /// Requests SMS and Call Log permissions
  Future<bool> requestPermissions() async {
    final smsStatus = await Permission.sms.request();
    final phoneStatus = await Permission.phone.request();
    return smsStatus.isGranted && phoneStatus.isGranted;
  }

  /// Loads SMS messages from the device inbox
  Future<List<Map<String, String>>> loadSMS() async {
    final List<SmsMessage> messages = await _telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    return messages.map((msg) {
      return {
        'address': msg.address ?? 'Unknown',
        'body': msg.body ?? '',
      };
    }).toList();
  }

  /// Loads call logs from the device
  Future<List<Map<String, String>>> loadCallLogs() async {
    final Iterable<CallLogEntry> entries = await CallLog.get();

    return entries.map((entry) {
      return {
        'name': entry.name ?? 'Unknown',
        'number': entry.number ?? '',
      };
    }).toList();
  }
}
