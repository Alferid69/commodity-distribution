import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/allocations_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/allocation_model.dart';
import 'package:public_commodity_distribution/widgets/allocation_card.dart';
import 'package:public_commodity_distribution/widgets/new_allocation.dart';

class AllocationsScreen extends StatefulWidget {
  const AllocationsScreen({super.key});

  @override
  State<AllocationsScreen> createState() => _AllocationsScreenState();
}

class _AllocationsScreenState extends State<AllocationsScreen> {
  Future<bool> _fetchAllocationsFuture = Future.value(false);

  final String token = prefs.getString('auth_token') ?? '';
  final String role = prefs.getString('role') ?? '';
  final String worksAt = prefs.getString('worksAt') ?? '';
  final List<Allocation> _allocations = [];

  Future<bool> _getAllocations() async {
    try {
      var data;
      if (role == 'RetailerCooperative') {
        data = await AllocationsApi.getAllocationsToRetailerCooperative(
          token: token,
          id: worksAt,
        );
      }

      else if(role == 'WoredaOffice'){
        data = await AllocationsApi.getAllocationsByWoreda(token: token, id: worksAt);
      }

      else if(role == 'TradeBureau' || role == 'SubCityOffice'){
        data = await AllocationsApi.getAllocations(token: token);
      }

      setState(() {
        _allocations.addAll(Allocation.fromListJson(data['data']));
      });
      
      return true;
    } catch (e) {
      print('Error getting allocations: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAllocationsFuture = _getAllocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Allocations')),
      body: FutureBuilder(
        future: _fetchAllocationsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (_allocations.isEmpty) {
              return const Center(child: Text('No Allocations Found'));
            }
            _allocations.sort((a, b) => b.date.compareTo(a.date));
            return ListView.builder(
              itemCount: _allocations.length,
              itemBuilder: (ctx, index) =>
                  AllocationCard(allocation: _allocations[index]),
            );
          }
        },
      ),

      floatingActionButton: role == 'TradeBureau'
          ? FloatingActionButton(onPressed: () {
            Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (ctx) => NewAllocation()));
          }, child: Icon(Icons.add))
          : null,
    );
  }
}
