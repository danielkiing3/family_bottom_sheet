import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/custom_button.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class StateKeptContent extends StatefulWidget {
  const StateKeptContent({super.key, this.depth = 1});

  final int depth;

  @override
  State<StateKeptContent> createState() => _StateKeptContentState();
}

class _StateKeptContentState extends State<StateKeptContent> {
  final _controller = TextEditingController();
  int _taps = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FamilyBottomSheetShell(
      headerText: 'Page ${widget.depth}',
      children: [
        Text(
          'Type below and tap the counter, then open the next page and come '
          'back. Nothing resets.',
          style: context.textStyles.bodySmall.copyWith(color: colors.textWeak),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Type something',
            filled: true,
            fillColor: colors.surfaceSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 6),
        CustomTestButton(
          text: 'Tapped $_taps times',
          icon: IconsaxPlusLinear.add_circle,
          onTap: () => setState(() => _taps++),
        ),
        CustomTestButton(
          text: 'Open page ${widget.depth + 1}',
          icon: IconsaxPlusLinear.arrow_right_3,
          onTap: () => FamilyModalSheet.of(
            context,
          ).pushPage(StateKeptContent(depth: widget.depth + 1)),
        ),
      ],
    );
  }
}
