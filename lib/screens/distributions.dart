import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/distributions_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/distribution_model.dart';
import 'package:public_commodity_distribution/widgets/distribution_card.dart';

class DistributionsScreen extends StatefulWidget {
  const DistributionsScreen({super.key});

  @override
  State<DistributionsScreen> createState() => _DistributionsScreenState();
}

class _DistributionsScreenState extends State<DistributionsScreen> {
  late Future<bool> _distributionFetchFuture;
  final token = prefs.getString('auth_token');
  final userRole = prefs.getString('role');
  final id = prefs.getString('worksAt');

  final List<Distribution> _distributions = [];
  Future<bool> _getDistributions() async {
    dynamic data;
    if (userRole == 'RetailerCooperativeShop') {
      data = await DistributionsApi.getReceivedDistributions(
        token: token!,
        id: id!,
      );
    } else {
      data = await DistributionsApi.getDistributions(token: token!);
    }

    setState(() {
      _distributions.addAll(Distribution.fromListJson(data['data']));
    });

    return true;
  }

  @override
  void initState() {
    super.initState();
    _distributionFetchFuture = _getDistributions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Distributions')),
      body: FutureBuilder(
        future: _distributionFetchFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to fetch. Try again"));
          } else {
            _distributions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ListView.builder(
              itemCount: _distributions.length,
              itemBuilder: (ctx, index) =>
                  DistributionCard(distribution: _distributions[index]),
            );
          }
        },
      ),
      floatingActionButton: userRole == 'RetailerCooperative'
          ? FloatingActionButton(onPressed: () {}, child: Icon(Icons.add))
          : null,
    );
  }
}
