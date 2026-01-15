# /dev-upgrade

Actualiza un proyecto existente a una nueva versión del JPS Dev Engine.

## Descripción

Este comando compara la versión del engine usada en el proyecto actual con la última versión disponible, muestra los cambios entre versiones y aplica las migraciones necesarias. Permite actualizar de forma segura manteniendo el código existente.

## Uso y Sintaxis

### Como Skill de Claude Code
```
/dev-upgrade
/dev-upgrade --dry-run
/dev-upgrade --to 1.2.0
```

### Como Script Bash
```bash
./scripts/dev-upgrade.sh
./scripts/dev-upgrade.sh --dry-run
./scripts/dev-upgrade.sh --to 1.2.0
```

## Opciones

| Opción | Descripción | Default |
|--------|-------------|---------|
| `--dry-run` | Muestra cambios sin aplicarlos | false |
| `--to` | Versión específica a la que actualizar | latest |
| `--force` | Fuerza upgrade incluso con cambios locales | false |
| `--backup` | Crea backup antes de actualizar | true |
| `--skip-migrations` | Solo actualiza versión, no aplica migraciones | false |

## Ejemplos

### Upgrade básico
```
/dev-upgrade
```
Output:
```
JPS Dev Engine - Upgrade
========================

Current Version: 1.0.0
Target Version: 1.1.0

Changes in 1.1.0:
  - Added: Golden test templates
  - Updated: AppLayoutBuilder with safe area support
  - Added: Error handling patterns in BLoC

Migrations to apply:
  1. Update AppLayoutBuilder import path
  2. Add new breakpoint constant (MOBILE_LANDSCAPE)

Creating backup at .backup/1.0.0/...
  ✓ Backup created

Applying migrations...
  [1/2] Updating AppLayoutBuilder...
    ✓ lib/core/widgets/responsive/app_layout_builder.dart

  [2/2] Adding breakpoint constant...
    ✓ lib/core/widgets/responsive/breakpoints.dart

Updating .engine_version...
  ✓ Version updated to 1.1.0

Upgrade complete!

Run /dev-check to verify your project.
```

### Dry run (preview)
```
/dev-upgrade --dry-run
```
Output:
```
JPS Dev Engine - Upgrade (DRY RUN)
==================================

Current Version: 1.0.0
Target Version: 1.1.0

Would apply these changes:

1. Update AppLayoutBuilder
   File: lib/core/widgets/responsive/app_layout_builder.dart
   Change: Add SafeArea wrapper to layouts

2. Add breakpoint constant
   File: lib/core/widgets/responsive/breakpoints.dart
   Change: Add MOBILE_LANDSCAPE = 480dp

No changes were made. Run without --dry-run to apply.
```

### Upgrade a versión específica
```
/dev-upgrade --to 1.0.1
```
Output:
```
Upgrading to specific version: 1.0.1

Note: Latest version is 1.1.0
      You can run /dev-upgrade again later to get to latest.

Changes in 1.0.1:
  - Fix: Typo in template
  - Fix: Missing export in barrel file
...
```

## Tipos de Migraciones

### 1. Automáticas
Cambios que se aplican automáticamente:
- Actualización de imports
- Renombrado de clases/funciones
- Agregar nuevos archivos
- Actualizar dependencias en pubspec.yaml

### 2. Manuales (con guía)
Cambios que requieren intervención:
- Reestructuración de arquitectura
- Cambios en lógica de negocio
- Migraciones de datos

### 3. Breaking Changes
Cambios incompatibles que se marcan claramente:
```
⚠️  BREAKING CHANGE in 2.0.0:
    AppLayoutBuilder ahora requiere SafeAreaConfig

    Before:
      AppLayoutBuilder(mobile: ..., tablet: ..., desktop: ...)

    After:
      AppLayoutBuilder(
        safeArea: SafeAreaConfig.all(),
        mobile: ...,
        tablet: ...,
        desktop: ...
      )

    Action required: Update all usages of AppLayoutBuilder
```

## Flujo de Ejecución

```
1. Verificar proyecto válido
   └── Buscar .engine_version
       └── Si no existe → Error: "Project not initialized with engine"

2. Cargar versiones
   ├── current_version = .engine_version
   └── target_version = --to || ENGINE_VERSION.yaml

3. Validar upgrade path
   └── Si current >= target → "Already up to date"

4. Cargar changelog entre versiones
   └── Extraer todas las entradas de current+1 a target

5. Si --dry-run:
   └── Mostrar preview y salir

6. Verificar git status
   ├── Si hay cambios sin commit y no --force
   └── → Error: "Commit or stash changes first"

7. Crear backup
   └── Copiar archivos afectados a .backup/{version}/

8. Aplicar migraciones en orden
   ├── Para cada versión intermedia:
   │   └── Ejecutar migration scripts
   └── Registrar progreso

9. Actualizar .engine_version
   └── Escribir nueva versión

10. Verificar resultado
    └── Ejecutar /dev-check internamente

11. Mostrar resumen
    ├── Archivos modificados
    ├── Migraciones manuales pendientes
    └── Next steps
```

## Rollback

Si algo sale mal durante el upgrade:

```bash
# Restaurar desde backup
./scripts/dev-upgrade.sh --rollback

# O manualmente
cp -r .backup/1.0.0/* ./
echo "1.0.0" > .engine_version
```

## Exit Codes

| Code | Significado |
|------|-------------|
| 0 | Upgrade exitoso |
| 1 | Error durante upgrade (backup disponible) |
| 2 | Proyecto inválido o no inicializado |
| 3 | Cambios locales sin commit (usar --force) |

## Archivos Relacionados

- `ENGINE_VERSION.yaml` - Changelog y migraciones
- `.engine_version` - Versión actual del proyecto
- `.backup/` - Backups de versiones anteriores

## Ver También

- [/dev-version](dev-version.md) - Ver versión actual
- [/dev-check](dev-check.md) - Verificar después de upgrade
- [/dev-new](dev-new.md) - Crear nuevo proyecto
