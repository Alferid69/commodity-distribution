import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/allocations_api.dart';
import 'package:public_commodity_distribution/api/commodities_api.dart';
import 'package:public_commodity_distribution/api/retailer_cooperatives_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/commodities_model.dart';
import 'package:public_commodity_distribution/models/retailer_cooperative_model.dart';

class NewAllocation extends StatefulWidget {
  const NewAllocation({super.key});

  @override
  State<NewAllocation> createState() => _NewAllocationState();
}

class _NewAllocationState extends State<NewAllocation> {
  var _isAllocating = false;
  var _isLoadingData = false;

  final String token = prefs.getString('auth_token') ?? '';
  final String worksAt = prefs.getString('worksAt') ?? '';

  final _amountController = TextEditingController();
  var _selectedCommodity = '';
  var _selectedCooperative = '';

  final List<Commodity> _commodities = [];
  final List<RetailerCooperative> _retailerCooperatives = [];

  void _getCommodities() async {
    setState(() {
      _isLoadingData = true;
    });
    final data = await CommoditiesApi.getCommodities(token: token);
    final data2 = await RetailerCooperativesApi.getRetailerCooperatives(
      token: token,
    );
    setState(() {
      _commodities.addAll(Commodity.fromJsonList(data['data']));
      _retailerCooperatives.addAll(
        RetailerCooperative.fromJsonList(data2['data']),
      );
    });
    setState(() {
      _isLoadingData = false;
    });
  }

  void _allocateCommodity() async {
    final amountText = _amountController.text.trim();

    if (_selectedCommodity.isEmpty ||
        _selectedCooperative.isEmpty ||
        amountText.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the required fields.')),
      );
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount has to be greater than zero.')),
      );
      return;
    }

    try {
      setState(() {
        _isAllocating = true;
      });

      final allocationData = {
        'commodity': _selectedCommodity,
        'retailerCooperativeId': _selectedCooperative,
        'amount': double.parse(_amountController.text),
        'tradeBureauId': worksAt,
      };

      final data = await AllocationsApi.createAllocation(
        token: token,
        allocationData: allocationData,
      );

      if (data['status'] == 'pending') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Allocating successfully')));

        setState(() {
          _amountController.text = '';
          _selectedCommodity = '';
          _selectedCooperative = '';
        });

        Navigator.of(context).pop();
      }

    } catch (e) {
      print('Error allocating... $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error allocating... please try again')),
      );
    } finally {
      setState(() {
        _isAllocating = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCommodities();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Allocation')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _isLoadingData ? Center(child: CircularProgressIndicator()) : Column(
          children:  [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Commodity',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              iconEnabledColor: Colors.black,
              items: [
                for (Commodity commodity in _commodities)
                  DropdownMenuItem(
                    value: commodity.id,
                    child: Text(
                      commodity.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCommodity = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a commodity' : null,
            ),

            SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Retailer Cooperative',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              iconEnabledColor: Colors.black,
              items: [
                for (RetailerCooperative coop in _retailerCooperatives)
                  DropdownMenuItem(
                    value: coop.id,
                    child: Text(
                      coop.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCooperative = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a commodity' : null,
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _allocateCommodity,
              child: _isAllocating
                  ? CircularProgressIndicator()
                  : Text('Allocate'),
            ),
          ],
        ),
      ),
    );
  }
}
