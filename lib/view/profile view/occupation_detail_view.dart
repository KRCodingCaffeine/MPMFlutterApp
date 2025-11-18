import 'package:flutter/material.dart';

class OccupationDetailViewPage extends StatefulWidget {
  final String memberId;
  final String memberOccupationId;

  const OccupationDetailViewPage({
    Key? key,
    required this.memberId,
    required this.memberOccupationId,
  }) : super(key: key);

  @override
  State<OccupationDetailViewPage> createState() => _OccupationDetailViewPageState();
}

class _OccupationDetailViewPageState extends State<OccupationDetailViewPage> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Occupation Detail"),
      ),
      body: Center(
        child: Text(
          "Member ID: ${widget.memberId}\n"
              "Occupation ID: ${widget.memberOccupationId}",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
