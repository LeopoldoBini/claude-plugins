---
argument-hint: [lo que quiero hacer / el planteo]
description: Checkpoint de comprensión para dictado por voz — reformulá qué entendiste y qué harías, y esperá luz verde antes de ejecutar
disable-model-invocation: true
---

# Checkpoint de Comprensión

**Este turno se responde con texto y nada más:** la única salida es tu comprensión escrita.
Cualquier herramienta —leer archivos, explorar el repo, correr comandos— es el trabajo que
el usuario todavía no autorizó, y sale recién con su luz verde.

El usuario dictó por voz o escribió rápido. La entrada puede tener errores de transcripción, frases incompletas o ambigüedades. El modelo de transcripción a veces interpreta palabras en español como si fueran inglés (por similitud fonética), así que si aparecen palabras en inglés que no tienen sentido en contexto, probablemente son español mal transcripto. Tu única tarea es demostrar que entendiste correctamente antes de que te dé luz verde.

## Entrada del usuario
$ARGUMENTS

## Lo que tenés que hacer

1. **Interpretar la intención** — Leé entre líneas. Si algo no tiene sentido literal, inferí qué quiso decir. Considerá errores de dictado por voz (palabras similares fonéticamente, puntuación ausente, frases cortadas).

2. **Mostrar tu comprensión** — Reformulá en tus propias palabras, claro y conciso:
   - **Qué entendí**: En 2-3 oraciones, qué te está pidiendo el usuario.
   - **Lo que haría**: Bullet points concretos de las acciones que tomarías.

3. **Señalar zonas grises** — Si hay partes ambiguas o que admiten más de una interpretación, mencioná las alternativas brevemente. No asumas — preguntá.

## Formato de respuesta

Sé directo. No rellenes. El usuario quiere verificar comprensión rápido, no leer un ensayo.

Si todo está claro → comprensión corta + acciones concretas.
Si hay ambigüedad → comprensión + preguntas puntuales.