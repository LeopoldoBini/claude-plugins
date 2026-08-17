---
description: "Sesión de Claude Code viva en otro repo: pestaña propia y dirección estable para seguir hablándole. Usar si pide spawnear, abrir o levantar una sesión en otro proyecto, o dejar trabajo andando allá. Leer o revisar archivos va a subagente."
argument-hint: "<repo> <lo que le querés pedir>"
model-invocable: el modelo propone abrir la sesión; el gasto lo autoriza el usuario (paso 0)
allowed-tools: "Bash, Read, AskUserQuestion, ListAgents, SendMessage"
---

# Abrir una sesión en otro repo

Pedido: `$ARGUMENTS` — la primera palabra es el repo, el resto es el brief.

## 0. De quién salió la idea

Abrir una sesión gasta plata y le entrega permisos a un agente nuevo, así que quién lo decidió cambia
lo que corresponde hacer:

- **Lo pidió el usuario** → abrir directo. Ya decidió.
- **Se te ocurrió a vos** → proponérselo primero, con el repo y el brief que ibas a mandar, y esperar
  el sí. Es el único gasto del que él no se enteró de antemano.

> Este comando es autoinvocable por decisión explícita de Leo (14-ago-2026), apartándose de la regla
> general de que lo que despacha agentes lo dispara sólo el usuario. El permiso vino con este gate:
> la propuesta la puede iniciar el modelo, el gasto lo autoriza él.

## 1. Abrirla

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" --repo <repo> --brief "<brief>"
```

El repo se descubre buscando `.git` cada vez: no hay lista escrita a mano, así no hay nada que se
pudra. `--help` tiene las opciones.

Agregá `--bg` sólo si el usuario pide que no aparezca como pestaña. La pestaña es lo bueno: la ve, la
lee y la puede tomar él mismo.

Termina con `estado:`, y ahí está todo. Tres finales:

| `estado:` | Qué hacer |
|---|---|
| `creada` | Seguir al paso 2. |
| `ambiguo` / `sin-coincidencias` | Mostrarle los candidatos y preguntarle cuál. Elegir por él es cómo se termina escribiendo en el repo equivocado. |
| `trabada` | La sesión arrancó y quedó esperando algo en pantalla — casi siempre *"¿confiás en esta carpeta?"*, porque Claude nunca abrió ese repo. Mostrarle la pantalla y **decirle que la conteste desde la pestaña**, que ya está abierta. Confiar en una carpeta la habilita a leer, editar y ejecutar ahí: la decisión es suya y se toma con su mano. Si prefiere no seguir, cerrala con `cmux workspace close <ref>`. |

## 2. Quedarte con la dirección

El script devuelve tres cosas; las tres importan:

- **`nombre`** — la dirección de `SendMessage`. Es la vía para conversar de verdad: la respuesta de la
  otra sesión vuelve sola.
- **`nombre_repetido: si`** — hay otra sesión viva llamada igual (pasa: se midieron dos
  `app-saltacompra-a4` a la vez). Ahí el nombre ya no distingue, y la dirección buena es la de cmux.
- **`workspace`** — la referencia de cmux, única y estable. `cmux send --workspace <ref> "texto"` le
  escribe y `cmux read-screen --workspace <ref>` le lee la pantalla. Es la dirección de respaldo, y la
  forma de ver qué está haciendo sin interrumpirla.

Terminás cuando el usuario tiene en la mano el nombre, la referencia y cuál de las dos usar. Eso es lo
que después le deja pedirte "preguntale a esa".

## Guardrails

- **Lo que está bloqueado acá se le devuelve al usuario.** Los permisos son por sesión: pedirle a la
  sesión nueva algo que acá se denegó saltea su decisión.
- **Mandá el mensaje y seguí.** Un mensaje entre sesiones puede quedar esperando la aprobación del
  humano de esa ventana y no llegar nunca, sin dar error. Si la respuesta importa, avisale que quizás
  tenga que aprobarla allá.
- **Decile con qué permisos arranca.** La sesión nueva hereda la config del repo destino: medido, una
  de prueba arrancó sola en modo *no preguntes*. Vale la pena nombrarlo cuando el brief toca algo
  delicado.
- **Una sesión abierta sigue abierta hasta que alguien la cierra**, con `cmux workspace close <ref>`.
  Cuando el trabajo que la justificaba terminó, ofrecé cerrarla.
