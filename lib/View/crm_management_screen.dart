// crm_management_screen.dart - Updated with inventory color scheme
import 'package:flutter/material.dart';
import '../Controls/crm_service.dart';
import '../Model/customer.dart';
import 'create_customer_screen.dart';
import 'customer_details_screen.dart';

class CrmManagementScreen extends StatefulWidget {
  @override
  _CrmManagementScreenState createState() => _CrmManagementScreenState();
}

class _CrmManagementScreenState extends State<CrmManagementScreen> {
  final CrmService _crmService = CrmService();
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _selectedFilter = 'Recent';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _crmService.getAllCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading customers: $e')),
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _customers;
      } else {
        _filteredCustomers = _customers
            .where((customer) =>
        customer.name.toLowerCase().contains(query) ||
            customer.phoneNumber.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  List<Customer> get _displayedCustomers {
    return _filteredCustomers;
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
                  'Customer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance the back button width
            ],
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500]),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : Icon(Icons.clear, color: Colors.grey[400]),
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
              child: Column(
                children: [
                  // Filter section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _buildFilterTab('Recent'),
                      ],
                    ),
                  ),

                  // Customer List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                        : _displayedCustomers.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No customers found',
                              style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: _displayedCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _displayedCustomers[index];
                        return _buildCustomerCard(customer);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCustomerScreen()),
          );
          if (result == true) {
            _loadCustomers();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.blue) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsScreen(customer: customer),
          ),
        );
        if (result == true) {
          _loadCustomers();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            // Customer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.phoneNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (customer.address.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        customer.address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}