#!/usr/bin/env bash
# Gemini CLI session logging hook
# Called by AfterAgent hook to log session summaries

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/session-logger.sh"

log_session "gemini-cli" "$@"
