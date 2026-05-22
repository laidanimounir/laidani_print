import 'package:flutter_test/flutter_test.dart';
import 'package:laidani_print/models/order.dart';

void main() {
  testWidgets('Order model works', (WidgetTester tester) async {
    final order = Order(
      id: 1,
      orderNumber: '20260522-0001',
      computerId: 'PC1',
      customerPhone: '0555123456',
      copies: 2,
      colorMode: 'bw',
      paperSize: 'A4',
      price: 20.0,
      pageCount: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(order.orderNumber, '20260522-0001');
    expect(order.price, 20.0);
  });
}
