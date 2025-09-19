import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/invoice.dart';
import '../Controls/invoice_service.dart';

class CreateInvoiceScreen extends StatefulWidget {
  @override
  _CreateInvoiceScreenState createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final List<InvoiceItem> _items = [];
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'New Invoice',
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Details
              _buildSectionTitle('Customer Details'),
              SizedBox(height: 16),
              _buildTextField(_customerNameController, 'Customer Name', Icons.person_outline),
              _buildTextField(_customerEmailController, 'Email', Icons.email_outlined),
              _buildTextField(_customerPhoneController, 'Phone', Icons.phone_outlined),
              _buildTextField(_addressController, 'Address', Icons.location_on_outlined, maxLines: 3),

              SizedBox(height: 32),

              // Items Section
              _buildSectionTitle('Items'),
              SizedBox(height: 16),
              _buildAddItemSection(),

              if (_items.isNotEmpty) ...[
                SizedBox(height: 20),
                ..._items.map((item) => _buildItemCard(item)).toList(),
              ],

              SizedBox(height: 24),

              // Total
              if (_items.isNotEmpty)
                _buildTotalSection(),

              SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Color(0xFFE5E7EB),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Create',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Color(0xFF1A1D29),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF000000).withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: Color(0xFF1A1D29), fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
            prefixIcon: Icon(icon, color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            fillColor: Colors.white,
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildAddItemSection() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'Item',
            style: TextStyle(
              color: Color(0xFF1A1D29),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            style: TextStyle(color: Color(0xFF1A1D29)),
            decoration: InputDecoration(
              labelText: 'Item Description',
              labelStyle: TextStyle(color: Color(0xFF9CA3AF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF3B82F6)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Color(0xFF1A1D29)),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Color(0xFF1A1D29)),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _addItem,
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF3B82F6),
                side: BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Add Item',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(InvoiceItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: TextStyle(
                    color: Color(0xFF1A1D29),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _items.remove(item);
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFDC2626),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    // Calculate total safely
    double total = 0.0;
    for (var item in _items) {
      total = total + item.total;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF3B82F6),
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (_descriptionController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _priceController.text.isEmpty) {
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    if (quantity <= 0 || price <= 0) {
      return;
    }

    setState(() {
      _items.add(InvoiceItem(
        description: _descriptionController.text,
        quantity: quantity,
        price: price,
        total: quantity * price,
      ));
    });

    _descriptionController.clear();
    _quantityController.clear();
    _priceController.clear();
  }

  Future<void> _createInvoice() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and add at least one item'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate total amount safely
      double totalAmount = 0.0;
      for (var item in _items) {
        totalAmount = totalAmount + item.total;
      }

      // Validate that total amount is valid
      if (totalAmount <= 0) {
        throw Exception('Invalid total amount');
      }

      // Create invoice object with validated data
      final invoice = Invoice(
        customerName: _customerNameController.text.trim(),
        customerEmail: _customerEmailController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        address: _addressController.text.trim(),
        items: List.from(_items), // Create a copy of the items
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      print('Creating invoice with total: $totalAmount'); // Debug print
      print('Items count: ${_items.length}'); // Debug print

      final createdInvoice = await InvoiceService().createInvoice(invoice);

      print('Invoice created successfully: ${createdInvoice.id}'); // Debug print

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice created successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error in _createInvoice: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating invoice: ${e.toString()}'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}