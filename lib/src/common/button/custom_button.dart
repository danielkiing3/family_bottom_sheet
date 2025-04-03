import 'package:family_bottom_sheet/src/common/button/on_tap_scaler.dart';
import 'package:family_bottom_sheet/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

const defaultColor = Color.fromARGB(255, 245, 246, 247);

class CustomTestButton extends StatelessWidget {
  const CustomTestButton({
    super.key,
    required this.text,
    this.contentColor,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
    this.icon,
    this.isCircular = false,
    this.shouldCenter = false,
    this.padding,
  });

  /// Color of the content of button
  final Color? contentColor;

  /// Specify a color for the icon or value default to [contentColor]
  final Color? iconColor;

  /// Background color of the button
  final Color? backgroundColor;

  /// Boolean to check if the button is circular
  final bool isCircular;

  /// The call back function of the button
  final VoidCallback? onTap;

  /// Icon to be displayed before the text content
  final IconData? icon;

  /// Main content of the button
  final String text;

  final bool shouldCenter;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 6),
      child: OnTapScaler(
        onTap: onTap,
        child: SizedBox.fromSize(
          size: Size.fromHeight(isCircular ? 46 : 50),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(isCircular ? 40 : 18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                isCircular && icon == null
                    ? Center(
                      child: Text(
                        text,
                        style: context.textStyles.labelLarge.copyWith(
                          color: contentColor ?? colors.textDefault,
                        ),
                      ),
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment:
                          shouldCenter
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                      children: [
                        Icon(icon, color: contentColor ?? colors.iconDefault),
                        const SizedBox(width: 10),
                        Text(
                          text,
                          style: context.textStyles.labelLarge.copyWith(
                            color: contentColor ?? colors.textDefault,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
