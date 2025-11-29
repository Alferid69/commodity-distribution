import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/requests_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/widgets/attachment_chip.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:public_commodity_distribution/models/request_model.dart';

class RequestCard extends StatefulWidget {
  final Request request;
  final bool isSent;
  const RequestCard({super.key, required this.request, required this.isSent});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  var _isApproving = false;
  final token = prefs.getString('auth_token');

  String get fileName {
    final fileUrl = widget.request.files[0];

    try {
      final uri = Uri.parse(fileUrl);
      return uri.pathSegments.last;
    } catch (_) {
      return 'file.pdf';
    }
  }

  Future<void> _launchURL({required String urlString}) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      // This is a basic error handling.
      // You could show a SnackBar or a dialog here.
      throw 'Could not launch $urlString';
    }
  }

  void _approveRequest(String token, String requestId) async {
    try {
      setState(() {
        _isApproving = true;
      });
      final res = await RequestsApi.approveRequest(
        token: token,
        requestId: requestId,
      );
      if (res && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request Approved Successfully')),
        );

        setState(() {
          widget.request.status = 'read';
        });
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to Approve Request')));
      }
    } catch (e) {
      debugPrint('Error approving request: $e');
    } finally {
      setState(() {
        _isApproving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return Container(
      height: widget.isSent ? 134 : 168,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isSent
                    ? 'To: ${request.to.name}'
                    : 'From: ${request.from.name}',
              ),
              Text(request.status),
            ],
          ),
          Row(children: [Text(request.message)]),

          Row(
            children: [
              AttachmentChip(
                fileName: 'attachment.pdf',
                onTap: () => _launchURL(urlString: request.files[0]),
              ),
            ],
          ),

          Row(children: [Text(request.createdAt.toIso8601String())]),
          if (!widget.isSent)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.status == 'sent')
                  ElevatedButton(
                    onPressed: () => _approveRequest(token!, request.id),
                    child: _isApproving
                        ? CircularProgressIndicator()
                        : Text('Approve'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
