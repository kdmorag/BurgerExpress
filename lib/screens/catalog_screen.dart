import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'admin_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // Estado local temporal para el prototipo visual
  int _categoriaSeleccionada = 0;
  final List<String> _categorias = [
    'Hamburguesas',
    'Combos',
    'Extras',
    'Bebidas',
  ]; // Categorización requerida

  void _mostrarFormularioPedido(BuildContext context) {
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
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    value: 1,
                    groupValue: 1,
                    onChanged: (v) {},
                    title: const Text('Local'),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    value: 2,
                    groupValue: 1,
                    onChanged: (v) {},
                    title: const Text('Domicilio'),
                  ),
                ),
              ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú BurgerExpress'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Administración',
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminScreen()),
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
      body: Column(
        children: [
          // Selector de Categorías[cite: 1]
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(_categorias[index]),
                    selected: _categoriaSeleccionada == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _categoriaSeleccionada = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Grilla de Productos[cite: 1]
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6, // Elementos ficticios para el mockup
              itemBuilder: (context, index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder para la imagen del producto
                      Expanded(
                        child: Container(
                          color: Colors.grey.shade300,
                          width: double.infinity,
                          child: const Icon(
                            Icons.fastfood,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Producto ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              '\$8.99',
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // TODO: Lógica para agregar al carrito
                                },
                                child: const Text('Agregar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
