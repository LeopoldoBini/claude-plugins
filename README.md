# Claude Plugins - Leopoldo Bini

Custom Claude Code plugins for productivity and workflow automation.

## Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| **clickup** | Full ClickUp API integration via direct curl (100+ endpoints) | Productivity |

## Installation

```bash
/plugin install clickup@leopoldo-plugins
```

Or browse in `/plugin > Discover`.

## Setup (ClickUp)

1. Get your ClickUp API token: Settings > Apps > API Token
2. Save it:
   ```bash
   mkdir -p ~/.config/clickup
   echo 'your_token_here' > ~/.config/clickup/token
   chmod 600 ~/.config/clickup/token
   ```
3. Set your Team ID:
   ```bash
   echo 'CLICKUP_TEAM_ID=your_team_id' > ~/.config/clickup/config.env
   ```
4. (Optional) Add project-specific config:
   ```bash
   cp ~/.claude/plugins/marketplaces/leopoldo-plugins/plugins/clickup/templates/clickup.local.md.template \
      your-project/.claude/clickup.local.md
   # Edit with your space/list IDs
   ```

## Slash Commands

- `/cu:search <term>` - Search tasks or fetch by ID
- `/cu:task <id>` - Detailed task card
- `/cu:spaces` - Workspace tree
- `/cu:status` - Dashboard by status

## Contributing

To add a new plugin, create a directory under `plugins/` with the standard structure and add an entry to `.claude-plugin/marketplace.json`.
