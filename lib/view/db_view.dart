import 'package:flutter/material.dart';
import 'package:identity_scan/db/db_helper.dart';

class DbView extends StatefulWidget {
  const DbView({super.key});

  @override
  State<DbView> createState() => _DbViewState();
}

class _DbViewState extends State<DbView> {
  DatabaseHelper dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: (() {
              dbHelper.selectData();
            }),
            child: Text("Select"))
      ],
    ));
  }
}
