import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/custom_button.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

const _colours = {
  'Teal': Color(0xFF14B8A6),
  'Amber': Color(0xFFF59E0B),
  'Rose': Color(0xFFF43F5E),
  'Indigo': Color(0xFF6366F1),
};

class PickResultContent extends StatefulWidget {
  const PickResultContent({super.key});

  @override
  State<PickResultContent> createState() => _PickResultContentState();
}

class _PickResultContentState extends State<PickResultContent> {
  String? _picked;

  Future<void> _pick() async {
    final picked = await FamilyModalSheet.of(
      context,
    ).pushPage<String>(const _ColourPickerContent());
    if (picked != null) setState(() => _picked = picked);
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;

    return FamilyBottomSheetShell(
      headerText: 'Your colour',
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: picked == null
                  ? context.colors.surfaceSecondary
                  : _colours[picked],
            ),
            const SizedBox(width: 12),
            Text(
              picked ?? 'Nothing picked yet',
              style: context.textStyles.bodyLarge.copyWith(
                color: context.colors.textDefault,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTestButton(
          text: 'Pick a colour',
          icon: IconsaxPlusLinear.colorfilter,
          onTap: _pick,
        ),
        if (picked != null)
          CustomTestButton(
            text: 'Use $picked',
            icon: IconsaxPlusLinear.tick_circle,
            onTap: () => FamilyModalSheet.of(context).popPage(picked),
          ),
      ],
    );
  }
}

class _ColourPickerContent extends StatelessWidget {
  const _ColourPickerContent();

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Pick a colour',
      children: [
        for (final MapEntry(key: name, value: colour) in _colours.entries)
          CustomTestButton(
            text: name,
            contentColor: colour,
            backgroundColor: colour.withValues(alpha: .15),
            icon: IconsaxPlusBold.record,
            onTap: () => FamilyModalSheet.of(context).popPage(name),
          ),
      ],
    );
  }
}
