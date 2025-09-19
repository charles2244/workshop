import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workshop_manager/View/work_scheduller.dart';
import 'package:workshop_manager/View/workload.dart';
import 'vehicle.dart';
import 'inventory.dart'; // Assuming InventoryPage is correctly defined
import '../Controls/workload_controller.dart';
import 'login.dart';

late WorkloadController workloadController;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kebauzussqhnrzptfksi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtlYmF1enVzc3FobnJ6cHRma3NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczMjc1MjcsImV4cCI6MjA3MjkwMzUyN30._ySYgOlA6cR_X3nXFDzsX7i-j2j86sQ0HrOYQbpHtVk',
  );

  workloadController = WorkloadController(
      'https://kebauzussqhnrzptfksi.supabase.co', // Or Supabase.instance.supabaseUrl if available and preferred
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtlYmF1enVzc3FobnJ6cHRma3NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczMjc1MjcsImV4cCI6MjA3MjkwMzUyN30._ySYgOlA6cR_X3nXFDzsX7i-j2j86sQ0HrOYQbpHtVk' // Or Supabase.instance.supabaseAnonKey
  );

  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FingerprintLoginScreen(),
    );
  }
}
class MyApp extends StatelessWidget {

  const MyApp({super.key,});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(controller: workloadController),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final WorkloadController controller;

  const MyHomePage({super.key, required this.controller,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
                child: Image.asset('assets/images/GS_logo.png', width: 100),
              ),
              const SizedBox(height: 10),
              const Text(
                'Greenstem Business\nSoftware Sdn Bhd',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Job Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        children: [
                          menuButton(
                            context,
                            Image.asset(
                              'assets/images/warehouse(2).png',
                              width: 50,
                              height: 50,
                            ),
                            'Vehicle\nManagement',
                            CustomersPage(),
                          ),
                          menuButton(
                            context,
                            Image.asset(
                              'assets/images/warehouse(2).png',
                              width: 50,
                              height: 50,
                            ),
                            'Work\nScheduler',
                            // Now 'controller' refers to the instance passed to MyHomePage
                            WorkSchedulerPage(controller: controller),
                          ),
                          menuButton(
                            context,
                            Image.asset(
                              'assets/images/warehouse(2).png',
                              width: 50,
                              height: 50,
                            ),
                            'Staff\nWorkload',
                            MonitorWorkloadPage(controller: controller,),
                          ),
                          menuButton(
                            context,
                            Image.asset(
                              'assets/images/warehouse(2).png',
                              width: 50,
                              height: 50,
                            ),
                            'Invoice\nManagement',
                            InventoryPage(),
                          ),
                          menuButton(
                            context,
                            Image.asset(
                              'assets/images/warehouse(2).png',
                              width: 50,
                              height: 50,
                            ),
                            'Inventory\nControl',
                            InventoryPage(),
                          ),
                          menuButton(
                            context,
                            Image.asset(
                              'assets/images/warehouse(2).png',
                              width: 50,
                              height: 50,
                            ),
                            'Customer Relationship\nManagement',
                            CustomersPage(),
                          ),
                        ],
                      ),
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

  static Widget menuButton(BuildContext context, Widget iconWidget, String label, Widget destinationPage,) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2c3e50), // dark blue
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationPage),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget, // Image.asset or Icon widget
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
