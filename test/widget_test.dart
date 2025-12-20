import 'package:flutter_test/flutter_test.dart';
import 'package:paydas_app/main.dart';

void main() {
  testWidgets('Register screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PaydasApp());

    // Verify that the register screen loads with tabs.
    expect(find.text('İşletme'), findsOneWidget);
    expect(find.text('Kullanıcı'), findsOneWidget);
    expect(find.text('Kayıt Ol'), findsOneWidget);
  });
}
