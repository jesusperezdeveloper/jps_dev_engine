# /dev-version

Muestra la versión actual del JPS Dev Engine e información del sistema.

## Descripción

Este comando lee el archivo `ENGINE_VERSION.yaml` y muestra información detallada sobre la versión del engine, componentes incluidos y changelog. Si se ejecuta dentro de un proyecto que usa el engine, también compara la versión local con la del engine.

## Uso y Sintaxis

### Como Skill de Claude Code
```
/dev-version
/dev-version --compare
```

### Como Script Bash
```bash
./scripts/dev-version.sh
./scripts/dev-version.sh --compare
```

## Opciones

| Opción | Descripción |
|--------|-------------|
| `--compare` | Compara la versión del proyecto actual con la del engine |
| `--changelog` | Muestra el changelog completo |
| `--json` | Output en formato JSON |

## Ejemplos

### Ver versión actual
```
/dev-version
```
Output:
```
JPS Dev Engine v1.0.0
Released: 2025-01-15

Components:
  - Flutter Architecture: 1.0.0
  - Skills: 0
  - Memory Edits: 10
```

### Comparar con proyecto actual
```
/dev-version --compare
```
Output:
```
Engine Version: 1.0.0
Project Version: 1.0.0
Status: Up to date
```

### Ver changelog
```
/dev-version --changelog
```
Output:
```
Changelog:

v1.0.0 (2025-01-15)
  Initial release - Arquitectura base Flutter

  Changes:
  - Clean Architecture por capas (core/data/domain/presentation)
  - AppLayoutBuilder obligatorio (mobile/tablet/desktop)
  - Sistema de responsive con breakpoints definidos
  - 10 Memory Edits base configurados
  - Testing strategy (unit/widget/golden)
  - BLoC como único state management permitido
```

## Flujo de Ejecución

```
1. Localizar ENGINE_VERSION.yaml
   └── Si no existe → Error: "Engine version file not found"

2. Parsear YAML
   └── Extraer version, release_date, includes, changelog

3. Si --compare:
   └── Buscar .engine_version en proyecto actual
       ├── Si existe → Comparar versiones
       └── Si no existe → "Project not initialized with engine"

4. Formatear output según opciones (--json, --changelog)

5. Mostrar resultado
```

## Archivos Relacionados

- `ENGINE_VERSION.yaml` - Archivo fuente de versión del engine
- `.engine_version` - Archivo de versión en proyectos (creado por /dev-new)

## Ver También

- [/dev-check](dev-check.md) - Verificar compatibilidad
- [/dev-upgrade](dev-upgrade.md) - Actualizar proyecto
- [/dev-new](dev-new.md) - Crear nuevo proyecto
