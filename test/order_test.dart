import 'package:campus_cup/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const CampusCupApp());
  }

  Future<void> tapControl(WidgetTester tester, String key) async {
    final control = find.byKey(Key(key));
    await tester.ensureVisible(control);
    await tester.pumpAndSettle();
    await tester.tap(control);
    await tester.pumpAndSettle();
  }

  testWidgets('empty order has four drinks and cannot be submitted',
      (tester) async {
    await openApp(tester);

    expect(find.byType(DrinkCard), findsNWidgets(4));
    expect(find.text('Latte'), findsOneWidget);
    expect(find.text('Cappuccino'), findsOneWidget);
    expect(find.text('Cold Brew'), findsOneWidget);
    expect(find.text('Mocha'), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(find.text('Tap + to start your order.'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('order-total'))).data,
        '\$0.00');
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('place-order')))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'quantities and tip update the total, then confirmation resets it',
      (tester) async {
    await openApp(tester);
    await tapControl(tester, 'add-Latte');
    await tapControl(tester, 'add-Latte');
    await tapControl(tester, 'add-Cold Brew');
    expect(tester.widget<Text>(find.byKey(const Key('order-total'))).data,
        '\$12.25');

    final slider = find.byKey(const Key('tip-slider'));
    await tester.ensureVisible(slider);
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(slider));
    await tester.pumpAndSettle();
    expect(tester.widget<Slider>(slider).value, 10);
    expect(tester.widget<Text>(find.byKey(const Key('order-total'))).data,
        '\$13.48');

    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    expect(find.text('Order confirmed!'), findsOneWidget);
    expect(find.text('2 × Latte'), findsOneWidget);
    expect(find.text('1 × Cold Brew'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(AlertDialog), matching: find.text('\$13.48')),
        findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(tester.widget<Text>(find.byKey(const Key('order-total'))).data,
        '\$0.00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing the last drink restores the empty state',
      (tester) async {
    await openApp(tester);
    await tapControl(tester, 'add-Mocha');
    expect(tester.widget<Text>(find.byKey(const Key('order-total'))).data,
        '\$4.75');
    await tapControl(tester, 'remove-Mocha');
    expect(find.byType(Slider), findsNothing);
    expect(tester.widget<Text>(find.byKey(const Key('order-total'))).data,
        '\$0.00');
    expect(
        tester
            .widget<IconButton>(find.byKey(const Key('remove-Mocha')))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quantities stop at nine and fit a smaller phone',
      (tester) async {
    await openApp(tester);
    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpAndSettle();
    for (var i = 0; i < 9; i++) {
      await tapControl(tester, 'add-Cappuccino');
    }
    expect(
        tester
            .widget<IconButton>(find.byKey(const Key('add-Cappuccino')))
            .onPressed,
        isNull);
    expect(tester.widget<Text>(find.byKey(const Key('order-total'))).data,
        '\$36.00');
    await tapControl(tester, 'remove-Cappuccino');
    expect(tester.widget<Text>(find.byKey(const Key('order-total'))).data,
        '\$32.00');
    expect(tester.takeException(), isNull);
  });
}
