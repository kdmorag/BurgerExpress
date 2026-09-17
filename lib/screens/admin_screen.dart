import 'package:flutter/material.dart';

import '../service/cliente_service.dart';
import 'clients_view.dart';

class Product {
  Product({
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  String name;
  String category;
  double price;
  int stock;
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, this.clienteService = const ClienteService()});

  final ClienteService clienteService;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<Product> _products = [
    Product(
      name: 'Burger Clásica',
      category: 'Hamburguesas',
      price: 8.99,
      stock: 20,
    ),
    Product(
      name: 'Combo Familiar',
      category: 'Combos',
      price: 15.50,
      stock: 10,
    ),
  ];

  Future<void> _mostrarFormularioProducto({Product? producto}) async {
    final nombreController = TextEditingController(text: producto?.name ?? '');
    final precioController = TextEditingController(
      text: producto?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: producto?.stock.toString() ?? '',
    );

    String categoria = producto?.category ?? 'Hamburguesas';

    final guardado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                producto == null ? 'Crear producto' : 'Editar producto',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.fastfood),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: categoria,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Hamburguesas',
                          child: Text('Hamburguesas'),
                        ),
                        DropdownMenuItem(
                          value: 'Combos',
                          child: Text('Combos'),
                        ),
                        DropdownMenuItem(
                          value: 'Extras',
                          child: Text('Extras'),
                        ),
                        DropdownMenuItem(
                          value: 'Bebidas',
                          child: Text('Bebidas'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => categoria = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: precioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixText: '\$ ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final nombre = nombreController.text.trim();
                    final precio = double.tryParse(precioController.text);
                    final stock = int.tryParse(stockController.text);

                    if (nombre.isEmpty || precio == null || stock == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Completa todos los campos correctamente',
                          ),
                        ),
                      );
                      return;
                    }

                    if (producto == null) {
                      _products.add(
                        Product(
                          name: nombre,
                          category: categoria,
                          price: precio,
                          stock: stock,
                        ),
                      );
                    } else {
                      producto
                        ..name = nombre
                        ..category = categoria
                        ..price = precio
                        ..stock = stock;
                    }

                    Navigator.pop(context, true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    nombreController.dispose();
    precioController.dispose();
    stockController.dispose();

    if (guardado == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _eliminarProducto(Product producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Deseas eliminar "${producto.name}"?'),
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
        );
      },
    );

    if (confirmar == true) {
      setState(() => _products.remove(producto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory_2), text: 'Productos'),
              Tab(icon: Icon(Icons.people), text: 'Clientes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _construirVistaProductos(),
            ClientsView(clienteService: widget.clienteService),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);

            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                if (tabController.index != 0) {
                  return const SizedBox.shrink();
                }

                return FloatingActionButton.extended(
                  onPressed: () => _mostrarFormularioProducto(),
                  icon: const Icon(Icons.add),
                  label: const Text('Producto'),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _construirVistaProductos() {
    if (_products.isEmpty) {
      return const Center(child: Text('No hay productos registrados'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final producto = _products[index];

        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.fastfood)),
            title: Text(producto.name),
            subtitle: Text('${producto.category} • Stock: ${producto.stock}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${producto.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _mostrarFormularioProducto(producto: producto);
                    } else {
                      _eliminarProducto(producto);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
