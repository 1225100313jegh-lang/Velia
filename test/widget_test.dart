import 'package:flutter_test/flutter_test.dart';
import 'package:velia/main.dart';

void main() {
  testWidgets('muestra la pantalla de acceso de Velia', (tester) async {
    await tester.pumpWidget(const AplicacionVelia());

    expect(find.text('Velia'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('admin@velia.com / admin123'), findsOneWidget);
  });
}
