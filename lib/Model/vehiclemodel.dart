class VehicleModel {
  final int id;
  final String make;
  final String model;
  final String plate;
  final int customerId;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.plate,
    required this.customerId,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: (json['id'] ?? 0) as int,
      make: (json['make'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      plate: (json['plate'] ?? json['license_plate'] ?? '').toString(),
      customerId: (json['customer_id'] ?? 0) as int,
    );
  }
}

class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? notes;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.notes,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      notes: (json['notes'] ?? json['remark'])?.toString(),
    );
  }
}

class CustomerVehicleItem {
  final CustomerModel customer;
  final VehicleModel vehicle;

  CustomerVehicleItem({
    required this.customer,
    required this.vehicle,
  });
}


