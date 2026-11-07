import 'package:family_bottom_sheet/material.dart';
import 'package:family_bottom_sheet_example/presentation/widgets/choose_emoji/choose_emoji_content.dart';
import 'package:family_bottom_sheet_example/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'common/divider/small_divider.dart';
import 'demo_mode.dart';
import 'presentation/widgets/helps_support/help_support_content.dart';
import 'presentation/widgets/options/options_content.dart';
import 'presentation/widgets/settings_menu_item.dart';
import 'presentation/widgets/use_cases/locked_content.dart';
import 'presentation/widgets/use_cases/long_list_content.dart';
import 'presentation/widgets/use_cases/pick_result_content.dart';
import 'presentation/widgets/use_cases/processing_content.dart';
import 'presentation/widgets/use_cases/state_kept_content.dart';
import 'presentation/widgets/use_cases/transfer_flow_content.dart';

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
                debugShowCheckedModeBanner: !kDemoMode,
                themeMode: themeMode,
                theme: AppTheme.lightTheme,
                highContrastTheme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                highContrastDarkTheme: AppTheme.darkTheme,
                builder: (context, child) {
                  final app = FamilySheetTheme(
                    data: const FamilySheetThemeData(
                      presentation: FamilyPresentationStyle.adaptive(),
                      surfaceBuilder: _familySurface,
                    ),
                    child: child!,
                  );
                  return kDemoMode ? DemoTouches(child: app) : app;
                },
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
          for (final (section, demos) in _demos) ...[
            _SectionTitle(section),
            for (final (index, demo) in demos.indexed) ...[
              if (index > 0) const SmallDivider(),
              SettingsMenuItem(
                title: demo.title,
                leadingIcon: demo.icon,
                trailingIcon: IconsaxPlusLinear.arrow_right_3,
                onTap: () => demo.open(context),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

typedef _Demo = ({
  String title,
  IconData icon,
  Future<void> Function(BuildContext context) open,
});

final List<(String, List<_Demo>)> _demos = [
  (
    'Flows',
    [
      (
        title: 'Options',
        icon: IconsaxPlusLinear.menu,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              builder: (_) => const OptionsContent(),
            ),
      ),
      (
        title: 'Pages keep their state',
        icon: IconsaxPlusLinear.save_2,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              builder: (_) => const StateKeptContent(),
            ),
      ),
      (
        title: 'Return a result (page to page, then to this screen)',
        icon: IconsaxPlusLinear.colorfilter,
        open: (context) async {
          final colour = await FamilyModalSheet.show<String>(
            context: context,
            builder: (_) => const PickResultContent(),
          );
          if (!context.mounted) return;
          _showResult(
            context,
            colour == null ? 'Closed without a colour' : 'You picked $colour',
          );
        },
      ),
      (
        title: 'Replace a page, then start over',
        icon: IconsaxPlusLinear.send_2,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              builder: (_) => const TransferFlowContent(),
            ),
      ),
    ],
  ),
  (
    'Scrolling',
    [
      (
        title: 'Long list (pull down from the top to close)',
        icon: IconsaxPlusLinear.task_square,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: const FamilyPresentationStyle.sheet(
                maxHeightFactor: 0.8,
              ),
              builder: (_) => const LongListContent(),
            ),
      ),
      (
        title: 'Long list (scrolling never closes)',
        icon: IconsaxPlusLinear.task_square,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: const FamilyPresentationStyle.sheet(
                maxHeightFactor: 0.8,
                dragFromScroll: false,
              ),
              builder: (_) => const LongListContent(),
            ),
      ),
      (
        title: 'Choose Emoji (search field, capped height)',
        icon: IconsaxPlusLinear.emoji_happy,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              surfaceBuilder: (context, child) => _familySurface(
                context,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 415),
                  child: child,
                ),
              ),
              builder: (_) => const ChooseEmojiContent(),
            ),
      ),
    ],
  ),
  (
    'Presentation',
    [
      (
        title: 'Adaptive (floating sheet on tablets)',
        icon: IconsaxPlusLinear.monitor_mobbile,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: const FamilyPresentationStyle.adaptive(),
              builder: (_) => const TransferFlowContent(),
            ),
      ),
      (
        title: 'Floating sheet, always',
        icon: IconsaxPlusLinear.maximize_4,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: const FamilyPresentationStyle.sheet(
                placement: FamilySheetPlacement.floating(),
              ),
              builder: (_) => const TransferFlowContent(),
            ),
      ),
      (
        title: 'Floating sheet, centre anchor and wider',
        icon: IconsaxPlusLinear.maximize_4,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: const FamilyPresentationStyle.sheet(
                placement: FamilySheetPlacement.floating(
                  anchor: FamilyAnchor.center,
                  maxWidth: 640,
                ),
              ),
              builder: (_) => const TransferFlowContent(),
            ),
      ),
      (
        title: 'Your own rule: floating in landscape, docked in portrait',
        icon: IconsaxPlusLinear.rotate_right,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: const FamilyPresentationStyle.resolve(
                _floatingInLandscape,
              ),
              builder: (_) => const TransferFlowContent(),
            ),
      ),
      (
        title: "The theme's presentation, without drag-to-close",
        icon: IconsaxPlusLinear.lock,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: FamilySheetTheme.of(context)
                  .presentation
                  .copyWith(enableDrag: false),
              builder: (_) => const LockedContent(),
            ),
      ),
      (
        title: 'Block closing while a payment processes',
        icon: IconsaxPlusLinear.card,
        open: (context) => Navigator.of(context).push(
              ProcessingSheetRoute<void>(
                surfaceBuilder: _familySurface,
                builder: (_) => const ProcessingContent(),
              ),
            ),
      ),
      (
        title: "Locked (tap outside or drag won't close)",
        icon: IconsaxPlusLinear.lock_1,
        open: (context) async {
          final accepted = await FamilyModalSheet.show<bool>(
            context: context,
            isDismissible: false,
            presentation: const FamilyPresentationStyle.sheet(
              enableDrag: false,
            ),
            builder: (_) => const LockedContent(),
          );
          if (!context.mounted) return;
          _showResult(context, accepted == true ? 'Accepted' : 'Declined');
        },
      ),
    ],
  ),
  (
    'Look',
    [
      (
        title: 'Material preset (Helps & Support)',
        icon: IconsaxPlusLinear.support,
        open: (context) => FamilyMaterialSheet.show<void>(
              context: context,
              backgroundColor: context.colors.surface,
              showDragHandle: true,
              builder: (_) => const HelpSupportContent(),
            ),
      ),
      (
        title: 'Material preset as a card (padding and corners)',
        icon: IconsaxPlusLinear.support,
        open: (context) => FamilyMaterialSheet.show<void>(
              context: context,
              backgroundColor: context.colors.surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              borderRadius: BorderRadius.circular(36),
              builder: (_) => const HelpSupportContent(),
            ),
      ),
      (
        title: 'Bouncy springs (sheet and pages)',
        icon: IconsaxPlusLinear.flash_1,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: const FamilyPresentationStyle.sheet(
                motion: FamilyMotion.spring(
                  duration: Duration(milliseconds: 500),
                  bounce: 0.25,
                ),
              ),
              pageMotion: const FamilyMotion.spring(
                duration: Duration(milliseconds: 450),
                bounce: 0.3,
              ),
              builder: (_) => const TransferFlowContent(),
            ),
      ),
      (
        title: 'Curved motion instead of springs',
        icon: IconsaxPlusLinear.chart_1,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              presentation: const FamilyPresentationStyle.sheet(
                motion: FamilyMotion.curved(Duration(milliseconds: 250)),
              ),
              pageMotion: const FamilyMotion.curved(
                Duration(milliseconds: 200),
              ),
              builder: (_) => const TransferFlowContent(),
            ),
      ),
      (
        title: 'Fade-through page transition',
        icon: IconsaxPlusLinear.arrange_square,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              pageTransitionBuilder: FamilyPageTransitions.fadeThrough(),
              builder: (_) => const TransferFlowContent(),
            ),
      ),
      (
        title: 'Custom page transition (scale)',
        icon: IconsaxPlusLinear.maximize_3,
        open: (context) => FamilyModalSheet.show<void>(
              context: context,
              pageMotion: const FamilyMotion.curved(
                Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              ),
              pageTransitionBuilder: _scaleTransition,
              builder: (_) => const TransferFlowContent(),
            ),
      ),
    ],
  ),
];

void _showResult(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// A presentation rule for [FamilyPresentationStyle.resolve], defined once
/// here rather than inline so it stays the same function between rebuilds.
FamilyPresentationStyle _floatingInLandscape(BuildContext context) =>
    MediaQuery.orientationOf(context) == Orientation.landscape
        ? const FamilyPresentationStyle.sheet(
            placement: FamilySheetPlacement.floating(),
          )
        : const FamilyPresentationStyle.sheet();

Widget _scaleTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
      child: FadeTransition(
        opacity: ReverseAnimation(secondaryAnimation),
        child: child,
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: context.textStyles.labelSmall.copyWith(
          color: context.colors.textWeak,
        ),
      ),
    );
  }
}

/// The floating, fully rounded Family-style surface.
Widget _familySurface(BuildContext context, Widget child) {
  // Material gives the pages a text style and an ancestor for TextField.
  final surface = Material(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(36),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
  // Only a docked sheet floats above the bottom edge with a margin; a
  // floating sheet is already placed with its own insets.
  if (FamilyPresentation.maybeOf(context) != FamilyPresentation.docked) {
    return surface;
  }
  return SafeArea(
    top: false,
    minimum: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: surface,
    ),
  );
}
