import 'package:flutter/material.dart';
import 'package:workshop_manager/View/work_scheduller.dart';
import '../Controls/inventory_controller.dart';
import '../Model/procurement.dart';
import 'ProcurementDetailPage.dart';
import 'ProcurementRequestPage.dart';
import 'inventory.dart';
import 'invoice_management_screen.dart';
import 'main.dart';

class ProcurementPage extends StatefulWidget {
  const ProcurementPage({super.key});

  @override
  State<ProcurementPage> createState() => _ProcurementPageState();
}

class _ProcurementPageState extends State<ProcurementPage> {
  final InventoryController controller = InventoryController();
  List<Procurement> procurementList = [];
  bool isLoading = true;
  int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    loadProcurement();
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
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InvoiceManagementScreen()),
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

  Future<void> loadProcurement() async {
    final list = await controller.fetchProcurementList();
    setState(() {
      procurementList = list;
      isLoading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.grey;
      case "In Transit":
        return Colors.yellow;
      case "Completed":
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, 'refresh'),
                ),
                const SizedBox(width: 100),
                const Text("Procurement",
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  height: 1.8,
                ),
                children: <TextSpan>[
                  const TextSpan(
                    text: "Procurement Request\n", // Add newline here
                    style: TextStyle(
                      color: Colors.black,       // Color for "Procurement Request"
                      fontSize: 15,
                      fontWeight: FontWeight.normal, // Normal weight
                    ),
                  ),
                  TextSpan(
                    text: procurementList.length.toString(), // The count
                    style: const TextStyle(
                      color: Colors.blue,        // Blue color for the count
                      fontSize: 25,
                      fontWeight: FontWeight.bold,   // Bold weight for the count
                    ),
                  ),
                ],
              ),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : procurementList.isEmpty && !isLoading
                          ? const Center(
                          child: Text(
                            "No procurement requests found.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                      )
                          : ListView.builder(
                        itemCount: procurementList.length,
                        itemBuilder: (context, index) {
                          final item = procurementList[index];
                          return _procurementItem(
                            item.id,
                            item.spName,
                            item.sName,
                            item.requestDate.toString().substring(0, 10),
                            item.status,
                            context,
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProcurementRequestPage()),
                        );
                        await loadProcurement();
                        setState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade300,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [ // Optional: Add a subtle shadow to the button
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Request Procurement",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
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
            icon: Icon(Icons.receipt),
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

  Widget _procurementItem(int procurementId, String itemName, String supplier, String date, String status, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Item info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(supplier),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 25, right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: getStatusColor(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
          // Middle: Date + Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProcurementDetailPage(
                            procurementId: procurementId,
                            partName: itemName,
                            requiredDate: date,
                            status: status,
                          ),
                    ),
                  );
                },
                child: const Text(
                  "Details >",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
