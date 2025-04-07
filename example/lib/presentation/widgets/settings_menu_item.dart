import 'package:family_bottom_sheet_example/common/button/on_tap_scaler.dart';
import 'package:family_bottom_sheet_example/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsMenuItem extends StatelessWidget {
  const SettingsMenuItem({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.trailingIcon,
    this.onTap,
  });

  final String title;

  final IconData leadingIcon;

  final IconData trailingIcon;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OnTapScaler(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 2),
            Icon(leadingIcon, color: colors.iconDefault),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyLarge.copyWith(
                        color: context.colors.textDefault,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(trailingIcon, color: colors.iconDefault),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
