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

class _CategoriaMenu {
  const _CategoriaMenu(
    this.nombre,
    this.descripcion,
    this.icono,
    this.color,
    this.fondo,
  );

  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;
  final Color fondo;
}

const _fondoMenu = Color(0xFFFFFAF5);
const _tintaMenu = Color(0xFF30241E);

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({
    super.key,
    this.clienteService = const ClienteService(),
  });

  final ClienteService clienteService;

  static const _categorias = [
    _CategoriaMenu(
      'Hamburguesas',
      'Tus favoritas de siempre',
      Icons.lunch_dining_rounded,
      Color(0xFFAD431E),
      Color(0xFFFFE9DC),
    ),
    _CategoriaMenu(
      'Combos',
      'Todo en un solo pedido',
      Icons.fastfood_rounded,
      Color(0xFF855B12),
      Color(0xFFFFF1CB),
    ),
    _CategoriaMenu(
      'Extras',
      'El acompañamiento ideal',
      Icons.local_dining_rounded,
      Color(0xFF3B674B),
      Color(0xFFE5F0DF),
    ),
    _CategoriaMenu(
      'Bebidas',
      'Un toque refrescante',
      Icons.local_drink_rounded,
      Color(0xFF326778),
      Color(0xFFE0F0F4),
    ),
  ];

  // Catálogo local compartido por las tarjetas y el detalle de cada categoría.
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

  Widget _carrito(BuildContext context) => IconButton(
    tooltip: 'Ver pedido',
    icon: const Badge(
      label: Text('1'),
      child: Icon(Icons.shopping_bag_outlined),
    ),
    onPressed: () => _mostrarFormularioPedido(context),
  );

  void _abrirCategoria(BuildContext context, _CategoriaMenu categoria) {
    final productos = _productos
        .where((producto) => producto.categoria == categoria.nombre)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: _fondoMenu,
          appBar: AppBar(
            backgroundColor: _fondoMenu,
            foregroundColor: _tintaMenu,
            title: Text(categoria.nombre),
            actions: [_carrito(context), const SizedBox(width: 12)],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: categoria.fondo,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            categoria.icono,
                            size: 48,
                            color: categoria.color,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoria.descripcion,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: _tintaMenu,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${productos.length} productos',
                                  style: TextStyle(color: categoria.color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final producto in productos)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFEDE4DC)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: categoria.fondo,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                categoria.icono,
                                color: categoria.color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.nombre,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: _tintaMenu,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${producto.precio.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: categoria.color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _seleccionarOpcion(BuildContext context, String opcion) {
    switch (opcion) {
      case 'registrar_cliente':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                ClientRegistrationScreen(clienteService: clienteService),
          ),
        );
      case 'administracion':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => AdminScreen(clienteService: clienteService),
          ),
        );
      case 'cerrar_sesion':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => AuthScreen(clienteService: clienteService),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoMenu,
      appBar: AppBar(
        backgroundColor: _fondoMenu,
        foregroundColor: _tintaMenu,
        titleSpacing: 20,
        title: const Text(
          'BurgerExpress',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
        actions: [
          _carrito(context),
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (opcion) => _seleccionarOpcion(context, opcion),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'registrar_cliente',
                child: Text('Registrar cliente'),
              ),
              PopupMenuItem(
                value: 'administracion',
                child: Text('Administración'),
              ),
              PopupMenuItem(
                value: 'cerrar_sesion',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFAD3D1B), Color(0xFFD75A29)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu_rounded,
                              size: 18,
                              color: Color(0xFFFFE2CE),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'HECHO PARA TU ANTOJO',
                                style: TextStyle(
                                  color: Color(0xFFFFE2CE),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '¿Qué se te antoja hoy?',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tu próxima favorita está en nuestro menú.',
                          style: TextStyle(color: Colors.white, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Explora el menú',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _tintaMenu,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Elige una categoría para ver sus productos.',
                    style: TextStyle(color: Color(0xFF75665D), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final escala =
                          MediaQuery.textScalerOf(context).scale(16) / 16;
                      final columnas =
                          constraints.maxWidth < 320 ||
                              (escala > 1.3 && constraints.maxWidth < 600)
                          ? 1
                          : 2;
                      final ancho =
                          (constraints.maxWidth - 14 * (columnas - 1)) /
                          columnas;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          for (final categoria in _categorias)
                            SizedBox(
                              width: ancho,
                              child: _TarjetaCategoria(
                                categoria: categoria,
                                cantidad: _productos
                                    .where(
                                      (producto) =>
                                          producto.categoria ==
                                          categoria.nombre,
                                    )
                                    .length,
                                onTap: () =>
                                    _abrirCategoria(context, categoria),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaCategoria extends StatelessWidget {
  const _TarjetaCategoria({
    required this.categoria,
    required this.cantidad,
    required this.onTap,
  });

  final _CategoriaMenu categoria;
  final int cantidad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTap: onTap,
      label: '${categoria.nombre}, $cantidad productos',
      excludeSemantics: true,
      child: Material(
        color: categoria.fondo,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categoria.icono,
                    size: 34,
                    color: categoria.color,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  categoria.nombre,
                  style: const TextStyle(
                    color: _tintaMenu,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$cantidad productos',
                        style: TextStyle(color: categoria.color, fontSize: 13),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: categoria.color,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
