# Bash History Utility 

## Overview

The Bash History Utility (`bash_history.sh` or proposed `bash_history_tool.sh`) is intended to automate the management of Bash command history in terminal sessions. Its primary functions are to:

- **Dump**: Capture the current session’s command history and save it as a Markdown file (`bash_history.md`).
- **Clear**: Clear both in-memory and on-disk (`~/.bash_history`) command history.
- **Archive**: Save the dumped history file with versioned timestamps.
- **Test**: Validate the dump and clear operations.

The utility is designed to be reusable across projects or as a standalone tool, supporting development workflows by preserving command history for documentation, debugging, or reuse. It was initially developed as part of the "HELPME" project (`script_bin_tools_dev`) but has been proposed as a separate project due to persistent issues.

## Current Status

- **Version**: 0.0.9  (proposed for standalone `bash_history_tool.sh`).

   [scripts/bash_history_tool.sh](https://github.com/DavitTec/bash_history_utility/blob/master/scripts/bash_history_tool.sh) 

## Installation

```bash
./INSTALL.sh install
```

## Usag

```bash

```

## Development

- Requirements: bash, pnpm, jq
- Deployment: [ to be inserted ]  or /opt/davit/bin  

## VSCode Setup

1. Open the project in VSCode
2. Install recommended extensions:
   - ShellCheck
   - Bash IDE
   - Markdown All in One
3. Configure tasks.json for running tests and the main script

## Current Version

VERSION: 0.0.9
