import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:burgerexpress/main.dart';
import 'package:burgerexpress/screens/catalog_screen.dart';
import 'package:burgerexpress/service/cliente_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  testWidgets('muestra la pantalla de autenticación', (tester) async {
    await tester.pumpWidget(
      BurgerExpressApp(
        clienteService: ClienteService(firestore: FakeFirebaseFirestore()),
      ),
    );

    expect(find.text('BurgerExpress'), findsOneWidget);
    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
    expect(find.text('REGISTRO'), findsOneWidget);
    expect(find.text('INGRESAR'), findsOneWidget);
  });

  testWidgets('permite cambiar al formulario de registro', (tester) async {
    await tester.pumpWidget(
      BurgerExpressApp(
        clienteService: ClienteService(firestore: FakeFirebaseFirestore()),
      ),
    );

    await tester.tap(find.text('REGISTRO'));
    await tester.pumpAndSettle();

    expect(find.text('Nombre Completo'), findsOneWidget);
    expect(find.text('CREAR CUENTA'), findsOneWidget);
  });

  testWidgets('valida campos vacíos y el formato del correo', (tester) async {
    await tester.pumpWidget(
      BurgerExpressApp(
        clienteService: ClienteService(firestore: FakeFirebaseFirestore()),
      ),
    );
    await tester.tap(find.text('INGRESAR'));
    await tester.pump();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(find.byType(CatalogScreen), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, 'correo-invalido');
    await tester.tap(find.text('INGRESAR'));
    await tester.pump();
    expect(find.text('Ingresa un correo válido'), findsOneWidget);
  });

  testWidgets('rechaza credenciales incorrectas', (tester) async {
    await tester.pumpWidget(
      BurgerExpressApp(
        clienteService: ClienteService(firestore: FakeFirebaseFirestore()),
      ),
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'estudiante@burgerexpress.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrecta');
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    expect(find.byType(CatalogScreen), findsNothing);
  });

  testWidgets('inicia sesión, navega por categorías y cierra sesión', (
    tester,
  ) async {
    await tester.pumpWidget(
      BurgerExpressApp(
        clienteService: ClienteService(firestore: FakeFirebaseFirestore()),
      ),
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'estudiante@burgerexpress.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();

    expect(find.text('Explora el menú'), findsOneWidget);
    expect(find.text('Burger Clásica'), findsNothing);
    for (final (categoria, productos, precio) in [
      ('Hamburguesas', ['Burger Clásica', 'Burger Doble'], '\$8.99'),
      ('Combos', ['Combo Personal', 'Combo Familiar'], '\$12.00'),
      ('Extras', ['Papas fritas', 'Aros de cebolla'], '\$2.50'),
      ('Bebidas', ['Gaseosa', 'Agua'], '\$1.50'),
    ]) {
      await tester.ensureVisible(find.text(categoria));
      await tester.tap(find.text(categoria));
      await tester.pumpAndSettle();
      expect(find.text(categoria), findsOneWidget);
      for (final producto in productos) {
        expect(find.text(producto), findsOneWidget);
      }
      expect(find.text(precio), findsOneWidget);
      if (categoria != 'Hamburguesas') {
        expect(find.text('Burger Clásica'), findsNothing);
      }
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Explora el menú'), findsOneWidget);
    }

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('INGRESAR'), findsOneWidget);
    expect(find.byType(CatalogScreen), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      isEmpty,
    );
  });

  for (final escala in [1.0, 2.0]) {
    testWidgets('categorías y productos en móvil con escala $escala', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(escala)),
            child: child!,
          ),
          home: const CatalogScreen(),
        ),
      );
      expect(tester.takeException(), isNull);
      for (final categoria in ['Hamburguesas', 'Combos', 'Extras', 'Bebidas']) {
        await tester.ensureVisible(find.text(categoria));
        await tester.tap(find.text(categoria));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byTooltip('Ver pedido'), findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('abre el registro de clientes desde el menú', (tester) async {
    await tester.pumpWidget(
      BurgerExpressApp(
        clienteService: ClienteService(firestore: FakeFirebaseFirestore()),
      ),
    );
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
    await tester.pumpAndSettle();
    expect(find.text('Cliente registrado correctamente'), findsOneWidget);
  });
}
