# Estrategia de Testing

## Tipos de Tests

| Tipo | Qué testear | Cuándo | Herramientas |
|------|-------------|--------|--------------|
| **Unit** | BLoCs, repositories, usecases | Siempre | `bloc_test`, `mockito` |
| **Widget** | Layouts con múltiples screen sizes | Siempre | `flutter_test` |
| **Golden** | Pantallas core | Features críticas | `golden_toolkit` |

## Screen Sizes para Tests

```dart
const screenSizes = [
  Size(375, 667),   // iPhone SE (mobile)
  Size(768, 1024),  // iPad Portrait (tablet)
  Size(1440, 900),  // MacBook (desktop)
];
```

---

## Unit Tests (BLoC)

### Setup

```yaml
# pubspec.yaml
dev_dependencies:
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
```

### Estructura

```
test/
├── presentation/
│   └── features/
│       └── login/
│           └── bloc/
│               └── login_bloc_test.dart
├── data/
│   └── repositories/
│       └── auth_repository_test.dart
└── mocks/
    └── mock_repositories.dart
```

### Template: BLoC Test

```dart
// login_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/presentation/features/login/bloc/login_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
  });

  group('LoginBloc', () {
    test('initial state is correct', () {
      final bloc = LoginBloc(authRepository: authRepository);
      expect(bloc.state, equals(const LoginState()));
    });

    blocTest<LoginBloc, LoginState>(
      'emits [loading, success] when login succeeds',
      build: () {
        when(() => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {});

        return LoginBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(
        const LoginSubmitted(email: 'test@test.com', password: '123456'),
      ),
      expect: () => [
        const LoginState(status: LoginStatus.loading),
        const LoginState(status: LoginStatus.success),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, failure] when login fails',
      build: () {
        when(() => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Invalid credentials'));

        return LoginBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(
        const LoginSubmitted(email: 'test@test.com', password: 'wrong'),
      ),
      expect: () => [
        const LoginState(status: LoginStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });
}
```

---

## Widget Tests (Responsive)

### Template: Test Multi-Size

```dart
// dashboard_layout_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/presentation/features/dashboard/page/dashboard_page.dart';

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

void main() {
  late MockDashboardBloc dashboardBloc;

  setUp(() {
    dashboardBloc = MockDashboardBloc();
    when(() => dashboardBloc.state).thenReturn(
      const DashboardState(
        status: DashboardStatus.success,
        totalUsers: 100,
        totalRevenue: 5000,
        totalOrders: 50,
      ),
    );
  });

  group('DashboardPage responsive layouts', () {
    testWidgets('renders mobile layout on small screens', (tester) async {
      // iPhone SE size
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DashboardBloc>.value(
            value: dashboardBloc,
            child: const DashboardPage(),
          ),
        ),
      );

      // Verificar elementos de mobile layout
      expect(find.byType(Drawer), findsNothing); // Drawer cerrado
      expect(find.byType(AppBar), findsOneWidget);

      // Cleanup
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('renders tablet layout on medium screens', (tester) async {
      // iPad size
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DashboardBloc>.value(
            value: dashboardBloc,
            child: const DashboardPage(),
          ),
        ),
      );

      // Verificar elementos de tablet layout
      expect(find.byType(AppBar), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('renders desktop layout on large screens', (tester) async {
      // MacBook size
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DashboardBloc>.value(
            value: dashboardBloc,
            child: const DashboardPage(),
          ),
        ),
      );

      // Verificar elementos de desktop layout
      expect(find.byType(NavigationRail), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
```

### Helper para Tests Multi-Size

```dart
// test/helpers/screen_size_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension ScreenSizeTestExtension on WidgetTester {
  void setScreenSize(Size size) {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
  }

  void resetScreenSize() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  }
}

void testAllScreenSizes(
  String description, {
  required Future<void> Function(WidgetTester tester, Size size) test,
}) {
  const sizes = {
    'mobile': Size(375, 667),
    'tablet': Size(768, 1024),
    'desktop': Size(1440, 900),
  };

  for (final entry in sizes.entries) {
    testWidgets('$description [${entry.key}]', (tester) async {
      tester.setScreenSize(entry.value);
      await test(tester, entry.value);
      addTearDown(tester.resetScreenSize);
    });
  }
}
```

---

## Golden Tests

### Setup

```yaml
# pubspec.yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
```

### Template

```dart
// dashboard_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:my_app/presentation/features/dashboard/page/dashboard_page.dart';

void main() {
  group('Dashboard Golden Tests', () {
    testGoldens('DashboardPage - all sizes', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          Device.phone,
          Device.tabletPortrait,
          Device.tabletLandscape,
        ])
        ..addScenario(
          widget: const DashboardPage(),
          name: 'default state',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'dashboard_page');
    });
  });
}
```

### Generar/Actualizar Goldens

```bash
# Generar goldens
flutter test --update-goldens

# Ejecutar tests
flutter test
```

---

## Cobertura

```bash
# Generar reporte de cobertura
flutter test --coverage

# Ver reporte HTML (requiere lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Estructura de Tests Recomendada

```
test/
├── helpers/
│   ├── pump_app.dart           # Helper para pump widgets
│   └── screen_size_helper.dart # Helper para screen sizes
├── mocks/
│   ├── mock_repositories.dart
│   └── mock_blocs.dart
├── data/
│   ├── datasources/
│   └── repositories/
├── domain/
│   └── usecases/
├── presentation/
│   └── features/
│       └── {feature}/
│           ├── bloc/
│           │   └── {feature}_bloc_test.dart
│           └── layouts/
│               └── {feature}_layouts_test.dart
└── goldens/
    └── {feature}_golden_test.dart
```
