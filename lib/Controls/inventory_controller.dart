import '../Model/procurement.dart';
import '../Model/procurementDetails.dart';
import '../Model/spare_part_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Model/usage_history_model.dart';

class InventoryController {
  final supabase = Supabase.instance.client;

  Future<List<SparePart>> fetchSpareParts() async {
    final response = await supabase.from('spare_parts').select();
    return (response as List).map((e) => SparePart.fromJson(e)).toList();
  }

  Future<List<UsageHistory>> fetchUsageHistory(int sparePartId) async {
    final response = await supabase
        .from('Usage_history')
        .select()
        .eq('sp_id', sparePartId)
        .order('used_at', ascending: false);

    if (response == null || response.isEmpty) {
      return [];
    }

    return (response as List)
        .map((json) => UsageHistory.fromJson(json))
        .toList();
  }

  Future<List<Procurement>> fetchProcurementList() async {
    final response = await supabase.from('Procurement').select();
    return (response as List).map((e) => Procurement.fromJson(e)).toList();
  }

  Future<List<ProcurementDetails>> fetchProcurementDetail(int procurementId) async {
    await Future.delayed(const Duration(seconds: 1));
    final response = await supabase
        .from('Procurement_details')
        .select()
        .eq('procurement_id', procurementId);
    return (response as List).map((e) => ProcurementDetails.fromJson(e)).toList();
  }

  Future<int> fetchProcurementId() async {
    final response = await supabase
        .from('Procurement')
        .select('procurement_id')
        .order('procurement_id', ascending: false)
        .limit(1)
        .maybeSingle();

    return (response?['procurement_id'] ?? 0) as int;
  }

  Future<int> fetchProcurementDetailId() async {
    final response = await supabase
        .from('Procurement_details')
        .select('pd_id')
        .order('pd_id', ascending: false)
        .limit(1)
        .maybeSingle();

    return (response?['pd_id'] ?? 0) as int;
  }

  Future<bool> insertProcurement({
    required int procurementId1,
    required int procurementId,
    String? spName = '',
    String? sName = '',
    String requestDate = '',
    String status = '',
    int managerId = 0,

    required int procurementDetailId,
    required int quantity,
    required String remarks,
    DateTime? receiveBy = null,
    String? receivedImage = null,
  }) async {
    try {
      // Data for Procurement table
      final data1 = {
        'procurement_id': procurementId1,
        'sparepart_name': spName,
        'supplier_name': sName,
        'request_date': requestDate,
        'status': status,
        'managerer_id': managerId,
      };

      // Data for Procurement_details table
      final data2 = {
        'pd_id': procurementDetailId,
        'quantity': quantity,
        'remarks': remarks,
        'received_by': receiveBy?.toIso8601String(),
        'received_image': receivedImage,
        'procurement_id': procurementId,
      };

      // Insert into Procurement table first
      final response1 = await supabase.from('Procurement').insert(data1);

      // Insert into Procurement_details table second
      final response2 = await supabase.from('Procurement_details').insert(data2);

      // Check if both inserts succeeded
      if (response1.isEmpty && response2.isEmpty) {
        return true;
      } else {
        print("Insert failed: Procurement: $response1, Procurement_details: $response2");
        return false;
      }
    } catch (e) {
      print("Insert Exception: $e");
      return false;
    }
  }
}
