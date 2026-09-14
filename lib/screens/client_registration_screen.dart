import 'package:flutter/material.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({super.key});

  @override
  State<ClientRegistrationScreen> createState() =>
      _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ciudadController = TextEditingController();

  void _guardarCliente() {
    if (!_formKey.currentState!.validate()) return;

    // Por ahora solo mostramos la confirmación; después se puede guardar en Firebase.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cliente registrado correctamente')),
    );
    _formKey.currentState!.reset();
    _cedulaController.clear();
    _nombreController.clear();
    _direccionController.clear();
    _telefonoController.clear();
    _ciudadController.clear();
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  String? _campoRequerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de clientes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cedulaController,
                keyboardType: TextInputType.number,
                validator: _campoRequerido,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                validator: _campoRequerido,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                validator: _campoRequerido,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                validator: _campoRequerido,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ciudadController,
                validator: _campoRequerido,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _guardarCliente,
                  icon: const Icon(Icons.save),
                  label: const Text('REGISTRAR CLIENTE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
