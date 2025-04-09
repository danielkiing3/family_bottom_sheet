import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/back_button.dart';
import 'package:family_bottom_sheet_example/common/button/custom_button.dart';
import 'package:family_bottom_sheet_example/common/info_card/privake_key_modal_info_card.dart';
import 'package:family_bottom_sheet_example/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class PrivateKeyContent extends StatelessWidget {
  const PrivateKeyContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 386),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  IconsaxPlusLinear.card_tick,
                  size: 44,
                  color: colors.iconDefault,
                ),
                CustomBackButton(),
              ],
            ),
            const SizedBox(height: 12),

            // -- Private Key header
            Text(
              'Private Key',
              style: context.textStyles.heading.copyWith(
                color: colors.textDefault,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),

            // -- Text Content
            Text(
              'Your Private key is the key used to back up your wallet. Keep it secret and secure at all times.',
              style: context.textStyles.labelLarge.copyWith(
                color: context.colors.textWeak,
              ),
            ),
            const SizedBox(height: 20),

            // -- Divider
            Divider(),
            const SizedBox(height: 20),

            // -- Info row
            const PrivakeKeyModalInfoCard(
              icon: IconsaxPlusLinear.security_safe,
              text: 'Keep your private key safe',
            ),
            const PrivakeKeyModalInfoCard(
              icon: IconsaxPlusLinear.message,
              text: 'Don\'t share with anyone else ',
            ),
            const PrivakeKeyModalInfoCard(
              icon: IconsaxPlusLinear.danger,
              text: 'If you lose it we can\'t recover',
            ),

            // --Buttons
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomTestButton(
                    onTap: () {
                      FamilyModalSheet.of(context).popPage();
                    },
                    text: 'Cancel',
                    isCircular: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CustomTestButton(
                    text: 'Reveal',
                    isCircular: true,
                    shouldCenter: true,
                    contentColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 79, 174, 248),
                    icon: IconsaxPlusLinear.eye_slash,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
