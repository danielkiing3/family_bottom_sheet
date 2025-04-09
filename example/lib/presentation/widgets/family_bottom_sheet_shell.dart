import 'package:family_bottom_sheet_example/common/button/back_button.dart';
import 'package:family_bottom_sheet_example/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FamilyBottomSheetShell extends StatelessWidget {
  const FamilyBottomSheetShell({
    super.key,
    required this.headerText,
    required this.children,
  });

  final String headerText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 386),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    child: Text(
                    headerText,
                      style: context.textStyles.heading.copyWith(
                        color: colors.textDefault,
                      ),
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                  ),
                  CustomBackButton(),
                ],
              ),
              const SizedBox(height: 20),

              // -- Divider
              Divider(),
              const SizedBox(height: 20),

              // -- Content
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
