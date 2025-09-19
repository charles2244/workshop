class Work {
  final String? id;
  final String? vehicleId; // Changed from customerId to vehicleId
  final String? mechanicsId;
  final DateTime? date;
  final String? time;
  final String? status;
  final String? descriptions; // Note: plural as in your DB
  final double? totalAmount;

  Work({
    this.id,
    this.vehicleId,
    this.mechanicsId,
    this.date,
    this.time,
    this.status,
    this.descriptions,
    this.totalAmount,
  });

  // Getter for compatibility with existing code
  DateTime get createdAt => date ?? DateTime.now();
  String? get description => descriptions;

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'mechanics_id': mechanicsId,
      'date': date?.toIso8601String().split('T')[0], // Only date part
      'time': time,
      'status': status,
      'descriptions': descriptions,
      'total_amount': totalAmount,
    };
  }

  static Work fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id']?.toString(),
      vehicleId: json['vehicle_id']?.toString(),
      mechanicsId: json['mechanics_id']?.toString(),
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : null,
      time: json['time']?.toString(),
      status: json['status']?.toString(),
      descriptions: json['descriptions']?.toString(),
      totalAmount: _parseDouble(json['total_amount']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }
}