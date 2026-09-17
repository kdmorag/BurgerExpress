import 'package:flutter/material.dart';

import 'auth_screen.dart';
import '../service/cliente_service.dart';
import 'admin_screen.dart';
import 'client_registration_screen.dart';

class _ProductoMenu {
  const _ProductoMenu(this.nombre, this.categoria, this.precio);

  final String nombre;
  final String categoria;
  final double precio;
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({
    super.key,
    this.clienteService = const ClienteService(),
  });

  final ClienteService clienteService;

  static const _categorias = ['Hamburguesas', 'Combos', 'Extras', 'Bebidas'];

  // Datos locales para practicar ListView y la navegación por categorías.
  static const _productos = [
    _ProductoMenu('Burger Clásica', 'Hamburguesas', 8.99),
    _ProductoMenu('Burger Doble', 'Hamburguesas', 10.50),
    _ProductoMenu('Combo Personal', 'Combos', 12.00),
    _ProductoMenu('Combo Familiar', 'Combos', 15.50),
    _ProductoMenu('Papas fritas', 'Extras', 2.50),
    _ProductoMenu('Aros de cebolla', 'Extras', 3.00),
    _ProductoMenu('Gaseosa', 'Bebidas', 1.50),
    _ProductoMenu('Agua', 'Bebidas', 1.00),
  ];

  void _mostrarFormularioPedido(BuildContext context) {
    var tipoEntrega = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que el modal suba si aparece el teclado
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24.0,
          right: 24.0,
          top: 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de tu Pedido',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const ListTile(
              title: Text('1x BurgerExpress Clásica'),
              trailing: Text('\$8.99'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            Text(
              'Tipo de Entrega',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // Opciones de entrega requeridas por el negocio TM1[cite: 1]
            StatefulBuilder(
              builder: (context, setModalState) => RadioGroup<int>(
                groupValue: tipoEntrega,
                onChanged: (valor) {
                  if (valor != null) setModalState(() => tipoEntrega = valor);
                },
                child: const Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(value: 1, title: Text('Local')),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        value: 2,
                        title: Text('Domicilio'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Dirección o Referencia',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pedido confirmado con éxito'),
                    ),
                  );
                },
                child: const Text('CONFIRMAR PEDIDO'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // El controlador mantiene sincronizados TabBar y TabBarView.
    return DefaultTabController(
      length: _categorias.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menú BurgerExpress'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final categoria in _categorias) Tab(text: categoria)],
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Más opciones',
              onSelected: (opcion) {
                if (opcion == 'registrar_cliente') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientRegistrationScreen(
                        clienteService: clienteService,
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'registrar_cliente',
                  child: Text('Registrar cliente'),
                ),
              ],
            ),
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthScreen(clienteService: clienteService),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Administración',
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminScreen(clienteService: clienteService),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Badge(
                label: Text('1'),
                child: Icon(Icons.shopping_cart),
              ),
              onPressed: () => _mostrarFormularioPedido(context),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            for (final categoria in _categorias)
              _crearListaProductos(categoria),
          ],
        ),
      ),
    );
  }

  Widget _crearListaProductos(String categoria) {
    final productosCategoria = _productos
        .where((producto) => producto.categoria == categoria)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: productosCategoria.length,
      itemBuilder: (context, index) {
        final producto = productosCategoria[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.fastfood, color: Colors.deepOrange),
            title: Text(producto.nombre),
            subtitle: Text(producto.categoria),
            trailing: Text('\$${producto.precio.toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }
}
