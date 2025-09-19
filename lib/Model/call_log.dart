class CallLog {
  final String? id;
  final String? customerId;
  final DateTime callDate;
  final String callType; // outgoing, incoming, missed
  final int? duration; // in seconds
  final String notes;
  final DateTime createdAt;

  CallLog({
    this.id,
    this.customerId,
    required this.callDate,
    this.callType = 'outgoing',
    this.duration,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'call_date': callDate.toIso8601String(),
      'call_type': callType,
      'duration': duration,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static CallLog fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['id']?.toString(),
      customerId: json['customer_id']?.toString(),
      callDate: json['call_date'] != null
          ? DateTime.parse(json['call_date'].toString())
          : DateTime.now(),
      callType: json['call_type']?.toString() ?? 'outgoing',
      duration: _parseInt(json['duration']),
      notes: json['notes']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}