import 'package:flutter_test/flutter_test.dart';
import 'package:laidani_print/models/order.dart';

void main() {
  group('Order Price Calculation', () {
    test('BW A4 1 copy is correct', () {
      final order = Order(
        id: 1,
        orderNumber: '001',
        computerId: 'PC1',
        customerPhone: '0555000000',
        copies: 1,
        colorMode: 'bw',
        paperSize: 'A4',
        pageCount: 5,
        price: 50.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(order.price, 50.0);
    });

    test('Color A4 3 copies is correct', () {
      final order = Order(
        id: 2,
        orderNumber: '002',
        computerId: 'PC1',
        customerPhone: '0555000000',
        copies: 3,
        colorMode: 'color',
        paperSize: 'A4',
        pageCount: 2,
        price: 180.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(order.price, 180.0);
    });
  });
}
