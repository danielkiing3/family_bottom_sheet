import 'package:family_bottom_sheet/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BuildContext hostContext;

  // A phone with a 34 home indicator, or a tablet when [size] is wider.
  Future<void> openApp(WidgetTester tester,
      {Size size = const Size(400, 800)}) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1
      ..padding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            hostContext = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
  }

  Material sheetMaterial(WidgetTester tester) => tester.widget<Material>(
        find
            .ancestor(
              of: find.byType(FamilyPageStack),
              matching: find.byType(Material),
            )
            .first,
      );

  testWidgets('pages fill the width of the Material sheet', (tester) async {
    await openApp(tester);

    for (final showDragHandle in [false, true]) {
      FamilyMaterialSheet.show<void>(
        context: hostContext,
        showDragHandle: showDragHandle,
        builder: (_) => const Text('narrow'),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(FamilyPageStack)).width, 400);

      Navigator.of(hostContext).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('docked, it touches the bottom with only the top corners rounded',
      (
    tester,
  ) async {
    await openApp(tester);
    FamilyMaterialSheet.show<void>(
      context: hostContext,
      builder: (_) => const SizedBox(height: 200, child: Text('page')),
    );
    await tester.pumpAndSettle();

    final material = find
        .ancestor(of: find.text('page'), matching: find.byType(Material))
        .first;
    expect(tester.getRect(material).bottom, 800, reason: 'touches the bottom');
    expect(tester.getRect(material).width, 400, reason: 'touches the sides');
    expect(
      sheetMaterial(tester).borderRadius,
      const BorderRadius.vertical(top: Radius.circular(28)),
    );
    expect(
      tester.getRect(find.byType(FamilyPageStack)).bottom,
      800 - 34,
      reason: 'the pages stay above the home indicator',
    );
  });

  testWidgets('padding floats it as a card', (tester) async {
    await openApp(tester);
    FamilyMaterialSheet.show<void>(
      context: hostContext,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      builder: (_) => const SizedBox(height: 200, child: Text('page')),
    );
    await tester.pumpAndSettle();

    final material = find
        .ancestor(of: find.text('page'), matching: find.byType(Material))
        .first;
    expect(tester.getRect(material).bottom, 800 - 34 - 16);
    expect(tester.getRect(material).left, 16);
    expect(
      sheetMaterial(tester).borderRadius,
      const BorderRadius.all(Radius.circular(28)),
    );
  });

  testWidgets('floating, every corner is rounded', (tester) async {
    await openApp(tester, size: const Size(1024, 768));
    FamilyMaterialSheet.show<void>(
      context: hostContext,
      presentation: const FamilyPresentationStyle.adaptive(),
      showDragHandle: true,
      builder: (_) => const SizedBox(height: 200, child: Text('page')),
    );
    await tester.pumpAndSettle();

    expect(
      sheetMaterial(tester).borderRadius,
      const BorderRadius.all(Radius.circular(28)),
    );
  });

  testWidgets('custom corners replace the defaults per placement', (
    tester,
  ) async {
    const docked = BorderRadius.vertical(top: Radius.circular(12));
    const floating = BorderRadius.all(Radius.circular(40));

    await openApp(tester);
    FamilyMaterialSheet.show<void>(
      context: hostContext,
      presentation: const FamilyPresentationStyle.adaptive(),
      borderRadius: docked,
      floatingBorderRadius: floating,
      builder: (_) => const SizedBox(height: 200, child: Text('page')),
    );
    await tester.pumpAndSettle();
    expect(sheetMaterial(tester).borderRadius, docked);

    tester.view.physicalSize = const Size(1024, 768);
    await tester.pumpAndSettle();
    expect(sheetMaterial(tester).borderRadius, floating);
  });
}
