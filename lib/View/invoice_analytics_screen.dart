import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/invoice.dart';
import 'package:fl_chart/fl_chart.dart';


class InvoiceAnalyticsScreen extends StatelessWidget {
  final List<Invoice> invoices;

  const InvoiceAnalyticsScreen({Key? key, required this.invoices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Financial Dashboard',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            SizedBox(height: 24),
            _buildRevenueChart(),
            SizedBox(height: 24),
            _buildStatusChart(),
            SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalInvoices = invoices.length;
    final paidInvoices = invoices.where((i) => i.status.toLowerCase() == 'paid').length;
    final pendingInvoices = invoices.where((i) => i.status.toLowerCase() == 'pending').length;
    final overdueInvoices = invoices.where((i) => i.status.toLowerCase() == 'overdue').length;

    // Calculate totals with proper null handling
    double totalRevenue = 0.0;
    double paidRevenue = 0.0;

    for (var invoice in invoices) {
      totalRevenue = totalRevenue + invoice.totalAmount;
      // Only calculate paid revenue from paid invoices (ignore overdue)
      if (invoice.status.toLowerCase() == 'paid') {
        paidRevenue = paidRevenue + invoice.totalAmount;
      }
    }

    // Format the revenue properly using string interpolation
    String formattedPaidRevenue = '\$${paidRevenue.toStringAsFixed(0)}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Invoice Created',
                totalInvoices.toString(),
                Color(0xFF3B82F6),
                Icons.receipt_long_outlined,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Total Paid',
                paidInvoices.toString(),
                Color(0xFF059669),
                Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Overdue',
                overdueInvoices.toString(),
                Color(0xFFDC2626),
                Icons.warning_outlined,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Monthly Revenue',
                formattedPaidRevenue, // Use the properly formatted string
                Color(0xFF7C3AED),
                Icons.trending_up_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              // Removed the 3 dots icon
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: Color(0xFF1A1D29),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (invoices.isEmpty) {
      return _buildEmptyChart('Revenue Chart', 'No revenue data available');
    }

    // Group invoices by month - only include PAID invoices for revenue calculation
    Map<String, double> monthlyRevenue = {};
    final paidInvoices = invoices.where((i) => i.status.toLowerCase() == 'paid').toList();

    for (var invoice in paidInvoices) {
      String monthKey = DateFormat('MMM yyyy').format(invoice.createdAt);
      if (monthlyRevenue.containsKey(monthKey)) {
        monthlyRevenue[monthKey] = monthlyRevenue[monthKey]! + invoice.totalAmount;
      } else {
        monthlyRevenue[monthKey] = invoice.totalAmount;
      }
    }

    if (monthlyRevenue.isEmpty) {
      return _buildEmptyChart('Revenue Chart', 'No paid invoices yet');
    }

    List<FlSpot> spots = [];
    List<String> months = monthlyRevenue.keys.toList()..sort();

    for (int i = 0; i < months.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyRevenue[months[i]]!));
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
                    'Revenue Chart',
                    style: TextStyle(
                      color: Color(0xFF1A1D29),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Monthly revenue overview',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF059669).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+12.5%',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: spots.isEmpty ? 1 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Color(0xFF3B82F6),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Color(0xFF3B82F6),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3B82F6).withOpacity(0.3),
                          Color(0xFF3B82F6).withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChart() {
    if (invoices.isEmpty) {
      return _buildEmptyChart('Invoice Status', 'No invoice data available');
    }

    final paidCount = invoices.where((i) => i.status.toLowerCase() == 'paid').length;
    final pendingCount = invoices.where((i) => i.status.toLowerCase() == 'pending').length;
    final overdueCount = invoices.where((i) => i.status.toLowerCase() == 'overdue').length;
    final totalCount = invoices.length;

    List<PieChartSectionData> sections = [];

    if (paidCount > 0) {
      sections.add(PieChartSectionData(
        color: Color(0xFF059669),
        value: paidCount.toDouble(),
        title: '',
        radius: 40,
      ));
    }

    if (pendingCount > 0) {
      sections.add(PieChartSectionData(
        color: Color(0xFFD97706),
        value: pendingCount.toDouble(),
        title: '',
        radius: 40,
      ));
    }

    if (overdueCount > 0) {
      sections.add(PieChartSectionData(
        color: Color(0xFFDC2626),
        value: overdueCount.toDouble(),
        title: '',
        radius: 40,
      ));
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
          Text(
            'Invoice Status',
            style: TextStyle(
              color: Color(0xFF1A1D29),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                      sections: sections,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    if (paidCount > 0)
                      _buildStatusLegend('Paid', paidCount, Color(0xFF059669), totalCount),
                    if (paidCount > 0 && (pendingCount > 0 || overdueCount > 0))
                      SizedBox(height: 16),
                    if (pendingCount > 0)
                      _buildStatusLegend('Pending', pendingCount, Color(0xFFD97706), totalCount),
                    if (pendingCount > 0 && overdueCount > 0)
                      SizedBox(height: 16),
                    if (overdueCount > 0)
                      _buildStatusLegend('Overdue', overdueCount, Color(0xFFDC2626), totalCount),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegend(String label, int count, Color color, int total) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count invoices ($percentage%)',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final recentInvoices = invoices.take(3).toList();

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
              Text(
                'Recent Activity',
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Removed "View All" text
            ],
          ),
          SizedBox(height: 20),
          if (recentInvoices.isEmpty)
            Center(
              child: Text(
                'No recent activity',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            )
          else
            ...recentInvoices.map((invoice) => _buildActivityItem(invoice)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Invoice invoice) {
    Color statusColor;
    Color statusBgColor;
    String displayStatus;

    switch (invoice.status.toLowerCase()) {
      case 'paid':
        statusColor = Color(0xFF059669);
        statusBgColor = Color(0xFFD1FAE5);
        displayStatus = 'Paid';
        break;
      case 'overdue':
        statusColor = Color(0xFFDC2626);
        statusBgColor = Color(0xFFFEE2E2);
        displayStatus = 'Overdue';
        break;
      default:
        statusColor = Color(0xFFD97706);
        statusBgColor = Color(0xFFFEF3C7);
        displayStatus = 'Pending';
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_outlined,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.customerName,
                  style: TextStyle(
                    color: Color(0xFF1A1D29),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy').format(invoice.createdAt),
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
                '\$${invoice.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title, String message) {
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
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF1A1D29),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}