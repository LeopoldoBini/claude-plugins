---
description: "Abre una sesión de Claude en otro repo con el pedido ya adentro, y deja una dirección estable para seguir hablándole."
argument-hint: "<repo> <lo que le querés pedir>"
allowed-tools: "Bash, Read, ListAgents, SendMessage"
disable-model-invocation: true
---

# Abrir una sesión en otro repo

Cada sesión abierta cuesta plata y arranca con los permisos del repo destino. Corré esto sólo cuando
el usuario lo pide; una sesión abierta de más no se deshace sola.

Pedido: `$ARGUMENTS` — la primera palabra es el repo, el resto es el brief.

## 1. Abrirla

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" --repo <repo> --brief "<brief>"
```

El script busca repos por `.git` bajo `$SPAWN_ROOTS` (default `~/Proyectos ~/cuenta-norte`). No hay
lista de repos escrita a mano: se descubren cada vez, así no hay nada que se pudra.

Agregá `--bg` sólo si el usuario pide que no aparezca como pestaña. La pestaña es lo bueno: la ve,
la lee y la puede tomar él mismo.

Sale con `estado:` y ahí está todo lo que pasó. Tres finales:

| `estado:` | Qué hacer |
|---|---|
| `creada` | Seguir al paso 2. |
| `ambiguo` / `sin-coincidencias` | Mostrarle los candidatos al usuario y preguntarle cuál. Elegir por él es cómo se termina escribiendo en el repo equivocado. |
| `trabada` | La sesión arrancó pero está esperando algo en pantalla — casi siempre *"¿confiás en esta carpeta?"*, porque Claude nunca abrió ese repo. Mostrarle la pantalla y que conteste él: confiar en una carpeta es decisión suya. |

## 2. Quedarte con la dirección

El script devuelve tres cosas; las tres importan:

- **`nombre`** — la dirección de `SendMessage`. Es lo que se usa para conversar de verdad: la
  respuesta de la otra sesión vuelve sola.
- **`nombre_repetido: si`** — hay otra sesión viva llamada igual (pasa: se midieron dos
  `app-saltacompra-a4` a la vez). Ahí el nombre no sirve como dirección: usar la referencia de cmux.
- **`workspace`** — la referencia de cmux, única y estable. `cmux send --workspace <ref> "texto"` le
  escribe y `cmux read-screen --workspace <ref>` le lee la pantalla. Es el respaldo cuando el nombre
  está repetido, y la forma de ver qué está haciendo sin interrumpirla.

Decile al usuario el nombre y la referencia. Son lo que él necesita para pedirte "preguntale a esa".

## Lo que no se hace

- **Los permisos son por sesión.** Si algo te lo bloquearon acá, no se lo pedís a la sesión nueva:
  eso saltea la decisión del usuario. Lo que está bloqueado se le devuelve a él.
- **Un mensaje entre sesiones puede quedar esperando la aprobación del humano de esa ventana** y no
  llegar nunca, sin dar error. Mandá y seguí; si la respuesta importa, avisale que quizás tenga que
  aprobarla allá.
- **La sesión nueva hereda la config del repo destino**, incluido el modo de permisos. Medido: una
  sesión de prueba arrancó sola en modo *no preguntes*. Si el brief toca algo delicado, decilo.
