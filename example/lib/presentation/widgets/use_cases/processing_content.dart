import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/custom_button.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class ProcessingSheetRoute<T> extends FamilyModalRoute<T> {
  ProcessingSheetRoute({required super.builder, super.surfaceBuilder});

  bool _isProcessing = false;

  @override
  bool get canUserDismiss => !_isProcessing;

  void setProcessing(bool isProcessing) {
    _isProcessing = isProcessing;
    changedInternalState();
  }
}

class ProcessingContent extends StatefulWidget {
  const ProcessingContent({super.key});

  @override
  State<ProcessingContent> createState() => _ProcessingContentState();
}

class _ProcessingContentState extends State<ProcessingContent> {
  bool _isProcessing = false;

  Future<void> _pay() async {
    final route = ModalRoute.of(context) as ProcessingSheetRoute;
    setState(() => _isProcessing = true);
    route.setProcessing(true);

    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    route.setProcessing(false);
    setState(() => _isProcessing = false);
    FamilyModalSheet.of(context).replacePage(const _PaidContent());
  }

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Pay \$25',
      children: [
        Text(
          _isProcessing
              ? 'Processing. Try tapping outside, dragging down or going back.'
              : 'While the payment processes, the sheet can only be closed '
                  'from code.',
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textWeak,
          ),
        ),
        const SizedBox(height: 16),
        CustomTestButton(
          text: _isProcessing ? 'Processing…' : 'Pay',
          icon: _isProcessing
              ? IconsaxPlusLinear.timer_1
              : IconsaxPlusLinear.card,
          onTap: _isProcessing ? null : _pay,
        ),
      ],
    );
  }
}

class _PaidContent extends StatelessWidget {
  const _PaidContent();

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Paid',
      children: [
        Text(
          'Done. The sheet can be closed again.',
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textWeak,
          ),
        ),
      ],
    );
  }
}
