import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  static const _borderRadius = 16.0;

  const SearchField({super.key, this.onChanged});

  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: context.textStyles.labelLarge.copyWith(
        color: context.colors.textDefault,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: context.colors.surfaceSecondary,
        hintText: 'Search',
        hintStyle: context.textStyles.labelLarge.copyWith(
          color: context.colors.textWeak,
        ),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}
