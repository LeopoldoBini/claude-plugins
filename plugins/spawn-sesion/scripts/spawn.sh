#!/usr/bin/env bash
# Abre una sesión de Claude en otro repo y devuelve una dirección con la que hablarle.
#
# El nombre que ve `ListAgents` NO se elige: sale de la carpeta + 2 caracteres al azar, y colisiona
# de verdad (medido: dos sesiones vivas llamadas `app-saltacompra-a4`). Por eso acá se fija el id de
# sesión ANTES de crear y después se pregunta qué nombre le tocó a ESE id — sin adivinar cuál de las
# sesiones nuevas es la nuestra.
set -euo pipefail

ROOTS_DEFAULT="$HOME/Proyectos $HOME/cuenta-norte"
COLOR_SPAWN="Indigo"   # color reservado: "esta ventana la abrió otra sesión, no Leo"
MODO="cmux"
REPO=""
TITULO=""
BRIEF=""
MODEL=""
DRY=0
WORKTREE=0
FORZAR_VENTANA=0

uso() {
  cat <<'EOF'
uso: spawn.sh --repo <ruta-o-fragmento> [opciones]

  --repo <r>       Carpeta donde abrirla (`.` = acá), o un fragmento a buscar entre los repos git.
                   Cualquier carpeta sirve: el contexto de trabajo no siempre es un repo.
  --brief <t>      Lo que se le pide a la sesión nueva. Sin esto arranca ociosa.
  --brief-file <f> Lee el brief de un archivo — el traspaso de /handoff entra derecho acá.
  --model <m>      Modelo de la sesión (fable, opus, sonnet…). Se fija al nacer: desde adentro
                   la sesión no puede cambiárselo (/model sólo existe tipeado por el usuario).
  --worktree       Árbol de trabajo propio del mismo repo, para que no se pisen dos sesiones.
  --ventana        Ventana propia aunque ya haya una abierta en ese repo.
  --titulo <t>     Título de la ventana de cmux. Default: nombre de la carpeta. No aplica a pestañas.
  --bg             Sesión de fondo (sin pestaña). Leo no la ve ni la puede tomar.
  --dry-run        Muestra lo que haría y sale.

Dónde aparece: si ya hay una ventana de cmux abierta en ese repo, entra como PESTAÑA ahí — al lado
de la que la pidió. Si no hay ninguna, abre ventana propia, marcada con color y con quién la abrió.

Sin cmux pero con tmux (la flota), abre una VENTANA en la mesa de tmux de ese repo — la que Leo ya
espeja desde la Mac. Sin mesa para ese repo, crea una. La ventana es siempre nueva: no se escribe
sobre una que ya existe.

Busca repos en $SPAWN_ROOTS (default: ~/Proyectos ~/cuenta-norte).
Los worktrees viven en $SPAWN_WORKTREES (default: ~/.spawn-worktrees), fuera del repo.
Salida: bloques `clave: valor`. Sale 2 si el fragmento es ambiguo, listando los candidatos.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)   REPO="${2:-}"; shift 2 ;;
    --brief)  BRIEF="${2:-}"; shift 2 ;;
    --brief-file)
      [ -f "${2:-}" ] || { echo "error: no existe el archivo de brief '${2:-}'" >&2; exit 66; }
      BRIEF="$(cat "$2")"; shift 2 ;;
    --model)  MODEL="${2:-}"; shift 2 ;;
    --worktree) WORKTREE=1; shift ;;
    --ventana) FORZAR_VENTANA=1; shift ;;
    --titulo) TITULO="${2:-}"; shift 2 ;;
    --bg)     MODO="bg"; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) uso; exit 0 ;;
    *) echo "error: opción desconocida '$1'" >&2; uso >&2; exit 64 ;;
  esac
done

[ -n "$REPO" ] || { echo "error: falta --repo" >&2; exit 64; }

# --- resolver el destino ----------------------------------------------------
# Una ruta existente se toma tal cual, tenga .git o no: el contexto adecuado para trabajar es a veces
# una carpeta del paraguas, no un repo. Sin ruta, el sistema de archivos ES el registro y los repos se
# descubren buscando .git, así no hay una lista a mano que se pudra. Ante duda se sale con 2 y se
# listan los candidatos — nunca se elige por el usuario.
if [ -d "$REPO" ]; then
  DESTINO="$(cd "$REPO" && pwd)"
