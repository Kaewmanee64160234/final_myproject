import 'package:flutter/material.dart';
import 'package:identity_scan/model/front/id_card.dart';

class FrontResultView extends StatefulWidget {
  final ID_CARD idCard;

  const FrontResultView({super.key, required this.idCard});

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
        children: [
          Center(child: Text("ID Card: ${widget.idCard.idNumber}")),
          Center(child: Text("FullName : ${widget.idCard.th.fullName}")),
          Center(child: Text("Address : ${widget.idCard.th.address.full}")),
        ],
      ),
    );
  }
}
