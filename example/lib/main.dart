import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/choose_emoji/choose_emoji_content.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'common/divider/small_divider.dart';
import 'presentation/widgets/helps_support/help_support_content.dart';
import 'presentation/widgets/options/options_content.dart';
import 'presentation/widgets/settings_menu_item.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeModeNotifierProvider(
      themeModeNotifier: ThemeModeNotifier(),
      child: Builder(
        builder: (context) {
          return ValueListenableBuilder(
            valueListenable: ThemeModeNotifierProvider.of(context),
            builder: (context, themeMode, _) {
              return MaterialApp(
                title: 'Family Tray Animation',
                themeMode: themeMode,
                theme: AppTheme.lightTheme,
                highContrastTheme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                highContrastDarkTheme: AppTheme.darkTheme,
                home: HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

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
          const SmallDivider(),
          SettingsMenuItem(
            title: 'Choose Emoji',
            leadingIcon: IconsaxPlusLinear.emoji_happy,
            trailingIcon: IconsaxPlusLinear.arrow_right_3,
            onTap: () {
              openChooseEmojiModal(context);
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

  Future<void> openChooseEmojiModal(BuildContext context) async {
    await FamilyModalSheet.show<void>(
      context: context,
      constraints: const BoxConstraints(maxHeight: 415),
      safeAreaMinimum: const EdgeInsets.only(bottom: 16),
      contentBackgroundColor: context.colors.surface,
      builder: (ctx) {
        return const ChooseEmojiContent();
      },
    );
  }
}
