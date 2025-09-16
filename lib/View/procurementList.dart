import 'package:flutter/material.dart';
import '../Controls/inventory_controller.dart';
import '../Model/procurement.dart';
import 'ProcurementDetailPage.dart';
import 'ProcurementRequestPage.dart';

class ProcurementPage extends StatefulWidget {
  const ProcurementPage({super.key});

  @override
  State<ProcurementPage> createState() => _ProcurementPageState();
}

class _ProcurementPageState extends State<ProcurementPage> {
  final InventoryController controller = InventoryController();
  List<Procurement> procurementList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProcurement();
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
          // Top Bar
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, 'refresh'),
                ),
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
          // Procurement Request Count
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              textAlign: TextAlign.center,
              "Procurement Request \n ${procurementList.length}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // White Container for Procurement List
          Expanded(
            child: Container(
              // Removed padding from here, will apply to Column or ListView instead
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column( // Wrap ListView and Button in a Column
                children: [
                  Expanded( // Make the ListView take available space
                    child: Padding( // Added padding around the list/loader
                      padding: const EdgeInsets.all(16.0),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : procurementList.isEmpty && !isLoading // Handle empty list case
                          ? const Center(
                          child: Text(
                            "No procurement requests found.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                      )
                          : ListView.builder(
                        // No need for itemExtent if rows have dynamic height
                        itemCount: procurementList.length,
                        itemBuilder: (context, index) {
                          final item = procurementList[index];
                          // Assuming your _procurementItem needs the whole 'item' for details page navigation
                          return _procurementItem(
                            item.id,
                            item.spName,
                            item.sName,
                            item.requestDate.toString().substring(0, 10), // Format date
                            item.status,
                            context,
                          );
                        },
                      ),
                    ),
                  ),
                  // Request Procurement Button
                  Padding( // Add padding around the button container for spacing
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProcurementRequestPage()),
                        );

                        // Reload procurement list when returning
                        await loadProcurement();
                        setState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        // margin: const EdgeInsets.only(top: 10), // Margin can be handled by the Padding above
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
    );
  }

  // Procurement Item Widget
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
