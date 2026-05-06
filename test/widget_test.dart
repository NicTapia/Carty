import 'package:flutter_test/flutter_test.dart';

import 'package:carty/main.dart';

void main() {
  testWidgets('Carty shows parent mode builder', (WidgetTester tester) async {
    await tester.pumpWidget(const CartyApp());

    expect(find.text('🛒 Carty'), findsOneWidget);
    expect(find.text('Modo Padre'), findsOneWidget);
    expect(find.text('Productos sugeridos'), findsOneWidget);
    expect(find.text('Producto personalizado'), findsOneWidget);
  });
}
