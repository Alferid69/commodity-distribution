import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final double iconSize;
  final int badgeCount;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconSize = 20,
    this.badgeCount = 0,
  });

  @override
Widget build(BuildContext context) {
  final bool isLoadingBadge = badgeCount == -1;
  return ListTile(
    leading: Icon(
      icon,
      size: iconSize,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    title: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 20,
      ),
    ),
    trailing: isLoadingBadge
        ? IgnorePointer(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              )
            : null,
    onTap: onTap,
  );
}
  }
