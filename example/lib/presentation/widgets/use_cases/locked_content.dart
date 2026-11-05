import 'package:family_bottom_sheet_example/common/button/custom_button.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class LockedContent extends StatelessWidget {
  const LockedContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Accept the terms',
      children: [
        Text(
          "Tapping outside or dragging down won't close this one.",
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textWeak,
          ),
        ),
        const SizedBox(height: 16),
        CustomTestButton(
          text: 'Accept',
          icon: IconsaxPlusLinear.tick_circle,
          onTap: () => Navigator.of(context).pop(true),
        ),
        CustomTestButton(
          text: 'Decline',
          icon: IconsaxPlusLinear.close_circle,
          onTap: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
