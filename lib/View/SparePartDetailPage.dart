import 'package:flutter/material.dart';
import 'package:workshop_manager/View/work_scheduller.dart';
import '../Controls/inventory_controller.dart';
import '../Model/usage_history_model.dart';
import 'inventory.dart';
import 'main.dart';

class SparePartDetailPage extends StatefulWidget {
  final int sparePartId;
  final String name;
  final int qty;


  const SparePartDetailPage({
    super.key,
    required this.sparePartId,
    required this.name,
    required this.qty,
  });

  @override
  State<SparePartDetailPage> createState() => _SparePartDetailPageState();
}

class _SparePartDetailPageState extends State<SparePartDetailPage> {
  final InventoryController controller = InventoryController();
  List<UsageHistory> usageHistory = [];
  bool isLoading = true;
  int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    loadUsageHistory();
  }

  Future<void> loadUsageHistory() async {
    try {
      final history = await controller.fetchUsageHistory(widget.sparePartId);
      setState(() {
        usageHistory = history;
        isLoading = false; // Ensure this always runs
      });
    } catch (e) {
      print("Error fetching usage history: $e");
      setState(() {
        isLoading = false; // Prevent infinite loading even on error
      });
    }
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WorkSchedulerPage(controller: workloadController)),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InventoryPage()),
        );
        break;
    }
  }

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
              const SizedBox(width: 100),
              const Text(
                'Usage History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Summary Card
          Container(
            color: const Color(0xFF2c3e50),
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            child: Row(
              children: [
                _summaryCard("Current Quantity", widget.qty.toString()),
              ],
            ),
          ),

          // Usage History List
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
                // This Column already exists or should exist to hold multiple children
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // Optional: if you want the text/header to stretch
                children: [
                  // Spare Part Name Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Text(
                      // REMOVE 'const'
                      widget.name, // Display the name of the current spare part
                      textAlign: TextAlign.center, // Center the text
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color:
                            Colors
                                .black87, // Ensure good contrast on white background
                      ),
                    ),
                  ),
                  // Optional: Separator Line
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    color: Colors.grey.shade300,
                  ),

                  // Existing Usage History List (or loading indicator)
                  Expanded(
                    child:
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                              padding: const EdgeInsets.all(0),
                              itemCount: usageHistory.length,
                              itemBuilder: (context, index) {
                                final record = usageHistory[index];
                                return _sparePartUsage(
                                  record.usedAt.toString().split(" ")[0],
                                  record.mechanicName,
                                  record.quantityUsed,
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2c3e50),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: '',
          ),
        ],
      ),
    );
  }

  // Summary Card
  static Widget _summaryCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Usage History Item
  static Widget _sparePartUsage(String date, String mecName, int qty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                "Mechanic Name: ",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(child: Text(mecName, textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                "Quantity Used: ",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  qty.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(' Pcs'),
            ],
          ),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
