import 'package:flutter/material.dart';

class FrontResultView extends StatefulWidget {
  const FrontResultView({super.key});

  @override
  State<FrontResultView> createState() => _FrontResultViewState();
}

class _FrontResultViewState extends State<FrontResultView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result Front"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("Name"), Text("Surname")],
      ),
    );
  }
}
