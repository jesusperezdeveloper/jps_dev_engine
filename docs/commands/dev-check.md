# /dev-check

Verifica que el proyecto actual cumple con la arquitectura y estándares del JPS Dev Engine.

## Descripción

Este comando analiza la estructura del proyecto Flutter actual y genera un reporte de compliance con las reglas del engine. Valida estructura de carpetas, uso de BLoC, layouts responsivos y convenciones de código.

## Uso y Sintaxis

### Como Skill de Claude Code
```
/dev-check
/dev-check --fix
/dev-check --strict
```

### Como Script Bash
```bash
./scripts/dev-check.sh [path/to/project]
./scripts/dev-check.sh --fix
```

## Opciones

| Opción | Descripción |
|--------|-------------|
| `--fix` | Intenta corregir problemas automáticamente |
| `--strict` | Modo estricto, falla con cualquier warning |
| `--json` | Output en formato JSON |
| `--verbose` | Muestra detalles de cada verificación |

## Verificaciones

### 1. Estructura de Carpetas
```
lib/
├── core/       ✓ Requerido
├── data/       ✓ Requerido
├── domain/     ✓ Requerido
└── presentation/
    └── features/  ✓ Requerido
```

### 2. Layouts Responsivos (por feature)
```
features/{name}/layouts/
├── {name}_mobile_layout.dart   ✓ Requerido
├── {name}_tablet_layout.dart   ✓ Requerido
└── {name}_desktop_layout.dart  ✓ Requerido
```

### 3. State Management
- ✓ BLoC permitido
- ✗ Provider NO permitido
- ✗ Riverpod NO permitido
- ✗ GetX NO permitido

### 4. Convenciones de Nombrado
- Archivos: `snake_case.dart`
- Clases: `PascalCase`
- Variables/funciones: `camelCase`

## Ejemplos

### Check básico
```
/dev-check
```
Output:
```
JPS Dev Engine - Project Check
==============================

Project: my_app
Engine Version: 1.0.0

Structure Check:
  ✓ lib/core/ exists
  ✓ lib/data/ exists
  ✓ lib/domain/ exists
  ✓ lib/presentation/features/ exists

Features Analysis:
  dashboard/
    ✓ mobile_layout.dart
    ✓ tablet_layout.dart
    ✓ desktop_layout.dart
    ✓ bloc/ found

  settings/
    ✓ mobile_layout.dart
    ✗ tablet_layout.dart (MISSING)
    ✓ desktop_layout.dart

State Management:
  ✓ Using BLoC (flutter_bloc: ^8.x)
  ✓ No Provider detected
  ✓ No Riverpod detected

Summary:
  Passed: 11
  Failed: 1
  Warnings: 0

Status: FAILED
```

### Check con fix automático
```
/dev-check --fix
```
Output:
```
Fixing issues...

Creating: lib/presentation/features/settings/layouts/settings_tablet_layout.dart
  → Generated from template

Summary:
  Fixed: 1
  Remaining: 0

Status: PASSED
```

## Flujo de Ejecución

```
1. Detectar raíz del proyecto Flutter
   └── Buscar pubspec.yaml
       └── Si no existe → Error: "Not a Flutter project"

2. Cargar configuración del engine
   └── Leer .engine_version o usar defaults

3. Verificar estructura base
   ├── lib/core/
   ├── lib/data/
   ├── lib/domain/
   └── lib/presentation/features/

4. Analizar cada feature
   ├── Verificar layouts (mobile/tablet/desktop)
   ├── Verificar bloc/ si tiene estado
   └── Verificar widgets/ específicos

5. Analizar pubspec.yaml
   ├── Detectar state management usado
   └── Verificar versiones de dependencias

6. Si --fix:
   └── Generar archivos faltantes desde templates

7. Generar reporte
   └── Formatear según --json o texto

8. Retornar exit code
   ├── 0 = PASSED
   └── 1 = FAILED
```

## Exit Codes

| Code | Significado |
|------|-------------|
| 0 | Todas las verificaciones pasaron |
| 1 | Una o más verificaciones fallaron |
| 2 | Error de configuración o proyecto inválido |

## Archivos Relacionados

- `ENGINE_VERSION.yaml` - Reglas y versión del engine
- `pubspec.yaml` - Dependencias del proyecto
- `analysis_options.yaml` - Reglas de linting

## Ver También

- [/dev-version](dev-version.md) - Ver versión del engine
- [/dev-upgrade](dev-upgrade.md) - Actualizar proyecto
- [/dev-new](dev-new.md) - Crear nuevo proyecto
