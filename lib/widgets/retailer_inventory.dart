import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/retailer_cooperatives_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/inventory_model.dart';

class RetailerInventory extends StatefulWidget {
  const RetailerInventory({super.key});

  @override
  State<RetailerInventory> createState() => _RetailerInventoryState();
}

class _RetailerInventoryState extends State<RetailerInventory> {
  final _token = prefs.getString('auth_token');
  final _id = prefs.getString('worksAt');
  final List<Inventory> _availableCommodities = [];

  void _getRetailerCooperativeData() async {
    final data = await RetailerCooperativesApi.getRetailerCooperative(
      token: _token!,
      id: _id!,
    );

    setState(() {
      _availableCommodities.addAll(Inventory.fromJsonList(data['data']['availableCommodity']));
    });

    print('we have ${_availableCommodities.length} commodities');
  }

  @override
  void initState() {
    super.initState();
    _getRetailerCooperativeData();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_availableCommodities[0].commodity.name);
  }
}
