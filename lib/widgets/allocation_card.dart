import 'package:public_commodity_distribution/api/allocations_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/models/allocation_model.dart';

class AllocationCard extends StatefulWidget {
  final Allocation allocation;
  const AllocationCard({super.key, required this.allocation});

  @override
  State<AllocationCard> createState() => _AllocationCardState();
}

class _AllocationCardState extends State<AllocationCard> {
  final userRole = prefs.getString('role');
  bool _loadingReject = false;
  bool _loadingApprove = false;
  String? _statusOverride;

  Future<void> _handleReject(BuildContext context) async {
    setState(() => _loadingReject = true);
    final token = prefs.getString('auth_token');
    final id = widget.allocation.id;
    final success = await AllocationsApi.rejectAllocation(
      token: token!,
      id: id,
    );
    setState(() => _loadingReject = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Allocation rejected' : 'Failed to reject allocation',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) {
      setState(() {
        _statusOverride = 'rejected';
      });
    }
  }

  Future<void> _handleApprove(BuildContext context) async {
    setState(() => _loadingApprove = true);
    final token = prefs.getString('auth_token');
    final id = widget.allocation.id;
    final success = await AllocationsApi.approveAllocation(
      token: token!,
      id: id,
    );
    setState(() => _loadingApprove = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Allocation approved' : 'Failed to approve allocation',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) {
      setState(() {
        _statusOverride = 'approved';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allocation = widget.allocation;
    final effectiveStatus = _statusOverride ?? allocation.status;
    return Container(
      height: 168,
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
              Text(allocation.commodity.name),
              Text(allocation.status),
            ],
          ),
          Row(children: [Text(allocation.retailerCooperative.name)]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(allocation.amount.toString()),
              Text(allocation.date.toIso8601String()),
            ],
          ),
          if (effectiveStatus == 'pending' && userRole == 'RetailerCooperative')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: (_loadingReject || _loadingApprove)
                      ? null
                      : () => _handleApprove(context),
                  child: _loadingApprove
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Approve'),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: (_loadingReject || _loadingApprove)
                      ? null
                      : () => _handleReject(context),
                  child: _loadingReject
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Reject'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
