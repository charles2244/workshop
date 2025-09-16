import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inventory.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kebauzussqhnrzptfksi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtlYmF1enVzc3FobnJ6cHRma3NpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczMjc1MjcsImV4cCI6MjA3MjkwMzUyN30._ySYgOlA6cR_X3nXFDzsX7i-j2j86sQ0HrOYQbpHtVk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c3e50),
      body: Column(
        children: [
          SizedBox(height: 50),
          // Top section (Logo + Company Name)
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

          // Container for Job Management + Grid
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
                            InventoryPage(),
                          ),
                          menuButton(
                            context,
                            Image.asset(
                              'assets/images/warehouse(2).png',
                              width: 50,
                              height: 50,
                            ),
                            'Work\nScheduler',
                            InventoryPage(),
                          ),
                          menuButton(
                            context,
                            Image.asset(
                              'assets/images/warehouse(2).png',
                              width: 50,
                              height: 50,
                            ),
                            'Staff\nWorkload',
                            InventoryPage(),
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
                            'Work\nScheduler',
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
                            InventoryPage(),
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
