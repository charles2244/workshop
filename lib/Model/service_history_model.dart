class ServiceHistory {
  final String id;
  final DateTime date;
  final String description;
  final String mechanicName;
  final String? vehicleId;
  final String? customerId;

  ServiceHistory({
    required this.id,
    required this.date,
    required this.description,
    required this.mechanicName,
    this.vehicleId,
    this.customerId,
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    return ServiceHistory(
      id: json['id']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      description: json['descriptions']?.toString() ?? '',
      mechanicName: json['mechanic_name']?.toString() ?? 'Unknown',
      vehicleId: json['vehicle_id']?.toString(),
      customerId: json['customer_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'descriptions': description,
      'mechanic_name': mechanicName,
      'vehicle_id': vehicleId,
      'customer_id': customerId,
    };
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
}
