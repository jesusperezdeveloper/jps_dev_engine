# /dev-new

Crea un nuevo proyecto Flutter basado en la arquitectura del JPS Dev Engine.

## Descripción

Este comando genera un proyecto Flutter completo con toda la estructura de carpetas, configuración y archivos base siguiendo los estándares del engine. Ejecuta `flutter create` internamente y luego aplica la arquitectura Clean Architecture con BLoC.

## Uso y Sintaxis

### Como Skill de Claude Code
```
/dev-new my_app
/dev-new my_app --org com.mycompany
/dev-new my_app --with-firebase
```

### Como Script Bash
```bash
./scripts/dev-new.sh my_app
./scripts/dev-new.sh my_app --org com.mycompany
```

## Opciones

| Opción | Descripción | Default |
|--------|-------------|---------|
| `--org` | Organization identifier | com.jpsdeveloper |
| `--with-firebase` | Incluir configuración de Firebase | false |
| `--with-supabase` | Incluir configuración de Supabase | false |
| `--platforms` | Plataformas a generar | ios,android,web |
| `--description` | Descripción del proyecto | - |

## Ejemplos

### Crear proyecto básico
```
/dev-new my_awesome_app
```
Output:
```
Creating new Flutter project: my_awesome_app
Using JPS Dev Engine v1.0.0

Step 1/5: Running flutter create...
  ✓ Flutter project created

Step 2/5: Creating architecture structure...
  ✓ lib/core/ created
  ✓ lib/data/ created
  ✓ lib/domain/ created
  ✓ lib/presentation/ created

Step 3/5: Generating base files...
  ✓ lib/core/di/injection.dart
  ✓ lib/core/theme/app_theme.dart
  ✓ lib/core/widgets/responsive/app_layout_builder.dart
  ✓ lib/main.dart (updated)

Step 4/5: Configuring dependencies...
  ✓ flutter_bloc: ^8.1.3
  ✓ get_it: ^7.6.0
  ✓ equatable: ^2.0.5

Step 5/5: Setting up Claude...
  ✓ CLAUDE.md created
  ✓ .engine_version created

Done! Project created at ./my_awesome_app

Next steps:
  cd my_awesome_app
  flutter pub get
  /dev-check
```

### Crear proyecto con Firebase
```
/dev-new my_saas_app --with-firebase --org com.iautomat
```
Output:
```
Creating new Flutter project: my_saas_app
...

Step 4/5: Configuring dependencies...
  ✓ flutter_bloc: ^8.1.3
  ✓ firebase_core: ^2.24.0
  ✓ firebase_auth: ^4.15.0
  ✓ cloud_firestore: ^4.13.0

Step 5/5: Generating Firebase config...
  ✓ lib/core/config/firebase_options.dart (template)
  ! Remember to run: flutterfire configure

Done!
```

## Estructura Generada

```
my_app/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── di/
│   │   │   └── injection.dart
│   │   ├── extensions/
│   │   │   └── context_extensions.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_theme.dart
│   │   │   └── app_typography.dart
│   │   └── widgets/
│   │       └── responsive/
│   │           ├── app_layout_builder.dart
│   │           └── breakpoints.dart
│   │
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   │
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   │
│   ├── presentation/
│   │   └── features/
│   │       └── home/
│   │           ├── bloc/
│   │           │   ├── home_bloc.dart
│   │           │   ├── home_event.dart
│   │           │   └── home_state.dart
│   │           ├── layouts/
│   │           │   ├── home_mobile_layout.dart
│   │           │   ├── home_tablet_layout.dart
│   │           │   └── home_desktop_layout.dart
│   │           └── page/
│   │               └── home_page.dart
│   │
│   └── main.dart
│
├── test/
│   ├── core/
│   ├── data/
│   ├── domain/
│   └── presentation/
│
├── pubspec.yaml
├── analysis_options.yaml
├── CLAUDE.md
└── .engine_version
```

## Flujo de Ejecución

```
1. Validar nombre del proyecto
   ├── snake_case requerido
   └── No puede empezar con número

2. Verificar que no existe directorio
   └── Si existe → Error o --force para sobrescribir

3. Ejecutar flutter create
   └── flutter create --org {org} --platforms {platforms} {name}

4. Eliminar archivos por defecto innecesarios
   ├── lib/main.dart (se regenera)
   └── test/widget_test.dart

5. Crear estructura de carpetas
   ├── lib/core/**
   ├── lib/data/**
   ├── lib/domain/**
   └── lib/presentation/**

6. Generar archivos base desde templates
   ├── Core widgets (AppLayoutBuilder, etc.)
   ├── Theme base
   ├── DI setup (GetIt)
   └── main.dart configurado

7. Actualizar pubspec.yaml
   ├── Agregar dependencias requeridas
   └── Configurar assets si aplica

8. Copiar/generar analysis_options.yaml

9. Crear CLAUDE.md del proyecto
   └── Basado en template del engine

10. Crear .engine_version
    └── Registrar versión usada

11. Mostrar resumen y next steps
```

## Archivos Relacionados

- `ENGINE_VERSION.yaml` - Versión del engine usada
- `flutter/templates/` - Templates de archivos base
- `.engine_version` - Versión del proyecto (generado)

## Ver También

- [/dev-version](dev-version.md) - Ver versión del engine
- [/dev-check](dev-check.md) - Verificar proyecto
- [/dev-upgrade](dev-upgrade.md) - Actualizar proyecto
