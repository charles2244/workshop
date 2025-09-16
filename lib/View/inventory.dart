import 'package:flutter/material.dart';
import 'package:workshop_manager/View/procurementList.dart';
import '../Controls/inventory_controller.dart';
import '../Model/spare_part_model.dart';
import 'SparePartDetailPage.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryController controller = InventoryController();
  List<SparePart> spareParts = [];
  int procurementRequestCount = 0;
  bool isLoadingProcurements = true;
  bool isLoading = true;
  bool _sortAscendingByQty = true;

  @override
  void initState() {
    super.initState();
    loadProcurementCount();
    loadSpareParts();
  }

  Future<void> loadSpareParts() async {
    final parts = await controller.fetchSpareParts();
    setState(() {
      spareParts = parts;
      isLoading = false;
    });
  }

  Future<void> loadProcurementCount() async {
    if (!mounted) return;
    setState(() {
      isLoadingProcurements = true;
    });
    try {
      // Assuming your controller has a method to fetch all procurements
      // or a method to get just the count.
      // If it fetches all procurements:
      final procurements = await controller.fetchProcurementList(); // Example method
      if (!mounted) return;
      setState(() {
        procurementRequestCount = procurements.length;
        isLoadingProcurements = false;
      });
    } catch (e) {
      if (!mounted) return;
      print("Error loading procurement count: $e");
      setState(() {
        isLoadingProcurements = false;
        // Optionally set procurementRequestCount to 0 or handle error display
      });
    }
  }

  void _sortSparePartsByQuantity() {
    setState(() {
      if (_sortAscendingByQty) {
        spareParts.sort((a, b) => a.qty.compareTo(b.qty)); // Sort ascending
      } else {
        spareParts.sort((a, b) => b.qty.compareTo(a.qty)); // Sort descending
      }
      _sortAscendingByQty = !_sortAscendingByQty; // Toggle for next click
      // If you want to rotate through ascending, descending, and unsorted,
      // you'll need more complex logic for the toggle.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50),
      body: Column(
        children: [
          // Top Bar
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 120),
              const Text(
                'Inventory',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Summary Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                _summaryCard(0, "Parts In Stock", spareParts.length.toString(), context, () async {
                await loadSpareParts();
                setState(() {});
                },),
                const SizedBox(width: 16),
                _summaryCard(1, "Procurement Req.", isLoadingProcurements ? "0" : procurementRequestCount.toString(), context, () async {
                  await loadProcurementCount();
                  setState(() {});
                },),
              ],
            ),
          ),

          // Spare Parts Container
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column( // Added Column to hold header and ListView
                children: [
                  // Spare Parts Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.settings, size: 18),
                            SizedBox(width: 5),
                            Text(
                              "Spare Parts",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        InkWell( // Wrap the Row containing Qty and Icon with InkWell
                          onTap: _sortSparePartsByQuantity, // Call sort method on tap
                          child: Row(
                            children: [
                              Text("Qty", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 5),
                              Icon(
                                Icons.swap_vert,
                                size: 18,
                                // Optionally change icon based on sort direction
                                // color: _sortAscendingByQty ? Colors.blue : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Existing ListView or Loading Indicator
                  Expanded( // Added Expanded so ListView takes remaining space
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: spareParts.length,
                      itemBuilder: (context, index) {
                        final part = spareParts[index];
                        return _sparePartItem(context, part);
                      },
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

  // Summary Card Widget
  Widget _summaryCard(
      int isProcurement,
      String title,
      String value,
      BuildContext context,
      Future<void> Function()? onRefresh, // New callback
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: isProcurement == 1
            ? () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProcurementPage()),
          );

          if (result == 'refresh' && onRefresh != null) {
            await onRefresh(); // Call the callback
          }
        }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }


  // Spare Part Item Widget
  static Widget _sparePartItem(BuildContext context, SparePart part) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SparePartDetailPage(
              sparePartId: part.id,
              name: part.name,
              qty: part.qty,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue.shade100,
              child: Image.network(part.imageUrl, width: 24, height: 24, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(part.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text("Location: ${part.location}",
                      style: const TextStyle(fontSize: 12, color: Colors.black)),
                ],
              ),
            ),
            Text(part.qty.toString(),
                style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
