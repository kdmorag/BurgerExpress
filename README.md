# BurgerExpress

Aplicación Flutter para explorar el menú de BurgerExpress, gestionar clientes con Cloud Firestore y simular pedidos para consumo local o domicilio. El catálogo y la administración de productos todavía utilizan datos locales.

## Clientes

Desde el menú, selecciona **Registrar cliente**, o entra en **Administración → Clientes → Nuevo cliente**. La pestaña Clientes permite:

- Registrar cédula, nombre, dirección, teléfono y ciudad.
- Buscar por cédula exacta, conservando sus ceros iniciales.
- Editar datos sin cambiar la cédula ni la fecha de registro.
- Eliminar después de confirmar nombre y cédula.
- Consultar todos los clientes en tiempo real, ordenados del más reciente al más antiguo.
- Filtrar por un rango de fechas de registro, incluyendo completos ambos días. **Mostrar todos** limpia los filtros. Buscar una cédula reemplaza el filtro de fechas y viceversa.

Las cédulas requieren diez dígitos (validación de formato; no se comprueba el dígito verificador). El registro comprueba duplicados mediante una transacción. Si falla el guardado, conserva el formulario y muestra el error.

## Firebase y ejecución

El proyecto incluye `firebase_core`, `cloud_firestore` y la configuración generada en `lib/firebase_options.dart` para el proyecto `burgerexpress-25634`. Firestore debe tener una base `(default)` habilitada en modo nativo y reglas que permitan las operaciones de la sesión utilizada.

```bash
flutter pub get
flutter run
```

Para asociar otra cuenta/proyecto o añadir plataformas, usa `firebase login` y `flutterfire configure`, seleccionando las plataformas correspondientes.

El acceso actual de la aplicación es una simulación: `estudiante@burgerexpress.com` / `123456`. No crea una sesión de Firebase Authentication. Las reglas que exijan `request.auth != null` rechazarán este acceso; la aplicación muestra ese error. Antes de usar datos reales, conecta Firebase Authentication y configura reglas que autoricen exclusivamente al personal correspondiente. No se incluyen ni se despliegan reglas públicas desde este repositorio.

## Estructura del CRUD

- `lib/models/cliente.dart`: modelo y conversión de documentos. Las fechas pueden estar pendientes de sincronización.
- `lib/service/cliente_service.dart`: creación atómica, búsqueda, actualización, eliminación, consultas y mensajes de error.
- `lib/screens/client_registration_screen.dart`: formulario compartido para registro y edición.
- `lib/screens/clients_view.dart`: lista, búsqueda, filtro de fechas y acciones, integrada en `AdminScreen`.

Cada documento vive en `clientes/{cedula}`. Sus campos son `cedula`, `nombre`, `direccion`, `telefono`, `ciudad`, `fechaRegistro` y `fechaActualizacion`. Las fechas son timestamps asignados por el servidor. Al actualizar, se conserva `fechaRegistro`. El rango se interpreta en la zona horaria local del dispositivo, desde medianoche hasta la medianoche posterior al último día (exclusiva). Los documentos antiguos necesitan los mismos campos y una `fechaRegistro` de tipo Timestamp para aparecer correctamente en la lista ordenada.

## Verificación

```bash
flutter analyze
flutter test
flutter build web
```

Las pruebas utilizan `fake_cloud_firestore` y servicios controlados: no escriben datos en la base real. Cubren persistencia mediante el servicio, duplicados, actualización de fechas, búsqueda, eliminación, límites del rango de fechas, cambios en tiempo real, navegación y errores. No sustituyen una prueba de escritura con las reglas y conexión reales.

Para comprobarlo manualmente con datos ficticios: registra un cliente, vuelve a abrir la aplicación, búscalo por cédula, intenta duplicarlo, edita su teléfono, filtra por su fecha de registro y comprueba la cancelación y confirmación de eliminación.

Referencias: [configuración Flutter](https://firebase.google.com/docs/flutter/setup), [transacciones](https://firebase.google.com/docs/firestore/manage-data/transactions) y [consultas](https://firebase.google.com/docs/firestore/query-data/queries).
