import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/common/divider/small_divider.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/help_support_content.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/options_content.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/settings_menu_item.dart';
import 'package:family_bottom_sheet_example/theme/app_theme.dart';
import 'package:family_bottom_sheet_example/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text('Family Bottom Sheet'),
        actions: [
          IconButton(
            icon: Icon(IconsaxPlusLinear.setting_2, color: colors.iconDefault),
            onPressed: () {
              ThemeModeNotifierProvider.of(context).toggleMode();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 48),
        children: [
          SettingsMenuItem(
            title: 'Options',
            leadingIcon: IconsaxPlusLinear.menu,
            trailingIcon: IconsaxPlusLinear.arrow_right_3,
            onTap: () {
              openOptionsModal(context);
            },
          ),
          const SmallDivider(),
          SettingsMenuItem(
            title: 'Helps & Support',
            leadingIcon: IconsaxPlusLinear.support,
            trailingIcon: IconsaxPlusLinear.arrow_right_3,
            onTap: () {
              openHelpSupportModal(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> openOptionsModal(BuildContext context) async {
    await FamilyModalSheet.show<void>(
      context: context,
      contentBackgroundColor: context.colors.surface,
      builder: (ctx) {
        return const OptionsContent();
      },
    );
  }

  Future<void> openHelpSupportModal(BuildContext context) async {
    await FamilyModalSheet.showMaterialDefault<void>(
      context: context,
      contentBackgroundColor: context.colors.surface,
      builder: (ctx) {
        return const HelpSupportContent();
      },
    );
  }
}
