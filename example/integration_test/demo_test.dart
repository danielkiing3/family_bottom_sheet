// Scripted demos for the README clips. Run through tool/record_demos.sh,
// which records the simulator and cuts a clip between each pair of markers.

import 'package:family_bottom_sheet_example/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Render every frame in real time, so the recording is smooth.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  // Let touches sent as if from the device through, see [touch].
  binding.shouldPropagateDevicePointerEvents = true;

  testWidgets('demos', (tester) async {
    app.main();
    await settle(tester);

    final view = tester.view;
    final isTablet =
        view.physicalSize.shortestSide / view.devicePixelRatio >= 600;

    if (isTablet) {
      await clip(
        tester,
        'floating',
        () => _floating(tester),
        scrollTo: 'Adaptive (floating sheet on tablets)',
      );
    } else {
      await clip(tester, 'state', () => _stateKept(tester),
          scrollTo: 'Pages keep their state');
      await clip(tester, 'flow', () => _flow(tester),
          scrollTo: 'Replace a page, then start over');
      await clip(tester, 'result', () => _result(tester),
          scrollTo: 'Return a result (page to page, then to this screen)');
      await clip(tester, 'scroll', () => _scroll(tester),
          scrollTo: 'Long list (pull down from the top to close)');
      await clip(tester, 'look', () => _look(tester),
          scrollTo: 'Choose Emoji (search field, capped height)');
    }
  });
}

Future<void> _stateKept(WidgetTester tester) async {
  await openDemo(tester, 'Pages keep their state');
  await settle(tester);

  await tapVisibly(tester, find.text('Tapped 0 times'));
  await tapVisibly(tester, find.text('Tapped 1 times'));
  await typeVisibly(tester, find.byType(TextField), 'Hello');
  await hold(tester);

  await tapVisibly(tester, find.text('Open page 2'));
  await settle(tester);
  await tapVisibly(tester, find.text('Tapped 0 times'));
  await hold(tester);

  await tapVisibly(tester, find.byIcon(Icons.close));
  await settle(tester);
  // Page 1 is back with its count and its text.
  await hold(tester, 1500);

  await dragVisibly(tester, find.text('Page 1'), const Offset(0, 500));
  await settle(tester);
}

Future<void> _flow(WidgetTester tester) async {
  await openDemo(tester, 'Replace a page, then start over');
  await tapVisibly(tester, find.text('\$50'));
  await settle(tester);
  await hold(tester);
  // Replaces the review page, so its step count stays at 2.
  await tapVisibly(tester, find.text('Send'));
  await settle(tester);
  await hold(tester, 1200);

  await tapVisibly(tester, find.text('Send another'));
  await settle(tester);
  await hold(tester);
  await tapVisibly(tester, find.text('\$10'));
  await settle(tester);
  await hold(tester);
  await tapVisibly(tester, find.byIcon(Icons.close));
  await settle(tester);
  await hold(tester);
  await tapOutside(tester);
  await settle(tester);
}

Future<void> _result(WidgetTester tester) async {
  await openDemo(tester, 'Return a result (page to page, then to this screen)');
  await tapVisibly(tester, find.text('Pick a colour'));
  await settle(tester);
  await hold(tester);
  await tapVisibly(tester, find.text('Teal'));
  await settle(tester);
  await hold(tester);
  await tapVisibly(tester, find.text('Use Teal'));
  await settle(tester);
  // The screen below shows the colour it got back.
  await hold(tester, 1800);
}

Future<void> _scroll(WidgetTester tester) async {
  await openDemo(tester, 'Long list (pull down from the top to close)');
  await hold(tester, 400);
  // Pulled up past its height, the sheet stretches and settles back.
  await dragVisibly(tester, find.text('Countries'), const Offset(0, -160));
  await settle(tester);

  await dragVisibly(tester, find.text('Country 6'), const Offset(0, -420));
  await settle(tester);
  await hold(tester, 500);
  await dragVisibly(tester, find.text('Country 12'), const Offset(0, 420));
  await settle(tester);
  await hold(tester, 500);
  // At the top, pulling down carries the sheet away.
  await dragVisibly(tester, find.text('Country 3'), const Offset(0, 600));
  await settle(tester);
}