else
  CANDIDATOS=""
  for root in ${SPAWN_ROOTS:-$ROOTS_DEFAULT}; do
    [ -d "$root" ] || continue
    while IFS= read -r g; do
      d="${g%/.git}"
      case "$(basename "$d" | tr '[:upper:]' '[:lower:]')" in
        *"$(echo "$REPO" | tr '[:upper:]' '[:lower:]')"*) CANDIDATOS="$CANDIDATOS$d"$'\n' ;;
      esac
    done < <(find "$root" -maxdepth 7 -name .git -type d 2>/dev/null)
  done
  CANDIDATOS="$(printf '%s' "$CANDIDATOS" | sed '/^$/d')"
  N=$(printf '%s' "$CANDIDATOS" | grep -c . || true)
  if [ "$N" -eq 0 ]; then
    echo "estado: sin-coincidencias"
    echo "buscado: $REPO"
    exit 2
  elif [ "$N" -gt 1 ]; then
    echo "estado: ambiguo"
    echo "buscado: $REPO"
    echo "candidatos:"
    printf '%s\n' "$CANDIDATOS" | sed 's/^/  - /'
    exit 2
  fi
  DESTINO="$CANDIDATOS"
fi

[ -n "$TITULO" ] || TITULO="$(basename "$DESTINO")"

# --- árbol propio -----------------------------------------------------------
# Dos sesiones sobre el mismo árbol se pisan sin avisar: una hace checkout mientras la otra edita, y
# el index de git queda trabado. El worktree vive FUERA del repo para no ensuciar lo que ya está.
RAMA=""
WTDIR=""
if [ "$WORKTREE" -eq 1 ]; then
  git -C "$DESTINO" rev-parse --git-dir >/dev/null 2>&1 \
    || { echo "error: --worktree necesita un repo git; '$DESTINO' no lo es" >&2; exit 64; }
  RAMA="spawn/$(basename "$DESTINO")-$(date +%H%M%S)"
  WTDIR="${SPAWN_WORKTREES:-$HOME/.spawn-worktrees}/$(basename "$RAMA")"
  if [ "$DRY" -eq 0 ]; then
    mkdir -p "$(dirname "$WTDIR")"
    git -C "$DESTINO" worktree add -b "$RAMA" "$WTDIR" >/dev/null 2>&1 \
      || { echo "error: no se pudo crear el worktree en $WTDIR" >&2; exit 70; }
  fi
  DESTINO="$WTDIR"
  TITULO="$TITULO (árbol propio)"
  FORZAR_VENTANA=1   # un árbol aparte es trabajo aparte: merece su ventana
fi
UUID="$(python3 -c 'import uuid;print(uuid.uuid4())')"

# El brief viaja por archivo, no incrustado en la línea de comando: así comillas, saltos de línea y
# acentos llegan intactos en vez de romper el quoting del shell que cmux ejecuta.
#
# Arranca como el alias `cc` de Leo — sin preguntar permisos. Se escribe la bandera y no el alias
# porque el comando lo corre un shell no interactivo, donde los alias no existen. Efecto de fondo:
# también saltea el "¿confiás en esta carpeta?" que dejaba sesiones trabadas en repos nuevos.
CLAUDE_BIN="claude --dangerously-skip-permissions"
[ -n "$MODEL" ] && CLAUDE_BIN="$CLAUDE_BIN --model $MODEL"
BRIEFFILE=""
CMD="$CLAUDE_BIN --session-id $UUID"
if [ -n "$BRIEF" ]; then
  BRIEFFILE="$(mktemp "${TMPDIR:-/tmp}/spawn-brief.XXXXXX")"
  printf '%s' "$BRIEF" > "$BRIEFFILE"
  CMD="$CLAUDE_BIN --session-id $UUID \"\$(cat $BRIEFFILE)\""
fi

