import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/models/customer_model.dart';

class CustomerDetail extends StatelessWidget {
  final Customer customer;

  const CustomerDetail({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.teal[100],
                        child: const Icon(Icons.person, size: 40, color: Colors.teal),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customer.phone,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Status: ${customer.status}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Customer Details Cards
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text(
                    'Woreda',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                  ),
                  subtitle: Text(customer.woreda.name),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text(
                    'Age',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                  ),
                  subtitle: Text('${customer.age} yrs'),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text(
                    'Gender',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                  ),
                  subtitle: Text(customer.gender),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text(
                    'House No / Ketena',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                  ),
                  subtitle: Text('${customer.houseNo} / ${customer.ketena}'),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text(
                    'Number of Family Members',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                  ),
                  subtitle: Text('${customer.numberOfFamilyMembers}'),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text(
                    'Purchased Commodities',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                  ),
                  subtitle: Text(
                      customer.purchasedCommodities.isEmpty
                          ? 'None'
                          : customer.purchasedCommodities.join(', ')),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text(
                    'Last Transaction Date',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                  ),
                  subtitle: Text(customer.lastTransactionDate != null
                      ? customer.lastTransactionDate!.toLocal().toString()
                      : 'No transactions yet'),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text(
                    'Updated At',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                  ),
                  subtitle: Text(customer.updatedAt != null
                      ? customer.updatedAt!.toLocal().toString()
                      : 'Not available'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
