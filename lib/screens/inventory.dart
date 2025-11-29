import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/widgets/retailer_inventory.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final userRole = prefs.getString('role');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory')),
      body: userRole == 'RetailerCooperative'
          ? RetailerInventory()
          : Center(child: Text('Inventory screen')),
    );
  }
}
