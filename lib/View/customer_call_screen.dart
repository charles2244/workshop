// customer_call_screen.dart - Updated with Figma color scheme
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controls/crm_service.dart';
import '../Model/call_log.dart';
import '../Model/customer.dart';

class CustomerCallScreen extends StatefulWidget {
  final Customer customer;

  const CustomerCallScreen({Key? key, required this.customer}) : super(key: key);

  @override
  _CustomerCallScreenState createState() => _CustomerCallScreenState();
}

class _CustomerCallScreenState extends State<CustomerCallScreen> {
  final CrmService _crmService = CrmService();
  List<CallLog> _callLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCallLogs();
  }

  Future<void> _loadCallLogs() async {
    try {
      final logs = await _crmService.getCustomerCallLogs(widget.customer.id!);
      setState(() {
        _callLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        _addCallLog('outgoing');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: $e')),
      );
    }
  }

  Future<void> _addCallLog(String callType) async {
    try {
      final callLog = CallLog(
        customerId: widget.customer.id,
        callDate: DateTime.now(),
        callType: callType,
        duration: callType == 'missed' ? null : 120,
        notes: 'Call ${callType == 'outgoing' ? 'made to' : 'received from'} customer',
        createdAt: DateTime.now(),
      );

      await _crmService.addCallLog(callLog);
      _loadCallLogs();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Call log added successfully'),
          backgroundColor: Color(0xFF2A9D8F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding call log: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3B4C68), // Dark blue background from Figma
      appBar: AppBar(
        title: Text('Call', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF3B4C68),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Name Header
          Container(
            padding: EdgeInsets.all(24),
            child: Text(
              widget.customer.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Call Log Section
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Call Log',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_isLoading)
                    Expanded(
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F))),
                    )
                  else if (_callLogs.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No call history',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _callLogs.length,
                        itemBuilder: (context, index) {
                          final log = _callLogs[index];
                          return _buildCallLogItem(log);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Call Button
          Container(
            margin: EdgeInsets.all(32),
            child: Container(
              width: 80,
              height: 80,
              child: ElevatedButton(
                onPressed: () => _makePhoneCall(widget.customer.phoneNumber),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B4C68), // Dark blue to match theme
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: Text(
                  'Call',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallLogItem(CallLog log) {
    IconData callIcon;
    Color iconColor;

    switch (log.callType) {
      case 'outgoing':
        callIcon = Icons.call_made;
        iconColor = Color(0xFF2A9D8F);
        break;
      case 'incoming':
        callIcon = Icons.call_received;
        iconColor = Colors.blue[600]!;
        break;
      case 'missed':
        callIcon = Icons.call_received;
        iconColor = Colors.red[400]!;
        break;
      default:
        callIcon = Icons.phone;
        iconColor = Colors.grey[500]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(callIcon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMM').format(log.callDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(log.callDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (log.duration != null)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      _formatDuration(log.duration!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')} min';
    }
    return '${seconds}s';
  }
}