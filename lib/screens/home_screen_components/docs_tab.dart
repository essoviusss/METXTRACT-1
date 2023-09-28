import 'package:flutter/material.dart';

class DocsTab extends StatefulWidget {
  const DocsTab({super.key});

  @override
  State<DocsTab> createState() => _DocsTabState();
}

class _DocsTabState extends State<DocsTab> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Docs Tab"),
      ),
    );
  }
}
