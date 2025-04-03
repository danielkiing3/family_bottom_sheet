import 'package:family_bottom_sheet/src/theme/theme.dart';
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
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colors.iconDefault),
          const SizedBox(width: 12),
          Text(
            text,
            style: context.textStyles.labelLarge.copyWith(
              color: context.colors.textWeak,
            ),
          ),
        ],
      ),
    );
  }
}
