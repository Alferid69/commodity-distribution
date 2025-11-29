import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:public_commodity_distribution/api/entities_api.dart';
import 'package:public_commodity_distribution/api/requests_api.dart';
import 'package:public_commodity_distribution/main.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  String? _fileUrl;
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });

    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final token = prefs.getString('auth_token');
    final role = prefs.getString('role');
    final worksAt = prefs.getString('worksAt');

    if (worksAt == null || role == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Message cannot be empty')));
      setState(() => _isSubmitting = false);
      return;
    }

    // Determine toModel
    String? determinedToModel;
    switch (role) {
      case "RetailerCooperative":
        determinedToModel = "WoredaOffice";
        break;
      case "WoredaOffice":
        determinedToModel = "SubCityOffice";
        break;
      case "SubCityOffice":
        determinedToModel = "TradeBureau";
        break;
      default:
        determinedToModel = null;
    }

    final entitiesData = await EntitiesApi.getAllEntities(token: token!);

    // Determine toId
    String? toId;
    if (role == "RetailerCooperative") {
      final company = entitiesData['data']['retailerCooperatives'].firstWhere(
        (coop) => coop['_id'] == worksAt,
      );
      toId = entitiesData['data']['woredas'].firstWhere(
        (w) => w['_id'] == company['woredaOffice'],
      )['_id'];
    } else if (role == "WoredaOffice") {
      final company = entitiesData['data']['woredas'].firstWhere(
        (w) => w['_id'] == worksAt,
      );
      toId = entitiesData['data']['subcities'].firstWhere(
        (s) => s['_id'] == company['subCityOffice'],
      )['_id'];
    } else if (role == "SubCityOffice") {
      final company = entitiesData['data']['subcities'].firstWhere(
        (s) => s['_id'] == worksAt,
      );
      toId = entitiesData['data']['tradeBureaus'].firstWhere(
        (t) => t['_id'] == company['tradeBureau'],
      )['_id'];
    }

    if (toId == null || determinedToModel == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final newRequest = {
      "from": worksAt,
      "to": toId,
      "fromModel": role,
      "toModel": determinedToModel,
      "message": message,
      "file": _selectedFile
    };

    try {
      final success = await RequestsApi.createRequest(
        token: token,
        data: newRequest,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit request.')),
        );
      }
    } catch (e) {
      debugPrint("Failed to create request: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Request")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter a message" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: Text(_selectedFile == null
                          ? "Attach File"
                          : _selectedFile!.path.split('/').last),
                    ),
                  ),
                  if (_fileUrl != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: Colors.green),
                  ]
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: const Icon(Icons.send),
                label: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Submit Request"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
