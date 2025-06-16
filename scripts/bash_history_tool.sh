#!/bin/bash
####### HEADER #######
# bash_history_tool.sh
# Version: 0.1.0
# Description: Standalone tool to dump, clear, or archive bash history in Markdown format.
# Created: 2025-06-16
# Updated: 2025-06-16
# Author: David Mullins
# Status: development
####### /HEADER #######

# Usage: source bash_history_tool.sh {local|clear|archive|test|help}
# Note: Must be sourced to access parent shell's history (e.g., `source bash_history_tool.sh local`)

# Check if sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Error: This script must be sourced. Use: source $0 {local|clear|archive|test|help}"
  exit 1
fi

# Configuration
VERSION="0.1.0"
OUTPUT_DIR="${HOME}/.bash_history_tool"
BASHHIST="${OUTPUT_DIR}/bash_history.md"
HISTORY_FILE="${HISTFILE:-$HOME/.bash_history}"
LOG_FILE="${OUTPUT_DIR}/bash_history_tool.log"
DESCRIPTION="A standalone tool to manage bash history"
USER="${USER:-$(whoami)}"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Logging function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

############ FUNCTIONS ####################

dump_bash_history() {
  # Debug: Log environment
  log "HISTFILE: ${HISTFILE:-unset}"
  log "HISTORY_FILE: $HISTORY_FILE"
  log "Current directory: $(pwd)"
  log "Shell: $SHELL"
  log "HISTSIZE: ${HISTSIZE:-unset}"
  log "PROMPT_COMMAND: ${PROMPT_COMMAND:-unset}"

  # Ensure history file exists
  if [[ ! -f "$HISTORY_FILE" ]]; then
    log "Creating empty history file: $HISTORY_FILE"
    touch "$HISTORY_FILE"
  fi

  # Create temporary file for history
  local temp_history
  temp_history=$(mktemp)

  # Force history sync
  history -a # Append in-memory to HISTORY_FILE
  history -w # Write in-memory to HISTORY_FILE
  history -n # Read new lines from HISTORY_FILE
  history > "$temp_history" # Dump in-memory history

  # Fallback: Read HISTORY_FILE if in-memory history is empty
  if [[ ! -s "$temp_history" ]]; then
    log "Warning: In-memory history empty, reading $HISTORY_FILE"
    cat "$HISTORY_FILE" > "$temp_history"
  fi

  # Debug: Log history state
  log "Pre-dump HISTORY_FILE lines: $(wc -l < "$HISTORY_FILE")"
  log "In-memory history lines: $(wc -l < "$temp_history")"
  log "Sample history: $(head -n 2 "$temp_history" | sed 's/^/  /')"

  # Create Markdown file
  {
    echo "# Bash History Dump"
    echo
    echo "## Session"
    echo
    echo "| Item              | Value                                                        |"
    echo "| ----------------- | ------------------------------------------------------------ |"
    echo "| **Version:**      | ${VERSION}                                           |"
    echo "| **Output_Dir:**   | ${OUTPUT_DIR}                                        |"
    echo "| **Bash_Hist:**    | ${BASHHIST}                                          |"
    echo "| **Script_Desc:**  | ${DESCRIPTION}                                       |"
    echo "| **Date:**         | $(date)                                              |"
    echo "| **User:**         | ${USER}                                              |"
    echo ""
    echo "## History"
    echo ""
    echo '```bash'
    if [[ -s "$temp_history" ]]; then
      sed 's/^ *[0-9]* *//' "$temp_history" | while IFS= read -r line; do
        [[ -n "$line" ]] && echo " - $line"
      done
    else
      echo " - No commands in current session"
    fi
    echo '```'
  } > "$BASHHIST"

  # Clean up
  rm -f "$temp_history"

  log "Dumped bash history to $BASHHIST"
  echo "Bash history dumped to $BASHHIST"
}

archive_bash_history() {
  if [[ ! -f "$BASHHIST" ]]; then
    log "No bash history file to archive: $BASHHIST"
    echo "No bash history file to archive: $BASHHIST"
    return 1
  fi

  local archive_dir="${OUTPUT_DIR}/archive"
  local archive_file="${archive_dir}/bash_history_v${VERSION}_$(date +%Y%m%d_%H%M%S).md"
  mkdir -p "$archive_dir"
  cp "$BASHHIST" "$archive_file"
  if [[ $? -eq 0 ]]; then
    log "Archived $BASHHIST to $archive_file"
    echo "Bash history archived to $archive_file"
  else
    log "Failed to archive $BASHHIST"
    echo "Failed to archive bash history"
    return 1
  fi
}

clear_bash_history() {
  # Debug: Log pre-clear state
  log "Pre-clear HISTORY_FILE lines: $(wc -l < "$HISTORY_FILE")"
  log "Pre-clear in-memory history: $(history | wc -l) lines"

  # Clear in-memory history
  history -c
  # Clear the history file
  if [[ -f "$HISTORY_FILE" ]]; then
    : > "$HISTORY_FILE" # Truncate
    log "Cleared bash history (in-memory and $HISTORY_FILE)"
    echo "Bash history cleared (in-memory and $HISTORY_FILE)"
  else
    log "History file not found: $HISTORY_FILE"
    echo "History file not found: $HISTORY_FILE"
    touch "$HISTORY_FILE"
  fi
  # Force reload of cleared history
  history -r

  # Debug: Log post-clear state
  log "Post-clear HISTORY_FILE lines: $(wc -l < "$HISTORY_FILE")"
  log "Post-clear in-memory history: $(history | wc -l) lines"
}

test_bash_history() {
  log "Starting tests"
  # Test dump
  dump_bash_history
  if [[ -f "$BASHHIST" ]]; then
    log "Dump test: PASS"
    echo "Dump test: PASS"
  else
    log "Dump test: FAIL"
    echo "Dump test: FAIL"
    return 1
  fi
  # Test clear
  clear_bash_history
  if [[ ! -s "$HISTORY_FILE" ]] && [[ -z "$(history)" ]]; then
    log "Clear test: PASS"
    echo "Clear test: PASS"
  else
    log "Clear test: FAIL"
    echo "Clear test: FAIL"
    return 1
  fi
  echo "All tests passed"
}

show_help() {
  echo "Usage: source $0 {local|clear|archive|test|help}"
  echo "Commands:"
  echo "  local   : Dump current session's bash history to $BASHHIST"
  echo "  clear   : Clear in-memory and on-disk bash history"
  echo "  archive : Archive $BASHHIST to $OUTPUT_DIR/archive"
  echo "  test    : Run tests for dump and clear functions"
  echo "  help    : Show this help message"
  echo "Note: Must be sourced to access parent shell's history."
}

############ MAIN #########################

case "$1" in
  local)
    dump_bash_history
    ;;
  clear)
    clear_bash_history
    ;;
  archive)
    archive_bash_history
    ;;
  test)
    test_bash_history
    ;;
  help)
    show_help
    ;;
  *)
    show_help
    return 1
    ;;
esac

############ /MAIN ########################

####### FOOTER #####
# NOTES:
# - Standalone utility for any terminal session
# - Must be sourced to work correctly
# TODO:
# - Add project integration options
# - Support custom output formats
# - Implement version checking
# FIXME:
# - Ensure compatibility with non-Bash shells
####### /FOOTER #####