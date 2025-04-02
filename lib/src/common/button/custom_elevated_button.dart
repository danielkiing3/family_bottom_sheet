import 'package:flutter/material.dart';

const defaultColor = Color.fromARGB(255, 245, 246, 247);

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.text,
    this.contentColor = Colors.black,
    this.backgroundColor = defaultColor,
    this.iconColor,
    required this.onTap,
    this.icon,
    this.isCircular = false,
  });

  /// Color of the content of button
  final Color contentColor;

  /// Specify a color for the icon or value default to [contentColor]
  final Color? iconColor;

  /// Background color of the button
  final Color backgroundColor;

  /// Boolean to check if the button is circular
  final bool isCircular;

  /// The call back function of the button
  final VoidCallback onTap;

  /// Icon to be displayed before the text content
  final IconData? icon;

  /// Main content of the button
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        fixedSize: Size.fromHeight(isCircular ? 46 : 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCircular ? 40 : 18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: isCircular && icon == null
          ? Text(
              text,
              style: TextStyle(
                fontSize: 18,
                color: contentColor,
              ),
            )
          : Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? contentColor,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    color: contentColor,
                  ),
                )
              ],
            ),
    );
  }
}
