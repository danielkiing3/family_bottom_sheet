import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/custom_button.dart';
import 'package:family_bottom_sheet_example/common/button/on_tap_scaler.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/report_bug_content.dart';
import 'package:family_bottom_sheet_example/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'family_bottom_sheet_shell.dart';

class ChooseAreaContent extends StatelessWidget {
  const ChooseAreaContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      text: 'Choose Area',
      children: [
        _ChooseMenuItem(
          text: 'Send',
          icon: IconsaxPlusLinear.send_2,
          onTap: () {},
        ),
        _ChooseMenuItem(text: 'Swaps', icon: IconsaxPlusLinear.arrow_swap),
        _ChooseMenuItem(text: 'Activity', icon: IconsaxPlusLinear.activity),
        _ChooseMenuItem(text: 'Tokens', icon: IconsaxPlusLinear.send_2),
        _ChooseMenuItem(
          text: 'Collectibles',
          icon: IconsaxPlusLinear.picture_frame,
        ),
        _ChooseMenuItem(
          text: 'Other',
          icon: IconsaxPlusLinear.message_question,
        ),
        CustomTestButton(
          onTap: () {
            FamilyModalSheet.of(context).pushPage(ReportBugContent());
          },
          text: 'Continue',
          isCircular: true,
          backgroundColor: const Color.fromARGB(255, 211, 97, 16),
        ),
      ],
    );
  }
}

class _ChooseMenuItem extends StatelessWidget {
  const _ChooseMenuItem({required this.text, required this.icon, this.onTap});

  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OnTapScaler(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: colors.iconDefault, size: 28),
            const SizedBox(width: 14),
            Text(text, style: context.textStyles.labelLarge),
          ],
        ),
      ),
    );
  }
}
