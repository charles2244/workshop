// crm_management_screen.dart - Updated with Figma color scheme
import 'package:flutter/material.dart';
import '../Model/customer.dart';
import '../Controls/crm_service.dart';
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
      backgroundColor: Color(0xFF3B4C68), // Dark blue background from Figma
      appBar: AppBar(
        title: Text('Customer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF3B4C68),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        // Removed the actions section with the person icon
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.black),
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
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Tabs - Only showing Recent
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterTab('Recent'),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Customer List
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)))
                  : _displayedCustomers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text('No customers found',
                        style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _displayedCustomers.length,
                itemBuilder: (context, index) {
                  final customer = _displayedCustomers[index];
                  return _buildCustomerCard(customer);
                },
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
        backgroundColor: Color(0xFF2A9D8F), // Teal accent color
        child: Icon(Icons.add, color: Colors.white),
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, color: Colors.grey[500], size: 24),
              ),
              SizedBox(width: 16),
              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      customer.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (customer.address.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          customer.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
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
      ),
    );
  }
}