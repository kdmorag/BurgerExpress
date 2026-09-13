import 'package:flutter_test/flutter_test.dart';

import 'package:burgerexpress/main.dart';

void main() {
  testWidgets('muestra la pantalla de autenticación', (tester) async {
    await tester.pumpWidget(const BurgerExpressApp());

    expect(find.text('BurgerExpress'), findsOneWidget);
    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
    expect(find.text('REGISTRO'), findsOneWidget);
    expect(find.text('INGRESAR'), findsOneWidget);
  });

  testWidgets('permite cambiar al formulario de registro', (tester) async {
    await tester.pumpWidget(const BurgerExpressApp());

    await tester.tap(find.text('REGISTRO'));
    await tester.pumpAndSettle();

    expect(find.text('Nombre Completo'), findsOneWidget);
    expect(find.text('CREAR CUENTA'), findsOneWidget);
  });
}
