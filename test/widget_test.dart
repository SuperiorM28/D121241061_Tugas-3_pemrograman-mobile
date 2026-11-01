import 'package:flutter_test/flutter_test.dart';
import 'package:air_quality_app/main.dart';

void main() {
  testWidgets('AirQualityApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AirQualityApp());
    expect(find.text('Air Quality App'), findsOneWidget);
  });
}
