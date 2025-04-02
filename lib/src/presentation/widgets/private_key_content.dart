import 'package:family_bottom_sheet/src/common/button/back_button.dart';
import 'package:family_bottom_sheet/src/common/button/custom_elevated_button.dart';
import 'package:family_bottom_sheet/src/common/info_card/privake_key_modal_info_card.dart';
import 'package:family_bottom_sheet/src/custom_bottom_sheet/widgets/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class PrivateKeyContent extends StatelessWidget {
  const PrivateKeyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: Colors.white,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    IconsaxPlusLinear.card_tick,
                    size: 44,
                    color: Colors.grey.withOpacity(0.9),
                  ),
                  const CustomBackButton(),
                ],
              ),
              const SizedBox(height: 12),

              // -- Private Key header
              const Text(
                'Private Key',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // -- Text Content
              Text(
                'Your Private key is the key used to back up your wallet. Keep it secret and secure at all times.',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

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
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CustomElevatedButton(
                        onTap: () async {
                          // await HapticFeedback.lightImpact();

                          FamilyModalSheet.of(context).popPage();
                        },
                        text: 'Cancel',
                        isCircular: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CustomElevatedButton(
                        onTap: () {},
                        text: 'Reveal',
                        isCircular: true,
                        contentColor: Colors.white,
                        backgroundColor: const Color.fromARGB(
                          255,
                          104,
                          173,
                          248,
                        ),
                        icon: IconsaxPlusLinear.eye_slash,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
