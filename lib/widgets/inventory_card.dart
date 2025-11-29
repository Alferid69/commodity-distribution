import 'package:flutter/material.dart';

class InventoryCard extends StatelessWidget {
  const InventoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Text('[item name]'),
        Text('[amount-unit]'),
        Text('[data]')
      ],),
    );
  }
}
