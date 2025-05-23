import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        FamilyModalSheet.of(context).popPage();
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surfaceSecondary,
        ),
        height: 32,
        width: 32,
        child: Icon(Icons.close, size: 22, color: colors.iconHighlighted),
      ),
    );
  }
}
