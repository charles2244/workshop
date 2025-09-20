import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../Model/invoice.dart';


class InvoiceAnalyticsScreen extends StatelessWidget {
  final List<Invoice> invoices;

  const InvoiceAnalyticsScreen({Key? key, required this.invoices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 120),
              const Text(
                'Financial Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildRevenueChart(),
                    const SizedBox(height: 24),
                    _buildStatusChart(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                const Color(0xFF3B82F6),
                Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Total Paid',
                paidInvoices.toString(),
                const Color(0xFF059669),
                Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Overdue',
                overdueInvoices.toString(),
                const Color(0xFFDC2626),
                Icons.warning_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Monthly Revenue',
                formattedPaidRevenue,
                const Color(0xFF7C3AED),
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
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              // Removed the 3 dots icon
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1D29),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
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
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
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
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: spots.isEmpty ? 1 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) / 4,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: const FlTitlesData(
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
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF3B82F6),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.3),
                          const Color(0xFF3B82F6).withOpacity(0.05),
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
        color: const Color(0xFF059669),
        value: paidCount.toDouble(),
        title: '',
        radius: 40,
      ));
    }

    if (pendingCount > 0) {
      sections.add(PieChartSectionData(
        color: const Color(0xFFD97706),
        value: pendingCount.toDouble(),
        title: '',
        radius: 40,
      ));
    }

    if (overdueCount > 0) {
      sections.add(PieChartSectionData(
        color: const Color(0xFFDC2626),
        value: overdueCount.toDouble(),
        title: '',
        radius: 40,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Status',
            style: TextStyle(
              color: Color(0xFF1A1D29),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
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
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    if (paidCount > 0)
                      _buildStatusLegend('Paid', paidCount, const Color(0xFF059669), totalCount),
                    if (paidCount > 0 && (pendingCount > 0 || overdueCount > 0))
                      const SizedBox(height: 16),
                    if (pendingCount > 0)
                      _buildStatusLegend('Pending', pendingCount, const Color(0xFFD97706), totalCount),
                    if (pendingCount > 0 && overdueCount > 0)
                      const SizedBox(height: 16),
                    if (overdueCount > 0)
                      _buildStatusLegend('Overdue', overdueCount, const Color(0xFFDC2626), totalCount),
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count invoices ($percentage%)',
                style: const TextStyle(
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
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
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
          const SizedBox(height: 20),
          if (recentInvoices.isEmpty)
            const Center(
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
        statusColor = const Color(0xFF059669);
        statusBgColor = const Color(0xFFD1FAE5);
        displayStatus = 'Paid';
        break;
      case 'overdue':
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEE2E2);
        displayStatus = 'Overdue';
        break;
      default:
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        displayStatus = 'Pending';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_outlined,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.customerName,
                  style: const TextStyle(
                    color: Color(0xFF1A1D29),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy').format(invoice.createdAt),
                  style: const TextStyle(
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
                style: const TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A1D29),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bar_chart_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(color: Color(0xFF9CA3AF)),
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