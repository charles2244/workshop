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
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Details',
          style: TextStyle(
            color: Color(0xFF1A1D29),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF1A1D29)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onPressed: () => _showOptionsBottomSheet(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceHeader(),
            SizedBox(height: 24),
            _buildCustomerInfo(),
            SizedBox(height: 24),
            _buildItemsList(),
            SizedBox(height: 24),
            _buildTotal(),
            SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    Color statusColor;
    Color statusBgColor;
    String displayStatus;

    switch (_invoice.status.toLowerCase()) {
      case 'paid':
        statusColor = Color(0xFF059669);
        statusBgColor = Color(0xFFD1FAE5);
        displayStatus = 'Paid';
        break;
      case 'pending':
        statusColor = Color(0xFFD97706);
        statusBgColor = Color(0xFFFEF3C7);
        displayStatus = 'Sent';
        break;
      case 'overdue':
        statusColor = Color(0xFFDC2626);
        statusBgColor = Color(0xFFFEE2E2);
        displayStatus = 'Overdue';
        break;
      default:
        statusColor = Color(0xFF6B7280);
        statusBgColor = Color(0xFFF3F4F6);
        displayStatus = 'Unknown';
        break;
    }

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
                  Text(
                    'INVOICE',
                    style: TextStyle(
                      color: Color(0xFF1A1D29),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _invoice.id != null ? '#${_invoice.id.toString().padLeft(8, '0')}' : '#00000000',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280), size: 20),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_invoice.createdAt),
                      style: TextStyle(
                        color: Color(0xFF1A1D29),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_invoice.createdAt.add(Duration(days: 30))),
                      style: TextStyle(
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 20),
          _buildInfoRow('Name:', _invoice.customerName, Icons.badge_outlined),
          SizedBox(height: 16),
          _buildInfoRow('Email:', _invoice.customerEmail, Icons.email_outlined),
          SizedBox(height: 16),
          _buildInfoRow('Phone:', _invoice.customerPhone, Icons.phone_outlined),
          if (_invoice.address.isNotEmpty) ...[
            SizedBox(height: 16),
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
            color: Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF3B82F6), size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 20),
          if (_items.isEmpty)
            Center(
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
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(
                      color: Color(0xFF1A1D29),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Color(0xFF1A1D29),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${item.price.toStringAsFixed(2)} each',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Color(0xFFE5E7EB),
            thickness: 1,
            height: 1,
          ),
      ],
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${_invoice.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
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
                backgroundColor: Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
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
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _handleMenuAction('mark_overdue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            if (_invoice.status.toLowerCase() != 'paid') ...[
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.check_circle_outline, color: Color(0xFF059669)),
                ),
                title: Text(
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
                    color: Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.schedule_outlined, color: Color(0xFFDC2626)),
                ),
                title: Text(
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
                  color: Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
              ),
              title: Text(
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
            SizedBox(height: 20),
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
            SnackBar(
              content: Text('Invoice marked as paid'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          Navigator.pop(context, true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating invoice: $e'),
              backgroundColor: Color(0xFFDC2626),
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
            SnackBar(
              content: Text('Invoice marked as overdue'),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
          Navigator.pop(context, true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating invoice: $e'),
              backgroundColor: Color(0xFFDC2626),
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
          title: Text(
            'Delete Invoice',
            style: TextStyle(
              color: Color(0xFF1A1D29),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this invoice? This action cannot be undone.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
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
                      backgroundColor: Color(0xFFDC2626),
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