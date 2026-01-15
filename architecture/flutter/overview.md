# Arquitectura Flutter - Overview

## Principios Fundamentales

### 1. Clean Architecture
Separación clara en 3 capas:
- **Presentation** - UI, BLoCs, layouts
- **Domain** - Entidades, casos de uso, interfaces de repositorios
- **Data** - Implementación de repositorios, datasources, modelos

### 2. BLoC Pattern (Obligatorio)
- **NUNCA** usar Provider, Riverpod u otras alternativas
- Un BLoC por feature con lógica de estado
- Eventos explícitos, estados inmutables

### 3. Responsive por Defecto
- **3 layouts obligatorios** por feature: mobile, tablet, desktop
- Breakpoints: mobile (<600), tablet (600-1024), desktop (>1024)
- `AppLayoutBuilder` para selección automática

### 4. SaaS Ready
- Multi-tenancy desde día 1
- Estructura preparada para billing y suscripciones
- Separación clara de datos por tenant

## Capas de la Arquitectura

```
┌─────────────────────────────────────────────┐
│              PRESENTATION                    │
│  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │
│  │  Pages  │  │  BLoCs  │  │   Layouts   │  │
│  └────┬────┘  └────┬────┘  └──────┬──────┘  │
└───────┼────────────┼──────────────┼─────────┘
        │            │              │
        ▼            ▼              ▼
┌─────────────────────────────────────────────┐
│                 DOMAIN                       │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │ Entities │  │ UseCases │  │ Repo Intf │  │
│  └──────────┘  └──────────┘  └───────────┘  │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│                  DATA                        │
│  ┌──────────┐  ┌─────────────┐  ┌────────┐  │
│  │  Models  │  │ DataSources │  │  Repos │  │
│  └──────────┘  └─────────────┘  └────────┘  │
└─────────────────────────────────────────────┘
```

## Flujo de Datos

1. **Usuario interactúa** con UI (Page/Layout)
2. **Page dispara evento** al BLoC
3. **BLoC procesa evento**, llama a UseCase/Repository
4. **Repository** obtiene datos de DataSource
5. **DataSource** conecta con API/DB/Cache
6. **Datos fluyen de vuelta** transformándose en cada capa
7. **BLoC emite nuevo estado**
8. **UI se reconstruye** con el nuevo estado

## Reglas de Dependencia

```
Presentation → Domain ← Data
```

- **Presentation** conoce Domain (pero NO Data)
- **Data** conoce Domain (pero NO Presentation)
- **Domain** NO conoce ninguna otra capa

## Documentos Relacionados

- [Estructura de Carpetas](folder-structure.md)
- [Patrones BLoC](bloc-patterns.md)
- [Sistema Responsivo](responsive-system.md)
- [Estrategia de Testing](testing-strategy.md)
