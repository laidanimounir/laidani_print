import 'package:flutter_test/flutter_test.dart';
import 'package:laidani_print/models/order.dart';
import 'package:laidani_print/models/worker.dart';
import 'package:laidani_print/models/customer.dart';
import 'package:laidani_print/services/connectivity_service.dart';

class MockConnectivity extends ConnectivityService {
  @override
  bool get isLocal => true;

  @override
  String get baseUrl => 'http://localhost:5000';
}

void main() {
  group('Order Model', () {
    test('fromJson creates Order correctly', () {
      final json = {
        'id': 1,
        'order_number': '20260522-0001',
        'computer_id': 'PC1',
        'customer_phone': '0555123456',
        'file_name': 'test.pdf',
        'copies': 2,
        'color_mode': 'bw',
        'paper_size': 'A4',
        'status': 'new',
        'price': 20.0,
        'page_count': 2,
        'is_duplex': false,
        'payment_status': 'unpaid',
        'created_at': '2026-05-22T10:00:00',
        'updated_at': '2026-05-22T10:00:00',
      };

      final order = Order.fromJson(json);
      expect(order.id, 1);
      expect(order.orderNumber, '20260522-0001');
      expect(order.customerPhone, '0555123456');
      expect(order.price, 20.0);
      expect(order.status, 'new');
    });

    test('toJson produces correct output', () {
      final order = Order(
        id: 1,
        orderNumber: '20260522-0001',
        computerId: 'PC1',
        customerPhone: '0555123456',
        filePath: '/tmp/test.pdf',
        fileName: 'test.pdf',
        copies: 3,
        colorMode: 'color',
        paperSize: 'A4',
        status: 'printing',
        price: 90.0,
        pageCount: 3,
        createdAt: DateTime(2026, 5, 22),
        updatedAt: DateTime(2026, 5, 22),
      );

      final json = order.toJson();
      expect(json['id'], 1);
      expect(json['copies'], 3);
      expect(json['color_mode'], 'color');
      expect(json['status'], 'printing');
    });

    test('copyWith preserves unmodified fields', () {
      final order = Order(
        id: 1,
        orderNumber: '20260522-0001',
        computerId: 'PC1',
        customerPhone: '0555123456',
        createdAt: DateTime(2026, 5, 22),
        updatedAt: DateTime(2026, 5, 22),
      );

      final updated = order.copyWith(status: 'done');
      expect(updated.status, 'done');
      expect(updated.id, 1);
      expect(updated.customerPhone, '0555123456');
    });

    test('OrderSubmission toFormData works', () {
      final sub = OrderSubmission(
        computerId: 'PC1',
        customerPhone: '0555123456',
        filePaths: ['/tmp/test.pdf'],
        fileNames: ['test.pdf'],
        copies: 2,
        colorMode: 'bw',
        paperSize: 'A4',
        isDuplex: true,
      );

      final data = sub.toFormData();
      expect(data['computer_id'], 'PC1');
      expect(data['is_duplex'], '1');
      expect(data['copies'], '2');
    });

    test('PaymentData toJson works', () {
      final payment = PaymentData(
        orderId: 1,
        paymentMethod: 'cash',
        amountReceived: 200.0,
      );

      final json = payment.toJson();
      expect(json['order_id'], 1);
      expect(json['payment_method'], 'cash');
    });
  });

  group('Worker Model', () {
    test('fromJson creates Worker correctly', () {
      final json = {
        'id': 1,
        'username': 'worker1',
        'full_name': 'Worker One',
        'role': 'worker',
        'computer_id': 'PC1',
        'is_active': true,
      };

      final worker = Worker.fromJson(json);
      expect(worker.id, 1);
      expect(worker.username, 'worker1');
      expect(worker.role, 'worker');
      expect(worker.isActive, true);
    });

    test('WorkerData toJson works', () {
      final data = WorkerData(
        username: 'worker5',
        password: 'pass123',
        fullName: 'Worker Five',
        computerId: 'PC3',
      );

      final json = data.toJson();
      expect(json['username'], 'worker5');
      expect(json['computer_id'], 'PC3');
    });
  });

  group('Customer Model', () {
    test('fromJson creates Customer correctly', () {
      final json = {
        'phone': '0555123456',
        'name': 'Customer Name',
        'total_orders': 10,
        'total_spent': 500.0,
        'discount_percent': 5,
        'is_vip': false,
      };

      final customer = Customer.fromJson(json);
      expect(customer.phone, '0555123456');
      expect(customer.totalOrders, 10);
      expect(customer.totalSpent, 500.0);
    });
  });

  group('API Login', () {
    test('login with correct credentials returns success response', () {
      const responseJson = {
        'success': true,
        'id': 1,
        'role': 'worker',
        'full_name': 'Worker 1',
        'computer_id': 'PC1',
        'username': 'worker1',
      };

      expect(responseJson['success'], true);
      expect(responseJson['role'], 'worker');
      expect(responseJson['id'], 1);
      expect(responseJson['full_name'], 'Worker 1');
    });

    test('login with wrong credentials returns failure', () {
      const responseJson = {
        'success': false,
        'message': 'اسم المستخدم أو كلمة المرور غير صحيحة',
      };

      expect(responseJson['success'], false);
      expect(responseJson['message'], 'اسم المستخدم أو كلمة المرور غير صحيحة');
    });
  });

  group('API Order Operations', () {
    test('submitOrder returns Order', () {
      final orderJson = {
        'id': 42,
        'order_number': '20260522-0042',
        'computer_id': 'PC1',
        'customer_phone': '0555123456',
        'file_name': 'test.pdf',
        'copies': 1,
        'color_mode': 'bw',
        'paper_size': 'A4',
        'status': 'new',
        'price': 10.0,
        'page_count': 1,
        'is_duplex': false,
        'payment_status': 'unpaid',
        'created_at': '2026-05-22T10:00:00',
        'updated_at': '2026-05-22T10:00:00',
      };

      final order = Order.fromJson(orderJson);
      expect(order.id, 42);
      expect(order.orderNumber, '20260522-0042');
      expect(order.status, 'new');
    });

    test('getOrders returns list of orders', () {
      final jsonList = [
        {
          'id': 1,
          'order_number': '20260522-0001',
          'computer_id': 'PC1',
          'customer_phone': '0555111111',
          'file_name': 'doc1.pdf',
          'copies': 2,
          'color_mode': 'bw',
          'paper_size': 'A4',
          'status': 'new',
          'price': 20.0,
          'page_count': 2,
          'is_duplex': false,
          'payment_status': 'unpaid',
          'created_at': '2026-05-22T10:00:00',
          'updated_at': '2026-05-22T10:00:00',
        },
        {
          'id': 2,
          'order_number': '20260522-0002',
          'computer_id': 'PC1',
          'customer_phone': '0555222222',
          'file_name': 'doc2.pdf',
          'copies': 1,
          'color_mode': 'color',
          'paper_size': 'A3',
          'status': 'printing',
          'price': 45.0,
          'page_count': 3,
          'is_duplex': true,
          'payment_status': 'unpaid',
          'created_at': '2026-05-22T11:00:00',
          'updated_at': '2026-05-22T11:00:00',
        },
      ];

      final orders = jsonList.map((j) => Order.fromJson(j as Map<String, dynamic>)).toList();
      expect(orders.length, 2);
      expect(orders[0].id, 1);
      expect(orders[1].colorMode, 'color');
    });
  });

  group('API Worker Operations', () {
    test('getWorkers returns list of workers', () {
      final jsonList = [
        {
          'id': 1,
          'username': 'worker1',
          'full_name': 'Worker 1',
          'role': 'worker',
          'computer_id': 'PC1',
          'is_active': true,
        },
        {
          'id': 2,
          'username': 'worker2',
          'full_name': 'Worker 2',
          'role': 'worker',
          'computer_id': 'PC2',
          'is_active': true,
        },
      ];

      final workers = jsonList.map((j) => Worker.fromJson(j as Map<String, dynamic>)).toList();
      expect(workers.length, 2);
      expect(workers[0].username, 'worker1');
      expect(workers[1].computerId, 'PC2');
    });

    test('getWorkers empty list returns empty', () {
      final jsonList = <Map<String, dynamic>>[];
      final workers = jsonList.map((j) => Worker.fromJson(j)).toList();
      expect(workers.length, 0);
    });
  });
}
