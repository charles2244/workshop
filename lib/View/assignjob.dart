import 'package:flutter/material.dart';
import '../Controls/workload_controller.dart';
import '../Model/workload_model.dart';
import 'work_scheduller.dart';
import 'workload.dart';

class AssignJobPage extends StatelessWidget {
  final WorkloadController controller;
  final WorkloadModel work;

  const AssignJobPage({super.key, required this.controller, required this.work});

  @override
  Widget build(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();
    int? selectedMechanic;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
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
                    "Assign Job",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MonitorWorkloadPage(controller: controller),
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

                    const Text(
                      "Description :",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "Description",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Assigned Mechanic :",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: controller.fetchMechanics(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No mechanics available'));
                        }

                        final mechanics = snapshot.data!;

                        return FutureBuilder<List<bool>>(
                          future: Future.wait(mechanics.map((mechanic) async {
                            final isAvailable = await controller.isMechanicAvailable(mechanic['id'], work.date!, work.time!);
                            final totalJobs = mechanic['totalJobs'] ?? 0;
                            return isAvailable && totalJobs < 5;
                          }).toList()),
                          builder: (context, availabilitySnapshot) {
                            if (availabilitySnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (availabilitySnapshot.hasError) {
                              return Center(child: Text('Error: ${availabilitySnapshot.error}'));
                            } else if (!availabilitySnapshot.hasData || availabilitySnapshot.data!.isEmpty) {
                              return const Center(child: Text('No mechanics available'));
                            }

                            final availability = availabilitySnapshot.data!;

                            return DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              hint: const Text("Select Mechanic"),
                              items: mechanics.asMap().entries.map((entry) {
                                final mechanic = entry.value;
                                final isAvailable = availability[entry.key];
                                return DropdownMenuItem<int>(
                                  value: isAvailable ? mechanic['id'] : null,
                                  child: Text(
                                    mechanic['Name'],
                                    style: TextStyle(color: isAvailable ? Colors.black : Colors.grey),
                                  ),
                                  enabled: isAvailable,
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                selectedMechanic = newValue;
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

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

                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedMechanic != null && descriptionController.text.isNotEmpty) {
                            await controller.updateWorkDetails(
                              work.id,
                              selectedMechanic!,
                              descriptionController.text,
                            );
                            await controller.updateWorkStatus(work.id, "waiting");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Job assigned successfully!"),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.only(bottom: 100), // Adjust position
                              ),
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => WorkSchedulerPage(controller: controller),
                              ),
                              (route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Please fill all fields"),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.only(bottom: 100), // Adjust position
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF2C3E50),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Assign",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
