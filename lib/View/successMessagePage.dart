import 'package:flutter/material.dart';
import 'dart:async';

class ProcurementSuccessPage extends StatefulWidget {
  final String message;

  const ProcurementSuccessPage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  _ProcurementSuccessPageState createState() => _ProcurementSuccessPageState();
}

class _ProcurementSuccessPageState extends State<ProcurementSuccessPage> {
  int dotCount = 0;
  bool showMessage = false;
  final Color customColor = const Color(0xFFDFF7E2);

  @override
  void initState() {
    super.initState();

    // Animate dots one by one
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (dotCount < 3) {
        setState(() {
          dotCount++;
        });
      } else {
        timer.cancel();
        setState(() {
          showMessage = true;
        });

        // Auto navigate back after 1 second
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: customColor, width: 3),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedOpacity(
                      opacity: dotCount > index ? 1 : 0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeIn,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: customColor,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (showMessage)
              Text(
                "${widget.message}\nHas Been Submitted\nSuccessfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: customColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
