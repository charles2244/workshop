import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Controls/invoice_service.dart';
import '../Model/invoice.dart';
import 'create_invoice_screen.dart';
import 'invoice_details_screen.dart';
import 'invoice_analytics_screen.dart';

class InvoiceManagementScreen extends StatefulWidget {
  @override
  _InvoiceManagementScreenState createState() => _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState extends State<InvoiceManagementScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      final invoices = await _invoiceService.getAllInvoices();
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invoices: $e')),
      );
    }
  }

  List<Invoice> get _filteredInvoices {
    List<Invoice> filtered = _invoices;

    // Filter by status - fix for "Sent" filter to show "pending" invoices
    if (_selectedFilter != 'All') {
      String statusToFilter = _selectedFilter.toLowerCase();
      if (_selectedFilter == 'Sent') {
        statusToFilter = 'pending'; // Map "Sent" filter to "pending" status
      }
      filtered = filtered.where((invoice) =>
      invoice.status.toLowerCase() == statusToFilter).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((invoice) =>
      invoice.customerName.toLowerCase().contains(searchTerm) ||
          invoice.customerEmail.toLowerCase().contains(searchTerm) ||
          invoice.id.toString().contains(searchTerm)
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50),
      appBar: null, // Remove the default AppBar
      body: Column(
        children: [
          const SizedBox(height: 30),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InvoiceAnalyticsScreen(invoices: _invoices)),
                    );
                  },
                ),
              ],
            ),
          ),

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
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        style: const TextStyle(color: Color(0xFF1A1D29)),
                      ),
                    ),
                  ),

                  // Filter Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Sent'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Paid'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Overdue'),
                      ],
                    ),
                  ),

                  // Invoice List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                        : _invoices.isEmpty
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF9CA3AF)),
                          SizedBox(height: 16),
                          Text(
                            'No invoices yet',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create your first invoice',
                            style: TextStyle(color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = _filteredInvoices[index];
                        return _buildInvoiceCard(invoice);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateInvoiceScreen()),
            );
            if (result == true) {
              _loadInvoices();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    Color chipColor;
    Color textColor;

    switch (label) {
      case 'Sent':
        chipColor = isSelected ? const Color(0xFFDDD6FE) : const Color(0xFFF3F4F6);
        textColor = isSelected ? const Color(0xFF7C3AED) : const Color(0xFF6B7280);
        break;
      case 'Paid':
        chipColor = isSelected ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6);
        textColor = isSelected ? const Color(0xFF059669) : const Color(0xFF6B7280);
        break;
      case 'Overdue':
        chipColor = isSelected ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6);
        textColor = isSelected ? const Color(0xFFDC2626) : const Color(0xFF6B7280);
        break;
      default: // All
        chipColor = isSelected ? const Color(0xFFDBEAFE) : const Color(0xFFF3F4F6);
        textColor = isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    Color statusColor;
    Color statusBgColor;
    String displayStatus;

    switch (invoice.status.toLowerCase()) {
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
      default:
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEE2E2);
        displayStatus = 'Overdue';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvoiceDetailsScreen(invoice: invoice)),
          );
          if (result == true) {
            _loadInvoices();
          }
        },
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_outlined,
            color: Color(0xFF3B82F6),
            size: 24,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                invoice.customerName,
                style: const TextStyle(
                  color: Color(0xFF1A1D29),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                displayStatus,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              invoice.id != null ? '#${invoice.id.toString().padLeft(8, '0')}' : '#00000000',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            // Changed from email to phone number
            Text(
              invoice.customerPhone,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(invoice.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '\$${invoice.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF1A1D29),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}