#!/usr/bin/env bash
# AI Dev Config Uninstallation Script
# Removes AI development tool configurations from a project

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
REMOVE_CODEX=false

# Print colored output
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Print usage
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Uninstall AI development tool configurations from a project.

Options:
  --remove-codex      Also remove Codex config from ~/.codex/
  -h, --help          Show this help message

Examples:
  $(basename "$0")                      # Remove symlinks only
  $(basename "$0") --remove-codex       # Also remove global Codex config

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --remove-codex)
                REMOVE_CODEX=true
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

# Remove symlink if it points to our config
remove_symlink() {
    local path="$1"
    local expected_target="$2"

    if [[ -L "$path" ]]; then
        local actual_target
        actual_target="$(readlink "$path")"
        if [[ "$actual_target" == *"$expected_target"* || "$actual_target" == "$expected_target" ]]; then
            rm "$path"
            print_success "Removed symlink: $path"
        else
            print_warning "Symlink $path points to $actual_target, not our config. Skipping."
        fi
    elif [[ -e "$path" ]]; then
        print_warning "$path exists but is not a symlink. Skipping."
    else
        print_info "$path does not exist. Nothing to remove."
    fi
}

# Uninstall Claude Code configuration
uninstall_claude_code() {
    local project_root="$1"
    print_info "Uninstalling Claude Code configuration..."
    remove_symlink "$project_root/.claude" ".ai-dev-config/claude-code"
}

# Uninstall Gemini CLI configuration
uninstall_gemini_cli() {
    local project_root="$1"
    print_info "Uninstalling Gemini CLI configuration..."
    remove_symlink "$project_root/.gemini" ".ai-dev-config/gemini-cli"
}

# Uninstall OpenCode configuration
uninstall_opencode() {
    local project_root="$1"
    print_info "Uninstalling OpenCode configuration..."
    remove_symlink "$project_root/opencode.json" ".ai-dev-config/opencode/opencode.json"
}

# Uninstall Codex configuration
uninstall_codex() {
    local project_root="$1"

    print_info "Uninstalling Codex configuration..."

    # Remove local reference file
    local local_ref="$project_root/.codex-config-ref"
    if [[ -f "$local_ref" ]]; then
        rm "$local_ref"
        print_success "Removed local Codex reference"
    fi

    # Optionally remove global config
    if [[ "$REMOVE_CODEX" == "true" ]]; then
        local codex_config="$HOME/.codex/config.toml"
        if [[ -f "$codex_config" ]]; then
            print_warning "Removing global Codex config: $codex_config"
            rm "$codex_config"
            print_success "Removed global Codex configuration"
        fi
    else
        print_info "Global Codex config at ~/.codex/config.toml was not removed."
        print_info "Use --remove-codex to remove it."
    fi
}

# Print uninstallation summary
print_summary() {
    local project_root="$1"

    echo ""
    echo "=============================================="
    echo -e "${GREEN}AI Dev Config Uninstallation Complete${NC}"
    echo "=============================================="
    echo ""
    echo "Project root: $project_root"
    echo ""
    echo "Removed configurations:"
    echo "  ✓ Claude Code symlink"
    echo "  ✓ Gemini CLI symlink"
    echo "  ✓ OpenCode symlink"
    echo "  ✓ Codex local reference"

    if [[ "$REMOVE_CODEX" == "true" ]]; then
        echo "  ✓ Codex global config"
    fi

    if [[ "$REMOVE_SESSIONS" == "true" ]]; then
        echo "  ✓ Session logs"
    fi

    echo ""
    echo "The .ai-dev-config/ directory itself was not removed."
    echo "To fully remove, delete the directory or remove the submodule:"
    echo "  git submodule deinit .ai-dev-config"
    echo "  git rm .ai-dev-config"
    echo ""
}

# Main uninstallation function
main() {
    parse_args "$@"

    print_info "AI Dev Config Uninstallation"
    echo ""

    # Find project root
    local project_root
    project_root="$(find_project_root)"
    print_info "Project root: $project_root"

    # Uninstall all tool configurations
    uninstall_claude_code "$project_root"
    uninstall_gemini_cli "$project_root"
    uninstall_opencode "$project_root"
    uninstall_codex "$project_root"

    # Handle session directory
    remove_sessions "$project_root"

    # Clean up gitignore if sessions were removed
    if [[ "$REMOVE_SESSIONS" == "true" ]]; then
        cleanup_gitignore "$project_root"
    fi

    # Print summary
    print_summary "$project_root"
}

main "$@"
