import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitweve/main.dart';

void main() {
  testWidgets('BitWeve initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BitWeveApp(),
      ),
    );

    // Avançar o tempo para que a animação da SplashScreen e o Future.delayed completem
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(BitWeveApp), findsOneWidget);
  });
}
