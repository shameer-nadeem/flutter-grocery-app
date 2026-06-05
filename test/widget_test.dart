import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ShelfSight smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('ShelfSight'),
        ),
      ),
    );

    expect(find.text('ShelfSight'), findsOneWidget);
  });
}
