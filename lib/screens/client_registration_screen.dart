import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../service/cliente_service.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({
    super.key,
    this.cliente,
    this.clienteService = const ClienteService(),
  });

  final Cliente? cliente;
  final ClienteService clienteService;

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

  bool _guardando = false;
  String? _error;
  bool get _editando => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    if (cliente != null) {
      _cedulaController.text = cliente.cedula;
      _nombreController.text = cliente.nombre;
      _direccionController.text = cliente.direccion;
      _telefonoController.text = cliente.telefono;
      _ciudadController.text = cliente.ciudad;
    }
  }

  Future<void> _guardarCliente() async {
    if (_guardando || !_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    final cliente = Cliente(
      cedula: _cedulaController.text.trim(),
      nombre: _nombreController.text.trim(),
      direccion: _direccionController.text.trim(),
      telefono: _telefonoController.text.trim(),
      ciudad: _ciudadController.text.trim(),
    );
    try {
      if (_editando) {
        await widget.clienteService.actualizarCliente(cliente);
      } else {
        await widget.clienteService.crearCliente(cliente);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Cliente actualizado correctamente'
                : 'Cliente registrado correctamente',
          ),
        ),
      );
      if (_editando) {
        Navigator.pop(context, true);
      } else {
        _formKey.currentState!.reset();
        for (final controller in [
          _cedulaController,
          _nombreController,
          _direccionController,
          _telefonoController,
          _ciudadController,
        ]) {
          controller.clear();
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = mensajeErrorCliente(error));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
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
      appBar: AppBar(
        title: Text(_editando ? 'Editar cliente' : 'Registro de clientes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          canPop: !_guardando,
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cedulaController,
                readOnly: _editando,
                enabled: !_guardando,
                keyboardType: TextInputType.number,
                validator: ClienteService.validarCedula,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                enabled: !_guardando,
                validator: _campoRequerido,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                enabled: !_guardando,
                validator: _campoRequerido,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                enabled: !_guardando,
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
                enabled: !_guardando,
                validator: _campoRequerido,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardarCliente,
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _guardando
                        ? 'GUARDANDO...'
                        : _editando
                        ? 'ACTUALIZAR CLIENTE'
                        : 'REGISTRAR CLIENTE',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
