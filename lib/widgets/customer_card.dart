import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/models/customer_model.dart';
import 'package:public_commodity_distribution/widgets/customer_detail.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({super.key, required this.customer});

  String _modifyWoreda(String woreda) {
    return woreda.split(' ').take(2).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      height: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.phone,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => CustomerDetail(customer: customer),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 100),
              Text(
                _modifyWoreda(customer.woreda.name),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              Text(
                customer.gender,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              Text(
                '${customer.age} yrs',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
