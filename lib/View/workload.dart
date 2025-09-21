import 'package:flutter/material.dart';
import 'package:workshop_manager/View/work_scheduller.dart';
import '../Controls/workload_controller.dart';
import '../Model/workload_model.dart';
import 'inventory.dart';
import 'invoice_management_screen.dart';
import 'main.dart';
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
  int _selectedIndex = 4;
  String _currentFilter = 'All'; // Default filter
  List<WorkloadModel> _filteredWorkloads = [];

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

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  List<WorkloadModel> _getFilteredWorkloads(List<WorkloadModel> workloads) {
    List<WorkloadModel> filtered = List.from(workloads);
    
    switch (_currentFilter) {
      case 'Most Available':
        filtered.sort((a, b) {
          int aJobs = a.jobsCompleted ?? 0;
          int bJobs = b.jobsCompleted ?? 0;
          return aJobs.compareTo(bJobs); // Sort by least jobs (most available)
        });
        break;
      case 'Least Available':
        filtered.sort((a, b) {
          int aJobs = a.jobsCompleted ?? 0;
          int bJobs = b.jobsCompleted ?? 0;
          return bJobs.compareTo(aJobs); // Sort by most jobs (least available)
        });
        break;
      case 'Alphabetical':
        filtered.sort((a, b) {
          String aName = a.mechanicName ?? "Unknown";
          String bName = b.mechanicName ?? "Unknown";
          return aName.compareTo(bName);
        });
        break;
      case 'Full Workload':
        filtered = filtered.where((workload) {
          int jobsCompleted = workload.jobsCompleted ?? 0;
          return jobsCompleted >= 5; // Full workload
        }).toList();
        break;
      case 'Available':
        filtered = filtered.where((workload) {
          int jobsCompleted = workload.jobsCompleted ?? 0;
          return jobsCompleted < 5; // Available
        }).toList();
        break;
      case 'All':
      default:
        // No filtering, keep original order
        break;
    }
    
    return filtered;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter & Sort Workload',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            ...['All', 'Most Available', 'Least Available', 'Alphabetical', 'Full Workload', 'Available']
                .map((filter) => ListTile(
                      title: Text(filter),
                      trailing: _currentFilter == filter
                          ? const Icon(Icons.check, color: Color(0xFF2C3E50))
                          : null,
                      onTap: () {
                        _applyFilter(filter);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
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
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InvoiceManagementScreen()),
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
                    child: Row(
                      children: [
                        Expanded(
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
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _showFilterBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              color: _currentFilter != 'All' ? const Color(0xFF2C3E50).withOpacity(0.1) : Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.filter_list, color: Color(0xFF2C3E50)),
                                const SizedBox(width: 8),
                                Text(
                                  _currentFilter,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                        final filteredWorkloads = _getFilteredWorkloads(workloads);
                        
                        if (filteredWorkloads.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No workloads found with current filter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try changing the filter or date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return DataTable(
                          headingRowColor: WidgetStateProperty.all(Color(0xFF2C3E50)),
                          columns: const [
                            DataColumn(label: Text('Name', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('Jobs', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('Status', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('Details' , style: TextStyle(color: Colors.white))),
                          ],
                          rows: filteredWorkloads.map((workload) {
                        int jobsCompleted = workload.jobsCompleted ?? 0;
                        int totalJobs = 5;

                        //Status coloring logic
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
            icon: Icon(Icons.receipt),
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
}
