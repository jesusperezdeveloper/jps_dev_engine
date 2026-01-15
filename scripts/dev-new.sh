#!/bin/bash
# JPS Dev Engine - New Project
# Creates a new Flutter project with engine architecture

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$(dirname "$SCRIPT_DIR")"
ENGINE_VERSION_FILE="$ENGINE_DIR/ENGINE_VERSION.yaml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Defaults
ORG="com.jpsdeveloper"
PLATFORMS="ios,android,web"
WITH_FIREBASE=false
WITH_SUPABASE=false
DESCRIPTION=""
PROJECT_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --org)
            ORG="$2"
            shift 2
            ;;
        --platforms)
            PLATFORMS="$2"
            shift 2
            ;;
        --with-firebase)
            WITH_FIREBASE=true
            shift
            ;;
        --with-supabase)
            WITH_SUPABASE=true
            shift
            ;;
        --description)
            DESCRIPTION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: dev-new.sh PROJECT_NAME [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --org ORG           Organization identifier (default: com.jpsdeveloper)"
            echo "  --platforms LIST    Platforms to generate (default: ios,android,web)"
            echo "  --with-firebase     Include Firebase configuration"
            echo "  --with-supabase     Include Supabase configuration"
            echo "  --description TEXT  Project description"
            echo "  -h, --help          Show this help"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

# Validate project name
if [[ -z "$PROJECT_NAME" ]]; then
    echo -e "${RED}Error: Project name is required${NC}"
    echo "Usage: dev-new.sh PROJECT_NAME [OPTIONS]"
    exit 1
fi

# Validate project name format (snake_case)
if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo -e "${RED}Error: Project name must be in snake_case (lowercase, underscores, start with letter)${NC}"
    exit 1
fi

# Check if directory exists
if [[ -d "$PROJECT_NAME" ]]; then
    echo -e "${RED}Error: Directory '$PROJECT_NAME' already exists${NC}"
    exit 1
fi

# Get engine version
ENGINE_VERSION=$(grep "^version:" "$ENGINE_VERSION_FILE" | cut -d' ' -f2)

echo -e "${BLUE}Creating new Flutter project:${NC} $PROJECT_NAME"
echo -e "Using JPS Dev Engine v${GREEN}$ENGINE_VERSION${NC}"
echo ""

# Step 1: Flutter create
echo -e "${BLUE}Step 1/5:${NC} Running flutter create..."
flutter create --org "$ORG" --platforms "$PLATFORMS" "$PROJECT_NAME" > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Flutter project created"

cd "$PROJECT_NAME"

# Step 2: Create architecture structure
echo -e "${BLUE}Step 2/5:${NC} Creating architecture structure..."

# Core directories
mkdir -p lib/core/{config,constants,di,extensions,theme,widgets/responsive}
echo -e "  ${GREEN}✓${NC} lib/core/ created"

# Data layer
mkdir -p lib/data/{datasources,models,repositories}
echo -e "  ${GREEN}✓${NC} lib/data/ created"

# Domain layer
mkdir -p lib/domain/{entities,repositories,usecases}
echo -e "  ${GREEN}✓${NC} lib/domain/ created"

# Presentation layer with home feature
mkdir -p lib/presentation/features/home/{bloc,layouts,page,widgets}
echo -e "  ${GREEN}✓${NC} lib/presentation/ created"

# Test directories
mkdir -p test/{core,data,domain,presentation}

# Step 3: Generate base files
echo -e "${BLUE}Step 3/5:${NC} Generating base files..."

# AppLayoutBuilder
cat > lib/core/widgets/responsive/app_layout_builder.dart << 'EOF'
import 'package:flutter/material.dart';
import 'breakpoints.dart';

class AppLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const AppLayoutBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

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
EOF
echo -e "  ${GREEN}✓${NC} lib/core/widgets/responsive/app_layout_builder.dart"

# Breakpoints
cat > lib/core/widgets/responsive/breakpoints.dart << 'EOF'
abstract class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}
EOF
echo -e "  ${GREEN}✓${NC} lib/core/widgets/responsive/breakpoints.dart"

# DI
cat > lib/core/di/injection.dart << 'EOF'
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Register your dependencies here
  // Example:
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
}
EOF
echo -e "  ${GREEN}✓${NC} lib/core/di/injection.dart"

# Theme
cat > lib/core/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
  );
}
EOF

cat > lib/core/theme/app_colors.dart << 'EOF'
import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
}
EOF
echo -e "  ${GREEN}✓${NC} lib/core/theme/app_theme.dart"

# Home feature - BLoC
cat > lib/presentation/features/home/bloc/home_bloc.dart << 'EOF'
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    // TODO: Load initial data
    emit(state.copyWith(status: HomeStatus.success));
  }
}
EOF

