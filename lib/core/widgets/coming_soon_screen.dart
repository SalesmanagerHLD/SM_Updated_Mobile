import 'package:flutter/material.dart';

/// Placeholder for a route whose real screen lands in a later phase — keeps
/// navigation wired end-to-end now instead of leaving a dead link.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.phase});

  final String title;
  final String phase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title lands in $phase')),
    );
  }
}
