// Basic Flutter widget test for Medit

import 'package:flutter_test/flutter_test.dart';
import 'package:medit/app/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const MeditApp());

    // Verify that the app loads (empty state should show "Select a note...")
    expect(find.textContaining('note'), findsWidgets);
  });
}
