import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/button.dart';
import 'package:family_bottom_sheet_example/common/text_field/search_field.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/choose_emoji/emoji_choice_content.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class ChooseEmojiContent extends StatefulWidget {
  const ChooseEmojiContent({super.key});

  @override
  State<ChooseEmojiContent> createState() => _ChooseEmojiContentState();
}

class _ChooseEmojiContentState extends State<ChooseEmojiContent> {
  late List<Emoji> _filteredEmojis;

  @override
  void initState() {
    super.initState();
    _filteredEmojis = UnicodeEmojis.allEmojis;
  }

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Choose an Emoji',
      children: [
        SearchField(
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _GradientFade(
            fadeHeight: 16,
            color: context.colors.surface,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _filteredEmojis.length,
              itemBuilder: (context, index) {
                final emoji = _filteredEmojis[index];

                return OnTapScaler(
                  onTap: () => FamilyModalSheet.of(context).pushPage(
                    EmojiChoiceContent(emoji: emoji),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        emoji.emoji,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 100, height: 1),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      _filteredEmojis = query.isEmpty
          ? UnicodeEmojis.allEmojis
          : UnicodeEmojis.allEmojis
              .where((emoji) =>
                  emoji.name.toLowerCase().contains(query) ||
                  emoji.shortName.toLowerCase().contains(query) ||
                  emoji.emoji.contains(query))
              .toList();
    });
  }
}

class _GradientFade extends StatelessWidget {
  final Widget child;
  final double fadeHeight;
  final Color color;

  const _GradientFade({
    required this.child,
    this.fadeHeight = 32,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Top gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color,
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Bottom gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    color,
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
