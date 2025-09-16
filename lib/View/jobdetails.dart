import 'package:flutter/material.dart';
import '../Model/workload_model.dart';
import '../Controls/workload_controller.dart';
import 'editjob.dart';

class Jobdetails extends StatelessWidget {
  final WorkloadModel work;
  final WorkloadController controller; // Added controller parameter

  const Jobdetails({super.key, required this.work, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          // Header section with back button, title, and edit icon
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Text(
                    "Work Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditJobPage(controller: controller, work: work),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Main content container with a white background and rounded corners
          Positioned.fill(
            top: 100,
            child: Container(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Name Section
                    const SizedBox(height: 10),
                    const Text(
                      "Customer Name :",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      work.customerName ?? "Unknown",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Section
                    const Text(
                      "Vehicle :",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${work.vehicleMake ?? ''} ${work.vehicleModel ?? ''}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "VIN: ${work.vehicleVIN ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Description Section
                    const Text(
                      "Description :",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      work.description ?? "No description available",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Assigned Mechanic Section
                    const Text(
                      "Assigned Mechanic :",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      work.mechanicName ?? "Unknown",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Date Section
                    const Text(
                      "Date :",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      work.date ?? "Unknown",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Time Section
                    const Text(
                      "Time :",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      work.time ?? "Unknown",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
