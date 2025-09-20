// customer_details_screen.dart - Updated with inventory color scheme
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controls/crm_service.dart';
import '../Model/customer.dart';
import '../Model/work.dart';
import 'customer_call_screen.dart';
import 'customer_reviews_screen.dart';
import 'edit_customer_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({Key? key, required this.customer}) : super(key: key);

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final CrmService _crmService = CrmService();
  List<Work> _works = [];
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;
  String? _error;
  late Customer _currentCustomer;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Loading data for customer ID: ${_currentCustomer.id}');

      // Load works and vehicles concurrently
      final worksFuture = _crmService.getCustomerWorks(_currentCustomer.id!);
      final vehiclesFuture = _crmService.getCustomerVehicles(_currentCustomer.id!);

      final results = await Future.wait([worksFuture, vehiclesFuture]);
      final works = results[0] as List<Work>;
      final vehicles = results[1] as List<Map<String, dynamic>>;

      print('Loaded ${works.length} works and ${vehicles.length} vehicles');

      setState(() {
        _works = works;
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50), // Updated to match inventory
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              'Error loading data',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
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
                  'Customer Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value),
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF4A5D7A),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Edit Customer', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red[300], size: 20),
                        const SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red[300])),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon: Icon(Icons.clear, color: Colors.grey[400]),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Main Content with rounded corners
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Customer Avatar and Info
                    _buildCustomerHeader(),

                    const SizedBox(height: 24),

                    // Service History Section
                    _buildWorksSection(),

                    const SizedBox(height: 24),

                    // Action Buttons
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

  Widget _buildCustomerHeader() {
    // Get vehicle info from vehicles array
    String vehicleInfo = 'No vehicle information';
    if (_vehicles.isNotEmpty) {
      final vehicle = _vehicles.first;
      final make = vehicle['make']?.toString() ?? '';
      final model = vehicle['model']?.toString() ?? '';
      final year = vehicle['year']?.toString() ?? '';

      vehicleInfo = '$make $model $year'.trim();
      if (vehicleInfo.isEmpty) vehicleInfo = 'Vehicle information available';
    }

    return Column(
      children: [
        // Vehicle info at top
        if (vehicleInfo != 'No vehicle information')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              vehicleInfo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 20),

        // Customer Name
        Text(
          _currentCustomer.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Customer details
        Column(
          children: [
            Text(
              _currentCustomer.phoneNumber,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (_currentCustomer.address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '[${_currentCustomer.address}]',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorksSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '${_works.length} records',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_works.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No service history',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Service records will appear here',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _works.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final work = _works[index];
                    return _buildWorkItem(work);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkItem(Work work) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time column
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM').format(work.createdAt),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(work.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Work details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (work.status != null && work.status!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(work.status!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      work.status!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (work.description != null && work.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      work.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                if (work.totalAmount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'RM ${work.totalAmount!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'waiting':
        return Colors.blue;
      case 'no show':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Call Button
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerCallScreen(customer: _currentCustomer),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
            child: Container(
              height: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 24, color: Colors.black54),
                  SizedBox(height: 4),
                  Text(
                    'Call',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Reviews Button
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerReviewsScreen(customer: _currentCustomer),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
            child: Container(
              height: 60,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review, size: 24, color: Colors.black54),
                  SizedBox(height: 4),
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'edit':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCustomerScreen(customer: _currentCustomer),
          ),
        );
        if (result == true) {
          await _refreshCustomerData();
        }
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  Future<void> _refreshCustomerData() async {
    try {
      final allCustomers = await _crmService.getAllCustomers();
      final updatedCustomer = allCustomers.firstWhere(
            (customer) => customer.id == _currentCustomer.id,
        orElse: () => _currentCustomer,
      );
      setState(() {
        _currentCustomer = updatedCustomer;
      });
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing customer data: $e')),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4A5D7A),
          title: const Text('Delete Customer', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this customer?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red[300])),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _crmService.deleteCustomer(_currentCustomer.id!);
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting customer: $e')),
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