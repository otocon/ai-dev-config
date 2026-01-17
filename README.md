# AI Dev Config

Shared configuration for AI-powered development tools. This repository provides pre-approved command lists, session logging, and standardized configurations for multiple AI coding assistants.

## ⚠️ Disclaimer

**USE AT YOUR OWN RISK.** This software is provided "as is" without warranty of any kind, express or implied.

### Potential Risks

By using this configuration, you acknowledge the following risks:

- **File operations without prompting:** Pre-approved commands include `rm`, `mv`, and `cp` which can modify or delete files without confirmation prompts
- **Backup bypass:** The `--no-backup` installation flag skips safety backups of existing configurations
- **Global configuration changes:** Codex installation merges settings into your global `~/.codex/config.toml` file
- **Configuration overwrite:** Symlinks may overwrite your existing tool configurations (`.claude/`, `.gemini/`, `opencode.json`)
- **Automatic script execution:** Session logging hooks execute automatically at the end of AI sessions

### Recommendations

Before installation:

1. **Review pre-approved commands** in `shared/commands.txt` and tool-specific configs
2. **Backup existing configurations** for `.claude/`, `.gemini/`, `opencode.json`, and `~/.codex/`
3. **Test in a non-production environment** first to understand the behavior

---

## Supported Tools

| Tool | Config Location | Pre-Approval Mechanism |
|------|-----------------|------------------------|
| **Claude Code** | `.claude/settings.json` | `permissions.allow` with wildcards |
| **OpenCode** | `opencode.json` | Permission patterns |
| **Codex** | `~/.codex/config.toml` | Approval policies |
| **Gemini CLI** | `.gemini/settings.json` + policies | Policy engine (TOML rules) |

## Quick Start

### 1. Add as Submodule

```bash
cd your-project
git submodule add <repo-url> .ai-dev-config
```

### 2. Run Installation

```bash
./.ai-dev-config/install.sh
```

### 3. Start Coding

Your AI tools will now have pre-approved commands and session logging enabled.

## Installation Options

```bash
./ai-dev-config/install.sh [OPTIONS]

Options:
  --log-to-git      Add .ai-sessions/ to git (default: gitignored)
  --no-backup       Skip backing up existing configs
  --tool=<name>     Install only specific tool (claude-code|opencode|codex|gemini-cli)
```

### Examples

```bash
# Install all tools
./.ai-dev-config/install.sh

# Install only Claude Code
./.ai-dev-config/install.sh --tool=claude-code

# Include session logs in version control
./.ai-dev-config/install.sh --log-to-git
```

## Uninstallation

```bash
./.ai-dev-config/uninstall.sh [OPTIONS]

Options:
  --remove-sessions   Also remove .ai-sessions/ directory and logs
  --remove-codex      Also remove Codex config from ~/.codex/
```

To fully remove the submodule:

```bash
./.ai-dev-config/uninstall.sh --remove-sessions
git submodule deinit .ai-dev-config
git rm .ai-dev-config
rm -rf .git/modules/.ai-dev-config
```

## Repository Structure

```
ai-dev-config/
├── install.sh                    # Main installation script
├── uninstall.sh                  # Cleanup script
├── README.md
│
├── claude-code/
│   ├── settings.json             # Pre-approved commands
│   ├── hooks/
│   │   └── log-session.sh        # Session logging hook
│   └── CLAUDE.md.template        # Project guidelines template
│
├── opencode/
│   ├── opencode.json             # Permission patterns
│   └── AGENTS.md.template        # Project guidelines template
│
├── codex/
│   └── config.toml               # Approval policies
│
├── gemini-cli/
│   ├── settings.json             # Tool settings
│   ├── policies/
│   │   └── dev-tools.toml        # Command approval rules
│   ├── hooks/
│   │   └── log-session.sh        # Session logging hook
│   └── GEMINI.md.template        # Project guidelines template
│
└── shared/
    ├── commands.txt              # Master list (documentation)
    └── session-logger.sh         # Shared logging logic
```

## Pre-Approved Commands

The following command categories are pre-approved across all tools:

### Java Development
- `java`, `javac`, `mvn`, `gradle`, `sdk`
- Maven goals: `clean`, `install`, `test`, `package`, `verify`, `dependency:*`
- Gradle tasks: `build`, `test`, `clean`, `run`

