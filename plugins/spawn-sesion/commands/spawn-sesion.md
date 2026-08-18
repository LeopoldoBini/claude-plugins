---
description: "Abrir otra sesión de Claude Code con el pedido adentro y una dirección para seguir hablándole. Usar si pide que algo lo siga o lo haga otra sesión, acá o en otra carpeta. Leer o revisar va a subagente."
argument-hint: "<repo> <lo que le querés pedir>"
model-invocable: el modelo propone abrir la sesión; el gasto lo autoriza el usuario (paso 0)
allowed-tools: "Bash, Read, AskUserQuestion, ListAgents, SendMessage"
---

# Abrir otra sesión

Pedido: `$ARGUMENTS`. Puede venir vacío o a medias: casi siempre llega como "seguí esto en otra
sesión", y lo que hay que mandar está en la conversación, no en el argumento.

## Dónde y qué — se deduce, no se pregunta

- **Dónde**: la carpeta que tiene el contexto del trabajo. La del proyecto que se está hablando; `.`
  si el trabajo es acá mismo. Cualquier carpeta sirve, tenga `.git` o no. Preguntá sólo si el script
  vuelve `ambiguo`.
- **Qué**: el brief lo redactás vos con lo que se venía hablando — qué hay que hacer, qué se decidió
  ya, qué archivo o ticket mirar primero. Copiar la frase del usuario tal cual deja a la sesión nueva
  arrancando ciega, porque el contexto estaba acá y no viajó.
- **Si el encargo es correr un comando slash** (`/to-tickets`, `/prd-pipeline`…): el brief **empieza
  con esa línea** — el comando y sus argumentos primero, el contexto a continuación. El brief entra
  como prompt tipeado, y eso cuenta como invocación del usuario; pedido en prosa ("corré /x"), la
  sesión queda bloqueada — los comandos `disable-model-invocation` no puede invocárselos ella misma
  (medido 18-ago-2026 con /to-tickets). A una sesión ya viva se la destraba igual: `cmux send` con esa
  misma línea.
- **Modelo**: si el pedido nombra uno ("con fable"), va en `--model` al abrir. Se fija al nacer:
  `/model` sólo existe tipeado por el usuario, la sesión no puede cambiárselo a sí misma.
- **Árbol de trabajo**: la sesión nueva abre en la carpeta tal cual, compartiendo el árbol. Si
  necesita uno propio lo decide ella, que tiene el repo delante y sabe si va a escribir. Abrila en un
  árbol aparte sólo si el usuario lo pide.
- **Dónde aparece**: lo decide el script, según qué haya en la máquina. Con cmux (la Mac): pestaña en
  la ventana que ya está abierta en ese repo, o ventana propia si no hay ninguna. Sin cmux pero con
  tmux (la flota): ventana nueva en la mesa de ese repo, o mesa nueva si no existe — nunca escribe
  sobre una ventana que ya estaba, que puede tener trabajo vivo adentro. Pasale `--ventana` sólo si el
  usuario pide que la sesión nueva tenga la suya aparte.

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
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn.sh" --repo <carpeta> --brief "<brief>"
```

Una ruta existente se usa tal cual; un fragmento se busca entre los repos, descubiertos por `.git`
cada vez, sin lista escrita a mano que se pudra. `--help` tiene las opciones — entre ellas
`--brief-file`, que toma derecho el archivo de traspaso que deja el skill de handoff.

Agregá `--bg` sólo si el usuario pide que no se vea. Que se vea es lo bueno: la lee y la puede tomar
él mismo.

Termina con `estado:`, y ahí está todo. Tres finales:

| `estado:` | Qué hacer |
|---|---|
| `creada` | Seguir al paso 2. |
| `ambiguo` / `sin-coincidencias` | Mostrarle los candidatos y preguntarle cuál. Elegir por él es cómo se termina escribiendo en el repo equivocado. |
| `trabada` | La sesión arrancó y quedó esperando algo en pantalla. Mostrarle esa pantalla y decirle que la conteste desde la pestaña, que ya está abierta. Si prefiere no seguir, cerrala (ver Guardrails). |

## 2. Quedarte con la dirección

El script devuelve tres cosas; las tres importan:

- **`nombre`** — la dirección de `SendMessage`. Es la vía para conversar de verdad: la respuesta de la
  otra sesión vuelve sola.
- **`nombre_repetido: si`** — hay otra sesión viva llamada igual (pasa: se midieron dos
  `app-saltacompra-a4` a la vez). Ahí el nombre ya no distingue, y la dirección buena es la de cmux.
- **`direccion_cmux`** — la referencia de cmux, única y estable: `surface:N` si entró como pestaña,
  `workspace:N` si abrió ventana. `cmux send --surface <ref> "texto"` le escribe y
  `cmux read-screen --surface <ref>` le lee la pantalla (con `--workspace` para las ventanas). Es la
  dirección de respaldo, y la forma de ver qué está haciendo sin interrumpirla.
- **`direccion_tmux`** — el equivalente en la flota: `mesa:ventana`. `tmux send-keys -t <ref> "texto"
  Enter` le escribe y `tmux capture-pane -p -t <ref>` le lee la pantalla. Se dirige sólo a la ventana
  que devolvió el script: mandarle teclas a otra es escribir sobre lo que esté corriendo ahí.

Terminás cuando el usuario tiene en la mano el nombre, la referencia y cuál de las dos usar. Eso es lo
que después le deja pedirte "preguntale a esa".

## Guardrails

- **Lo que está bloqueado acá se le devuelve al usuario.** Los permisos son por sesión: pedirle a la
  sesión nueva algo que acá se denegó saltea su decisión.
- **Mandá el mensaje y seguí.** Un mensaje entre sesiones puede quedar esperando la aprobación del
  humano de esa ventana y no llegar nunca, sin dar error. Si la respuesta importa, avisale que quizás
  tenga que aprobarla allá.
- **Arranca sin preguntar permisos** — el alias `cc` de Leo, por decisión suya. Edita, borra y
  ejecuta en esa carpeta sin freno. Nombralo cuando el brief toca algo delicado.
- **Una sesión abierta sigue abierta hasta que alguien la cierra.** Pestaña: `cmux close-surface
  --surface <ref>`. Ventana: `cmux workspace close <ref>` — cierra todas sus pestañas, así que mirá
  antes qué más hay adentro. Cuando el trabajo que la justificaba terminó, ofrecé cerrarla.
