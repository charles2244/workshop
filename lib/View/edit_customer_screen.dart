// edit_customer_screen.dart - Updated with inventory color scheme
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
      backgroundColor: const Color(0xFF2c3e50), // Updated to match inventory
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Header with back button and title
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Edit Customer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
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

          // Main Form Container
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Information Title
                      const Text(
                        'Customer Information',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Customer Name Field with label
                      const Text(
                        'Customer Name',
                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(_nameController, 'Customer Name', Icons.person),

                      const SizedBox(height: 16),

                      // Phone Number Field with label
                      const Text(
                        'Phone Number',
                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),

                      const SizedBox(height: 16),

                      // Email Field with label
                      const Text(
                        'Email',
                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),

                      const SizedBox(height: 16),

                      // Address Field with label
                      const Text(
                        'Address',
                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(_addressController, 'Address', Icons.location_on, maxLines: 2),

                      const SizedBox(height: 32),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateCustomer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Updated to match inventory theme
                            disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text(
                            'Update Customer',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        fillColor: Colors.grey[50],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            content: const Text('Customer updated successfully!'),
            backgroundColor: Colors.blue,
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