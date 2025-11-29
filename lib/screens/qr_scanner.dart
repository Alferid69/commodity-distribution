import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:public_commodity_distribution/api/customers_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/customer_model.dart';
import 'package:public_commodity_distribution/widgets/new_transaction.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    cameraResolution: Size(1920, 1080),
    useNewCameraSelector: true,
    returnImage: false,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_isProcessing) return;
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? scannedCode = barcodes.first.rawValue;
            if (scannedCode != null) {
              final RegExp digitRegex = RegExp(r'\d{16}');
              final Match? match = digitRegex.firstMatch(scannedCode);
              final String? extractedCode = match?.group(0);

              if (extractedCode != null) {
                setState(() {
                  _isProcessing = true;
                });
                _handleScannedFayda(extractedCode);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Invalid QR code. Please scan a valid 16-digit beneficiary ID.',
                    ),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }

  Future<void> _handleScannedFayda(String fayda) async {
    try {
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missing auth token. Please login.'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }

      final res = await CustomersApi.getCustomerFayda(
        token: token,
        fayda: fayda,
      );

      final data = res['data']['customer'];
      if (data == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No customer found for Fayda $fayda')),
        );
        setState(() => _isProcessing = false);
        return;
      }
      final customer = Customer.fromJson(data);

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AddTransactionSheet(prefilledCustomer: customer,commodities: [], onCreate: (name, houseNumber, woreda, selectedCommodity, quantity) => {},)
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch customer: $e')));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
