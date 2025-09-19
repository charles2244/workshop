// create_customer_screen.dart - Updated with Figma color scheme
import 'package:flutter/material.dart';
import '../Model/customer.dart';
import '../Controls/crm_service.dart';

class CreateCustomerScreen extends StatefulWidget {
  @override
  _CreateCustomerScreenState createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

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
      backgroundColor: Color(0xFF3B4C68), // Dark blue background from Figma
      appBar: AppBar(
        title: Text('Add Customer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF3B4C68),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Details Section
              _buildSectionTitle('Customer Information'),
              _buildTextField(_nameController, 'Customer Name', Icons.person),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
              _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
              _buildTextField(_addressController, 'Address', Icons.location_on, maxLines: 2),

              SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2A9D8F), // Teal accent color
                    disabledBackgroundColor: Color(0xFF2A9D8F).withOpacity(0.6),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                    'Add Customer',
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
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
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
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
      ),
    );
  }

  Future<void> _createCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customer = Customer(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await CrmService().createCustomer(customer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer added successfully!'),
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
            content: Text('Error adding customer: ${e.toString()}'),
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