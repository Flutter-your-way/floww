import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:floww/config/utils/dates/date_change_direction.dart';
import 'package:floww/config/widgets/animations/date_change_transition.dart';

void main() {
  Future<void> pumpValue(
    WidgetTester tester,
    Object value,
    DateChangeDirection direction,
  ) {
    return tester.pumpWidget(
      MaterialApp(
        home: DateChangeTransition(
          value: value,
          direction: direction,
          child: Text('$value'),
        ),
      ),
    );
  }

  double opacityOf(WidgetTester tester) =>
      tester.widget<Opacity>(find.byType(Opacity).first).opacity;

  double offsetOf(WidgetTester tester) => tester
      .widget<Transform>(find.byType(Transform).first)
      .transform
      .getTranslation()
      .x;

  testWidgets('settles fully visible and unshifted', (tester) async {
    await pumpValue(tester, 'a', DateChangeDirection.forward);

    expect(opacityOf(tester), 1);
    expect(offsetOf(tester), 0);
  });

  testWidgets('a forward change slides in from the right', (tester) async {
    await pumpValue(tester, 'a', DateChangeDirection.forward);
    await pumpValue(tester, 'b', DateChangeDirection.forward);
    await tester.pump();

    expect(opacityOf(tester), lessThan(1));
    expect(offsetOf(tester), greaterThan(0));

    await tester.pumpAndSettle();
    expect(opacityOf(tester), 1);
    expect(offsetOf(tester), 0);
  });

  testWidgets('a backward change slides in from the left', (tester) async {
    await pumpValue(tester, 'b', DateChangeDirection.forward);
    await pumpValue(tester, 'a', DateChangeDirection.backward);
    await tester.pump();

    expect(offsetOf(tester), lessThan(0));

    await tester.pumpAndSettle();
    expect(offsetOf(tester), 0);
  });

  testWidgets('an unchanged value does not restart the animation', (
    tester,
  ) async {
    await pumpValue(tester, 'a', DateChangeDirection.forward);
    await pumpValue(tester, 'a', DateChangeDirection.forward);
    await tester.pump();

    expect(opacityOf(tester), 1);
    expect(offsetOf(tester), 0);
  });
}
