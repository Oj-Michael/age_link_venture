import 'package:agelink_venture/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgeLinkApp());
    await tester.pumpAndSettle();

    expect(find.text('Command Center'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
