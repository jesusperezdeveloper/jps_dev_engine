# Template: Configuración Global de Claude

Este es el template recomendado para `~/.claude/CLAUDE.md`.

```markdown
# Instrucciones Globales para Claude

## Idioma
Responde siempre en español a menos que el usuario escriba en otro idioma.

## Notificaciones via MCP claude-nonstop (OBLIGATORIO)

### 1. Notificaciones de Finalización

Cuando completes una tarea significativa (no trivial), DEBES notificar al usuario:

notify_user(
    task_id="done-{descripcion-corta}-{timestamp}",
    summary="Completado: {resumen de 1-2 líneas}",
    question="Tarea finalizada. ¿Necesitas algo más?"
)

**Cuándo notificar finalización:**
- Al completar una implementación de código
- Al terminar un refactor
- Al finalizar una investigación/análisis solicitado
- Al resolver un bug
- Al completar múltiples tareas de una lista

### 2. Notificaciones de Decisión (IMPORTANTE)

Cuando necesites una decisión del usuario o tengas una pregunta importante, DEBES notificar:

notify_user(
    task_id="decision-{descripcion-corta}-{timestamp}",
    summary="Necesito tu decisión: {contexto breve}",
    question="{tu pregunta específica con las opciones}"
)

**Cuándo notificar decisión:**
- Cuando encuentres ambigüedad en los requisitos
- Cuando haya múltiples enfoques posibles y necesites elegir
- Cuando encuentres un problema que requiera confirmación
- Cuando necesites clarificar algo antes de continuar

### 3. Notificaciones de Errores Críticos

Cuando ocurra un error crítico durante una tarea, DEBES notificar inmediatamente:

notify_user(
    task_id="error-{descripcion-corta}-{timestamp}",
    summary="❌ Error: {tipo de error}",
    question="Error encontrado: {descripción del error}. ¿Cómo quieres proceder?"
)

**Cuándo notificar errores:**
- Errores de compilación/build que bloquean el progreso
- Tests fallidos (resumen: X de Y tests fallaron)
- Errores de permisos o acceso a archivos
- Fallos de conexión a servicios externos

### Cuándo NO notificar:
- Preguntas simples de información
- Lecturas de archivos sin acción posterior
- Cuando el usuario está activamente en la conversación respondiendo rápido
```

## Cómo instalar

1. Copia el contenido del template
2. Crea/edita el archivo `~/.claude/CLAUDE.md`
3. Pega el contenido
4. Ajusta según tus preferencias

```bash
# Crear directorio si no existe
mkdir -p ~/.claude

# Crear archivo
touch ~/.claude/CLAUDE.md

# Editar
code ~/.claude/CLAUDE.md
```
