import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts the sheet behind a button, the way a screen does: the modal only
/// exists once there is a route to push it onto.
Widget _host(WidgetBuilder builder) => MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => FamilyModalSheet.show<void>(
                context: context,
                contentBackgroundColor: Colors.white,
                builder: builder,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('FamilyModalSheet', () {
    testWidgets('the first page may read inherited widgets from its context',
        (tester) async {
      // The builder is handed a BuildContext and is expected to be able to use
      // it. Building the first page in initState made that throw
      // "dependOnInheritedWidgetOfExactType() was called before
      // FamilyModalSheetState.initState() completed".
      await tester.pumpWidget(
        _host(
          (context) => Text(
            MaterialLocalizations.of(context).okButtonLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );

      await _open(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('opens with exactly one page on the stack', (tester) async {
      await tester.pumpWidget(_host((_) => const Text('first')));

      await _open(tester);

      final sheet = FamilyModalSheet.of(
        tester.element(find.text('first')),
      );
      expect(sheet.getTotalPageCount(), 1);
      expect(sheet.canPopPage(), isFalse);
    });

    testWidgets('still pushes and pops pages', (tester) async {
      await tester.pumpWidget(
        _host(
          (context) => TextButton(
            onPressed: () => FamilyModalSheet.of(context).pushPage(
              Builder(
                builder: (context) => TextButton(
                  onPressed: () => FamilyModalSheet.of(context).popPage(),
                  child: const Text('second'),
                ),
              ),
            ),
            child: const Text('first'),
          ),
        ),
      );
      await _open(tester);

      await tester.tap(find.text('first'));
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
      expect(find.text('first'), findsNothing);

      await tester.tap(find.text('second'));
      await tester.pumpAndSettle();
      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsNothing);
    });
  });
}
