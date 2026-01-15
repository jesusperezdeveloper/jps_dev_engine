# Estructura de Carpetas Flutter

## Estructura Completa

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

## Descripción de Carpetas

### `/core`

| Carpeta | Propósito |
|---------|-----------|
| `assets/` | Paths a assets (imágenes, fonts, SVGs) |
| `config/` | Configuración de entorno, feature flags |
| `constants/` | Valores constantes globales |
| `di/` | Setup de dependency injection (get_it) |
| `extensions/` | Extension methods para tipos de Dart |
| `gen/` | Código generado (assets, localization) |
| `lang/` | Archivos de internacionalización |
| `theme/` | AppTheme, colores, tipografía, spacing |
| `widgets/` | Widgets reutilizables en toda la app |

### `/data`

| Carpeta | Propósito |
|---------|-----------|
| `datasources/` | Conexión con APIs, bases de datos, cache |
| `models/` | DTOs para serialización/deserialización |
| `repositories/` | Implementación de interfaces del domain |

### `/domain`

| Carpeta | Propósito |
|---------|-----------|
| `entities/` | Objetos de negocio puros (sin dependencias) |
| `repositories/` | Interfaces abstractas de repositorios |
| `usecases/` | Lógica de negocio encapsulada (opcional) |

### `/presentation/features/{feature}`

| Carpeta | Propósito | Obligatorio |
|---------|-----------|-------------|
| `bloc/` | State management con BLoC | Solo si hay estado |
| `layouts/` | Layouts responsivos (mobile/tablet/desktop) | **SÍ** |
| `page/` | Página principal de la feature | Sí |
| `routes/` | Configuración de rutas | Sí |
| `widgets/` | Widgets específicos de esta feature | No |

## Ejemplo: Feature "Dashboard"

```
lib/presentation/features/dashboard/
├── bloc/
│   ├── dashboard_bloc.dart
│   ├── dashboard_event.dart
│   └── dashboard_state.dart
├── layouts/
│   ├── dashboard_mobile_layout.dart
│   ├── dashboard_tablet_layout.dart
│   └── dashboard_desktop_layout.dart
├── page/
│   └── dashboard_page.dart
├── routes/
│   └── dashboard_route.dart
└── widgets/
    ├── stats_card.dart
    └── activity_list.dart
```

## Reglas de Nombrado

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Archivos | snake_case | `user_profile_bloc.dart` |
| Clases | PascalCase | `UserProfileBloc` |
| Variables | camelCase | `userName` |
| Constantes | camelCase | `defaultPadding` |
| Enums | PascalCase + camelCase values | `UserStatus.active` |

## Convenciones Importantes

1. **Un archivo = una clase principal** (excepto eventos/estados de BLoC)
2. **Imports relativos** dentro del mismo feature
3. **Imports absolutos** entre features y capas
4. **No circular dependencies** entre features
