class Invoice {
  final String? id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String address;
  final List<InvoiceItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final String status;

  Invoice({
    this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.address,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'address': address,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  static Invoice fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString(),
      customerName: json['customer_name']?.toString() ?? '',
      customerEmail: json['customer_email']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      items: [], // Will be loaded separately
      totalAmount: _parseDouble(json['total_amount']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      status: json['status']?.toString() ?? 'pending',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}

class InvoiceItem {
  final String? id;
  final String? invoiceId;
  final String description;
  final int quantity;
  final double price;
  final double total;

  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.description,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'description': description,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  static InvoiceItem fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id']?.toString(),
      invoiceId: json['invoice_id']?.toString(),
      description: json['description']?.toString() ?? '',
      quantity: _parseInt(json['quantity']),
      price: _parseDouble(json['price']),
      total: _parseDouble(json['total']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}