# --- dónde ponerla: pestaña en una ventana que ya existe, o ventana nueva -----
# Abrir una ventana por sesión llena la barra de duplicados del mismo repo (medido: dos ventanas en
# `radar` a la vez). Si ya hay una abierta ahí, la sesión nueva entra como pestaña: aparece al lado
# de la que la pidió y el origen se lee solo, sin marca. Se prefiere la ventana de quien llama; si no
# es esa, la de actividad más reciente. Sin ninguna, ventana propia — y ahí sí hace falta marcarla.
WSTAB=""; GRUPO=""; ORIGEN=""
# La Mac tiene cmux y es la interfaz; la flota no lo tiene ni le sirve. Ahí el análogo de la ventana
# es la mesa de tmux del repo, que ya se espeja desde la Mac: una ventana nueva adentro aparece en la
# pantalla de Leo sin ningún puente extra.
if [ "$MODO" = "cmux" ] && ! command -v cmux >/dev/null 2>&1 && command -v tmux >/dev/null 2>&1; then
  MODO="tmux"
fi
if [ "$MODO" = "cmux" ] && command -v cmux >/dev/null 2>&1; then
  INFO="$(python3 - "$DESTINO" "${CMUX_WORKSPACE_ID:-}" <<'PY' 2>/dev/null || true
import json, os, subprocess, sys

dest, caller = sys.argv[1], sys.argv[2]

def cmux_json(*args):
    try:
        r = subprocess.run(["cmux", *args, "--json"], capture_output=True, text=True, timeout=10)
        return json.loads(r.stdout)
    except Exception:
        return {}

def toplevel(path):
    if not os.path.isdir(path):
        return None
    r = subprocess.run(["git", "-C", path, "rev-parse", "--show-toplevel"],
                       capture_output=True, text=True)
    return r.stdout.strip() or None

wss = cmux_json("workspace", "list").get("workspaces", [])
dest_top = toplevel(dest)

# Coincidencia exacta primero; si no hay, misma raíz de repo — abrir en el paraguas del mismo repo
# sigue siendo el mismo contexto de trabajo.
cands = [w for w in wss if (w.get("current_directory") or "").rstrip("/") == dest.rstrip("/")]
if not cands and dest_top:
    cands = [w for w in wss if toplevel(w.get("current_directory") or "") == dest_top]

elegido = next((w for w in cands if w.get("id") == caller), None)
if elegido is None and cands:
    elegido = sorted(cands, key=lambda w: w.get("latest_submitted_at") or "")[-1]

# El grupo y el título de quien llama sólo sirven si termina abriéndose ventana nueva.
mio = next((w for w in wss if w.get("id") == caller), None)
grupo = ""
if mio:
    for g in cmux_json("workspace-group", "list").get("groups", []):
        if mio.get("ref") in g.get("member_workspace_refs", []):
            grupo = g.get("ref", "")
            break

print("ws_tab=" + (elegido.get("ref", "") if elegido else ""))
print("grupo=" + grupo)
print("origen=" + (mio.get("custom_title") or os.path.basename(mio.get("current_directory") or "") if mio else ""))
PY
)"
  WSTAB="$(printf '%s\n' "$INFO" | sed -n 's/^ws_tab=//p')"
  GRUPO="$(printf '%s\n' "$INFO" | sed -n 's/^grupo=//p')"
  ORIGEN="$(printf '%s\n' "$INFO" | sed -n 's/^origen=//p')"
fi
MESA=""
if [ "$MODO" = "tmux" ]; then
  # La mesa del repo se reconoce por dónde está parada: coincidencia exacta primero, y si no, misma
  # raíz de repo — una mesa abierta en un subdirectorio sigue siendo el mismo contexto de trabajo.
  DEST_TOP="$(git -C "$DESTINO" rev-parse --show-toplevel 2>/dev/null || true)"
  while IFS=' ' read -r sname spath; do
    [ -n "$sname" ] || continue
    if [ "${spath%/}" = "${DESTINO%/}" ]; then MESA="$sname"; break; fi
    if [ -n "$DEST_TOP" ] && [ "$(git -C "$spath" rev-parse --show-toplevel 2>/dev/null || true)" = "$DEST_TOP" ]; then
      [ -n "$MESA" ] || MESA="$sname"
    fi
  done < <(tmux list-panes -a -F '#{session_name} #{pane_current_path}' 2>/dev/null || true)
