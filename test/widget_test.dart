import 'package:flutter_test/flutter_test.dart';
import 'package:jasaku_mitra/main.dart';

void main() {
  testWidgets('JasaKu Mitra smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JasaKuMitraApp());
    expect(find.text('JasaKu Mitra'), findsOneWidget);
  });
}
