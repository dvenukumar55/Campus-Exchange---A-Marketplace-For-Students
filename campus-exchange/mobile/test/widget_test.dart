import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_exchange/main.dart';

void main() {
  testWidgets('Smoke test: Campus Exchange app launches to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusExchangeApp());

    // Verify app brand text is displayed
    expect(find.text('Campus Exchange'), findsOneWidget);
    expect(find.text('Closed Student Marketplace • AVIH Pilot'), findsOneWidget);
  });
}
