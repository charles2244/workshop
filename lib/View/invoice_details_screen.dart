import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Controls/invoice_service.dart';
import '../Model/invoice.dart';


class InvoiceDetailsScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({Key? key, required this.invoice}) : super(key: key);

  @override
  _InvoiceDetailsScreenState createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  late Invoice _invoice;
  List<InvoiceItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    _loadInvoiceItems();
  }

  Future<void> _loadInvoiceItems() async {
    try {
      final items = await InvoiceService().getInvoiceItems(_invoice.id!);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Invoice Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showOptionsBottomSheet(),
              ),
            ],
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInvoiceHeader(),
                    const SizedBox(height: 24),
                    _buildCustomerInfo(),
                    const SizedBox(height: 24),
                    _buildItemsList(),
                    const SizedBox(height: 24),
                    _buildTotal(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    Color statusColor;
    Color statusBgColor;
    String displayStatus;

    switch (_invoice.status.toLowerCase()) {
      case 'paid':
        statusColor = const Color(0xFF059669);
        statusBgColor = const Color(0xFFD1FAE5);
        displayStatus = 'Paid';
        break;
      case 'pending':
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        displayStatus = 'Sent';
        break;
      case 'overdue':
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEE2E2);
        displayStatus = 'Overdue';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusBgColor = const Color(0xFFF3F4F6);
        displayStatus = 'Unknown';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INVOICE',
                    style: TextStyle(
                      color: Color(0xFF1A1D29),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _invoice.id != null ? '#${_invoice.id.toString().padLeft(8, '0')}' : '#00000000',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280), size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_invoice.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF1A1D29),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_invoice.createdAt.add(const Duration(days: 30))),
                      style: const TextStyle(
                        color: Color(0xFF1A1D29),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFF3B82F6), size: 20),
              SizedBox(width: 8),
              Text(
                'Customer Info',
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Name:', _invoice.customerName, Icons.badge_outlined),
          const SizedBox(height: 16),
          _buildInfoRow('Email:', _invoice.customerEmail, Icons.email_outlined),
          const SizedBox(height: 16),
          _buildInfoRow('Phone:', _invoice.customerPhone, Icons.phone_outlined),
          if (_invoice.address.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow('Address:', _invoice.address, Icons.location_on_outlined),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3B82F6), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: Color(0xFF3B82F6), size: 20),
              SizedBox(width: 8),
              Text(
                'Items',
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_items.isEmpty)
            const Center(
              child: Text(
                'No items found',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            )
          else
            Column(
              children: _items.map((item) => _buildItemRow(item)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item) {
    final isLast = _items.indexOf(item) == _items.length - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      color: Color(0xFF1A1D29),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Color(0xFF1A1D29),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.price.toStringAsFixed(2)} each',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            color: Color(0xFFE5E7EB),
            thickness: 1,
            height: 1,
          ),
      ],
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${_invoice.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_invoice.status.toLowerCase() != 'paid') ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _handleMenuAction('mark_paid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Mark as Paid',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _handleMenuAction('mark_overdue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Mark as Overdue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (_invoice.status.toLowerCase() != 'paid') ...[
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Color(0xFF059669)),
                ),
                title: const Text(
                  'Mark as Paid',
                  style: TextStyle(
                    color: Color(0xFF1A1D29),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleMenuAction('mark_paid');
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.schedule_outlined, color: Color(0xFFDC2626)),
                ),
                title: const Text(
                  'Mark as Overdue',
                  style: TextStyle(
                    color: Color(0xFF1A1D29),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleMenuAction('mark_overdue');
                },
              ),
            ],
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
              ),
              title: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleMenuAction('delete');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'mark_paid':
        try {
          await InvoiceService().updateInvoiceStatus(_invoice.id!, 'paid');
          setState(() {
            _invoice = Invoice(
              id: _invoice.id,
              customerName: _invoice.customerName,
              customerEmail: _invoice.customerEmail,
              customerPhone: _invoice.customerPhone,
              address: _invoice.address,
              items: _invoice.items,
              totalAmount: _invoice.totalAmount,
              createdAt: _invoice.createdAt,
              status: 'paid',
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice marked as paid'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          Navigator.pop(context, true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating invoice: $e'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
        break;
      case 'mark_overdue':
        try {
          await InvoiceService().updateInvoiceStatus(_invoice.id!, 'overdue');
          setState(() {
            _invoice = Invoice(
              id: _invoice.id,
              customerName: _invoice.customerName,
              customerEmail: _invoice.customerEmail,
              customerPhone: _invoice.customerPhone,
              address: _invoice.address,
              items: _invoice.items,
              totalAmount: _invoice.totalAmount,
              createdAt: _invoice.createdAt,
              status: 'overdue',
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice marked as overdue'),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
          Navigator.pop(context, true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating invoice: $e'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Invoice',
            style: TextStyle(
              color: Color(0xFF1A1D29),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this invoice? This action cannot be undone.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await InvoiceService().deleteInvoice(_invoice.id!);
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting invoice: $e'),
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}