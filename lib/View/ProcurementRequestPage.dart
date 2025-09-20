import 'package:flutter/material.dart';
import 'package:workshop_manager/View/successMessagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controls/inventory_controller.dart';
import '../Model/spare_part_model.dart';

class ProcurementRequestPage extends StatefulWidget {
  const ProcurementRequestPage({Key? key}) : super(key: key);

  @override
  _ProcurementRequestPageState createState() => _ProcurementRequestPageState();
}

class _ProcurementRequestPageState extends State<ProcurementRequestPage> {
  final InventoryController controller = InventoryController();
  List<SparePart> spareParts = [];
  SparePart? selectedPart;
  DateTime selectedDate = DateTime.now();
  String? customPartName;
  bool isOtherSelected = false;
  final TextEditingController remarksController = TextEditingController();
  int selectedQuantity = 1;
  final TextEditingController _numberController = TextEditingController();
  late int userId;

  @override
  void initState() {
    super.initState();
    loadSpareParts();
    _numberController.text = selectedQuantity.toString();
    _loadUserId();
  }

  Future<void> loadSpareParts() async {
    final parts = await controller.fetchSpareParts();
    setState(() {
      spareParts = parts;
      if (spareParts.isNotEmpty) {
        selectedPart = spareParts.first;
      }
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('user_id');
    setState(() {
      userId = id!;
    });
    if (userId != null) {
      print('User ID: $userId');
      // Do something with userId
    } else {
      print('No user ID found');
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
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 100),
                const Text(
                  "Procurement",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Form Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Part Name"),
                    spareParts.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _buildPartDropdown(),
                    const SizedBox(height: 16),

                    _buildLabel("Quantity"),
                    _buildNumberInput(),
                    const SizedBox(height: 16),

                    _buildLabel("Required By"),
                    _buildDatePicker(context),
                    const SizedBox(height: 16),

                    _buildLabel("Remarks"),
                    _buildRemarksField(),
                    const SizedBox(height: 30),

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2c3e50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),

                        onPressed: () async {
                          final partName = isOtherSelected ? customPartName : selectedPart?.name;

                          if (partName == null || partName.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select or enter a spare part")),
                            );
                            return;
                          }

                          if (selectedQuantity == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Quantity cannot be zero.")),
                            );
                          }else {
                            await _showConfirmationDialog(
                              context,
                              partName,
                              selectedQuantity,
                              "${selectedDate.toLocal()}".split(' ')[0],
                              remarksController.text,
                                  () async {
                                int lastId1 = await controller
                                    .fetchProcurementId();
                                int newId1 = lastId1 + 1;

                                int lastId = await controller
                                    .fetchProcurementDetailId();
                                int newId = lastId + 1;

                                bool success = await controller
                                    .insertProcurement(
                                  procurementId1: newId1,
                                  spName: partName,
                                  sName: "- ",
                                  requestDate: selectedDate.toString(),
                                  status: "Pending",
                                  managerId: userId,
                                  procurementDetailId: newId,
                                  quantity: selectedQuantity,
                                  remarks: remarksController.text,
                                  receiveBy: null,
                                  receivedImage: null,
                                  procurementId: newId1,
                                );

                                if (success) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProcurementSuccessPage(message: "Procurement Request"),
                                    ),
                                  );

                                  setState(() {
                                    selectedPart = spareParts.isNotEmpty
                                        ? spareParts.first
                                        : null;
                                    selectedQuantity = 1;
                                    _numberController.text = "1";
                                    remarksController.clear();
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text(
                                        "Failed to submit request")),
                                  );
                                }

                                print(
                                    "Procurement submitted successfully with Procurement ID: $newId1 and Detail ID: $newId");
                              },
                            );
                          }
                        },
                        child: const Text(
                          "Submit Request",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF2c3e50),
      ),
    );
  }

  /// Dropdown for Spare Parts
  Widget _buildPartDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<dynamic>(
            value: isOtherSelected ? "Other" : selectedPart,
            isExpanded: true,
            underline: const SizedBox(),
            items: [
              ...spareParts.map(
                (part) => DropdownMenuItem(
                  value: part,
                  child: Text("${part.name} (Qty: ${part.qty})"),
                ),
              ),
              const DropdownMenuItem(value: "Other", child: Text("Other")),
            ],
            onChanged: (value) {
              setState(() {
                if (value == "Other") {
                  isOtherSelected = true;
                  selectedPart = null;
                } else {
                  isOtherSelected = false;
                  selectedPart = value;
                }
              });
            },
          ),
        ),

        if (isOtherSelected) ...[
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: "Enter new spare part name",
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => customPartName = val,
          ),
        ],
      ],
    );
  }

  Widget _buildNumberInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (value) {
                setState(() {
                  selectedQuantity = int.tryParse(value) ?? 0;
                });
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: const Icon(Icons.arrow_drop_up, size: 20),
                onTap: () {
                  setState(() {
                    selectedQuantity++;
                    _numberController.text = selectedQuantity.toString();
                  });
                },
              ),
              InkWell(
                child: const Icon(Icons.arrow_drop_down, size: 20),
                onTap: () {
                  setState(() {
                    if (selectedQuantity > 0) selectedQuantity--;
                    _numberController.text = selectedQuantity.toString();
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) setState(() => selectedDate = picked);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "${selectedDate.toLocal()}".split(' ')[0],
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// Remarks TextField
  Widget _buildRemarksField() {
    return TextField(
      controller: remarksController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "Enter remarks here...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String partName, int qty, String requiredBy, String remarks, Function onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Submit Request",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Please Review The Details Below. Is All The Information Correct?\n"),
              Text("Part Name: $partName", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Qty: $qty", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Required By: $requiredBy", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Remarks: $remarks", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      child: const Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