### Zig Development
- `zig build`, `zig test`, `zig run`, `zig fmt`, `zig cc`

### Node.js / Frontend
- `node`, `npm`, `npx`, `yarn`, `pnpm`, `bun`
- `tsc`, `eslint`, `prettier`, `vite`, `webpack`, `esbuild`

### Git & DevOps
- `git`, `gh`
- `docker`, `docker-compose`, `podman`
- `make`, `cmake`

### System Utilities
- File ops: `ls`, `pwd`, `mkdir`, `cp`, `mv`, `rm`, `cat`, `head`, `tail`
- Text processing: `find`, `grep`, `rg`, `sed`, `awk`, `sort`, `uniq`, `wc`, `diff`
- Network/data: `curl`, `wget`, `jq`, `yq`
- Compression: `tar`, `gzip`, `zip`, `unzip`
- Process: `ps`, `kill`, `free`, `df`, `du`

### Additional Languages
- **Rust**: `cargo`, `rustc`, `rustfmt`
- **Go**: `go`, `gofmt`
- **Python**: `python`, `pip`, `poetry`, `pipenv`, `uv`

See `shared/commands.txt` for the complete list.

## Session Logging

Sessions are automatically logged to `.ai-sessions/` with the following format:

**Filename:** `YYYY-MM-DD_HH-MM-SS_<slug>.md`

**Content:**
```markdown
# <Task Title>

**Date:** 2026-01-17 14:30:00
**Tool:** claude-code
**Model:** claude-opus-4-5

## Prompt
> [Original user request]

## Specification
[AI-generated plan or specification]

## Files Changed
- src/auth/AuthService.java (modified)
- src/api/UserController.java (created)

## Outcome
[Brief summary of what was accomplished]
```

### Session Directory Options

By default, `.ai-sessions/` is added to `.gitignore`. To track sessions in git:

```bash
./.ai-dev-config/install.sh --log-to-git
```

## Customization

### Adding Custom Commands

1. Edit the relevant tool configuration:
   - Claude Code: `claude-code/settings.json`
   - Gemini CLI: `gemini-cli/policies/dev-tools.toml`
   - OpenCode: `opencode/opencode.json`
   - Codex: `codex/config.toml`

2. Update `shared/commands.txt` for documentation

3. Commit and push changes to your fork

### Project Guidelines

Each tool has a template file for project-specific guidelines:
- `claude-code/CLAUDE.md.template`
- `opencode/AGENTS.md.template`
- `gemini-cli/GEMINI.md.template`

Copy and customize these for your project's needs.

## How It Works

### Symlink Strategy

The installation script creates symlinks from standard tool config locations to this repository:

```
.claude/          →  .ai-dev-config/claude-code/
.gemini/          →  .ai-dev-config/gemini-cli/
opencode.json     →  .ai-dev-config/opencode/opencode.json
```

This allows:
- Version-controlled configurations
- Easy updates via git pull
- Consistent settings across team members

### Codex Special Handling

Codex uses a global config at `~/.codex/config.toml`. The installer:
1. Creates the directory if needed
2. Merges settings with existing config (if present)
3. Creates a local reference file for tracking

## Verification

After installation, verify the setup:

1. **Check symlinks:**
   ```bash
   ls -la .claude .gemini opencode.json
   ```

2. **Test with Claude Code:**
   ```bash
   claude
   # Run: mvn --version
   # Should execute without permission prompt
   ```

3. **Check session logging:**
   ```bash
   ls .ai-sessions/
   ```

## Troubleshooting

### Symlinks not working
- Ensure you ran the install script from the project root
- Check that `.ai-dev-config/` exists

### Commands still prompting for approval
- Verify the symlink points to the correct location
- Check the tool-specific config syntax
- Restart the AI tool to reload configuration

### Session logs not created
- Ensure `.ai-sessions/` directory exists
- Check that hook scripts are executable: `chmod +x .ai-dev-config/shared/*.sh`

## Contributing

1. Fork this repository
2. Add new commands or tool configurations
3. Update documentation
4. Submit a pull request

## License

MIT License - See LICENSE file for details.
