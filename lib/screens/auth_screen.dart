import 'package:flutter/material.dart';

import 'catalog_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  void _mostrarInfo(BuildContext context, String titulo, String contenido) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(contenido),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BurgerExpress'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'INICIAR SESIÓN'),
              Tab(text: 'REGISTRO'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Image.asset(
                'assets/images/logo.jpg',
                width: 140,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            
            // Sección informativa requerida por la rúbrica
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Quiénes Somos'),
                    onPressed: () => _mostrarInfo(
                      context,
                      'Nuestra Empresa',
                      'Misión: Proveer la mejor comida rápida...',
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.contact_support),
                    label: const Text('Contacto'),
                    onPressed: () => _mostrarInfo(
                      context,
                      'Contáctanos',
                      'Teléfono: 0999999999\nDirección: Local Centro',
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [_LoginFormulario(), _RegistroFormulario()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFormulario extends StatelessWidget {
  const _LoginFormulario();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                // En auth_screen.dart, dentro de _LoginFormulario
                onPressed: () {
                  // Navegación temporal para probar el diseño del Catálogo
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CatalogScreen(),
                    ), // Recuerda importar el archivo en auth_screen.dart
                  );
                },
                child: const Text('INGRESAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistroFormulario extends StatelessWidget {
  const _RegistroFormulario();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar guardado de cliente en base de datos
                },
                child: const Text('CREAR CUENTA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
