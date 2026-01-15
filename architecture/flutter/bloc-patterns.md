# Patrones BLoC

## Regla Fundamental

**BLoC es OBLIGATORIO** para state management. Nunca usar Provider, Riverpod u otras alternativas.

## Estructura de un BLoC

Cada feature con estado tiene 3 archivos:

```
bloc/
├── {feature}_bloc.dart     # Lógica del BLoC
├── {feature}_event.dart    # Eventos (inputs)
└── {feature}_state.dart    # Estados (outputs)
```

## Template: Events

```dart
// login_event.dart
import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class LoginReset extends LoginEvent {
  const LoginReset();
}
```

## Template: States

```dart
// login_state.dart
import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.errorMessage,
  });

  final LoginStatus status;
  final String email;
  final String password;
  final String? errorMessage;

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, email, password, errorMessage];
}
```

## Template: BLoC

```dart
// login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  final AuthRepository _authRepository;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) {
    emit(const LoginState());
  }
}
```

## Uso en UI

```dart
// En el widget tree
BlocProvider(
  create: (context) => LoginBloc(
    authRepository: context.read<AuthRepository>(),
  ),
  child: const LoginPage(),
)

// Consumir estado
BlocBuilder<LoginBloc, LoginState>(
  builder: (context, state) {
    if (state.status == LoginStatus.loading) {
      return const CircularProgressIndicator();
    }
    return LoginForm();
  },
)

// Disparar eventos
context.read<LoginBloc>().add(
  LoginSubmitted(email: email, password: password),
);

// Escuchar side effects
BlocListener<LoginBloc, LoginState>(
  listenWhen: (previous, current) =>
    previous.status != current.status,
  listener: (context, state) {
    if (state.status == LoginStatus.success) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
    if (state.status == LoginStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Error')),
      );
    }
  },
  child: const LoginForm(),
)
```

## Patrones Recomendados

### 1. Status Enum

Siempre usar un enum para el status:

```dart
enum DataStatus { initial, loading, success, failure }
```

### 2. copyWith para Inmutabilidad

Siempre usar `copyWith` para modificar estados:

```dart
emit(state.copyWith(status: DataStatus.loading));
```

### 3. Equatable para Comparación

Extender `Equatable` en eventos y estados para comparación eficiente.

### 4. Sealed Classes para Eventos

Usar `sealed class` para eventos (Dart 3+):

```dart
sealed class MyEvent extends Equatable { ... }
```

### 5. Inyección de Dependencias

Inyectar repositorios en el constructor del BLoC:

```dart
LoginBloc({required AuthRepository authRepository})
```

## Anti-Patrones a Evitar

| Anti-Patrón | Por qué evitarlo |
|-------------|------------------|
| Estado mutable | Dificulta debugging y testing |
| Lógica en UI | Viola separación de responsabilidades |
| BLoC sin repositorio | Acopla lógica de negocio con datos |
| Múltiples emits sin await | Puede causar race conditions |
| Context en BLoC | BLoC debe ser agnóstico a UI |

## Testing de BLoCs

Ver [testing-strategy.md](testing-strategy.md) para patrones de testing de BLoCs.
