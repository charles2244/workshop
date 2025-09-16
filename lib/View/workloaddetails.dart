import 'package:flutter/material.dart';
import '../Controls/workload_controller.dart';
import '../Model/workload_model.dart';
import 'jobdetails.dart';

class WorkloadDetailsPage extends StatelessWidget {
  final DateTime selectedDate;
  final WorkloadController controller;
  final String mechanic;

  const WorkloadDetailsPage({
    super.key,
    required this.selectedDate,
    required this.controller,
    required this.mechanic,
  });

  Future<List<WorkloadModel>> _fetchWorks() async {
    final allWorks = await controller.fetchWorksForDateWithDetails(selectedDate);
    return allWorks.where((work) => work.mechanicName == mechanic).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "in progress":
        return Colors.orange;
      case "waiting":
        return Colors.purple;
      case "pending":
        return Colors.red;
      case "no show":
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workload Details for $mechanic"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<WorkloadModel>>(
        future: _fetchWorks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No works available for the selected date."));
          }

          final works = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work = works[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.build, color: Colors.grey),
                  title: Text("${work.time} - ${work.vehicleMake} ${work.vehicleModel}"),
                  subtitle: Text("Assigned To: ${work.mechanicName}"),
                  trailing: Text(
                    work.status,
                    style: TextStyle(
                      color: _getStatusColor(work.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Jobdetails(work: work, controller: controller),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}