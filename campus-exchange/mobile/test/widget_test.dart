import 'package:flutter_test/flutter_test.dart';
import 'package:campus_exchange/main.dart';

void main() {
  testWidgets('Smoke test: Campus Exchange app launches to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusExchangeApp());

    // Verify app brand text is displayed on splash
    expect(find.text('Campus Exchange'), findsOneWidget);
    expect(find.text('Closed Student Marketplace • AVIH Pilot'), findsOneWidget);

    // Advance time by enough milliseconds to allow the splash timer (1200ms) to complete.
    await tester.pump(const Duration(milliseconds: 1500));
    
    // Pump an additional frame to process the resulting navigation
    await tester.pump();
  });
}
