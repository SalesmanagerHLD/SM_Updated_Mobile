import 'package:flutter/material.dart';

/// Shown only while [AuthNotifier] is hydrating the stored session at boot
/// - go_router's redirect (see app.dart) moves away from this the moment
/// that resolves, to either /login or /home.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
