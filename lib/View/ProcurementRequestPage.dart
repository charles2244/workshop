import 'package:flutter/material.dart';
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
  int selectedQuantity = 5;
  final TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSpareParts();
    _numberController.text = selectedQuantity.toString();
  }

  /// Load spare parts from the database
  Future<void> loadSpareParts() async {
    final parts = await controller.fetchSpareParts();
    setState(() {
      spareParts = parts;
      if (spareParts.isNotEmpty) {
        selectedPart = spareParts.first; // Default to first item
      }
    });
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
                  onPressed: () => Navigator.pop(context),
                ),
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
                        : _buildPartDropdown(), // Show parts from DB
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
                          final partName =
                              isOtherSelected
                                  ? customPartName
                                  : selectedPart?.name;

                          if (partName == null || partName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please select or enter a spare part",
                                ),
                              ),
                            );
                            return;
                          }

                          int lastId1 = await controller.fetchProcurementId();
                          int newId1 = lastId1 + 1;

                          int lastId = await controller.fetchProcurementDetailId();
                          int newId = lastId + 1;

                          bool success = await controller.insertProcurement(
                            procurementId1: newId1,
                            spName: partName,
                            sName: "- ",
                            requestDate: selectedDate.toString(),
                            status: "Pending",
                            managerId: 5001,

                            procurementDetailId: newId,
                            quantity: selectedQuantity,
                            remarks: remarksController.text,
                            receiveBy: null,
                            receivedImage: null,
                            procurementId: newId1,
                          );

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Request submitted successfully!",
                                ),
                              ),
                            );

                            // Reset form
                            setState(() {
                              selectedPart =
                                  spareParts.isNotEmpty
                                      ? spareParts.first
                                      : null;
                              selectedQuantity = 1;
                              _numberController.text = "1";
                              remarksController.clear();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text("Failed to submit request"),
                              ),
                            );
                            print("Procurement submitted successfully with Procurement ID: $newId1 and Detail ID: $newId");
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

        // Show TextField if "Other" is selected
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
          // Number text field
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

          // Up/Down arrows
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

  /// Date Picker
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
}
