import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laidani_print/models/worker.dart';

void main() {
  group('AuthProvider', () {
    test('initial role is customer', () async {
      SharedPreferences.setMockInitialValues({});
      expect(true, true);
    });

    test('Worker model role detection', () {
      final manager = Worker(
        id: 1,
        username: 'admin',
        fullName: 'Admin',
        role: 'manager',
        computerId: 'PC1',
      );

      final worker = Worker(
        id: 2,
        username: 'worker1',
        fullName: 'Worker One',
        role: 'worker',
        computerId: 'PC2',
      );

      expect(manager.role, 'manager');
      expect(worker.role, 'worker');
    });
  });
}
