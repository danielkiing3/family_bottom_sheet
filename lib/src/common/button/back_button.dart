import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.2),
      ),
      height: 32,
      // width: 34,
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.close,
          size: 22,
        ),
      ),
    );
  }
}
