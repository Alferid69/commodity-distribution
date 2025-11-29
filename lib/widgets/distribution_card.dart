import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/distribution_model.dart';

class DistributionCard extends StatelessWidget {
  final Distribution distribution;

  const DistributionCard({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final userRole = prefs.getString('role');
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('To: ${distribution.retailerCooperativeShop.name}'),
              Text(distribution.status),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(distribution.commodity.name),
              Text(distribution.amount.toString()),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(distribution.createdAt.toIso8601String()),
              if (distribution.status != 'approved')
                if (userRole == 'RetailerCooperativeShop')
                  ElevatedButton(onPressed: () {}, child: Text('Approve')),
            ],
          ),
        ],
      ),
    );
  }
}
