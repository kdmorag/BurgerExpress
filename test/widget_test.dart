import 'package:flutter/material.dart';
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

  testWidgets('valida campos vacíos y el formato del correo', (tester) async {
    await tester.pumpWidget(const BurgerExpressApp());
    await tester.tap(find.text('INGRESAR'));
    await tester.pump();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(find.text('Menú BurgerExpress'), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, 'correo-invalido');
    await tester.tap(find.text('INGRESAR'));
    await tester.pump();
    expect(find.text('Ingresa un correo válido'), findsOneWidget);
  });

  testWidgets('rechaza credenciales incorrectas', (tester) async {
    await tester.pumpWidget(const BurgerExpressApp());
    await tester.enterText(
      find.byType(TextFormField).first,
      'estudiante@burgerexpress.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrecta');
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    expect(find.text('Menú BurgerExpress'), findsNothing);
  });

  testWidgets('inicia sesión, navega por categorías y cierra sesión', (
    tester,
  ) async {
    await tester.pumpWidget(const BurgerExpressApp());
    await tester.enterText(
      find.byType(TextFormField).first,
      'estudiante@burgerexpress.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();

    expect(find.text('Menú BurgerExpress'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Burger Clásica'), findsOneWidget);
    expect(find.text('Combo Personal'), findsNothing);

    await tester.tap(find.widgetWithText(Tab, 'Combos'));
    await tester.pumpAndSettle();
    expect(find.text('Combo Personal'), findsOneWidget);
    expect(find.text('Burger Clásica'), findsNothing);

    // También se puede cambiar de categoría deslizando el contenido.
    await tester.drag(find.byType(TabBarView), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('Papas fritas'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Bebidas'));
    await tester.pumpAndSettle();
    expect(find.text('Gaseosa'), findsOneWidget);
    expect(find.text('Agua'), findsOneWidget);
    expect(find.text('\$1.50'), findsOneWidget);

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('INGRESAR'), findsOneWidget);
    expect(find.text('Menú BurgerExpress'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('abre el registro de clientes desde el menú', (tester) async {
    await tester.pumpWidget(const BurgerExpressApp());
    await tester.enterText(
      find.byType(TextFormField).first,
      'estudiante@burgerexpress.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Registro de clientes'), findsOneWidget);
    expect(find.text('Cédula'), findsOneWidget);
    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Dirección'), findsOneWidget);
    expect(find.text('Teléfono'), findsOneWidget);
    expect(find.text('Ciudad'), findsOneWidget);

    await tester.tap(find.text('REGISTRAR CLIENTE'));
    await tester.pump();
    expect(find.text('Este campo es obligatorio'), findsNWidgets(5));

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '0102030405');
    await tester.enterText(campos.at(1), 'Ana Pérez');
    await tester.enterText(campos.at(2), 'Av. Central 123');
    await tester.enterText(campos.at(3), '0999999999');
    await tester.enterText(campos.at(4), 'Guayaquil');
    await tester.tap(find.text('REGISTRAR CLIENTE'));
    await tester.pump();
    expect(find.text('Cliente registrado correctamente'), findsOneWidget);
  });
}
