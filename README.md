# JPS Development Engine

Motor de desarrollo estandarizado para proyectos Flutter y Python, diseñado para trabajar con Claude AI como asistente de desarrollo.

## Filosofía

- **100% SaaS oriented** - Todo el desarrollo está enfocado en crear productos SaaS
- **Multi-tenancy desde día 1** - Arquitectura preparada para múltiples clientes/organizaciones
- **Preparado para monetización** - Estructura lista para billing, suscripciones y planes

## Objetivo

Proporcionar una arquitectura, convenciones y herramientas estandarizadas que permitan:
- Desarrollo consistente entre proyectos
- Integración optimizada con Claude AI
- Código mantenible y escalable
- Testing comprehensivo

## Stack Tecnológico

| Tecnología | Versión | Uso |
|------------|---------|-----|
| Flutter | 3.x | Apps móviles/web/desktop |
| Dart | 3.x | Lenguaje principal Flutter |
| Python | 3.11+ | Backend, scripts, automation |
| BLoC | 8.x | State management (obligatorio) |

## Estructura del Repositorio

```
jps_dev_engine/
├── docs/                    # Documentación
│   ├── architecture/        # Arquitectura detallada
│   ├── conventions/         # Convenciones de código
│   └── templates/           # Plantillas de features
├── flutter/                 # Recursos Flutter
│   ├── templates/           # Código base reutilizable
│   └── analysis_options.yaml
├── python/                  # Recursos Python
│   └── templates/
├── scripts/                 # Scripts de automatización
└── .claude/                 # Configuración para Claude
```

## Arquitectura Flutter

```
lib/
├── core/                    # Código compartido
│   ├── assets/              # Asset paths
│   ├── config/              # Configuración app
│   ├── constants/           # Constantes globales
│   ├── di/                  # Dependency injection
│   ├── extensions/          # Extension methods
│   ├── gen/                 # Código generado
│   ├── lang/                # Internacionalización
│   ├── theme/               # Tema y estilos
│   └── widgets/             # Widgets reutilizables
│       ├── avatar/
│       ├── buttons/
│       ├── feedback/
│       ├── inputs/
│       ├── layout/
│       ├── lists/
│       ├── navigation/
│       └── responsive/
├── data/                    # Capa de datos
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/                  # Capa de dominio
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/            # Capa de presentación
│   └── features/
│       └── {feature}/
│           ├── bloc/        # State management
│           ├── layouts/     # Responsive layouts (OBLIGATORIO)
│           │   ├── {feature}_mobile_layout.dart
│           │   ├── {feature}_tablet_layout.dart
│           │   └── {feature}_desktop_layout.dart
│           ├── page/        # Páginas/screens
│           ├── routes/      # Rutas de la feature
│           └── widgets/     # Widgets específicos
└── main.dart
```

## Reglas Fundamentales

### State Management
- **BLoC es obligatorio** - Nunca usar Provider, Riverpod u otras alternativas
- Cada feature con lógica de estado debe tener su BLoC
- Usar `flutter_bloc` para la integración con widgets

### Responsive Design
- **3 layouts obligatorios por feature**: mobile, tablet, desktop
- Usar `AppLayoutBuilder` para selección automática de layout
- Breakpoints: mobile (<600), tablet (600-1024), desktop (>1024)

### Testing
| Tipo | Cobertura | Herramientas |
|------|-----------|--------------|
| Unit | BLoC, repositories, use cases | `bloc_test`, `mockito` |
| Widget | Diferentes tamaños de pantalla | `flutter_test` |
| Golden | Pantallas core | `golden_toolkit` |

### Convenciones de Código
- **Código en inglés** (variables, funciones, clases)
- **Comunicación en español** (commits, PRs, documentación)
- Seguir Effective Dart
- Máximo 80 caracteres por línea

## Documentación

- [Arquitectura Flutter](docs/architecture/flutter.md)
- [Arquitectura Python](docs/architecture/python.md)
- [Convenciones de Código](docs/conventions/code_style.md)
- [Guía de Testing](docs/conventions/testing.md)
- [Plantilla de Feature](docs/templates/feature_template.md)

## Uso con Claude

Este repositorio está optimizado para trabajar con Claude AI. El archivo `CLAUDE.md` en la raíz del repositorio contiene las instrucciones específicas para que Claude siga la arquitectura y convenciones definidas.

### Comandos útiles
```bash
# Crear nueva feature siguiendo la arquitectura
# Claude generará: bloc/, layouts/, page/, routes/, widgets/

# Revisar arquitectura antes de implementar
# Claude validará cumplimiento de reglas
```

## Principios de Diseño

1. **Consistencia** - Misma estructura en todos los proyectos
2. **Simplicidad** - Evitar sobre-ingeniería
3. **Mantenibilidad** - Código fácil de entender y modificar
4. **Testabilidad** - Arquitectura que facilita testing
5. **Escalabilidad** - Preparado para crecer

## Licencia

MIT License - Ver [LICENSE](LICENSE)

## Autor

**Jesús Pérez** (JPSDeveloper / IAutomat)
- GitHub: [@jesusperezdeveloper](https://github.com/jesusperezdeveloper)
