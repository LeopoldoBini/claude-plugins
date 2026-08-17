#!/usr/bin/env bash
# Abre una sesión de Claude en otro repo y devuelve una dirección con la que hablarle.
#
# El nombre que ve `ListAgents` NO se elige: sale de la carpeta + 2 caracteres al azar, y colisiona
# de verdad (medido: dos sesiones vivas llamadas `app-saltacompra-a4`). Por eso acá se fija el id de
# sesión ANTES de crear y después se pregunta qué nombre le tocó a ESE id — sin adivinar cuál de las
# sesiones nuevas es la nuestra.
set -euo pipefail

ROOTS_DEFAULT="$HOME/Proyectos $HOME/cuenta-norte"
MODO="cmux"
REPO=""
TITULO=""
BRIEF=""
DRY=0
WORKTREE=0

uso() {
  cat <<'EOF'
uso: spawn.sh --repo <ruta-o-fragmento> [opciones]

  --repo <r>       Carpeta donde abrirla (`.` = acá), o un fragmento a buscar entre los repos git.
                   Cualquier carpeta sirve: el contexto de trabajo no siempre es un repo.
  --brief <t>      Lo que se le pide a la sesión nueva. Sin esto arranca ociosa.
  --brief-file <f> Lee el brief de un archivo — el traspaso de /handoff entra derecho acá.
  --worktree       Árbol de trabajo propio del mismo repo, para que no se pisen dos sesiones.
  --titulo <t>     Título de la pestaña de cmux. Default: nombre de la carpeta.
  --bg             Sesión de fondo (sin pestaña). Leo no la ve ni la puede tomar.
  --dry-run        Muestra lo que haría y sale.

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
    --worktree) WORKTREE=1; shift ;;
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
fi
UUID="$(python3 -c 'import uuid;print(uuid.uuid4())')"

# El brief viaja por archivo, no incrustado en la línea de comando: así comillas, saltos de línea y
# acentos llegan intactos en vez de romper el quoting del shell que cmux ejecuta.
BRIEFFILE=""
CMD="claude --session-id $UUID"
if [ -n "$BRIEF" ]; then
  BRIEFFILE="$(mktemp "${TMPDIR:-/tmp}/spawn-brief.XXXXXX")"
  printf '%s' "$BRIEF" > "$BRIEFFILE"
  CMD="claude --session-id $UUID \"\$(cat $BRIEFFILE)\""
fi

if [ "$DRY" -eq 1 ]; then
  echo "estado: dry-run"
  echo "repo: $DESTINO"
  [ -n "$RAMA" ] && echo "rama: $RAMA"
  echo "modo: $MODO"
  echo "titulo: $TITULO"
  echo "session_id: $UUID"
  echo "comando: $CMD"
  [ -n "$BRIEFFILE" ] && rm -f "$BRIEFFILE"
  exit 0
fi

WS=""
if [ "$MODO" = "cmux" ]; then
  command -v cmux >/dev/null 2>&1 || { echo "error: no está el cli de cmux; usá --bg" >&2; exit 69; }
  SALIDA="$(cmux workspace create --name "$TITULO" --cwd "$DESTINO" --command "$CMD" --focus false 2>&1)"
  WS="$(printf '%s' "$SALIDA" | grep -oE 'workspace:[0-9]+' | head -1)"
  [ -n "$WS" ] || { echo "error: cmux no devolvió una referencia de workspace" >&2; printf '%s\n' "$SALIDA" >&2; exit 70; }
else
  ( cd "$DESTINO" && claude --bg --session-id "$UUID" "${BRIEF:-hola}" >/dev/null 2>&1 & )
fi

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

if [ -z "$NOMBRE" ]; then
  # La causa medida y frecuente: en un repo que Claude nunca abrió, la sesión se traba en la pregunta
  # "¿confiás en esta carpeta?" y nunca se registra. Mostrar la pantalla convierte un guión mudo en
  # un diagnóstico.
  echo "estado: trabada"
  echo "repo: $DESTINO"
  echo "modo: $MODO"
  echo "session_id: $UUID"
  echo "workspace: ${WS:-—}"
  if [ -n "$WS" ]; then
    echo "pantalla:"
    cmux read-screen --workspace "$WS" 2>/dev/null | sed '/^[[:space:]]*$/d' | tail -12 | sed 's/^/  /'
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
echo "nombre: $NOMBRE"
echo "nombre_repetido: $REPETIDO"
[ -n "$BRIEFFILE" ] && echo "brief_tmp: $BRIEFFILE"
exit 0
