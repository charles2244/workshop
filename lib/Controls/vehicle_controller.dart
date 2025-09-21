import 'package:supabase_flutter/supabase_flutter.dart';

import '../Model/vehiclemodel.dart';

class CrmController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CustomerVehicleItem>> fetchCustomerVehicles() async {
    final vehiclesRaw = await _client.from('vehicles').select();
    if (vehiclesRaw == null) return [];

    final vehicles = vehiclesRaw
        .map((e) => VehicleModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final Set<int> customerIds = vehicles.map((v) => v.customerId).toSet();
    if (customerIds.isEmpty) return [];

    final customersRaw = await _client
        .from('Customers')
        .select();

    final Map<int, CustomerModel> customersById = {};
    if (customersRaw is List) {
      for (final row in customersRaw) {
        final map = Map<String, dynamic>.from(row as Map);
        final c = CustomerModel.fromJson(map);
        if (customerIds.contains(c.id)) {
          customersById[c.id] = c;
        }
      }
    }

    // Compose list
    final List<CustomerVehicleItem> items = [];
    for (final v in vehicles) {
      final customer = customersById[v.customerId];
      if (customer != null) {
        items.add(CustomerVehicleItem(customer: customer, vehicle: v));
      }
    }

    return items;
  }
}


