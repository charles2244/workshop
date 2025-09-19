// edit_customer_screen.dart - Updated with Figma color scheme
import 'package:flutter/material.dart';
import '../Controls/crm_service.dart';
import '../Model/customer.dart';

class EditCustomerScreen extends StatefulWidget {
  final Customer customer;

  const EditCustomerScreen({Key? key, required this.customer}) : super(key: key);

  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing customer data
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phoneNumber);
    _emailController = TextEditingController(text: widget.customer.email);
    _addressController = TextEditingController(text: widget.customer.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3B4C68),
      appBar: AppBar(
        title: Text('Edit Customer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF3B4C68),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'DEL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back link
              Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 16),

              // Customer Information Title
              Text(
                'Customer Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 24),

              // Customer Name Field with label
              Text(
                'Customer Name',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 8),
              _buildTextField(_nameController, 'Customer Name', Icons.person),

              SizedBox(height: 16),

              // Phone Number Field with label
              Text(
                'Phone Number',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 8),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),

              SizedBox(height: 16),

              // Email Field with label
              Text(
                'Email',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 8),
              _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),

              SizedBox(height: 16),

              // Address Field with label
              Text(
                'Address',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 8),
              _buildTextField(_addressController, 'Address', Icons.location_on, maxLines: 2),

              SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F),
                    disabledBackgroundColor: Color(0xFF2A9D8F).withOpacity(0.6),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                    'Update Customer',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF2A9D8F), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (controller == _nameController || controller == _phoneController) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter ${label.toLowerCase()}';
          }
        }
        if (controller == _emailController && value != null && value.isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
        }
        return null;
      },
    );
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedCustomer = Customer(
        id: widget.customer.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        createdAt: widget.customer.createdAt,
        updatedAt: DateTime.now(),
      );

      await CrmService().updateCustomer(updatedCustomer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer updated successfully!'),
            backgroundColor: Color(0xFF2A9D8F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating customer: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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