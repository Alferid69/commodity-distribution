import 'package:flutter/material.dart';

class AttachmentChip extends StatelessWidget {
  final String fileName;
  final VoidCallback onTap;
  const AttachmentChip({super.key, required this.fileName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attachment_rounded, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              fileName,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}