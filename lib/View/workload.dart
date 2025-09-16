import 'package:flutter/material.dart';
import '../Controls/workload_controller.dart';
import '../Model/workload_model.dart';
import 'workloaddetails.dart';

class MonitorWorkloadPage extends StatefulWidget {
  final WorkloadController controller;

  const MonitorWorkloadPage({Key? key, required this.controller}) : super(key: key);

  @override
  _MonitorWorkloadPageState createState() => _MonitorWorkloadPageState();
}

class _MonitorWorkloadPageState extends State<MonitorWorkloadPage> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<WorkloadModel>> _workloads;

  @override
  void initState() {
    super.initState();
    _loadWorkloads();
  }

  void _loadWorkloads() {
    setState(() {
      _workloads = widget.controller.fetchWorkloadsForDate(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    "Monitor Workload",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.person, color: Colors.white),
                ],
              ),
            ),
          ),
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _selectedDate = selectedDate;
                          });
                          _loadWorkloads();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.toLocal()}'.split(' ')[0],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.calendar_month, color: Color(0xFF2C3E50)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<WorkloadModel>>(
                      future: _workloads,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No workloads found'));
                        }

                        final workloads = snapshot.data!;
                    return DataTable(
                      headingRowColor: MaterialStateProperty.all(Color(0xFF2C3E50)),
                      columns: const [
                        DataColumn(label: Text('Name', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Jobs', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Status', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Details' , style: TextStyle(color: Colors.white))),
                      ],
                      rows: workloads.map((workload) {
                        int jobsCompleted = workload.jobsCompleted ?? 0;
                        int totalJobs = 5; // ✅ always 5 jobs max per mechanic

                        // --- Status coloring logic ---
                        Color statusColor;
                        String status;

                        if (jobsCompleted >= totalJobs) {
                          status = "Full";
                          statusColor = Colors.red;
                        } else if (jobsCompleted >= 3) {
                          status = "Available";
                          statusColor = Colors.orange;
                        } else {
                          status = "Available";
                          statusColor = Colors.green;
                        }

                        return DataRow(
                          cells: [
                            DataCell(Text(workload.mechanicName ?? "Unknown")),
                            DataCell(Text('$jobsCompleted/$totalJobs')),
                            DataCell(Text(
                              status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            )),
                            DataCell(
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WorkloadDetailsPage(
                                            selectedDate: _selectedDate,
                                            controller: widget.controller,
                                            mechanic: workload.mechanicName ?? "Unknown",
                                          ),
                                    ),
                                  );
                                },
                                child: const Text("View"),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
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
}
