import 'package:flutter_test/flutter_test.dart';
import 'package:netpulse/main.dart';

void main() {
  testWidgets('NetPulse app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NetPulseApp());
    expect(find.text('NETPULSE'), findsOneWidget);
  });
}
