import 'package:flutter/material.dart';

class PrivakeKeyModalInfoCard extends StatelessWidget {
  const PrivakeKeyModalInfoCard({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.black.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.6),
            ),
          )
        ],
      ),
    );
  }
}
