#!/usr/bin/env bash
# cu-api.sh - ClickUp API wrapper with auto-auth and retry
# Usage: cu-api.sh METHOD /endpoint [json_body]
# Examples:
#   cu-api.sh GET /user
#   cu-api.sh GET /team/90133019410/space
#   cu-api.sh POST /list/123/task '{"name":"New task"}'
#   cu-api.sh PUT /task/abc123 '{"status":"in progress"}'
#   cu-api.sh DELETE /task/abc123
#   cu-api.sh setup  (interactive discovery)

set -euo pipefail

BASE_URL="https://api.clickup.com/api/v2"
CONFIG_DIR="$HOME/.config/clickup"
MAX_RETRIES=3

# --- Token Resolution (priority order) ---
resolve_token() {
    # 1. File token
    if [[ -f "$CONFIG_DIR/token" ]]; then
        cat "$CONFIG_DIR/token" | tr -d '[:space:]'
        return 0
    fi
    # 2. Environment variable
    if [[ -n "${CLICKUP_API_KEY:-}" ]]; then
        echo "$CLICKUP_API_KEY"
        return 0
    fi
    # 3. Legacy location
    if [[ -f "$HOME/.config/saltacompra/clickup.env" ]]; then
        grep -oP 'CLICKUP_API_KEY=\K.*' "$HOME/.config/saltacompra/clickup.env" | tr -d '[:space:]'
        return 0
    fi
    echo "ERROR: No ClickUp token found." >&2
    echo "  Set up: echo 'your_token' > ~/.config/clickup/token && chmod 600 ~/.config/clickup/token" >&2
    return 1
}

# --- Load config.env for TEAM_ID and other defaults ---
load_config() {
    if [[ -f "$CONFIG_DIR/config.env" ]]; then
        set -a
        source "$CONFIG_DIR/config.env"
        set +a
    fi
}

# --- Setup subcommand ---
do_setup() {
    local token
    token=$(resolve_token)
    echo "Discovering workspace..."
    echo ""

    # Get teams
    local teams
    teams=$(curl -s -H "Authorization: $token" "$BASE_URL/team")
    echo "Teams:"
    echo "$teams" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for t in data.get('teams', []):
    print(f\"  ID: {t['id']}  Name: {t['name']}  Members: {len(t.get('members', []))}\")
" 2>/dev/null || echo "$teams"

    # Get spaces for first team
    local team_id
    team_id=$(echo "$teams" | python3 -c "import sys,json; print(json.load(sys.stdin)['teams'][0]['id'])" 2>/dev/null)
    if [[ -n "$team_id" ]]; then
        echo ""
        echo "Spaces (team $team_id):"
        local spaces
        spaces=$(curl -s -H "Authorization: $token" "$BASE_URL/team/$team_id/space?archived=false")
        echo "$spaces" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for s in data.get('spaces', []):
    print(f\"  ID: {s['id']}  Name: {s['name']}\")
" 2>/dev/null || echo "$spaces"
    fi
}

# --- API call with retry ---
api_call() {
    local method="$1"
    local endpoint="$2"
    local body="${3:-}"
    local token
    token=$(resolve_token)

    # Build URL
    local url
    if [[ "$endpoint" == http* ]]; then
        url="$endpoint"
    else
        url="${BASE_URL}${endpoint}"
    fi

    local attempt=0
    local wait_time=2

    while (( attempt < MAX_RETRIES )); do
        local http_code
        local response
        local tmpfile
        tmpfile=$(mktemp)

        # Build curl args
        local curl_args=(-s -w "\n%{http_code}" -H "Authorization: $token" -H "Content-Type: application/json")
        if [[ "$method" != "GET" ]]; then
            curl_args+=(-X "$method")
        fi
        if [[ -n "$body" ]]; then
            curl_args+=(-d "$body")
        fi

        response=$(curl "${curl_args[@]}" "$url" 2>/dev/null)
        http_code=$(echo "$response" | tail -1)
        response=$(echo "$response" | sed '$d')

        # Rate limited - retry with backoff
        if [[ "$http_code" == "429" ]]; then
            attempt=$((attempt + 1))
            if (( attempt < MAX_RETRIES )); then
                echo "Rate limited. Retrying in ${wait_time}s... (attempt $attempt/$MAX_RETRIES)" >&2
                sleep "$wait_time"
                wait_time=$((wait_time * 2))
                continue
            fi
        fi

        # Output response
        echo "$response"

        # Exit code based on HTTP status
        if [[ "$http_code" =~ ^2 ]]; then
            return 0
        else
            echo "HTTP $http_code" >&2
            return 1
        fi
    done

    echo "Max retries reached" >&2
    return 1
}

# --- Main ---
load_config

if [[ $# -lt 1 ]]; then
    echo "Usage: cu-api.sh METHOD /endpoint [json_body]"
    echo "       cu-api.sh setup"
    exit 1
fi

case "$1" in
    setup)
        do_setup
        ;;
    GET|POST|PUT|DELETE|PATCH)
        if [[ $# -lt 2 ]]; then
            echo "Usage: cu-api.sh $1 /endpoint [json_body]" >&2
            exit 1
        fi
        api_call "$1" "$2" "${3:-}"
        ;;
    *)
        echo "Unknown method: $1. Use GET, POST, PUT, DELETE, PATCH, or setup." >&2
        exit 1
        ;;
esac