cat > lib/presentation/features/home/bloc/home_event.dart << 'EOF'
part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}
EOF

cat > lib/presentation/features/home/bloc/home_state.dart << 'EOF'
part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
EOF
echo -e "  ${GREEN}✓${NC} lib/presentation/features/home/bloc/"

# Home layouts
cat > lib/presentation/features/home/layouts/home_mobile_layout.dart << 'EOF'
import 'package:flutter/material.dart';

class HomeMobileLayout extends StatelessWidget {
  const HomeMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Mobile Layout'),
      ),
    );
  }
}
EOF

cat > lib/presentation/features/home/layouts/home_tablet_layout.dart << 'EOF'
import 'package:flutter/material.dart';

class HomeTabletLayout extends StatelessWidget {
  const HomeTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Tablet Layout'),
      ),
    );
  }
}
EOF

cat > lib/presentation/features/home/layouts/home_desktop_layout.dart << 'EOF'
import 'package:flutter/material.dart';

class HomeDesktopLayout extends StatelessWidget {
  const HomeDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Desktop Layout'),
      ),
    );
  }
}
EOF
echo -e "  ${GREEN}✓${NC} lib/presentation/features/home/layouts/"

# Home page
cat > lib/presentation/features/home/page/home_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/responsive/app_layout_builder.dart';
import '../bloc/home_bloc.dart';
import '../layouts/home_desktop_layout.dart';
import '../layouts/home_mobile_layout.dart';
import '../layouts/home_tablet_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(const HomeStarted()),
      child: const AppLayoutBuilder(
        mobile: HomeMobileLayout(),
        tablet: HomeTabletLayout(),
        desktop: HomeDesktopLayout(),
      ),
    );
  }
}
EOF
echo -e "  ${GREEN}✓${NC} lib/presentation/features/home/page/home_page.dart"

# Update main.dart
cat > lib/main.dart << EOF
import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'presentation/features/home/page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${PROJECT_NAME//_/ }',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}
EOF
echo -e "  ${GREEN}✓${NC} lib/main.dart (updated)"

# Step 4: Configure dependencies
echo -e "${BLUE}Step 4/5:${NC} Configuring dependencies..."

# Build new pubspec.yaml
cat > pubspec.yaml << EOF
name: $PROJECT_NAME
description: $DESCRIPTION
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.0.0

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  equatable: ^2.0.5
  get_it: ^7.6.0
EOF

if $WITH_FIREBASE; then
    cat >> pubspec.yaml << EOF
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
EOF
    echo -e "  ${GREEN}✓${NC} Firebase dependencies added"
fi

if $WITH_SUPABASE; then
    cat >> pubspec.yaml << EOF
  supabase_flutter: ^2.0.0
EOF
    echo -e "  ${GREEN}✓${NC} Supabase dependencies added"
fi

cat >> pubspec.yaml << EOF

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  bloc_test: ^9.1.5
  mocktail: ^1.0.1

flutter:
  uses-material-design: true
EOF

echo -e "  ${GREEN}✓${NC} flutter_bloc: ^8.1.3"
echo -e "  ${GREEN}✓${NC} get_it: ^7.6.0"
echo -e "  ${GREEN}✓${NC} equatable: ^2.0.5"

# Step 5: Setup Claude
echo -e "${BLUE}Step 5/5:${NC} Setting up Claude..."

# Create CLAUDE.md
cat > CLAUDE.md << EOF
# CLAUDE.md - $PROJECT_NAME

## Project Info
- **Name**: $PROJECT_NAME
- **Engine Version**: $ENGINE_VERSION
- **Created**: $(date +%Y-%m-%d)

## Architecture
This project follows the JPS Dev Engine architecture:
- Clean Architecture (core/data/domain/presentation)
- BLoC for state management (ONLY)
- 3 responsive layouts per feature (mobile/tablet/desktop)

## Rules
1. BLoC obligatorio - NO Provider, NO Riverpod, NO GetX
2. 3 layouts responsivos por feature
3. Código en inglés, comunicación en español
4. Testing obligatorio: unit, widget, golden

## Commands
- \`/dev-check\` - Verify project compliance
- \`/dev-upgrade\` - Update to latest engine version

## See Also
- JPS Dev Engine: https://github.com/jesusperezdeveloper/jps_dev_engine
EOF
echo -e "  ${GREEN}✓${NC} CLAUDE.md created"

# Create .engine_version
echo "$ENGINE_VERSION" > .engine_version
echo -e "  ${GREEN}✓${NC} .engine_version created"

echo ""
echo -e "${GREEN}Done!${NC} Project created at ./$PROJECT_NAME"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  flutter pub get"
echo "  /dev-check"

if $WITH_FIREBASE; then
    echo ""
    echo -e "${YELLOW}Note:${NC} Run 'flutterfire configure' to complete Firebase setup"
fi
