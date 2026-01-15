# CLAUDE.md - JPS Dev Engine

## Contexto

Este es **jps_dev_engine** - motor de desarrollo estandarizado para proyectos Flutter/Python de JPSDeveloper e IAutomat.

**Propietario**: Jesús Pérez  
**Empresas**: IAutomat (agencia automatización) + JPSDeveloper (freelance)  
**Objetivo**: 100% SaaS oriented - crear múltiples SaaS para ingresos recurrentes

## Stack Principal

- **Frontend**: Flutter (BLoC + Clean Architecture)
- **Backend**: Firebase, Python
- **Automatización**: n8n
- **Hardware**: MacBook Pro M4 Pro (48GB RAM) - no limitar tareas pesadas

## Reglas Inamovibles

1. **BLoC obligatorio** para state management. Nunca Provider ni Riverpod.
2. **3 layouts responsivos obligatorios** por feature (mobile/tablet/desktop)
3. **Código en inglés**, comunicación en español
4. **Testing obligatorio**: unit (BLoC/repos), widget (screen sizes), golden (pantallas core)
5. **Simplicidad > Clever code** - soluciones mantenibles siempre

## Arquitectura Flutter Estándar

```
lib/
├── core/
│   ├── assets/           # Imágenes, fonts, etc.
│   ├── config/           # Configuración de la app
│   ├── constants/        # Constantes globales
│   ├── di/               # Dependency injection
│   ├── extensions/       # Extensions de Dart
│   ├── gen/              # Código generado
│   ├── lang/             # Internacionalización
│   ├── theme/            # Design system (colores, tipografía, spacing)
│   └── widgets/          # Widgets genéricos reutilizables
│       ├── avatar/
│       ├── buttons/
│       ├── feedback/
│       ├── inputs/
│       ├── layout/
│       ├── lists/
│       ├── navigation/
│       └── responsive/   # AppLayoutBuilder, breakpoints
│
├── data/
│   ├── datasources/      # Remote y local data sources
│   ├── models/           # DTOs, modelos de datos
│   └── repositories/     # Implementaciones de repositories
│
├── domain/
│   ├── entities/         # Entidades de negocio
│   ├── repositories/     # Interfaces de repositories
│   └── usecases/         # Casos de uso (si aplica)
│
├── presentation/
│   └── features/
│       └── {feature_name}/
│           ├── bloc/                        # Opcional - solo si hay estado
│           │   ├── {feature}_bloc.dart
│           │   ├── {feature}_event.dart
│           │   └── {feature}_state.dart
│           ├── layouts/                     # OBLIGATORIO
│           │   ├── {feature}_mobile_layout.dart
│           │   ├── {feature}_tablet_layout.dart
│           │   └── {feature}_desktop_layout.dart
│           ├── page/
│           │   └── {feature}_page.dart
│           ├── routes/
│           │   └── {feature}_route.dart
│           └── widgets/                     # Widgets específicos de la feature
│
└── main.dart
```

## Sistema de Responsividad

Todas las features usan `AppLayoutBuilder` que requiere **3 layouts obligatorios**:

```dart
AppLayoutBuilder(
  mobile: FeatureMobileLayout(),   // < 600dp
  tablet: FeatureTabletLayout(),   // 600dp - 1024dp
  desktop: FeatureDesktopLayout(), // > 1024dp
)
```

**Breakpoints**:
- Mobile: < 600dp
- Tablet: 600dp - 1024dp
- Desktop: > 1024dp

## Testing Strategy

| Tipo | Qué testear | Cuándo |
|------|-------------|--------|
| **Unit tests** | BLoCs, repositories, usecases | Siempre |
| **Widget tests** | Layouts con múltiples screen sizes | Siempre |
| **Golden tests** | Pantallas core (home, dashboard, forms principales) | Features críticas |

### Screen sizes para widget tests

```dart
final screenSizes = [
  Size(375, 667),   // iPhone SE (mobile)
  Size(768, 1024),  // iPad Portrait (tablet)
  Size(1440, 900),  // MacBook (desktop)
];
```

## Rol de Claude

- **Arquitecto senior crítico**, NO asistente complaciente
- **Cuestionar** decisiones que no escalen o generen deuda técnica
- **Proponer mejoras** proactivamente
- **Explicar el "por qué"**, no solo el "qué"
- **Mantener simplicidad** - si algo se puede hacer más simple, decirlo

## Proyectos Activos

- PaddockManager
- FutManager
- Apps de movilidad
- Pickleball app

## Comandos Útiles

```bash
# Generar código (freezed, json_serializable, etc.)
dart run build_runner build --delete-conflicting-outputs

# Tests
flutter test
flutter test --coverage

# Análisis
flutter analyze
dart fix --apply
```

## Referencias

- **Proyecto Claude**: "JPS Development Engine" (contiene toda la conversación de diseño)
- **Repo**: https://github.com/jesusperezdeveloper/jps_dev_engine