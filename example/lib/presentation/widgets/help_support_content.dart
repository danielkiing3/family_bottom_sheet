import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/on_tap_scaler.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/choose_area_content.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:family_bottom_sheet_example/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class HelpSupportContent extends StatelessWidget {
  const HelpSupportContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'How can we help?',
      children: [
        _HelpSupportButton(
          icon: IconsaxPlusBold.building_4,
          color: Colors.orange,
          title: 'Report Bug',
          subtitle: 'Let us know about a specific issue you\'re experiencing ',
          onTap: () {
            FamilyModalSheet.of(context).pushPage(ChooseAreaContent());
          },
        ),
        _HelpSupportButton(
          icon: IconsaxPlusBold.message_notif,
          color: Colors.blue,
          title: 'Share Feedback',
          subtitle: 'Let us know how to improve by providing some feedback ',
          onTap: () {
            FamilyModalSheet.of(context).pushPage(ChooseAreaContent());
          },
        ),
        _HelpSupportButton(
          icon: IconsaxPlusBold.note_text,
          color: Colors.green,
          title: 'Something else',
          padding: EdgeInsets.zero,
          subtitle: 'Request features, leave a nice comment, or anything else',
          onTap: () {
            FamilyModalSheet.of(context).pushPage(ChooseAreaContent());
          },
        ),
      ],
    );
  }
}

//TODO: Choose a better name
class _HelpSupportButton extends StatelessWidget {
  const _HelpSupportButton({
    // super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.padding,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 12),
      child: OnTapScaler(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Icon
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                  height: 42,
                  width: 42,
                  child: Icon(icon, size: 26, color: Colors.white),
                ),
              ),

              const SizedBox(width: 12),

              // --Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Title
                    Text(
                      title,
                      style: context.textStyles.labelLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    // const SizedBox(height: 2),

                    // -- Subtitle
                    Text(
                      subtitle,
                      style: context.textStyles.bodyLarge.copyWith(
                        color: context.colors.textWeak,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
