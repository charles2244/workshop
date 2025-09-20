import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:math';
import '../Controls/User_control.dart';
import 'main.dart';

class FingerprintLoginScreen extends StatefulWidget {
  @override
  _FingerprintLoginScreenState createState() => _FingerprintLoginScreenState();
}

class _FingerprintLoginScreenState extends State<FingerprintLoginScreen> {
  final LocalAuthentication localAuth = LocalAuthentication();
  bool _loading = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please scan your fingerprint to continue',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('user_id');
        if (userId == null) {
          userId = 5001; // generate or assign user ID here
          await prefs.setInt('user_id', userId);
          await UserController().insertManager(id: userId);
        }
        print('Existing user ID: $userId');
        setState(() {
          _authenticated = true;
        });
      }
    } catch (e) {
      print('Authentication error: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_authenticated) {
      return MyApp();
    }

    return const Scaffold(
      body: Center(child: Text('Authentication Failed')),
    );
  }
}