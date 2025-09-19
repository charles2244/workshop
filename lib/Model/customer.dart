class Customer {
  final String? id;
  final String name;
  final String phoneNumber; // Changed from phone to phoneNumber
  final String email;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phoneNumber, // Use phone_number for database
      'email': email,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static Customer fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '', // Changed from phone to phone_number
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }
}