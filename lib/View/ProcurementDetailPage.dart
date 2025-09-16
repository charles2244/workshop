import 'package:flutter/material.dart';
import '../Controls/inventory_controller.dart';
import '../Model/procurementDetails.dart';

class ProcurementDetailPage extends StatelessWidget {
  final int procurementId;
  final String partName;
  final String requiredDate;
  final String status;

  const ProcurementDetailPage({
    super.key,
    required this.procurementId,
    required this.partName,
    required this.requiredDate,
    required this.status,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.grey;
      case "In Transit":
        return Colors.yellow.shade700;
      case "Completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = InventoryController();

    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50),
      body: FutureBuilder<List<ProcurementDetails>>(
        future: controller.fetchProcurementDetail(procurementId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No details found'));
          }

          final details = snapshot.data!.first;

          return Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
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

              // Content
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDetailItem("Part Name :", partName),
                      buildDetailItem("Quantity:", details.quantity.toString()),
                      buildDetailItem("Required By:", requiredDate),
                      buildDetailItem("Remarks:", details.remarks),
                      buildDetailItem("Received By:", details.receivedBy != null ? details.receivedBy!.toString() : '-'),
                      buildDetailItem(" ", details.receivedImage != null ? details.receivedImage!.toString() : '-'),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Status:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D3557),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: getStatusColor(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildDetailItem(String label, String value) {
    // Check if the value looks like an image URL
    bool isImage = value.startsWith("http") &&
        (value.endsWith(".webp") || value.endsWith(".jpg") || value.endsWith(".jpeg") || value.endsWith(".png") || value.endsWith(".gif"));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 4),
          isImage
              ? Image.network(
            value,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Text("Image failed to load");
            },
          )
              : Text(value),
        ],
      ),
    );
  }
}