fi
[ "$FORZAR_VENTANA" -eq 1 ] && WSTAB=""
[ "$FORZAR_VENTANA" -eq 1 ] && MESA=""
[ -n "$WSTAB" ] && MODO="tab"

if [ "$DRY" -eq 1 ]; then
  echo "estado: dry-run"
  echo "repo: $DESTINO"
  [ -n "$RAMA" ] && echo "rama: $RAMA"
  echo "modo: $MODO"
  [ -n "$WSTAB" ] && echo "ventana_destino: $WSTAB"
  if [ "$MODO" = "tmux" ]; then
    echo "sustrato: tmux (sin cmux en esta máquina)"
    echo "mesa_destino: ${MESA:-— (mesa nueva)}"
  fi
  [ -n "$GRUPO" ] && echo "grupo: $GRUPO"
  echo "titulo: $TITULO"
  echo "session_id: $UUID"
  echo "comando: $CMD"
  [ -n "$BRIEFFILE" ] && rm -f "$BRIEFFILE"
  exit 0
fi

WS=""; SURF=""
case "$MODO" in
  tab)
    # Una pestaña nace fría: sin proceso hasta que recibe algo (medido). El Enter la despierta, y el
    # comando recién se manda con el prompt vivo — si no, el shell se come los primeros caracteres.
    SALIDA="$(cmux new-surface --type terminal --workspace "$WSTAB" --working-directory "$DESTINO" --focus false 2>&1)"
    SURF="$(printf '%s' "$SALIDA" | grep -oE 'surface:[0-9]+' | head -1)"
    [ -n "$SURF" ] || { echo "error: cmux no devolvió una referencia de pestaña" >&2; printf '%s\n' "$SALIDA" >&2; exit 70; }
    WS="$WSTAB"
    cmux send --surface "$SURF" "\n" >/dev/null 2>&1 || true
    for _ in $(seq 1 20); do
      [ -n "$(cmux read-screen --surface "$SURF" 2>/dev/null | tr -d '[:space:]')" ] && break
      sleep 0.5
    done
    sleep 1
    cmux send --surface "$SURF" "$CMD\n" >/dev/null 2>&1 \
      || { echo "error: no se pudo escribir en la pestaña $SURF" >&2; exit 70; }
    ;;
  cmux)
    command -v cmux >/dev/null 2>&1 || { echo "error: no está el cli de cmux; usá --bg" >&2; exit 69; }
    if [ -n "$GRUPO" ]; then
      SALIDA="$(cmux workspace create --name "$TITULO" --cwd "$DESTINO" --command "$CMD" --focus false --group "$GRUPO" 2>&1)"
    else
      SALIDA="$(cmux workspace create --name "$TITULO" --cwd "$DESTINO" --command "$CMD" --focus false 2>&1)"
    fi
    WS="$(printf '%s' "$SALIDA" | grep -oE 'workspace:[0-9]+' | head -1)"
    [ -n "$WS" ] || { echo "error: cmux no devolvió una referencia de workspace" >&2; printf '%s\n' "$SALIDA" >&2; exit 70; }
    # Color y descripción son la marca de origen: cmux no las pisa, a diferencia del título, que la
    # sesión reescribe sola con lo que está haciendo.
    cmux workspace-action --workspace "$WS" --action set-color --color "$COLOR_SPAWN" >/dev/null 2>&1 || true
    cmux workspace-action --workspace "$WS" --action set-description \
      --description "↩ abierta desde ${ORIGEN:-otra sesión} · $(date +'%d/%m %H:%M')" >/dev/null 2>&1 || true
    ;;
  tmux)
    # Una mesa de tmux puede tener trabajo vivo adentro, así que acá NUNCA se escribe sobre una
    # ventana que ya existe: la sesión nueva nace en la suya. El comando va puesto al crearla — no
    # hay prompt frío que despertar, que es donde send-keys se come los primeros caracteres.
    VENTANA="↩ $TITULO"
    if [ -n "$MESA" ]; then
      WS="$(tmux new-window -P -F '#{session_name}:#{window_index}' -t "$MESA:" -c "$DESTINO" -n "$VENTANA" "$CMD" 2>&1)" \
        || { echo "error: no se pudo abrir la ventana en la mesa '$MESA'" >&2; exit 70; }
    else
      # tmux no admite '.' ni ':' en el nombre de una mesa: los usa para direccionar ventana y panel.
      MESA="$(printf '%s' "$TITULO" | tr ' .:' '---' | cut -c1-24)"
      tmux has-session -t "=$MESA" 2>/dev/null \
        && { echo "error: ya existe una mesa llamada '$MESA' que no está en ese repo" >&2; exit 70; }
      tmux new-session -d -s "$MESA" -c "$DESTINO" -n "$VENTANA" "$CMD" 2>/dev/null \
        || { echo "error: no se pudo crear la mesa '$MESA'" >&2; exit 70; }
      WS="$(tmux list-windows -t "=$MESA" -F '#{session_name}:#{window_index}' 2>/dev/null | head -1)"
    fi
    ;;
  bg)
    ( cd "$DESTINO" && $CLAUDE_BIN --bg --session-id "$UUID" "${BRIEF:-hola}" >/dev/null 2>&1 & )
    ;;
