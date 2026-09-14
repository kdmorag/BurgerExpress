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

class _LoginFormulario extends StatefulWidget {
  const _LoginFormulario();

  @override
  State<_LoginFormulario> createState() => _LoginFormularioState();
}

class _LoginFormularioState extends State<_LoginFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();

  void _iniciarSesion() {
    if (!_formKey.currentState!.validate()) return;

    // Usuario de prueba para la práctica. No usa Firebase Authentication.
    final correo = _correoController.text.trim().toLowerCase();
    final clave = _claveController.text;
    if (correo == 'estudiante@burgerexpress.com' && clave == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CatalogScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo o contraseña incorrectos')),
      );
    }
  }

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final correo = value?.trim() ?? '';
                if (correo.isEmpty) return 'Ingresa tu correo';
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(correo)) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _claveController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                return null;
              },
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
                onPressed: _iniciarSesion,
                child: const Text('INGRESAR'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Usuario de prueba: estudiante@burgerexpress.com\n'
              'Contraseña: 123456',
              textAlign: TextAlign.center,
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
