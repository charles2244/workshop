// services/crm_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Model/customer.dart';
import '../Model/work.dart';
import '../Model/call_log.dart';
import '../Model/customer_review.dart';
import '../Model/service_history_model.dart';

class CrmService {
  final SupabaseClient _client = Supabase.instance.client;

  // Customer operations
  Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await _client
          .from('Customers')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  Future<Customer> createCustomer(Customer customer) async {
    try {
      if (customer.name.trim().isEmpty) {
        throw Exception('Customer name cannot be empty');
      }
      if (customer.phoneNumber.trim().isEmpty) {
        throw Exception('Phone number cannot be empty');
      }

      final customerData = {
        'name': customer.name.trim(),
        'phone_number': customer.phoneNumber.trim(),
        'email': customer.email.trim(),
        'address': customer.address.trim(),
        'created_at': customer.createdAt.toIso8601String(),
        'updated_at': customer.updatedAt.toIso8601String(),
      };

      final response = await _client
          .from('Customers')
          .insert(customerData)
          .select()
          .single();

      return Customer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _client
          .from('Customers')
          .update({
        'name': customer.name.trim(),
        'phone_number': customer.phoneNumber.trim(),
        'email': customer.email.trim(),
        'address': customer.address.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', customer.id!);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _client.from('Customers').delete().eq('id', customerId);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Get vehicles for a customer
  Future<List<Map<String, dynamic>>> getCustomerVehicles(String customerId) async {
    try {
      print('Fetching vehicles for customer ID: $customerId');

      final response = await _client
          .from('vehicles')
          .select('*')
          .eq('customer_id', customerId);

      print('Found ${response?.length ?? 0} vehicles');
      return List<Map<String, dynamic>>.from(response ?? []);

    } catch (e) {
      print('Error fetching customer vehicles: $e');
      // If customer_id column doesn't exist, return empty list
      return [];
    }
  }

  // Work operations - Updated to work with actual Works table structure
  Future<List<Work>> getCustomerWorks(String customerId) async {
    try {
      print('Fetching works for customer ID: $customerId');

      // First get customer vehicles
      final vehicles = await getCustomerVehicles(customerId);

      if (vehicles.isEmpty) {
        print('No vehicles found for customer, cannot fetch works');
        return [];
      }

      List<Work> allWorks = [];

      // Get works for each vehicle
      for (final vehicle in vehicles) {
        final vehicleId = vehicle['id']?.toString();
        if (vehicleId != null) {
          try {
            final response = await _client
                .from('Works')
                .select('*')
                .eq('vehicle_id', vehicleId)
                .order('date', ascending: false);

            if (response != null) {
              final works = (response as List<dynamic>)
                  .map((json) => Work.fromJson(json as Map<String, dynamic>))
                  .toList();
              allWorks.addAll(works);
            }
          } catch (e) {
            print('Error fetching works for vehicle $vehicleId: $e');
            // Continue with other vehicles even if one fails
          }
        }
      }

      // Sort all works by date (newest first)
      allWorks.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });

      print('Found ${allWorks.length} works for customer');
      return allWorks;

    } catch (e) {
      print('Error fetching customer works: $e');
      throw Exception('Failed to load customer works: $e');
    }
  }

  Future<Work> addWork(Work work) async {
    try {
      final response = await _client
          .from('Works')
          .insert(work.toJson())
          .select()
          .single();

      return Work.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add work: $e');
    }
  }

  // Call log operations
  Future<List<CallLog>> getCustomerCallLogs(String customerId) async {
    try {
      final response = await _client
          .from('call_logs')
          .select()
          .eq('customer_id', customerId)
          .order('call_date', ascending: false);

      return (response as List).map((json) => CallLog.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch call logs: $e');
    }
  }

  Future<CallLog> addCallLog(CallLog callLog) async {
    try {
      final response = await _client
          .from('call_logs')
          .insert(callLog.toJson())
          .select()
          .single();

      return CallLog.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add call log: $e');
    }
  }

  // Customer review operations
  Future<List<CustomerReview>> getCustomerReviews(String customerId) async {
    try {
      final response = await _client
          .from('customer_review')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => CustomerReview.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<CustomerReview> addCustomerReview(CustomerReview review) async {
    try {
      final response = await _client
          .from('customer_review')
          .insert(review.toJson())
          .select()
          .single();

      return CustomerReview.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  Future<void> updateCustomerReview(CustomerReview review) async {
    try {
      await _client
          .from('customer_review')
          .update({
        'rating': review.rating,
        'review_text': review.reviewText,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', review.id!);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  Future<void> deleteCustomerReview(String reviewId) async {
    try {
      await _client.from('customer_review').delete().eq('id', reviewId);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  // Search customers
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final response = await _client
          .from('Customers')
          .select()
          .or('name.ilike.%$query%,phone_number.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  // Get customer with vehicle info
  Future<Map<String, dynamic>?> getCustomerWithVehicleInfo(String customerId) async {
    try {
      final response = await _client
          .from('Customers')
          .select('*, vehicles(*)')
          .eq('id', customerId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch customer with vehicle info: $e');
    }
  }

  // Get service history for a customer
  Future<List<ServiceHistory>> getCustomerServiceHistory(String customerId) async {
    try {
      print('Fetching service history for customer ID: $customerId');

      // First get customer vehicles
      final vehicles = await getCustomerVehicles(customerId);

      if (vehicles.isEmpty) {
        print('No vehicles found for customer, cannot fetch service history');
        return [];
      }

      List<ServiceHistory> allServiceHistory = [];

      // Get service history for each vehicle
      for (final vehicle in vehicles) {
        final vehicleId = vehicle['id']?.toString();
        if (vehicleId != null) {
          try {
            // Join Works with Mechanics to get mechanic names
            final response = await _client
                .from('Works')
                .select('''
                  id,
                  date,
                  descriptions,
                  mechanic_id,
                  vehicle_id,
                  Mechanics!inner(Name)
                ''')
                .eq('vehicle_id', vehicleId)
                .order('date', ascending: false);

            if (response != null) {
              final serviceHistory = (response as List<dynamic>)
                  .map((json) {
                    final workData = json as Map<String, dynamic>;
                    final mechanicData = workData['Mechanics'] as Map<String, dynamic>?;
                    
                    return ServiceHistory(
                      id: workData['id']?.toString() ?? '',
                      date: workData['date'] != null
                          ? DateTime.parse(workData['date'].toString())
                          : DateTime.now(),
                      description: workData['descriptions']?.toString() ?? '',
                      mechanicName: mechanicData?['Name']?.toString() ?? 'Unknown',
                      vehicleId: vehicleId,
                      customerId: customerId,
                    );
                  })
                  .toList();
              allServiceHistory.addAll(serviceHistory);
            }
          } catch (e) {
            print('Error fetching service history for vehicle $vehicleId: $e');
            // Continue with other vehicles even if one fails
          }
        }
      }

      // Sort all service history by date (newest first)
      allServiceHistory.sort((a, b) => b.date.compareTo(a.date));

      print('Found ${allServiceHistory.length} service history records for customer');
      return allServiceHistory;

    } catch (e) {
      print('Error fetching customer service history: $e');
      throw Exception('Failed to load customer service history: $e');
    }
  }
}