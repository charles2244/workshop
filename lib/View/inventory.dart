import 'package:flutter/material.dart';
import 'package:workshop_manager/View/procurementList.dart';
import 'package:workshop_manager/View/work_scheduller.dart';
import 'main.dart'; // Import your home page
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
  int _selectedIndex = 4;

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
      final procurements = await controller.fetchProcurementList();
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
      });
    }
  }

  void _sortSparePartsByQuantity() {
    setState(() {
      if (_sortAscendingByQty) {
        spareParts.sort((a, b) => a.qty.compareTo(b.qty));
      } else {
        spareParts.sort((a, b) => b.qty.compareTo(a.qty));
      }
      _sortAscendingByQty = !_sortAscendingByQty;
    });
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                _summaryCard(0, "Parts In Stock", spareParts.length.toString(), context, () async {
                  await loadSpareParts();
                  setState(() {});
                }),
                const SizedBox(width: 16),
                _summaryCard(1, "Procurement Req.", isLoadingProcurements ? "0" : procurementRequestCount.toString(), context, () async {
                  await loadProcurementCount();
                  setState(() {});
                }),
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
                        InkWell(
                          onTap: _sortSparePartsByQuantity,
                          child: Row(
                            children: const [
                              Text("Qty", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 5),
                              Icon(Icons.swap_vert, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
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

  Widget _summaryCard(
      int isProcurement,
      String title,
      String value,
      BuildContext context,
      Future<void> Function()? onRefresh,
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
            await onRefresh();
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
