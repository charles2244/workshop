import 'package:supabase_flutter/supabase_flutter.dart';
import '../Model/workload_model.dart';

class WorkloadController {
  final SupabaseClient _client;

  WorkloadController(String supabaseUrl, String supabaseAnonKey)
      : _client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  Future<List<WorkloadModel>> fetchWorkloadsForDate(DateTime date) async {
    final formattedDate =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final works = await _client.from('Works').select().eq('date', formattedDate);
    final mechanics = await _client.from('Mechanics').select();

    return mechanics.map<WorkloadModel>((mechanic) {
      final mechanicWorks =
          works.where((work) => work['mechanic_id'] == mechanic['id']).toList();

      final assignedJobs = mechanicWorks.length;
      const maxJobs = 5;

      String status = assignedJobs >= maxJobs ? "Full" : "Available";

      return WorkloadModel(
        id: mechanic['id'],
        mechanicName: mechanic['Name'],
        jobsCompleted: assignedJobs,
        totalJobs: maxJobs,
        status: status,
        vehicleId: mechanicWorks.isNotEmpty ? mechanicWorks.first['vehicle_id'] : null,
        date: formattedDate,
        time: mechanicWorks.isNotEmpty ? mechanicWorks.first['time'] : null,
      );
    }).toList();
  }

  Future<List<WorkloadModel>> fetchWorksForDateWithDetails(DateTime date) async {
    final formattedDate =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final works = await _client.from('Works').select().eq('date', formattedDate);
    final mechanics = await _client.from('Mechanics').select();
    final vehicles = await _client.from('vehicles').select();
    final customers = await _client.from('Customers').select();


    return works.map<WorkloadModel>((work) {
      final mechanic = mechanics.firstWhere((m) => m['id'] == work['mechanic_id'],
          orElse: () => {});
      final vehicle = vehicles.firstWhere((v) => v['id'] == work['vehicle_id'],
          orElse: () => {});
      final customer = customers.firstWhere((c) => c['id'] == vehicle['customer_id'],
          orElse: () => {});

      // Determine status
      String status = (work['status'] ?? "Pending").toString();
      if (status.toLowerCase() == "pending" && work['time'] != null) {
        final jobTime = DateTime.tryParse("${work['date']} ${work['time']}");
        if (jobTime != null) {
          final now = DateTime.now();
          final diff = now.difference(jobTime).inMinutes;
          if (diff >= 0 && diff <= 120) {
            status = "In Progress"; // auto-update
          }
        }
      }

      return WorkloadModel(
        id: work['id'],
        mechanicName: mechanic['Name'],
        vehicleId: vehicle['id'],
        vehicleMake: vehicle['make'],
        vehicleModel: vehicle['model'],
        vehicleVIN: vehicle['vin'],
        customerName: customer['name'],
        date: work['date'],
        time: work['time'],
        status: status,
        description: work['descriptions'],
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchMechanics() async {
    final mechanics = await _client.from('Mechanics').select();
    return List<Map<String, dynamic>>.from(mechanics);
  }

  Future<void> updateWorkDetails(int workId, int mechanicId, String description) async {
    await _client.from('Works').update({
      'mechanic_id': mechanicId,
      'descriptions': description,
    }).eq('id', workId);
  }

  Future<void> updateWorkStatus(int workId, String status) async {
    await _client.from('Works').update({
      'status': status,
    }).eq('id', workId);
  }

  Future<bool> isMechanicAvailable(int mechanicId, String date, String time) async {
    final works = await _client.from('Works').select().eq('mechanic_id', mechanicId).eq('date', date);

    for (var work in works) {
      final jobTime = DateTime.tryParse("${work['date']} ${work['time']}");
      if (jobTime != null) {
        final endTime = jobTime.add(const Duration(hours: 2));
        final currentJobTime = DateTime.tryParse("$date $time");

        if (currentJobTime != null && currentJobTime.isAfter(jobTime) && currentJobTime.isBefore(endTime)) {
          return false; // Mechanic is not available
        }
      }
    }

    return true; // Mechanic is available
  }

  Future<WorkloadModel?> fetchWorkloadDetails(int workerId) async {
    final works = await _client.from('Works').select().eq('mechanic_id', workerId);
    final mechanics = await _client.from('Mechanics').select();
    final vehicles = await _client.from('vehicles').select();
    final customers = await _client.from('Customers').select();

    if (works.isEmpty) return null;

    final work = works.first;
    final mechanic = mechanics.firstWhere((m) => m['id'] == work['mechanic_id'], orElse: () => {});
    final vehicle = vehicles.firstWhere((v) => v['id'] == work['vehicle_id'], orElse: () => {});
    final customer = customers.firstWhere((c) => c['id'] == vehicle['customer_id'], orElse: () => {});

    return WorkloadModel(
      id: work['id'],
      mechanicName: mechanic['Name'],
      vehicleId: vehicle['id'],
      vehicleMake: vehicle['make'],
      vehicleModel: vehicle['model'],
      vehicleVIN: vehicle['vin'],
      customerName: customer['name'],
      date: work['date'],
      time: work['time'],
      status: work['status'],
      description: work['descriptions'],
    );
  }
}
