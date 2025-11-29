import 'package:flutter/material.dart';

class CreateTransactionScreen extends StatefulWidget {
  final String beneficiaryId;
  const CreateTransactionScreen({super.key, required this.beneficiaryId});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Transaction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Beneficiary ID: ${widget.beneficiaryId}'),
            const SizedBox(height: 20),
            // TODO: Add form fields for transaction details
            ElevatedButton(
              onPressed: () {
                // TODO: Implement transaction creation logic
              },
              child: const Text('Create Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
