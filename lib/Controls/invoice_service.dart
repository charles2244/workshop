import 'package:supabase_flutter/supabase_flutter.dart';
import '../Model/invoice.dart';

class InvoiceService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Invoice>> getAllInvoices() async {
    try {
      final response = await _client
          .from('invoices')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      // Validate input data before sending to database
      if (invoice.customerName.trim().isEmpty) {
        throw Exception('Customer name cannot be empty');
      }

      if (invoice.totalAmount <= 0) {
        throw Exception('Total amount must be greater than 0');
      }

      // Ensure all numeric values are properly formatted and not null
      final invoiceData = {
        'customer_name': invoice.customerName.trim(),
        'customer_email': invoice.customerEmail.trim(),
        'customer_phone': invoice.customerPhone.trim(),
        'address': invoice.address.trim(),
        'total_amount': double.parse(invoice.totalAmount.toStringAsFixed(2)), // Ensure proper decimal format
        'created_at': invoice.createdAt.toIso8601String(),
        'status': invoice.status,
      };

      print('=== Invoice Service Debug ===');
      print('Sending invoice data to Supabase: $invoiceData');

      final response = await _client
          .from('invoices')
          .insert(invoiceData)
          .select()
          .single();

      print('Received response from Supabase: $response');

      final createdInvoice = Invoice.fromJson(response);
      print('Created invoice object: $createdInvoice');

      // Insert invoice items with proper validation
      if (invoice.items.isNotEmpty) {
        List<Map<String, dynamic>> itemsData = [];

        for (var item in invoice.items) {
          // Validate each item before adding
          if (item.description.trim().isEmpty) {
            throw Exception('Item description cannot be empty');
          }

          if (item.quantity <= 0) {
            throw Exception('Item quantity must be greater than 0');
          }

          if (item.price <= 0) {
            throw Exception('Item price must be greater than 0');
          }

          itemsData.add({
            'invoice_id': createdInvoice.id,
            'description': item.description.trim(),
            'quantity': item.quantity,
            'price': double.parse(item.price.toStringAsFixed(2)),
            'total': double.parse(item.total.toStringAsFixed(2)),
          });
        }

        print('Sending invoice items data: $itemsData');

        final itemsResponse = await _client.from('invoice_items').insert(itemsData);
        print('Invoice items created successfully');
      }

      return createdInvoice;
    } catch (e) {
      print('=== Invoice Service Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');

      if (e.toString().contains('duplicate key value')) {
        throw Exception('Duplicate invoice detected. Please try again.');
      } else if (e.toString().contains('foreign key')) {
        throw Exception('Database relationship error. Please contact support.');
      } else {
        throw Exception('Failed to create invoice: ${e.toString()}');
      }
    }
  }

  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    try {
      final response = await _client
          .from('invoice_items')
          .select()
          .eq('invoice_id', invoiceId);

      return (response as List).map((json) => InvoiceItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch invoice items: $e');
    }
  }

  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    try {
      await _client
          .from('invoices')
          .update({'status': status})
          .eq('id', invoiceId);
    } catch (e) {
      throw Exception('Failed to update invoice status: $e');
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _client.from('invoices').delete().eq('id', invoiceId);
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }


}