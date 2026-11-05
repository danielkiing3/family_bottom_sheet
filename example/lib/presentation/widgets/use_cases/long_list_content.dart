import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/back_button.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';

class LongListContent extends StatelessWidget {
  const LongListContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Countries',
                style: context.textStyles.heading.copyWith(
                  color: colors.textDefault,
                ),
              ),
              const CustomBackButton(),
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: 60,
            itemBuilder: (context, index) => ListTile(
              title: Text('Country ${index + 1}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => FamilyModalSheet.of(
                context,
              ).pushPage(_CountryContent(number: index + 1)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CountryContent extends StatelessWidget {
  const _CountryContent({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Country $number',
            style: context.textStyles.heading.copyWith(
              color: context.colors.textDefault,
            ),
          ),
          const CustomBackButton(),
        ],
      ),
    );
  }
}
