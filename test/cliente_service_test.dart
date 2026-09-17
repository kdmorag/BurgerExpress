import 'package:burgerexpress/models/cliente.dart';
import 'package:burgerexpress/service/cliente_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Cliente cliente({String cedula = '0102030405', String nombre = 'Ana Pérez'}) =>
    Cliente(
      cedula: cedula,
      nombre: nombre,
      direccion: 'Av. Central 123',
      telefono: '0999999999',
      ciudad: 'Guayaquil',
    );

void main() {
  late FakeFirebaseFirestore db;
  late ClienteService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    service = ClienteService(firestore: db);
  });

  test(
    'crea con fecha de servidor, busca y conserva ceros iniciales',
    () async {
      await service.crearCliente(cliente(nombre: '  Ana Pérez  '));
      final guardado = await service.buscarPorCedula(' 0102030405 ');
      expect(guardado!.cedula, '0102030405');
      expect(guardado.nombre, 'Ana Pérez');
      expect(guardado.telefono, '0999999999');
      expect(guardado.fechaRegistro, isNotNull);
      expect(guardado.fechaActualizacion, isNotNull);
      expect(await service.buscarPorCedula('9999999999'), isNull);
    },
  );

  test('rechaza duplicados sin sobrescribir el primer registro', () async {
    await service.crearCliente(cliente());
    await expectLater(
      service.crearCliente(cliente(nombre: 'Otro nombre')),
      throwsA(isA<ClienteException>()),
    );
    expect((await service.buscarPorCedula('0102030405'))!.nombre, 'Ana Pérez');
    expect(await service.obtenerClientes(), hasLength(1));
  });

  test('actualiza sin cambiar fecha de registro y elimina', () async {
    final fechaOriginal = DateTime(2026, 9, 1);
    await db.collection('clientes').doc('0102030405').set({
      ...cliente().toMap(),
      'fechaRegistro': Timestamp.fromDate(fechaOriginal),
    });
    await service.actualizarCliente(cliente(nombre: 'Ana Actualizada'));
    final actualizado = await service.buscarPorCedula('0102030405');
    expect(actualizado!.nombre, 'Ana Actualizada');
    expect(actualizado.fechaRegistro, fechaOriginal);
    expect(actualizado.fechaActualizacion, isNotNull);
    await service.eliminarCliente('0102030405');
    expect(await service.buscarPorCedula('0102030405'), isNull);
    expect(await service.obtenerClientes(), isEmpty);
  });

  test('actualizar un cliente inexistente no lo crea', () async {
    await expectLater(
      service.actualizarCliente(cliente()),
      throwsA(isA<FirebaseException>()),
    );
    expect(await service.obtenerClientes(), isEmpty);
  });

  test(
    'filtra días completos, excluye día siguiente y ordena descendente',
    () async {
      final fechas = [
        DateTime(2026, 9, 15, 23, 59, 59),
        DateTime(2026, 9, 16),
        DateTime(2026, 9, 17, 23, 59, 59, 999),
        DateTime(2026, 9, 18),
      ];
      for (var i = 0; i < fechas.length; i++) {
        final c = cliente(cedula: '010203040$i');
        await db.collection('clientes').doc(c.id).set({
          ...c.toMap(),
          'fechaRegistro': Timestamp.fromDate(fechas[i]),
        });
      }
      final encontrados = await service.obtenerClientes(
        desde: DateTime(2026, 9, 16, 15),
        hasta: DateTime(2026, 9, 17),
      );
      expect(encontrados.map((c) => c.id), ['0102030402', '0102030401']);
      expect(await service.obtenerClientes(), hasLength(4));
      expect(
        await service.obtenerClientes(desde: DateTime(2026, 9, 19)),
        isEmpty,
      );
      await expectLater(
        service.obtenerClientes(
          desde: DateTime(2026, 9, 18),
          hasta: DateTime(2026, 9, 16),
        ),
        throwsA(isA<ClienteException>()),
      );
    },
  );

  test('consulta en vivo refleja altas, cambios y eliminaciones', () async {
    final emisiones = <List<Cliente>>[];
    final subscription = service
        .observarClientes(cedula: '0102030405')
        .listen(emisiones.add);
    await Future<void>.delayed(Duration.zero);
    await service.crearCliente(cliente());
    await Future<void>.delayed(Duration.zero);
    await service.actualizarCliente(cliente(nombre: 'Actualizado'));
    await Future<void>.delayed(Duration.zero);
    await service.eliminarCliente('0102030405');
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    expect(emisiones.first, isEmpty);
    expect(
      emisiones.any((lista) => lista.any((c) => c.nombre == 'Ana Pérez')),
      isTrue,
    );
    expect(
      emisiones.any((lista) => lista.any((c) => c.nombre == 'Actualizado')),
      isTrue,
    );
    expect(emisiones.last, isEmpty);
  });

  test('rechaza cédulas inválidas antes de escribir', () async {
    await expectLater(
      service.crearCliente(cliente(cedula: '123/456')),
      throwsA(isA<ClienteException>()),
    );
    expect(await service.obtenerClientes(), isEmpty);
  });
}
