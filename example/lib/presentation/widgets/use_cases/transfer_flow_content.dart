import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/custom_button.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class TransferFlowContent extends StatelessWidget {
  const TransferFlowContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Send money',
      children: [
        const _StepLabel(),
        for (final amount in const [10, 50, 100])
          CustomTestButton(
            text: '\$$amount',
            icon: IconsaxPlusLinear.wallet_2,
            onTap: () => FamilyModalSheet.of(
              context,
            ).pushPage(_ReviewContent(amount: amount)),
          ),
      ],
    );
  }
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Review',
      children: [
        const _StepLabel(),
        Text(
          'Send \$$amount to Ada?',
          style: context.textStyles.bodyLarge.copyWith(
            color: context.colors.textDefault,
          ),
        ),
        const SizedBox(height: 16),
        CustomTestButton(
          text: 'Send',
          icon: IconsaxPlusLinear.send_2,
          shouldCenter: true,
          onTap: () => FamilyModalSheet.of(
            context,
          ).replacePage(_SuccessContent(amount: amount)),
        ),
      ],
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Sent',
      children: [
        const _StepLabel(),
        Text(
          '\$$amount is on its way. The review page was replaced, so going '
          'back skips it.',
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textWeak,
          ),
        ),
        const SizedBox(height: 16),
        CustomTestButton(
          text: 'Send another',
          icon: IconsaxPlusLinear.refresh,
          onTap: () => FamilyModalSheet.of(context).popToFirstPage(),
        ),
        CustomTestButton(
          text: 'Done',
          icon: IconsaxPlusLinear.tick_circle,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel();

  @override
  Widget build(BuildContext context) {
    final stack = FamilyModalSheet.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        '${stack.pageCount} page(s) in the stack · '
        '${stack.canPopPage ? 'back pops a page' : 'back closes the sheet'}',
        style: context.textStyles.labelSmall.copyWith(
          color: context.colors.textWeak,
        ),
      ),
    );
  }
}
