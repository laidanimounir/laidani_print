// matches Flask SQLite schema exactly
class OrderFile {
  final int? id;
  final int? orderId;
  final String filePath;
  final String fileName;
  final String? fileType;
  final int pageCount;
  final String? thumbnailPath;
  final String printStatus;
  final int sortOrder;

  OrderFile({
    this.id,
    this.orderId,
    required this.filePath,
    required this.fileName,
    this.fileType,
    this.pageCount = 0,
    this.thumbnailPath,
    this.printStatus = 'pending',
    this.sortOrder = 0,
  });

  factory OrderFile.fromJson(Map<String, dynamic> json) {
    return OrderFile(
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      filePath: json['file_path'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      fileType: json['file_type'] as String?,
      pageCount: json['page_count'] as int? ?? 0,
      thumbnailPath: json['thumbnail_path'] as String?,
      printStatus: json['print_status'] as String? ?? 'pending',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      'file_path': filePath,
      'file_name': fileName,
      'file_type': fileType,
      'page_count': pageCount,
      'thumbnail_path': thumbnailPath,
      'print_status': printStatus,
      'sort_order': sortOrder,
    };
  }
}

class Order {
  final int id;
  final String orderNumber;
  final String computerId;
  final int? workerId;
  final String customerPhone;
  final List<OrderFile> files;
  final String filePath;
  final String fileName;
  final String? fileType;
  final int copies;
  final String colorMode;
  final String paperSize;
  final String? notes;
  final String status;
  final double price;
  final int pageCount;
  final bool isDuplex;
  final String duplexStatus;
  final String? aiSuggestions;
  final String paymentStatus;
  final String? paymentMethod;
  final double? amountReceived;
  final double? changeGiven;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.computerId,
    this.workerId,
    required this.customerPhone,
    this.files = const [],
    this.filePath = '',
    this.fileName = '',
    this.fileType,
    this.copies = 1,
    this.colorMode = 'bw',
    this.paperSize = 'A4',
    this.notes,
    this.status = 'new',
    this.price = 0,
    this.pageCount = 0,
    this.isDuplex = false,
    this.duplexStatus = 'none',
    this.aiSuggestions,
    this.paymentStatus = 'unpaid',
    this.paymentMethod,
    this.amountReceived,
    this.changeGiven,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderFile> fileList = [];
    if (json['files'] != null && json['files'] is List) {
      fileList = (json['files'] as List)
          .map((f) => OrderFile.fromJson(f as Map<String, dynamic>))
          .toList();
    }
    if (json['order_files'] != null && json['order_files'] is List) {
      fileList = (json['order_files'] as List)
          .map((f) => OrderFile.fromJson(f as Map<String, dynamic>))
          .toList();
    }
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String? ?? '',
      computerId: json['computer_id'] as String? ?? '',
      workerId: json['worker_id'] as int?,
      customerPhone: json['customer_phone'] as String? ?? '',
      files: fileList,
      filePath: json['file_path'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      fileType: json['file_type'] as String?,
      copies: json['copies'] as int? ?? 1,
      colorMode: json['color_mode'] as String? ?? 'bw',
      paperSize: json['paper_size'] as String? ?? 'A4',
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'new',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      pageCount: json['page_count'] as int? ?? 0,
      isDuplex: json['is_duplex'] == true || json['is_duplex'] == 1,
      duplexStatus: json['duplex_status'] as String? ?? 'none',
      aiSuggestions: json['ai_suggestions'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      paymentMethod: json['payment_method'] as String?,
      amountReceived: (json['amount_received'] as num?)?.toDouble(),
      changeGiven: (json['change_given'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'computer_id': computerId,
      'worker_id': workerId,
      'customer_phone': customerPhone,
      'files': files.map((f) => f.toJson()).toList(),
      'file_path': filePath,
      'file_name': fileName,
      'file_type': fileType,
      'copies': copies,
      'color_mode': colorMode,
      'paper_size': paperSize,
      'notes': notes,
      'status': status,
      'price': price,
      'page_count': pageCount,
      'is_duplex': isDuplex,
      'duplex_status': duplexStatus,
      'ai_suggestions': aiSuggestions,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'amount_received': amountReceived,
      'change_given': changeGiven,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Order copyWith({
    int? id,
    String? orderNumber,
    String? computerId,
    int? workerId,
    String? customerPhone,
    List<OrderFile>? files,
    String? filePath,
    String? fileName,
    String? fileType,
    int? copies,
    String? colorMode,
    String? paperSize,
    String? notes,
    String? status,
    double? price,
    int? pageCount,
    bool? isDuplex,
    String? duplexStatus,
    String? aiSuggestions,
    String? paymentStatus,
    String? paymentMethod,
    double? amountReceived,
    double? changeGiven,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      computerId: computerId ?? this.computerId,
      workerId: workerId ?? this.workerId,
      customerPhone: customerPhone ?? this.customerPhone,
      files: files ?? this.files,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      copies: copies ?? this.copies,
      colorMode: colorMode ?? this.colorMode,
      paperSize: paperSize ?? this.paperSize,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      price: price ?? this.price,
      pageCount: pageCount ?? this.pageCount,
      isDuplex: isDuplex ?? this.isDuplex,
      duplexStatus: duplexStatus ?? this.duplexStatus,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountReceived: amountReceived ?? this.amountReceived,
      changeGiven: changeGiven ?? this.changeGiven,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderSubmission {
  final String computerId;
  final String customerPhone;
  final List<String> filePaths;
  final List<String> fileNames;
  final int copies;
  final String colorMode;
  final String paperSize;
  final String? notes;
  final bool isDuplex;
  final String? customerNumber;

  OrderSubmission({
    required this.computerId,
    required this.customerPhone,
    required this.filePaths,
    required this.fileNames,
    this.copies = 1,
    this.colorMode = 'bw',
    this.paperSize = 'A4',
    this.notes,
    this.isDuplex = false,
    this.customerNumber,
  });

  Map<String, dynamic> toFormData() {
    return {
      'computer_id': computerId,
      'customer_phone': customerPhone,
      'copies': copies.toString(),
      'color_mode': colorMode,
      'paper_size': paperSize,
      'notes': notes ?? '',
      'is_duplex': isDuplex ? '1' : '0',
      if (customerNumber != null) 'customer_number': customerNumber,
    };
  }
}

class PaymentData {
  final int orderId;
  final String paymentMethod;
  final double amountReceived;

  PaymentData({
    required this.orderId,
    required this.paymentMethod,
    required this.amountReceived,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'payment_method': paymentMethod,
      'amount_received': amountReceived,
    };
  }
}
