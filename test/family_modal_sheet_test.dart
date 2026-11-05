import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BuildContext hostContext;

  Widget app(WidgetTester tester, {Size size = const Size(400, 800)}) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return WidgetsApp(
      color: const Color(0xFF000000),
      onGenerateRoute: (settings) => PageRouteBuilder<void>(
        settings: settings,
        pageBuilder: (context, _, __) {
          hostContext = context;
          return const SizedBox.expand();
        },
      ),
    );
  }

  testWidgets('a covered page keeps its state and is built once', (
    tester,
  ) async {
    await tester.pumpWidget(app(tester));
    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => const _CounterPage(label: 'first', height: 200),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('first: 0'));
    await tester.pump();
    await tester.tap(find.text('first: 1'));
    await tester.pump();
    expect(find.text('first: 2'), findsOneWidget);

    FamilyModalSheet.of(tester.element(find.text('first: 2')))
        .pushPage(const _CounterPage(label: 'second', height: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('second: 0'));
    await tester.pump();

    FamilyModalSheet.of(tester.element(find.text('second: 1'))).popPage();
    await tester.pumpAndSettle();

    expect(find.text('first: 2'), findsOneWidget);
    expect(find.text('second: 1'), findsNothing);
    expect(_CounterPage.initCount['first'], 1);
    expect(_CounterPage.initCount['second'], 1);
  });

  testWidgets('a page holding a GlobalKey mounts without a duplicate', (
    tester,
  ) async {
    await tester.pumpWidget(app(tester));
    final key = GlobalKey();
    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => SizedBox(key: key, height: 100),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('a covered page is not painted or hit', (tester) async {
    await tester.pumpWidget(app(tester));
    var firstTaps = 0;
    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => GestureDetector(
        onTap: () => firstTaps++,
        child: const SizedBox(height: 300, child: Text('first')),
      ),
    );
    await tester.pumpAndSettle();
    FamilyModalSheet.of(tester.element(find.text('first')))
        .pushPage(const SizedBox(height: 300, child: Text('second')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('second'), warnIfMissed: false);
    await tester.pump();
    expect(firstTaps, 0);
    expect(find.text('first', skipOffstage: false), findsOneWidget);
  });

  testWidgets('the sheet resizes to the page on top', (tester) async {
    await tester.pumpWidget(app(tester));
    FamilyModalSheet.show<void>(
      context: hostContext,
      surfaceBuilder: (_, child) => child,
      builder: (_) => const SizedBox(height: 200, child: Text('first')),
    );
    await tester.pumpAndSettle();
    final stack = find.byType(FamilyPageStack);
    expect(tester.getSize(stack).height, 200);

    FamilyModalSheet.of(tester.element(find.text('first')))
        .pushPage(const SizedBox(height: 400, child: Text('second')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final midHeight = tester.getSize(stack).height;
    expect(midHeight, greaterThan(200));
    expect(midHeight, lessThan(400));

    await tester.pumpAndSettle();
    expect(tester.getSize(stack).height, 400);
  });

  testWidgets('back pops a page before it closes the sheet', (tester) async {
    await tester.pumpWidget(app(tester));
    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => const SizedBox(height: 200, child: Text('first')),
    );
    await tester.pumpAndSettle();
    FamilyModalSheet.of(tester.element(find.text('first')))
        .pushPage(const SizedBox(height: 200, child: Text('second')));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('first'), findsNothing);
  });

  testWidgets('tapping the barrier closes the sheet from any page', (
    tester,
  ) async {
    await tester.pumpWidget(app(tester));
    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => const SizedBox(height: 200, child: Text('first')),
    );
    await tester.pumpAndSettle();
    FamilyModalSheet.of(tester.element(find.text('first')))
        .pushPage(const SizedBox(height: 200, child: Text('second')));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(200, 50));
    await tester.pumpAndSettle();
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsNothing);
  });

  testWidgets('pushPage completes with the popPage result', (tester) async {
    await tester.pumpWidget(app(tester));
    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => const SizedBox(height: 200, child: Text('first')),
    );
    await tester.pumpAndSettle();

    final result = FamilyModalSheet.of(tester.element(find.text('first')))
        .pushPage<String>(const SizedBox(height: 200, child: Text('second')));
    await tester.pumpAndSettle();
    FamilyModalSheet.of(tester.element(find.text('second'))).popPage('picked');
    await tester.pumpAndSettle();

    expect(await result, 'picked');
  });

  testWidgets('show completes with the result the first page pops with', (
    tester,
  ) async {
    await tester.pumpWidget(app(tester));
    final result = FamilyModalSheet.show<String>(
      context: hostContext,
      builder: (_) => const SizedBox(height: 200, child: Text('first')),
    );
    await tester.pumpAndSettle();
    FamilyModalSheet.of(
      tester.element(find.text('first')),
    ).pushPage(const SizedBox(height: 200, child: Text('picker')));
    await tester.pumpAndSettle();
    FamilyModalSheet.of(tester.element(find.text('picker'))).popPage();
    await tester.pumpAndSettle();

    FamilyModalSheet.of(tester.element(find.text('first'))).popPage('Teal');
    await tester.pumpAndSettle();

    expect(await result, 'Teal');
    expect(find.text('first'), findsNothing);
  });

  testWidgets('adaptive floats the sheet on wide screens', (
    tester,
  ) async {
    await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
    FamilyPresentation? presentation;
    FamilyModalSheet.show<void>(
      context: hostContext,
      presentation: const FamilyPresentationStyle.adaptive(),
      surfaceBuilder: (context, child) {
        presentation = FamilyPresentation.maybeOf(context);
        return child;
      },
      builder: (_) => const SizedBox(width: 300, height: 200),
    );
    await tester.pumpAndSettle();

    expect(presentation, FamilyPresentation.floating);
    expect(
      tester.getCenter(find.byType(FamilyPageStack)),
      const Offset(512, 384),
    );
  });

  testWidgets('adaptive docks the sheet on narrow screens', (
    tester,
  ) async {
    await tester.pumpWidget(app(tester));
    FamilyPresentation? presentation;
    FamilyModalSheet.show<void>(
      context: hostContext,
      presentation: const FamilyPresentationStyle.adaptive(),
      surfaceBuilder: (context, child) {
        presentation = FamilyPresentation.maybeOf(context);
        return child;
      },
      builder: (_) => const SizedBox(height: 200),
    );
    await tester.pumpAndSettle();

    expect(presentation, FamilyPresentation.docked);
    expect(tester.getBottomLeft(find.byType(FamilyPageStack)).dy, 800);
  });

  testWidgets('replacePage swaps the top page and completes its future', (
    tester,
  ) async {
    await tester.pumpWidget(app(tester));
    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => const SizedBox(height: 200, child: Text('first')),
    );
    await tester.pumpAndSettle();
    final stack = FamilyModalSheet.of(tester.element(find.text('first')));

    final formResult = stack.pushPage<String>(
      const SizedBox(height: 300, child: Text('form')),
    );
    await tester.pumpAndSettle();
    stack.replacePage(
      const SizedBox(height: 100, child: Text('success')),
      result: 'sent',
    );
    await tester.pumpAndSettle();

    expect(await formResult, 'sent');
    expect(find.text('form', skipOffstage: false), findsNothing);
    expect(find.text('success'), findsOneWidget);
    expect(stack.pageCount, 2);

    stack.popPage();
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
  });

  testWidgets('popToFirstPage returns to the first page', (tester) async {
    await tester.pumpWidget(app(tester));
    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => const _CounterPage(label: 'root', height: 200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('root: 0'));
    await tester.pump();
    final stack = FamilyModalSheet.of(tester.element(find.text('root: 1')));

    final secondResult = stack.pushPage<String>(const Text('second'));
    await tester.pumpAndSettle();
    stack.pushPage<void>(const Text('third'));
    await tester.pumpAndSettle();
    expect(stack.pageCount, 3);
    expect(stack.canPopPage, isTrue);

    stack.popToFirstPage();
    await tester.pumpAndSettle();

    expect(await secondResult, isNull);
    expect(find.text('root: 1'), findsOneWidget);
    expect(stack.pageCount, 1);
    expect(stack.canPopPage, isFalse);
  });

  testWidgets('a FamilySheetTheme sets the defaults and show overrides it', (
    tester,
  ) async {
    Widget surface(String name) => Builder(builder: (_) => Text(name));

    await tester.pumpWidget(
      FamilySheetTheme(
        data: FamilySheetThemeData(
          presentation: const FamilyPresentationStyle.sheet(
            placement: FamilySheetPlacement.floating(),
          ),
          surfaceBuilder: (context, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [surface('theme surface'), child],
          ),
        ),
        child: app(tester, size: const Size(1024, 768)),
      ),
    );

    FamilyModalSheet.show<void>(
      context: hostContext,
      builder: (_) => const SizedBox(width: 300, height: 200),
    );
    await tester.pumpAndSettle();
    expect(find.text('theme surface'), findsOneWidget);
    expect(
      tester.getCenter(find.byType(FamilyPageStack)).dx,
      512,
    );

    Navigator.of(hostContext).pop();
    await tester.pumpAndSettle();

    FamilyModalSheet.show<void>(
      context: hostContext,
      presentation: const FamilyPresentationStyle.sheet(),
      surfaceBuilder: (context, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [surface('call surface'), child],
      ),
      builder: (_) => const SizedBox(height: 200),
    );
    await tester.pumpAndSettle();
    expect(find.text('call surface'), findsOneWidget);
    expect(find.text('theme surface'), findsNothing);
    expect(tester.getBottomLeft(find.byType(FamilyPageStack)).dy, 768);
  });

  group('dragging from a list', () {
    Widget list(BuildContext _) => SizedBox(
          height: 400,
          child: ListView(
            children: [
              for (var i = 0; i < 40; i++)
                SizedBox(height: 50, child: Text('row $i')),
            ],
          ),
        );

    testWidgets('closes the sheet when the list is at its top', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester));
      FamilyModalSheet.show<void>(context: hostContext, builder: list);
      await tester.pumpAndSettle();

      await tester.fling(find.text('row 2'), const Offset(0, 300), 1500);
      await tester.pumpAndSettle();
      expect(find.text('row 2'), findsNothing);
    });

    testWidgets('scrolls the list back first when it is scrolled', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester));
      FamilyModalSheet.show<void>(context: hostContext, builder: list);
      await tester.pumpAndSettle();

      await tester.drag(find.text('row 2'), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.drag(find.text('row 12'), const Offset(0, 200));
      await tester.pumpAndSettle();

      expect(find.text('row 12'), findsOneWidget);
      expect(find.byType(FamilyPageStack), findsOneWidget);
    });

    testWidgets('never closes from the list with dragFromScroll off', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.sheet(
          dragFromScroll: false,
        ),
        builder: list,
      );
      await tester.pumpAndSettle();

      await tester.fling(find.text('row 2'), const Offset(0, 300), 1500);
      await tester.pumpAndSettle();
      expect(find.text('row 2'), findsOneWidget);
    });
  });

  group('sheet width', () {
    testWidgets('is capped at 640 and centred on wide screens', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
      FamilyModalSheet.show<void>(
        context: hostContext,
        builder: (_) => const SizedBox(height: 200),
      );
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byType(FamilyPageStack));
      expect(rect.width, 640);
      expect(rect.center.dx, 512);
    });

    testWidgets('fills the screen with an unlimited max width', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.sheet(
          placement: FamilySheetPlacement.docked(maxWidth: double.infinity),
        ),
        builder: (_) => const SizedBox(height: 200),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(FamilyPageStack)).width, 1024);
    });
  });

  group('releasing a drag', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.pumpWidget(app(tester));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.sheet(
          motion: FamilyMotion.curved(Duration(milliseconds: 200)),
        ),
        builder: (_) => const SizedBox(height: 400, child: Text('sheet')),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a slow drag past halfway closes the sheet', (tester) async {
      await openSheet(tester);
      await tester.timedDrag(
        find.text('sheet'),
        const Offset(0, 300),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(find.text('sheet'), findsNothing);
    });

    testWidgets('a short drag settles back open', (tester) async {
      await openSheet(tester);
      await tester.timedDrag(
        find.text('sheet'),
        const Offset(0, 100),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(FamilyPageStack)).dy, 400);
    });

    testWidgets('a fling up from below halfway opens it again', (
      tester,
    ) async {
      await openSheet(tester);
      var time = Duration.zero;
      Future<void> move(TestGesture gesture, double dy, int ms) async {
        time += Duration(milliseconds: ms);
        await gesture.moveBy(Offset(0, dy), timeStamp: time);
        await tester.pump(Duration(milliseconds: ms));
      }

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('sheet')),
      );
      for (var i = 0; i < 10; i++) {
        await move(gesture, 30, 16);
      }
      // A pause so the release speed only counts the flick up. The release is
      // below halfway, so only that speed keeps the sheet open.
      time += const Duration(milliseconds: 60);
      for (var i = 0; i < 5; i++) {
        await move(gesture, -15, 8);
      }
      await gesture.up(timeStamp: time);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(FamilyPageStack)).dy, 400);
    });
  });

  group('rubber band', () {
    Future<double> stretchBy(WidgetTester tester, double dy) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('sheet')),
      );
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(Offset(0, dy / 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      final top = tester.getTopLeft(find.byType(FamilyPageStack)).dy;
      await gesture.up();
      await tester.pumpAndSettle();
      return top;
    }

    Future<void> openSheet(
      WidgetTester tester, {
      bool enableDrag = true,
    }) async {
      await tester.pumpWidget(app(tester));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: FamilyPresentationStyle.sheet(enableDrag: enableDrag),
        builder: (_) => const SizedBox(height: 400, child: Text('sheet')),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('stretches past fully open and springs back', (
      tester,
    ) async {
      await openSheet(tester);
      final top = await stretchBy(tester, -200);

      expect(top, lessThan(400));
      expect(top, greaterThan(200));
      expect(tester.getTopLeft(find.byType(FamilyPageStack)).dy, 400);
    });

    testWidgets('a sheet that cannot close gives a little and springs back', (
      tester,
    ) async {
      await openSheet(tester, enableDrag: false);
      final top = await stretchBy(tester, 300);

      expect(top, greaterThan(400));
      expect(top, lessThan(700));
      expect(tester.getTopLeft(find.byType(FamilyPageStack)).dy, 400);
      expect(find.text('sheet'), findsOneWidget);
    });
  });

  group('adaptive follows the screen live', () {
    Future<void> openAdaptive(WidgetTester tester, Size size) async {
      await tester.pumpWidget(app(tester, size: size));
      FamilyModalSheet.show<String>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.adaptive(),
        surfaceBuilder: (context, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${FamilyPresentation.maybeOf(context)?.name}'),
            child,
          ],
        ),
        builder: (_) => const _CounterPage(label: 'first', height: 200),
      );
      await tester.pumpAndSettle();
    }

    Future<void> resize(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
    }

    testWidgets('switches between docked and floating as the window resizes', (
      tester,
    ) async {
      await openAdaptive(tester, const Size(400, 800));
      expect(find.text('docked'), findsOneWidget);

      await resize(tester, const Size(1024, 768));
      expect(find.text('floating'), findsOneWidget);
      expect(
        tester.getCenter(find.byType(FamilyPageStack)).dx,
        512,
      );

      await resize(tester, const Size(400, 800));
      expect(find.text('docked'), findsOneWidget);
      expect(tester.getBottomLeft(find.byType(FamilyPageStack)).dy, 800);
    });

    testWidgets('switches when the device rotates', (tester) async {
      await openAdaptive(tester, const Size(500, 900));
      expect(find.text('docked'), findsOneWidget);

      await resize(tester, const Size(900, 500));
      expect(find.text('floating'), findsOneWidget);
    });

    testWidgets('state survives a surface that changes shape per placement', (
      tester,
    ) async {
      _CounterPage.initCount.clear();
      await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.adaptive(),
        // The default surface adds padding only when docked.
        builder: (_) => const _CounterPage(label: 'first', height: 200),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('first: 0'));
      await tester.pump();

      await resize(tester, const Size(400, 800));
      expect(find.text('first: 1'), findsOneWidget);
      await resize(tester, const Size(1024, 768));
      expect(find.text('first: 1'), findsOneWidget);
      expect(_CounterPage.initCount['first'], 1);
    });

    testWidgets('pages keep their state across the switch', (tester) async {
      _CounterPage.initCount.clear();
      await openAdaptive(tester, const Size(400, 800));
      await tester.tap(find.text('first: 0'));
      await tester.pump();
      FamilyModalSheet.of(tester.element(find.text('first: 1')))
          .pushPage(const _CounterPage(label: 'second', height: 300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('second: 0'));
      await tester.pump();

      await resize(tester, const Size(1024, 768));
      await resize(tester, const Size(400, 800));

      expect(find.text('second: 1'), findsOneWidget);
      FamilyModalSheet.of(tester.element(find.text('second: 1'))).popPage();
      await tester.pumpAndSettle();
      expect(find.text('first: 1'), findsOneWidget);
      expect(_CounterPage.initCount['first'], 1);
      expect(_CounterPage.initCount['second'], 1);
    });

    testWidgets('still returns a result and drags closed after switching', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
      final result = FamilyModalSheet.show<String>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.adaptive(),
        builder: (_) => const SizedBox(height: 300, child: Text('page')),
      );
      await tester.pumpAndSettle();
      await resize(tester, const Size(400, 800));

      await tester.fling(find.text('page'), const Offset(0, 300), 1500);
      await tester.pumpAndSettle();
      expect(find.text('page'), findsNothing);
      expect(await result, isNull);
    });
  });

  group('floating anchor', () {
    // 1024 x 768 with the default 24 inset leaves a 720-tall area from y 24.
    Future<FamilyPageStackState> openFloatingAt(
      WidgetTester tester, {
      FamilyAnchor anchor = FamilyAnchor.top,
    }) async {
      await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: FamilyPresentationStyle.sheet(
          placement: FamilySheetPlacement.floating(anchor: anchor),
        ),
        surfaceBuilder: (_, child) => child,
        builder: (_) => const SizedBox(height: 200, child: Text('first')),
      );
      await tester.pumpAndSettle();
      return FamilyModalSheet.of(tester.element(find.text('first')));
    }

    Rect floatingRect(WidgetTester tester) =>
        tester.getRect(find.byType(FamilyPageStack));

    testWidgets('returns after the keyboard pushed it up', (tester) async {
      await openFloatingAt(tester);
      expect(floatingRect(tester).top, 284);

      // A 300 keyboard leaves a 420-tall area from y 24, so the 200-tall
      // sheet slides up to fit above it.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(floatingRect(tester).top, 244);

      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(floatingRect(tester).top, 284);
    });

    testWidgets('opens centred, then keeps its top edge between pages', (
      tester,
    ) async {
      final stack = await openFloatingAt(tester);
      expect(floatingRect(tester).top, 284);

      stack.pushPage(const SizedBox(height: 400, child: Text('second')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(floatingRect(tester).top, 284);
      await tester.pumpAndSettle();
      expect(floatingRect(tester).top, 284);
      expect(floatingRect(tester).height, 400);

      stack.popPage();
      await tester.pumpAndSettle();
      expect(floatingRect(tester).top, 284);
    });

    testWidgets('slides up just enough for a tall page, and stays', (
      tester,
    ) async {
      final stack = await openFloatingAt(tester);

      stack.pushPage(const SizedBox(height: 600, child: Text('tall')));
      await tester.pumpAndSettle();
      expect(floatingRect(tester).bottom, 744);
      expect(floatingRect(tester).top, 144);

      stack.popPage();
      await tester.pumpAndSettle();
      expect(floatingRect(tester).top, 144);
    });

    testWidgets('re-centres when the width changes', (tester) async {
      final stack = await openFloatingAt(tester);
      stack.pushPage(const SizedBox(height: 600, child: Text('tall')));
      await tester.pumpAndSettle();
      stack.popPage();
      await tester.pumpAndSettle();
      expect(floatingRect(tester).top, 144);

      tester.view.physicalSize = const Size(1000, 768);
      await tester.pumpAndSettle();
      expect(floatingRect(tester).top, 284);
    });

    testWidgets('a centre anchor grows around the middle', (tester) async {
      final stack = await openFloatingAt(tester, anchor: FamilyAnchor.center);
      stack.pushPage(const SizedBox(height: 400, child: Text('second')));
      await tester.pumpAndSettle();
      expect(floatingRect(tester).top, 184);
    });

    testWidgets('a bottom anchor keeps its bottom edge', (tester) async {
      final stack = await openFloatingAt(tester, anchor: FamilyAnchor.bottom);
      expect(floatingRect(tester).bottom, 484);
      stack.pushPage(const SizedBox(height: 400, child: Text('second')));
      await tester.pumpAndSettle();
      expect(floatingRect(tester).bottom, 484);
      expect(floatingRect(tester).top, 84);
    });
  });

  group('canUserDismiss', () {
    late _GuardedSheetRoute route;

    Future<void> openGuarded(WidgetTester tester) async {
      await tester.pumpWidget(app(tester));
      route = _GuardedSheetRoute(
        builder: (_) => const SizedBox(height: 200, child: Text('first')),
      );
      Navigator.of(hostContext).push(route);
      await tester.pumpAndSettle();
      FamilyModalSheet.of(tester.element(find.text('first')))
          .pushPage(const SizedBox(height: 200, child: Text('second')));
      await tester.pumpAndSettle();
      route.setBlocked(true);
      await tester.pump();
    }

    testWidgets('blocks the barrier, back and drag', (tester) async {
      await openGuarded(tester);

      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);

      await tester.fling(find.text('second'), const Offset(0, 300), 1500);
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('blocks back on a single page too', (tester) async {
      await tester.pumpWidget(app(tester));
      final single = _GuardedSheetRoute(
        builder: (_) => const SizedBox(height: 200, child: Text('only')),
      );
      Navigator.of(hostContext).push(single);
      await tester.pumpAndSettle();
      single.setBlocked(true);
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('only'), findsOneWidget);
    });

    testWidgets('still lets code close the route', (tester) async {
      await openGuarded(tester);

      Navigator.of(hostContext).pop();
      await tester.pumpAndSettle();
      expect(find.text('second'), findsNothing);
    });

    testWidgets('lets everything through again once lifted', (tester) async {
      await openGuarded(tester);
      route.setBlocked(false);
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('first'), findsOneWidget);

      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();
      expect(find.text('first'), findsNothing);
    });
  });

  group('floating sheet', () {
    // 1024 x 768 with the default 24 inset leaves a 976 x 720 area from y 24.
    Future<FamilyPageStackState> openFloating(
      WidgetTester tester, {
      FamilyAnchor anchor = FamilyAnchor.top,
    }) async {
      await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: FamilyPresentationStyle.sheet(
          placement: FamilySheetPlacement.floating(anchor: anchor),
        ),
        surfaceBuilder: (_, child) => child,
        builder: (_) => const SizedBox(height: 200, child: Text('first')),
      );
      await tester.pumpAndSettle();
      return FamilyModalSheet.of(tester.element(find.text('first')));
    }

    Rect sheetRect(WidgetTester tester) =>
        tester.getRect(find.byType(FamilyPageStack));

    testWidgets('slides up from below the screen and rests centred', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.sheet(
          placement: FamilySheetPlacement.floating(),
        ),
        surfaceBuilder: (_, child) => child,
        builder: (_) => const SizedBox(height: 200, child: Text('first')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(sheetRect(tester).top, greaterThan(284));

      await tester.pumpAndSettle();
      expect(sheetRect(tester), const Rect.fromLTWH(242, 284, 540, 200));
    });

    testWidgets('swipes closed like a docked sheet', (tester) async {
      await openFloating(tester);
      await tester.fling(find.text('first'), const Offset(0, 300), 1500);
      await tester.pumpAndSettle();
      expect(find.text('first'), findsNothing);
    });

    testWidgets('a switch to docked mid-drag still settles open', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester, size: const Size(1024, 768)));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.adaptive(),
        surfaceBuilder: (_, child) => child,
        builder: (_) => const SizedBox(height: 200, child: Text('first')),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('first')),
      );
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      tester.view.physicalSize = const Size(400, 800);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('first'), findsOneWidget);
      expect(sheetRect(tester).bottom, 800);
    });
  });

  group('resolve', () {
    testWidgets('a rule that returns itself reports a clear error', (
      tester,
    ) async {
      await tester.pumpWidget(app(tester));
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: const FamilyPresentationStyle.resolve(_returnsItself),
        builder: (_) => const SizedBox(height: 200, child: Text('still open')),
      );
      await tester.pumpAndSettle();

      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect(
        (error as FlutterError).message,
        contains('kept returning other resolves'),
      );
      expect(find.text('still open'), findsOneWidget);
    });

    FamilyPresentationStyle byOrientation(BuildContext context) =>
        MediaQuery.orientationOf(context) == Orientation.landscape
            ? const FamilyPresentationStyle.sheet(
                placement: FamilySheetPlacement.floating(),
              )
            : const FamilyPresentationStyle.sheet();

    testWidgets('picks by any rule, live', (tester) async {
      await tester.pumpWidget(app(tester, size: const Size(900, 600)));
      FamilyPresentation? presentation;
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: FamilyPresentationStyle.resolve(byOrientation),
        surfaceBuilder: (context, child) {
          presentation = FamilyPresentation.maybeOf(context);
          return child;
        },
        builder: (_) => const SizedBox(height: 200),
      );
      await tester.pumpAndSettle();
      expect(presentation, FamilyPresentation.floating);

      tester.view.physicalSize = const Size(600, 900);
      await tester.pumpAndSettle();
      expect(presentation, FamilyPresentation.docked);
    });
  });

  group('copyWith', () {
    test('changes a sheet', () {
      const style = FamilyPresentationStyle.sheet();
      final changed = style.copyWith(enableDrag: false) as FamilySheetStyle;
      expect(changed.enableDrag, isFalse);
      expect(changed.placement, const FamilySheetPlacement.docked());
    });

    test('changes both sides of adaptive', () {
      const style = FamilyPresentationStyle.adaptive();
      final changed = style.copyWith(enableDrag: false) as FamilyAdaptiveStyle;
      expect(changed.sheetFor(400).enableDrag, isFalse);
      expect(changed.sheetFor(1000).enableDrag, isFalse);
    });

    test('keeps equal copies of a resolve equal', () {
      FamilyPresentationStyle rule(BuildContext context) =>
          const FamilyPresentationStyle.sheet();
      final style = FamilyPresentationStyle.resolve(rule);
      expect(
        style.copyWith(enableDrag: false),
        style.copyWith(enableDrag: false),
      );
      expect(style.copyWith(enableDrag: false), isNot(style));
    });

    testWidgets('applies to whatever a resolve picks', (tester) async {
      FamilyPresentationStyle rule(BuildContext context) =>
          const FamilyPresentationStyle.adaptive();
      await tester.pumpWidget(app(tester));
      final style = FamilyPresentationStyle.resolve(rule)
          .copyWith(enableDrag: false) as FamilyResolvedStyle;
      final picked = style.resolve(hostContext) as FamilyAdaptiveStyle;
      expect(picked.enableDrag, isFalse);
    });

    testWidgets("turns off drag for one sheet from the theme's", (
      tester,
    ) async {
      await tester.pumpWidget(
        FamilySheetTheme(
          data: const FamilySheetThemeData(
            presentation: FamilyPresentationStyle.adaptive(),
          ),
          child: app(tester),
        ),
      );
      FamilyModalSheet.show<void>(
        context: hostContext,
        presentation: FamilySheetTheme.of(hostContext)
            .presentation
            .copyWith(enableDrag: false),
        builder: (_) => const SizedBox(height: 300, child: Text('pin')),
      );
      await tester.pumpAndSettle();

      await tester.fling(find.text('pin'), const Offset(0, 300), 1500);
      await tester.pumpAndSettle();
      expect(find.text('pin'), findsOneWidget);
    });
  });

  testWidgets('FamilySheetTheme.of fills gaps with the defaults', (
    tester,
  ) async {
    await tester.pumpWidget(app(tester));
    final theme = FamilySheetTheme.of(hostContext);
    expect(theme.presentation, const FamilyPresentationStyle.sheet());
    expect(theme.isDismissible, isTrue);
  });
}

class _CounterPage extends StatefulWidget {
  const _CounterPage({required this.label, required this.height});

  static final Map<String, int> initCount = {};

  final String label;
  final double height;

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _CounterPage.initCount.update(
      widget.label,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        onTap: () => setState(() => _count++),
        child: Text('${widget.label}: $_count'),
      ),
    );
  }
}

class _GuardedSheetRoute extends FamilyModalRoute<void> {
  _GuardedSheetRoute({required super.builder});

  bool _blocked = false;

  void setBlocked(bool blocked) {
    _blocked = blocked;
    changedInternalState();
  }

  @override
  bool get canUserDismiss => !_blocked;
}

FamilyPresentationStyle _returnsItself(BuildContext context) =>
    const FamilyPresentationStyle.resolve(_returnsItself);
