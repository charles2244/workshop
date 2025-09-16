import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Controls/workload_controller.dart';
import '../Model/workload_model.dart';
import 'jobdetails.dart';
import 'assignjob.dart';
import 'workload.dart';

class WorkSchedulerPage extends StatefulWidget {
  final WorkloadController controller;

  const WorkSchedulerPage({super.key, required this.controller});

  @override
  _WorkSchedulerPageState createState() => _WorkSchedulerPageState();
}

class _WorkSchedulerPageState extends State<WorkSchedulerPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Future<List<WorkloadModel>> _works;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadWorks();
  }

  void _loadWorks() {
    setState(() {
      _works = widget.controller.fetchWorksForDateWithDetails(_selectedDay!);
    });
  }

  void _navigateBasedOnStatus(BuildContext context, WorkloadModel work) {
    final normalizedStatus = work.status.toLowerCase();
    if (normalizedStatus == "completed" || normalizedStatus == "in progress" || normalizedStatus == "waiting" || normalizedStatus == "no show") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Jobdetails(work: work, controller: widget.controller),
        ),
      );
    } else if (normalizedStatus == "pending") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssignJobPage(controller: widget.controller, work: work),
        ),
      );
    }
  }

Color _getStatusColor(String status) {
  switch (status) {
    case "completed":
      return Colors.green;
    case "in Progress":
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
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          // 🔹 Header
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    "Work Scheduler",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MonitorWorkloadPage(controller: widget.controller),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Calendar + Jobs
          Positioned.fill(
            top: 100,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _loadWorks();
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(color: Color(0xFF2C3E50), shape: BoxShape.circle),
                      selectedDecoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Jobs List (scrollable)
                  Expanded(
                    child: FutureBuilder<List<WorkloadModel>>(
                      future: _works,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No jobs found"));
                        }

                        final works = snapshot.data!;

                        // 🔹 Sort jobs by time
                        works.sort((a, b) {
                          if (a.time == null || b.time == null) return 0;
                          return a.time!.compareTo(b.time!);
                        });

                        // 🔹 Override DB status with "In Progress" if within 2 hours, or "Completed" if past 2 hours
                        DateTime now = DateTime.now();
                        for (var work in works) {
                          if (work.time != null) {
                            try {
                              final parts = work.time!.split(":");
                              final int hour = int.parse(parts[0]);
                              final int minute = int.parse(parts[1]);

                              DateTime start = DateTime(
                                _selectedDay!.year,
                                _selectedDay!.month,
                                _selectedDay!.day,
                                hour,
                                minute,
                              );

                              DateTime end = start.add(const Duration(hours: 2));

                              if (now.isAfter(start) && now.isBefore(end)) {
                                final updatedWork = WorkloadModel(
                                  id: work.id,
                                  mechanicName: work.mechanicName,
                                  jobsCompleted: work.jobsCompleted,
                                  totalJobs: work.totalJobs,
                                  status: "In Progress",
                                  vehicleId: work.vehicleId,
                                  vehicleMake: work.vehicleMake,
                                  vehicleModel: work.vehicleModel,
                                  customerName: work.customerName,
                                  date: work.date,
                                  time: work.time,
                                );
                                work = updatedWork;
                              } else if (now.isAfter(end)) {
                                final updatedWork = WorkloadModel(
                                  id: work.id,
                                  mechanicName: work.mechanicName,
                                  jobsCompleted: work.jobsCompleted,
                                  totalJobs: work.totalJobs,
                                  status: "completed",
                                  vehicleId: work.vehicleId,
                                  vehicleMake: work.vehicleMake,
                                  vehicleModel: work.vehicleModel,
                                  customerName: work.customerName,
                                  date: work.date,
                                  time: work.time,
                                );
                                work = updatedWork;
                              }
                            } catch (e) {
                              debugPrint("Time parse error: ${work.time}");
                            }
                          }
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: works.length,
                          itemBuilder: (context, index) {
                            final work = works[index];
                            return GestureDetector(
                              onTap: () => _navigateBasedOnStatus(context, work),
                              child: Card(
                                color: const Color(0xFFE5E9ED),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  leading: const Icon(Icons.build, color: Colors.grey),
                                  title: Text("${work.time} - ${work.vehicleMake ?? ''} ${work.vehicleModel ?? ''}"),
                                  subtitle: Text("Assigned To: ${work.mechanicName ?? 'Unknown'}"),
                                  trailing: Text(
                                    work.status,
                                    style: TextStyle(color: _getStatusColor(work.status), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          },
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
