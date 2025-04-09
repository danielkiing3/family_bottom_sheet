import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/button/custom_button.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/family_bottom_sheet_shell.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/private_key_content.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class OptionsContent extends StatelessWidget {
  const OptionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyBottomSheetShell(
      headerText: 'Options',
      children: [
        CustomTestButton(
          onTap: () {
            FamilyModalSheet.of(context).pushPage(const PrivateKeyContent());
          },
          text: 'View Private Key',
          icon: IconsaxPlusLinear.lock_1,
        ),

        // CustomTestButton(
        //   onTap: () {},
        //   text: 'View Recovery Phase',
        //   icon: IconsaxPlusLinear.add_circle,
        // ),
        CustomTestButton(
          text: 'Remove Wallet',
          contentColor: const Color.fromARGB(255, 254, 25, 50),
          backgroundColor: Color.fromARGB(
            255,
            254,
            25,
            50,
          ).withValues(alpha: .2),
          icon: IconsaxPlusLinear.danger,
        ),
      ],
    );
  }
}
