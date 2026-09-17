import 'package:flutter/material.dart';

import '../models/cliente.dart';
import '../service/cliente_service.dart';
import 'client_registration_screen.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key, this.clienteService = const ClienteService()});

  final ClienteService clienteService;

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  final _buscarController = TextEditingController();
  final _buscarKey = GlobalKey<FormState>();
  late Stream<List<Cliente>> _clientes;
  String? _cedula;
  DateTimeRange? _rango;
  bool _eliminando = false;
  int _consultaVersion = 0;

  @override
  void initState() {
    super.initState();
    _cargarConsulta();
  }

  void _cargarConsulta() {
    _consultaVersion++;
    try {
      _clientes = widget.clienteService.observarClientes(
        cedula: _cedula,
        desde: _rango?.start,
        hasta: _rango?.end,
      );
    } catch (error) {
      _clientes = Stream.error(error);
    }
  }

  void _buscar() {
    if (!_buscarKey.currentState!.validate()) return;
    setState(() {
      _cedula = _buscarController.text.trim();
      _rango = null;
      _cargarConsulta();
    });
  }

  void _limpiar() {
    setState(() {
      _buscarKey.currentState?.reset();
      _buscarController.clear();
      _cedula = null;
      _rango = null;
      _cargarConsulta();
    });
  }

  Future<void> _seleccionarFechas() async {
    final ahora = DateTime.now();
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(ahora.year + 1, 12, 31),
      initialDateRange: _rango,
      helpText: 'Filtrar por fecha de registro',
      saveText: 'Aplicar',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      fieldStartLabelText: 'Desde',
      fieldEndLabelText: 'Hasta',
    );
    if (rango == null || !mounted) return;
    setState(() {
      _rango = rango;
      _cedula = null;
      _buscarKey.currentState?.reset();
      _buscarController.clear();
      _cargarConsulta();
    });
  }

  Future<void> _abrirFormulario([Cliente? cliente]) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ClientRegistrationScreen(
          cliente: cliente,
          clienteService: widget.clienteService,
        ),
      ),
    );
  }

  Future<void> _eliminar(Cliente cliente) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          '¿Deseas eliminar a ${cliente.nombre} (cédula ${cliente.cedula})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _eliminando = true);
    try {
      await widget.clienteService.eliminarCliente(cliente.cedula);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente eliminado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeErrorCliente(error))));
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  String _fecha(DateTime fecha) {
    final local = fecha.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: _eliminando ? null : () => _abrirFormulario(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Nuevo cliente'),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _buscarKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _buscarController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.search,
                          validator: ClienteService.validarCedula,
                          onFieldSubmitted: (_) => _buscar(),
                          decoration: const InputDecoration(
                            labelText: 'Buscar por cédula',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _buscar,
                        tooltip: 'Buscar cliente',
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _seleccionarFechas,
                      icon: const Icon(Icons.date_range),
                      label: const Text('Filtrar por fecha'),
                    ),
                    TextButton(
                      onPressed: _limpiar,
                      child: const Text('Mostrar todos'),
                    ),
                  ],
                ),
                if (_rango != null)
                  Text(
                    'Registro: ${_fecha(_rango!.start)} — ${_fecha(_rango!.end)}',
                  ),
                if (_cedula != null) Text('Cédula: $_cedula'),
                if (_eliminando) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
        StreamBuilder<List<Cliente>>(
          key: ValueKey(_consultaVersion),
          stream: _clientes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        mensajeErrorCliente(snapshot.error!),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => setState(_cargarConsulta),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final clientes = snapshot.data!;
            if (clientes.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _cedula != null
                        ? 'Cliente no encontrado'
                        : _rango != null
                        ? 'No hay clientes registrados en estas fechas'
                        : 'No hay clientes registrados',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: clientes.length,
                itemBuilder: (context, index) {
                  final cliente = clientes[index];
                  return Card(
                    key: ValueKey(cliente.cedula),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cliente.nombre,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('Cédula: ${cliente.cedula}'),
                          Text('Teléfono: ${cliente.telefono}'),
                          Text('${cliente.direccion} · ${cliente.ciudad}'),
                          Text(
                            'Registro: ${cliente.fechaRegistro == null ? 'Pendiente de sincronización' : _fecha(cliente.fechaRegistro!)}',
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: _eliminando
                                    ? null
                                    : () => _abrirFormulario(cliente),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                              ),
                              TextButton.icon(
                                onPressed: _eliminando
                                    ? null
                                    : () => _eliminar(cliente),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
