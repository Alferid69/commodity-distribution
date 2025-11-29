import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/customers_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/customer_model.dart';
import 'package:public_commodity_distribution/widgets/customer_card.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final List<Customer> customers = [];
  var _isLoading = false;

  void _printCustomers() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final token = prefs.getString('auth_token');
      final data = await CustomersApi.fetchCustomers(token: token!);

      final customerss = Customer.fromJsonList(data['data']);
      customers.addAll(customerss);
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _printCustomers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: CircularProgressIndicator());

    if(!_isLoading && customers.isEmpty) {
      content = const Center(child: Text('No customers found.'));
    } else if(!_isLoading && customers.isNotEmpty) {
      content = ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return CustomerCard(customer: customer, key: Key(customer.id));
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Customers')),
      body: content
    );
  }
}
