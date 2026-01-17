#!/usr/bin/env bash
# AI Dev Config Installation Script
# Installs and configures AI development tools for a project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default options
NO_BACKUP=false
SPECIFIC_TOOL=""

# Print colored output
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Print usage
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Install AI development tool configurations for a project.

Options:
  --no-backup       Skip backing up existing configurations
  --tool=<name>     Install only specific tool (claude-code|opencode|codex|gemini-cli)
  -h, --help        Show this help message

Examples:
  $(basename "$0")                     # Install all tools
  $(basename "$0") --tool=claude-code  # Install only Claude Code

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-backup)
                NO_BACKUP=true
                shift
                ;;
            --tool=*)
                SPECIFIC_TOOL="${1#*=}"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Find project root (directory containing .git)
find_project_root() {
    local dir="$SCRIPT_DIR"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    # If no .git found, use parent of script directory
    echo "$(dirname "$SCRIPT_DIR")"
}

# Backup existing file or directory
backup_if_exists() {
    local path="$1"
    if [[ -e "$path" && "$NO_BACKUP" == "false" ]]; then
        local backup_path="${path}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $path to $backup_path"
        mv "$path" "$backup_path"
    elif [[ -e "$path" ]]; then
        print_warning "Removing existing $path (--no-backup specified)"
        rm -rf "$path"
    fi
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ -L "$target" ]]; then
        # Already a symlink, remove it
        rm "$target"
    elif [[ -e "$target" ]]; then
        backup_if_exists "$target"
    fi

    ln -s "$source" "$target"
    print_success "Created symlink: $target -> $source"
}

# Install Claude Code configuration
install_claude_code() {
    local project_root="$1"
    local config_dir="$SCRIPT_DIR/claude-code"
    local target_dir="$project_root/.claude"

    print_info "Installing Claude Code configuration..."

    # Create symlink for .claude directory
    create_symlink ".ai-dev-config/claude-code" "$target_dir"

    # Make hook scripts executable
    chmod +x "$config_dir/hooks/"*.sh 2>/dev/null || true

    print_success "Claude Code configuration installed"
}

# Install Gemini CLI configuration
install_gemini_cli() {
    local project_root="$1"
    local config_dir="$SCRIPT_DIR/gemini-cli"
    local target_dir="$project_root/.gemini"

    print_info "Installing Gemini CLI configuration..."

    # Create symlink for .gemini directory
    create_symlink ".ai-dev-config/gemini-cli" "$target_dir"

    # Make hook scripts executable
    chmod +x "$config_dir/hooks/"*.sh 2>/dev/null || true

    print_success "Gemini CLI configuration installed"
}

# Install OpenCode configuration
install_opencode() {
    local project_root="$1"
    local config_file="$SCRIPT_DIR/opencode/opencode.json"
    local target_file="$project_root/opencode.json"

    print_info "Installing OpenCode configuration..."

    # Create symlink for opencode.json
    create_symlink ".ai-dev-config/opencode/opencode.json" "$target_file"

    print_success "OpenCode configuration installed"
}

# Install Codex configuration
install_codex() {
    local project_root="$1"
    local config_file="$SCRIPT_DIR/codex/config.toml"
    local codex_dir="$HOME/.codex"
    local target_file="$codex_dir/config.toml"

    print_info "Installing Codex configuration..."

    # Create ~/.codex directory if it doesn't exist
    mkdir -p "$codex_dir"

    # For Codex, we need to merge with existing config or create new
    if [[ -f "$target_file" ]]; then
        print_warning "Existing Codex config found at $target_file"
        print_warning "Merging configurations..."

        # Create backup
        if [[ "$NO_BACKUP" == "false" ]]; then
            cp "$target_file" "${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
        fi

        # Append our config (basic merge - in production you'd want proper TOML merging)
        echo -e "\n# Merged from ai-dev-config ($(date))" >> "$target_file"
        cat "$config_file" >> "$target_file"
        print_success "Merged Codex configuration"
    else
        cp "$config_file" "$target_file"
        print_success "Created Codex configuration at $target_file"
    fi

    # Also create a local reference file
    local local_ref="$project_root/.codex-config-ref"
    echo "# Codex configuration is stored at: $target_file" > "$local_ref"
    echo "# This file is a reference marker for the ai-dev-config installation" >> "$local_ref"
    print_info "Created local Codex reference at $local_ref"
}

# Print installation summary
print_summary() {
    local project_root="$1"

    echo ""
    echo "=============================================="
    echo -e "${GREEN}AI Dev Config Installation Complete${NC}"
    echo "=============================================="
    echo ""
    echo "Project root: $project_root"
    echo ""
    echo "Installed configurations:"

    if [[ -z "$SPECIFIC_TOOL" || "$SPECIFIC_TOOL" == "claude-code" ]]; then
        [[ -L "$project_root/.claude" ]] && echo "  ✓ Claude Code (.claude/)"
    fi
    if [[ -z "$SPECIFIC_TOOL" || "$SPECIFIC_TOOL" == "gemini-cli" ]]; then
        [[ -L "$project_root/.gemini" ]] && echo "  ✓ Gemini CLI (.gemini/)"
    fi
    if [[ -z "$SPECIFIC_TOOL" || "$SPECIFIC_TOOL" == "opencode" ]]; then
        [[ -L "$project_root/opencode.json" ]] && echo "  ✓ OpenCode (opencode.json)"
    fi
    if [[ -z "$SPECIFIC_TOOL" || "$SPECIFIC_TOOL" == "codex" ]]; then
        [[ -f "$HOME/.codex/config.toml" ]] && echo "  ✓ Codex (~/.codex/config.toml)"
    fi

    echo ""
    echo "To uninstall, run: ./.ai-dev-config/uninstall.sh"
    echo ""
}

# Main installation function
main() {
    parse_args "$@"

    print_info "AI Dev Config Installation"
    echo ""

    # Find project root
    local project_root
    project_root="$(find_project_root)"
    print_info "Project root: $project_root"

    # Verify we're in the right place
    if [[ ! -d "$SCRIPT_DIR/claude-code" ]]; then
        print_error "Cannot find ai-dev-config structure. Are you running from the correct location?"
        exit 1
    fi

    # Install tool configurations
    if [[ -z "$SPECIFIC_TOOL" ]]; then
        # Install all tools
        install_claude_code "$project_root"
        install_gemini_cli "$project_root"
        install_opencode "$project_root"
        install_codex "$project_root"
    else
        # Install specific tool
        case "$SPECIFIC_TOOL" in
            claude-code)
                install_claude_code "$project_root"
                ;;
            gemini-cli)
                install_gemini_cli "$project_root"
                ;;
            opencode)
                install_opencode "$project_root"
                ;;
            codex)
                install_codex "$project_root"
                ;;
            *)
                print_error "Unknown tool: $SPECIFIC_TOOL"
                print_error "Valid options: claude-code, opencode, codex, gemini-cli"
                exit 1
                ;;
        esac
    fi

    # Print summary
    print_summary "$project_root"
}

main "$@"
