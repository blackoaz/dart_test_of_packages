// ignore_for_file: use_build_context_synchronously

import 'package:face_id/screens/Homepage.dart';
import 'package:face_id/screens/alternate_login.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face ID Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyFaceId(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class MyFaceId extends StatefulWidget {
  const MyFaceId({super.key});

  @override
  State<MyFaceId> createState() => _MyFaceIdState();
}

class _MyFaceIdState extends State<MyFaceId> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _authStatus = "Not Authenticated";

  Future<void> _authenticate() async {
    try {
      bool isAvailable = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        setState(() {
          _authStatus = "Face ID not available on this device";
        });
        return;
      }

      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate using Face ID',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      setState(() {
        _authStatus = isAuthenticated ? "Authenticated Successfully" : "Authentication Failed";
      });

      if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to Home if success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed, please try again')),
        );
        Navigator.pushReplacementNamed(context, '/login'); // Navigate to Login if failed
      }
    } catch (e) {
      setState(() {
        _authStatus = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face ID Authentication')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_authStatus, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: const Text('Authenticate with Face ID'),
            ),
          ],
        ),
      ),
    );
  }
}