esac

# --- resolver qué nombre le tocó a NUESTRO id -------------------------------
NOMBRE=""
for _ in $(seq 1 15); do
  NOMBRE="$(claude agents --json 2>/dev/null | python3 -c '
import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
for s in d:
    if s.get("sessionId")==sys.argv[1]:
        print(s.get("name",""))
' "$UUID" || true)"
  [ -n "$NOMBRE" ] && break
  sleep 1
done

# Un nombre repetido entre sesiones vivas no se puede usar como dirección: SendMessage sólo direcciona
# por nombre, así que ahí la vía buena es la referencia de cmux.
REPETIDO="$(claude agents --json 2>/dev/null | python3 -c '
import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
n=sys.argv[1]
print("si" if n and sum(1 for s in d if s.get("name")==n)>1 else "no")
' "$NOMBRE" || echo "no")"

# La dirección de cmux es la pestaña cuando hay pestaña: leer por ventana devuelve la pestaña
# seleccionada, que casi nunca es la nuestra.
DIR_CMUX="${SURF:-$WS}"

if [ -z "$NOMBRE" ]; then
  # La causa medida y frecuente: en un repo que Claude nunca abrió, la sesión se traba en la pregunta
  # "¿confiás en esta carpeta?" y nunca se registra. Mostrar la pantalla convierte un guión mudo en
  # un diagnóstico.
  echo "estado: trabada"
  echo "repo: $DESTINO"
  echo "modo: $MODO"
  echo "session_id: $UUID"
  echo "workspace: ${WS:-—}"
  [ -n "$SURF" ] && echo "pestaña: $SURF"
  if [ "$MODO" = "tmux" ] && [ -n "$WS" ]; then
    echo "pantalla:"
    tmux capture-pane -p -t "$WS" 2>/dev/null | sed '/^[[:space:]]*$/d' | tail -12 | sed 's/^/  /'
  elif [ -n "$DIR_CMUX" ]; then
    echo "pantalla:"
    if [ -n "$SURF" ]; then
      cmux read-screen --surface "$SURF" 2>/dev/null | sed '/^[[:space:]]*$/d' | tail -12 | sed 's/^/  /'
    else
      cmux read-screen --workspace "$WS" 2>/dev/null | sed '/^[[:space:]]*$/d' | tail -12 | sed 's/^/  /'
    fi
  fi
  [ -n "$BRIEFFILE" ] && echo "brief_tmp: $BRIEFFILE"
  exit 3
fi

echo "estado: creada"
echo "repo: $DESTINO"
[ -n "$RAMA" ] && echo "rama: $RAMA"
echo "modo: $MODO"
echo "session_id: $UUID"
echo "workspace: ${WS:-—}"
[ -n "$SURF" ] && echo "pestaña: $SURF"
if [ "$MODO" = "tmux" ]; then
  # Se le escribe con `tmux send-keys -t <ref> "texto" Enter` y se le lee con `tmux capture-pane -p -t <ref>`.
  echo "direccion_tmux: ${WS:-—}"
else
  echo "direccion_cmux: ${DIR_CMUX:-—}"
fi
echo "nombre: $NOMBRE"
echo "nombre_repetido: $REPETIDO"
[ -n "$BRIEFFILE" ] && echo "brief_tmp: $BRIEFFILE"
exit 0
