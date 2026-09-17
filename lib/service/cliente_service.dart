import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cliente.dart';

class ClienteException implements Exception {
  const ClienteException(this.mensaje);
  final String mensaje;

  @override
  String toString() => mensaje;
}

class ClienteService {
  const ClienteService({this.firestore});

  final FirebaseFirestore? firestore;
  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _clientes =>
      _db.collection('clientes');

  static String? validarCedula(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(valor.trim())) {
      return 'Ingresa una cédula de 10 dígitos';
    }
    return null;
  }

  String _cedulaValida(String cedula) {
    final error = validarCedula(cedula);
    if (error != null) throw ClienteException(error);
    return cedula.trim();
  }

  void _validarCliente(Cliente cliente) {
    _cedulaValida(cliente.cedula);
    if ([
      cliente.nombre,
      cliente.direccion,
      cliente.telefono,
      cliente.ciudad,
    ].any((valor) => valor.trim().isEmpty)) {
      throw const ClienteException('Completa todos los campos del cliente');
    }
  }

  Future<void> crearCliente(Cliente cliente) async {
    _validarCliente(cliente);
    final ref = _clientes.doc(cliente.cedula.trim());
    // La lectura y la creación son atómicas para no sobrescribir duplicados.
    await _db.runTransaction((transaction) async {
      if ((await transaction.get(ref)).exists) {
        throw const ClienteException('Ya existe un cliente con esta cédula');
      }
      transaction.set(ref, {
        ...cliente.toMap(),
        'fechaRegistro': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<Cliente?> buscarPorCedula(String cedula) async {
    final doc = await _clientes.doc(_cedulaValida(cedula)).get();
    return doc.exists ? Cliente.fromSnapshot(doc) : null;
  }

  Future<void> actualizarCliente(Cliente cliente) async {
    _validarCliente(cliente);
    await _clientes.doc(cliente.cedula.trim()).update({
      ...cliente.toMap(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarCliente(String cedula) async {
    await _clientes.doc(_cedulaValida(cedula)).delete();
  }

  Query<Map<String, dynamic>> _consulta({DateTime? desde, DateTime? hasta}) {
    Query<Map<String, dynamic>> query = _clientes;
    final inicio = desde == null
        ? null
        : DateTime(desde.year, desde.month, desde.day);
    final fin = hasta == null
        ? null
        : DateTime(hasta.year, hasta.month, hasta.day + 1);
    if (inicio != null && fin != null && !inicio.isBefore(fin)) {
      throw const ClienteException('El rango de fechas no es válido');
    }
    if (inicio != null) {
      query = query.where(
        'fechaRegistro',
        isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
      );
    }
    if (fin != null) {
      query = query.where('fechaRegistro', isLessThan: Timestamp.fromDate(fin));
    }
    return query.orderBy('fechaRegistro', descending: true);
  }

  Future<List<Cliente>> obtenerClientes({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final snapshot = await _consulta(desde: desde, hasta: hasta).get();
    return snapshot.docs.map(Cliente.fromSnapshot).toList();
  }

  Stream<List<Cliente>> observarClientes({
    String? cedula,
    DateTime? desde,
    DateTime? hasta,
  }) {
    if (cedula != null && cedula.trim().isNotEmpty) {
      return _clientes
          .doc(_cedulaValida(cedula))
          .snapshots()
          .map((doc) => doc.exists ? [Cliente.fromSnapshot(doc)] : <Cliente>[]);
    }
    return _consulta(desde: desde, hasta: hasta).snapshots().map(
      (snapshot) => snapshot.docs.map(Cliente.fromSnapshot).toList(),
    );
  }
}

String mensajeErrorCliente(Object error) {
  if (error is ClienteException) return error.mensaje;
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => 'No tienes permisos para acceder a los clientes. Revisa las reglas de Firestore y la sesión.',
      'unauthenticated' => 'Se requiere una sesión de Firebase para continuar.',
      'unavailable' =>
        'No se pudo conectar. Comprueba tu conexión e inténtalo de nuevo.',
      'not-found' => 'El cliente ya no existe. Actualiza la lista.',
      'failed-precondition' => 'No se pudo consultar la base. Revisa su configuración e índices de Firestore.',
      _ => 'No se pudo completar la operación. Inténtalo de nuevo.',
    };
  }
  return 'No se pudo completar la operación. Inténtalo de nuevo.';
}
