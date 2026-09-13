# BurgerExpress

Aplicación Flutter para explorar el menú de BurgerExpress, gestionar productos y clientes desde el panel de administración y simular pedidos para consumo local o domicilio.

El proyecto es un prototipo funcional: el catálogo y la administración usan datos locales en memoria, mientras que Firebase está preparado como punto de integración para autenticación y persistencia.

## Requisitos

- Flutter (canal estable) con Dart 3.13 o superior
- Android Studio/Xcode si se desea ejecutar en un dispositivo móvil
- Un proyecto Firebase configurado para las plataformas que se vayan a ejecutar

## Ejecutar localmente

```bash
flutter pub get
flutter run
```

Para comprobar el código y ejecutar las pruebas:

```bash
flutter analyze
flutter test
```

## Plataformas

La estructura incluye Android, iOS, macOS, Linux, Windows y Web. Antes de compilar una plataforma adicional, genera su configuración de Firebase con FlutterFire CLI y coloca los archivos de configuración correspondientes en el proyecto. Los archivos específicos de cada equipo, como `android/local.properties`, están excluidos de Git.

## Funcionalidades actuales

- Inicio de sesión y registro (interfaz)
- Catálogo por categorías: hamburguesas, combos, extras y bebidas
- Carrito y confirmación de pedido (flujo simulado)
- Administración local de productos (crear, editar y eliminar)
- Consulta de clientes de ejemplo

## Estructura

- `lib/main.dart`: arranque y tema de la aplicación
- `lib/screens/`: pantallas de autenticación, catálogo y administración
- `assets/images/`: recursos visuales
- `test/`: pruebas Flutter

## Estado del proyecto

Las operaciones de autenticación, registro, carrito y persistencia todavía son demostraciones de interfaz. Para producción deben conectarse a Firebase Authentication y una base de datos, además de añadir reglas de seguridad y validaciones del lado servidor.

## Licencia

Este proyecto no declara todavía una licencia. Añade un archivo `LICENSE` antes de distribuirlo públicamente.
