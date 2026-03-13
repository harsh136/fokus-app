import 'package:flutter_test/flutter_test.dart';

// Note: If your app folder is named something else, change 'first_app' to match it.
import 'package:first_app/main.dart'; 

void main() {
  testWidgets('Fokus app loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame using the new class name.
    await tester.pumpWidget(const FokusApp());

    // Verify that our home screen title loads correctly.
    expect(find.text('Fokus.|'), findsOneWidget);
  });
}