Future<void> _look(WidgetTester tester) async {
  await openDemo(tester, 'Choose Emoji (search field, capped height)');
  await hold(tester, 1200);
  await tapOutside(tester);
  await settle(tester);

  await openDemo(tester, 'Material preset (Helps & Support)');
  await tapVisibly(tester, find.text('Report Bug'));
  await settle(tester);
  await hold(tester);
  await tapOutside(tester);
  await settle(tester);

  await openDemo(tester, 'Material preset as a card (padding and corners)');
  await hold(tester, 1200);
  await tapOutside(tester);
  await settle(tester);
}

Future<void> _floating(WidgetTester tester) async {
  await openDemo(tester, 'Adaptive (floating sheet on tablets)');
  await tapVisibly(tester, find.text('\$50'));
  await settle(tester);
  await hold(tester);
  await tapVisibly(tester, find.text('Send'));
  await settle(tester);
  await hold(tester);
  // Swipes away like the phone sheet.
  await dragVisibly(tester, find.text('Sent'), const Offset(0, 600));
  await settle(tester);

  await openDemo(tester, 'Floating sheet, centre anchor and wider');
  await tapVisibly(tester, find.text('\$100'));
  await settle(tester);
  await hold(tester);
  await tapOutside(tester);
  await settle(tester);
}

Future<void> openDemo(WidgetTester tester, String title) async {
  await tapVisibly(tester, find.text(title));
  await settle(tester);
}

/// Clears any snackbar and scrolls the home list so the demo called [title]
/// sits near the top.
Future<void> scrollHomeTo(WidgetTester tester, String title) async {
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
      .removeCurrentSnackBar();
  final list = find.byType(Scrollable).first;
  tester.state<ScrollableState>(list).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(find.text(title), 200, scrollable: list);
  await Scrollable.ensureVisible(tester.element(find.text(title)),
      alignment: 0.15);
  await tester.pumpAndSettle();
}

/// Taps the barrier above the sheet.
Future<void> tapOutside(WidgetTester tester) async {
  final gesture = await touch(tester, const Offset(60, 120));
  await hold(tester, 160);
  await gesture.up();
  await hold(tester, 300);
}

/// Marks a clip for the recording script: everything between the two
/// markers, plus a little either side, becomes one clip. The home list is
/// scrolled to [scrollTo] first, before the clip starts.
Future<void> clip(
  WidgetTester tester,
  String name,
  Future<void> Function() body, {
  required String scrollTo,
}) async {
  await scrollHomeTo(tester, scrollTo);
  await hold(tester, 600);
  // ignore: avoid_print
  print('DEMO_CLIP_START $name');
  await hold(tester, 400);
  await body();
  await hold(tester, 600);
  // ignore: avoid_print
  print('DEMO_CLIP_END $name');
}

Future<void> hold(WidgetTester tester, [int milliseconds = 700]) =>
    tester.pump(Duration(milliseconds: milliseconds));

Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await hold(tester, 300);
}

int _nextPointer = 1;

/// Puts a finger down at [position]. Sent as if from the device rather than
/// from the test, because the test binding draws a debug crosshair on every
/// test touch; the app's own demo dot shows instead.
Future<TestGesture> touch(WidgetTester tester, Offset position) async {
  final gesture = TestGesture(
    pointer: _nextPointer++,
    dispatcher: (event) async => tester.binding.handlePointerEventForSource(
      event,
      source: TestBindingEventSource.device,
    ),
  );
  await gesture.down(position);
  return gesture;
}

/// A tap long enough for the touch dot to show.
Future<void> tapVisibly(WidgetTester tester, Finder finder) async {
  final target = finder.hitTestable().first;
  final gesture = await touch(tester, tester.getCenter(target));
  await hold(tester, 160);
  await gesture.up();
  await hold(tester, 450);
}

/// Types one character at a time, like a person would.
Future<void> typeVisibly(
  WidgetTester tester,
  Finder field,
  String text,
) async {
  await tapVisibly(tester, field);
  for (var i = 1; i <= text.length; i++) {
    await tester.enterText(field, text.substring(0, i));
    await hold(tester, 110);
  }
  FocusManager.instance.primaryFocus?.unfocus();
  await hold(tester, 400);
}

/// A drag by [offset], 16ms a step, with the finger shown.
Future<void> dragVisibly(
  WidgetTester tester,
  Finder from,
  Offset offset, {
  int steps = 24,
}) async {
  final gesture = await touch(
    tester,
    tester.getCenter(from.hitTestable().first),
  );
  await hold(tester, 120);
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(offset / steps.toDouble());
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await hold(tester, 300);
}
