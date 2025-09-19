// customer_details_screen.dart - Fixed version
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
      print('Loading data for customer ID: ${_currentCustomer.id}'); // Debug log

      // Load works and vehicles concurrently
      final worksFuture = _crmService.getCustomerWorks(_currentCustomer.id!);
      final vehiclesFuture = _crmService.getCustomerVehicles(_currentCustomer.id!);

      final results = await Future.wait([worksFuture, vehiclesFuture]);
      final works = results[0] as List<Work>;
      final vehicles = results[1] as List<Map<String, dynamic>>;

      print('Loaded ${works.length} works and ${vehicles.length} vehicles'); // Debug log

      setState(() {
        _works = works;
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e'); // Debug log
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3B4C68), // Dark blue background from Figma
      appBar: AppBar(
        title: Text('Customer Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF3B4C68),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Color(0xFF4A5D7A), // Slightly lighter dark blue
            itemBuilder: (context) => [
              PopupMenuItem(
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
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red[300])),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)))
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2A9D8F),
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Search Bar (matching the design)
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon: Icon(Icons.clear, color: Colors.grey[400]),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Customer Avatar and Info
                  _buildCustomerHeader(),

                  SizedBox(height: 24),

                  // Service History Section
                  _buildWorksSection(),

                  SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                ],
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              vehicleInfo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        SizedBox(height: 20),

        // Customer Name
        Text(
          _currentCustomer.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8),

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
                padding: EdgeInsets.only(top: 4),
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
              Text(
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

          SizedBox(height: 12),

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
                    SizedBox(height: 16),
                    Text(
                      'No service history',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
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
                  color: Color(0xFFE8F4F8), // Light blue/teal background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.all(16),
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
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time column
          Container(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM').format(work.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
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

          SizedBox(width: 16),

          // Work details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (work.status != null && work.status!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(work.status!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      work.status!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (work.description != null && work.description!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 6),
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
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'RM ${work.totalAmount!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A9D8F),
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
                _loadData(); // Refresh data
              }
            },
            child: Container(
              height: 60,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Column(
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
                _loadData(); // Refresh data
              }
            },
            child: Container(
              height: 60,
              margin: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Column(
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
            (customer) => customer.id != null && _currentCustomer.id != null && customer.id.toString() == _currentCustomer.id.toString(),
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
          backgroundColor: Color(0xFF4A5D7A),
          title: Text('Delete Customer', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete this customer?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
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