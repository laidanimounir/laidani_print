import 'package:flutter_test/flutter_test.dart';
import 'package:laidani_print/services/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    test('initial mode is unknown', () {
      final service = ConnectivityService();
      expect(service.mode, ConnectionMode.unknown);
      expect(service.isOnline, false);
    });

    test('status text returns correct values', () {
      final service = ConnectivityService();
      expect(service.statusText, 'جاري الاتصال...');
    });

    test('status icon returns correct values', () {
      final service = ConnectivityService();
      expect(service.statusIcon, '\u{1F7E1}');
    });
  });
}
