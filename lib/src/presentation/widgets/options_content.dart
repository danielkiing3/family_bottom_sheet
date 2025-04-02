import 'package:family_bottom_sheet/src/common/button/back_button.dart';
import 'package:family_bottom_sheet/src/common/button/custom_elevated_button.dart';
import 'package:family_bottom_sheet/src/custom_bottom_sheet/widgets/modal_sheet.dart';
import 'package:family_bottom_sheet/src/presentation/widgets/private_key_content.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class OptionsContent extends StatelessWidget {
  const OptionsContent({super.key});

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
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Options',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  CustomBackButton(),
                ],
              ),
              const SizedBox(height: 20),

              // -- Divider
              Divider(color: Colors.grey.withOpacity(0.2)),

              // -- Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CustomElevatedButton(
                  onTap: () async {
                    // await HapticFeedback.lightImpact();

                    FamilyModalSheet.of(
                      context,
                    ).pushPage(const PrivateKeyContent());
                  },
                  text: 'View Private Key',
                  icon: IconsaxPlusLinear.lock_1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CustomElevatedButton(
                  onTap: () {
                    // openModal(context);
                  },
                  text: 'View Recovery Phase',
                  icon: IconsaxPlusLinear.add_circle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CustomElevatedButton(
                  onTap: () {},
                  text: 'Remove Wallet',
                  contentColor: Colors.red,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  icon: IconsaxPlusLinear.danger,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
