import 'package:flutter/material.dart';

class ReturnToggle extends StatelessWidget {
  final bool showPercentage;
  final VoidCallback toggleReturn;
  const ReturnToggle({
    super.key,
    required this.showPercentage,
    required this.toggleReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Returns: "),
        Switch(
          value: showPercentage,
          onChanged: (_) => toggleReturn(),
          activeColor: Colors.blue,
          inactiveThumbColor: Colors.orange,
        ),
        Text(showPercentage ? "Percentage" : "Amount"),
      ],
    );
  }
}
