import 'dart:async';

import 'package:burgerexpress/models/cliente.dart';
import 'package:burgerexpress/screens/admin_screen.dart';
import 'package:burgerexpress/screens/client_registration_screen.dart';
import 'package:burgerexpress/service/cliente_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const ana = Cliente(
  cedula: '0102030405',
  nombre: 'Ana Pérez',
  direccion: 'Av. Central 123',
  telefono: '0999999999',
  ciudad: 'Guayaquil',
);

class ControlledService extends ClienteService {
  final guardado = Completer<void>();
  int llamadas = 0;
  @override
  Future<void> crearCliente(Cliente cliente) {
    llamadas++;
    return guardado.future;
  }
}

class ErrorService extends ClienteService {
  @override
  Stream<List<Cliente>> observarClientes({
    String? cedula,
    DateTime? desde,
    DateTime? hasta,
  }) => Stream.error(
    FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
  );
}

Future<void> llenarFormulario(WidgetTester tester) async {
  final campos = find.byType(TextFormField);
  for (final (index, valor) in [
    ana.cedula,
    ana.nombre,
    ana.direccion,
    ana.telefono,
    ana.ciudad,
  ].indexed) {
    await tester.enterText(campos.at(index), valor);
  }
}

void main() {
  testWidgets('administración busca, edita, cancela y confirma eliminación', (
    tester,
  ) async {
    final service = ClienteService(firestore: FakeFirebaseFirestore());
    await service.crearCliente(ana);
    await tester.pumpWidget(
      MaterialApp(home: AdminScreen(clienteService: service)),
    );
    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Pérez'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Buscar por cédula'),
      '9999999999',
    );
    await tester.tap(find.byTooltip('Buscar cliente'));
    await tester.pumpAndSettle();
    expect(find.text('Cliente no encontrado'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Buscar por cédula'),
      ana.cedula,
    );
    await tester.tap(find.byTooltip('Buscar cliente'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Pérez'), findsOneWidget);

    await tester.ensureVisible(find.text('Editar'));
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    final campos = find.byType(TextFormField);
    expect(
      tester.widget<TextFormField>(campos.first).controller!.text,
      ana.cedula,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).first).readOnly,
      isTrue,
    );
    await tester.enterText(campos.at(3), '0987654321');
    await tester.ensureVisible(find.text('ACTUALIZAR CLIENTE'));
    await tester.tap(find.text('ACTUALIZAR CLIENTE'));
    await tester.pumpAndSettle();
    expect((await service.buscarPorCedula(ana.cedula))!.telefono, '0987654321');
    expect(find.text('Teléfono: 0987654321'), findsOneWidget);

    await tester.ensureVisible(find.text('Eliminar'));
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await service.buscarPorCedula(ana.cedula), isNotNull);
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(await service.buscarPorCedula(ana.cedula), isNull);
    expect(find.text('Cliente no encontrado'), findsOneWidget);
    await tester.tap(find.text('Mostrar todos'));
    await tester.pumpAndSettle();
    expect(find.text('No hay clientes registrados'), findsOneWidget);
  });

  testWidgets(
    'filtra desde el selector de fechas y restaura todos los clientes',
    (tester) async {
      final db = FakeFirebaseFirestore();
      final service = ClienteService(firestore: db);
      for (final (id, nombre, fecha) in [
        ('0102030405', 'Ana Pérez', DateTime(2026, 9, 16, 23, 59)),
        ('0102030406', 'Luis Fuera', DateTime(2026, 9, 17)),
      ]) {
        await db.collection('clientes').doc(id).set({
          ...ana.toMap(),
          'cedula': id,
          'nombre': nombre,
          'fechaRegistro': Timestamp.fromDate(fecha),
        });
      }
      await tester.pumpWidget(
        MaterialApp(home: AdminScreen(clienteService: service)),
      );
      await tester.tap(find.text('Clientes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Filtrar por fecha'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      final campos = find.descendant(
        of: find.byType(DateRangePickerDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(campos.at(0), '09/16/2026');
      await tester.enterText(campos.at(1), '09/16/2026');
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();
      expect(find.text('Registro: 16/09/2026 — 16/09/2026'), findsOneWidget);
      expect(find.text('Ana Pérez'), findsOneWidget);
      expect(find.text('Luis Fuera'), findsNothing);
      await tester.tap(find.text('Mostrar todos'));
      await tester.pumpAndSettle();
      expect(find.text('Luis Fuera'), findsOneWidget);
      expect(find.text('Registro: 16/09/2026 — 16/09/2026'), findsNothing);
    },
  );

  testWidgets('registro duplicado conserva los datos y muestra el error', (
    tester,
  ) async {
    final service = ClienteService(firestore: FakeFirebaseFirestore());
    await service.crearCliente(ana);
    await tester.pumpWidget(
      MaterialApp(home: ClientRegistrationScreen(clienteService: service)),
    );
    await llenarFormulario(tester);
    await tester.ensureVisible(find.text('REGISTRAR CLIENTE'));
    await tester.tap(find.text('REGISTRAR CLIENTE'));
    await tester.pumpAndSettle();
    expect(find.text('Ya existe un cliente con esta cédula'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      ana.nombre,
    );
    expect(find.text('Cliente registrado correctamente'), findsNothing);
  });

  testWidgets('bloquea doble envío y conserva los datos si falla', (
    tester,
  ) async {
    final service = ControlledService();
    await tester.pumpWidget(
      MaterialApp(home: ClientRegistrationScreen(clienteService: service)),
    );
    await llenarFormulario(tester);
    await tester.ensureVisible(find.text('REGISTRAR CLIENTE'));
    await tester.tap(find.text('REGISTRAR CLIENTE'));
    await tester.pump();
    expect(find.text('GUARDANDO...'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(service.llamadas, 1);
    service.guardado.completeError(
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('No tienes permisos'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      ana.cedula,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('muestra errores de consulta y permite reintentar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AdminScreen(clienteService: ErrorService())),
    );
    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No tienes permisos'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No tienes permisos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
