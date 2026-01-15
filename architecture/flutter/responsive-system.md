# Sistema de Responsividad

## Regla Fundamental

**3 layouts obligatorios por feature**: mobile, tablet, desktop.

## Breakpoints

| Dispositivo | Ancho | Constante |
|-------------|-------|-----------|
| Mobile | < 600dp | `Breakpoints.mobile` |
| Tablet | 600dp - 1024dp | `Breakpoints.tablet` |
| Desktop | > 1024dp | `Breakpoints.desktop` |

## AppLayoutBuilder

Widget principal para selección automática de layouts:

```dart
// core/widgets/responsive/app_layout_builder.dart
import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

class AppLayoutBuilder extends StatelessWidget {
  const AppLayoutBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.mobile) {
          return mobile;
        } else if (constraints.maxWidth < Breakpoints.tablet) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
```

## Estructura de Archivos

```
presentation/features/{feature}/
├── layouts/
│   ├── {feature}_mobile_layout.dart
│   ├── {feature}_tablet_layout.dart
│   └── {feature}_desktop_layout.dart
└── page/
    └── {feature}_page.dart
```

## Ejemplo: Feature Dashboard

### Page (Orquestador)

```dart
// dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../layouts/dashboard_mobile_layout.dart';
import '../layouts/dashboard_tablet_layout.dart';
import '../layouts/dashboard_desktop_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(
        statsRepository: context.read<StatsRepository>(),
      )..add(const DashboardLoaded()),
      child: const AppLayoutBuilder(
        mobile: DashboardMobileLayout(),
        tablet: DashboardTabletLayout(),
        desktop: DashboardDesktopLayout(),
      ),
    );
  }
}
```

### Mobile Layout

```dart
// dashboard_mobile_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../widgets/stats_card.dart';

class DashboardMobileLayout extends StatelessWidget {
  const DashboardMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cards apiladas verticalmente
              StatsCard(title: 'Users', value: state.totalUsers),
              const SizedBox(height: 16),
              StatsCard(title: 'Revenue', value: state.totalRevenue),
              const SizedBox(height: 16),
              StatsCard(title: 'Orders', value: state.totalOrders),
            ],
          ),
          drawer: const AppDrawer(),
        );
      },
    );
  }
}
```

### Tablet Layout

```dart
// dashboard_tablet_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../widgets/stats_card.dart';

class DashboardTabletLayout extends StatelessWidget {
  const DashboardTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Grid de 2 columnas
                Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Users',
                        value: state.totalUsers,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatsCard(
                        title: 'Revenue',
                        value: state.totalRevenue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatsCard(title: 'Orders', value: state.totalOrders),
              ],
            ),
          ),
          drawer: const AppDrawer(),
        );
      },
    );
  }
}
```

### Desktop Layout

```dart
// dashboard_desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import '../widgets/stats_card.dart';

class DashboardDesktopLayout extends StatelessWidget {
  const DashboardDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          body: Row(
            children: [
              // Sidebar persistente
              const NavigationRail(
                destinations: [...],
              ),
              // Contenido principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 32),
                      // Grid de 3 columnas
                      Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Users',
                              value: state.totalUsers,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: StatsCard(
                              title: 'Revenue',
                              value: state.totalRevenue,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: StatsCard(
                              title: 'Orders',
                              value: state.totalOrders,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Diferencias Clave por Layout

| Aspecto | Mobile | Tablet | Desktop |
|---------|--------|--------|---------|
| Navegación | Drawer | Drawer | Rail/Sidebar |
| Grid | 1 columna | 2 columnas | 3+ columnas |
| Padding | 16dp | 24dp | 32dp |
| AppBar | Sí | Sí | No (título inline) |
| Cards | Full width | 2 por fila | 3+ por fila |

## Helpers Adicionales

### Responsive Value

```dart
// Para valores que cambian según breakpoint
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  required T tablet,
  required T desktop,
}) {
  final width = MediaQuery.of(context).size.width;
  if (width < Breakpoints.mobile) return mobile;
  if (width < Breakpoints.tablet) return tablet;
  return desktop;
}

// Uso
final padding = responsiveValue(
  context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);
```

### Screen Size Extensions

```dart
extension ScreenSizeExtension on BuildContext {
  bool get isMobile =>
      MediaQuery.of(this).size.width < Breakpoints.mobile;

  bool get isTablet =>
      MediaQuery.of(this).size.width >= Breakpoints.mobile &&
      MediaQuery.of(this).size.width < Breakpoints.tablet;

  bool get isDesktop =>
      MediaQuery.of(this).size.width >= Breakpoints.tablet;
}
```

## Testing

Ver [testing-strategy.md](testing-strategy.md) para widget tests con múltiples tamaños de pantalla.
