import 'package:supabase_flutter/supabase_flutter.dart';

class UserController {
  final supabase = Supabase.instance.client;

  Future<bool> insertManager({
    required int id,
    //required String name,
  }) async {
    try {
      final managerData = {
        'id': id,
        //'name': name,
      };

      final response = await supabase.from('Manager').insert(managerData).select();

      if (response != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Insert Exception: $e");
      return false;
    }
  }
}
