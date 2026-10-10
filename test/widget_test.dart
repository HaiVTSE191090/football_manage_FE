import 'package:flutter_test/flutter_test.dart';
import 'package:football_management_fe/app.dart';

void main() {
  testWidgets('App shows login page', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
