import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  const Cliente({
    required this.cedula,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.ciudad,
    this.fechaRegistro,
    this.fechaActualizacion,
  });

  // La cédula es la identidad del documento y no cambia al editar.
  String get id => cedula;
  final String cedula;
  final String nombre;
  final String direccion;
  final String telefono;
  final String ciudad;
  final DateTime? fechaRegistro;
  final DateTime? fechaActualizacion;

  factory Cliente.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final datos = doc.data()!;
    return Cliente(
      cedula: doc.id,
      nombre: datos['nombre'] as String,
      direccion: datos['direccion'] as String,
      telefono: datos['telefono'] as String,
      ciudad: datos['ciudad'] as String,
      fechaRegistro: (datos['fechaRegistro'] as Timestamp?)?.toDate(),
      fechaActualizacion: (datos['fechaActualizacion'] as Timestamp?)?.toDate(),
    );
  }

  // Las fechas las asigna el servidor en el servicio, no el formulario.
  Map<String, dynamic> toMap() => {
    'cedula': cedula.trim(),
    'nombre': nombre.trim(),
    'direccion': direccion.trim(),
    'telefono': telefono.trim(),
    'ciudad': ciudad.trim(),
  };
}
