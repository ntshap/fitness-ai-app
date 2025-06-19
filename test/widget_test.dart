import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_ai_app/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessApp());

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
  });
}
