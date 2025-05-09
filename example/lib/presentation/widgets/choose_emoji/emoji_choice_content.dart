import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class EmojiChoiceContent extends StatelessWidget {
  const EmojiChoiceContent({super.key, required this.emoji});

  final Emoji emoji;

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Emoji Preview',
      children: [
        Center(
          child: Text(
            emoji.emoji,
            style: const TextStyle(fontSize: 100),
          ),
        ),
      ],
    );
  }
}
