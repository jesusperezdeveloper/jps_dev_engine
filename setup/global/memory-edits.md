# Memory Edits - Configuración Global de Claude

## ¿Qué son los Memory Edits?

Los Memory Edits son instrucciones persistentes que Claude recuerda entre conversaciones. Se almacenan en `~/.claude/CLAUDE.md` y aplican a **todos los proyectos**.

## Ubicación

```
~/.claude/CLAUDE.md    # Instrucciones globales (todos los proyectos)
proyecto/CLAUDE.md     # Instrucciones específicas del proyecto
```

## Prioridad

1. Instrucciones del proyecto (`proyecto/CLAUDE.md`) tienen prioridad
2. Instrucciones globales (`~/.claude/CLAUDE.md`) aplican como fallback

## Cuándo usar Memory Edits Globales

- Preferencias de idioma
- Estilo de comunicación
- Integraciones con herramientas (MCP servers)
- Notificaciones y alertas
- Reglas que aplican a TODOS tus proyectos

## Cuándo usar CLAUDE.md del proyecto

- Arquitectura específica del proyecto
- Stack tecnológico
- Convenciones de código del proyecto
- Testing strategy específica
- Reglas de negocio

## Ejemplo de Configuración Global

Ver [claude-global-config.md](claude-global-config.md) para un template completo.

## Comandos útiles

```bash
# Ver configuración global actual
cat ~/.claude/CLAUDE.md

# Editar configuración global
code ~/.claude/CLAUDE.md

# Ver configuración del proyecto
cat CLAUDE.md
```

## Tips

1. **Mantén lo global mínimo** - Solo lo que realmente aplica a todos los proyectos
2. **Sé específico** - Instrucciones vagas generan resultados inconsistentes
3. **Actualiza regularmente** - Revisa y ajusta según evoluciona tu workflow
