# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Urbit test ship repository containing a fake zod (galaxy) ship for local development and testing. Urbit is a peer-to-peer network operating system built on a deterministic virtual machine (Nock).

## Key Commands

### Running the Test Ship

```bash
# Start the zod test ship
./urbit zod

# Start with fake networking (no network connections)
./urbit -F zod

# Start in daemon mode (background)
./urbit -d zod

# Start with verbose output for debugging
./urbit -v zod

# Start with specific Ames port
./urbit -p 8080 zod
```

### Development Commands

Inside the Dojo (Urbit's command-line interface):
- `|commit %base` - Commit changes to the base desk
- `|mount %base` - Mount the base desk to filesystem for editing
- `+ls %` - List files in current directory
- `|mass` - Memory profiling
- `|pack` - Garbage collection
- `.^(@t %cx /===/gen/hello/hoon)` - Scry (read) file contents

## Architecture

### Core Structure

- **`urbit`**: The Urbit runtime binary (Vere)
- **`zod/`**: The test ship pier directory
  - **`base/`**: The main desk containing system files
    - **`app/`**: Gall applications (userspace programs)
    - **`gen/`**: Generators (command-line scripts)
    - **`lib/`**: Libraries
    - **`mar/`**: Marks (data type definitions)
    - **`sur/`**: Structures (shared type definitions)
    - **`sys/`**: System files (Arvo kernel and vanes)
    - **`ted/`**: Threads (asynchronous computations)
  - **`.urb/`**: Runtime data directory
    - **`chk/`**: Checkpoints
    - **`log/`**: Event log
    - **`put/`**: Output files

### Key System Components

**Vanes** (kernel modules in `sys/vane/`):
- `ames.hoon`: Networking and peer-to-peer communication
- `behn.hoon`: Timer management
- `clay.hoon`: Filesystem and version control
- `dill.hoon`: Terminal driver
- `eyre.hoon`: HTTP server
- `gall.hoon`: Application management
- `iris.hoon`: HTTP client
- `jael.hoon`: Public key infrastructure

**Core Applications** (in `app/`):
- `dojo.hoon`: Interactive command-line interface
- `hood.hoon`: System management suite
- `spider.hoon`: Thread runner for async operations
- `azimuth.hoon`: Ethereum-based PKI integration

### Development Workflow

1. Mount desk to filesystem: `|mount %base`
2. Edit files in `zod/base/`
3. Commit changes: `|commit %base`
4. Test changes in Dojo or through web interface

### File Types

- `.hoon`: Hoon source code files
- `.bill`: Desk manifest files listing installed apps
- `.kelvin`: Version compatibility files

## Testing

Run tests using the test framework:
```
> -test /=base=/tests
```

Run specific generator tests:
```
> +hello
```

## Library Sync

The repository includes automatic bidirectional syncing between `/lib` and `zod/base/lib`:

### Starting the Sync
```bash
# Start automatic sync (runs in foreground)
./start-sync.sh

# Or run directly with Python
python3 sync-lib.py
```

### How It Works
- Any changes in `/lib` are automatically synced to `zod/base/lib`
- Any changes in `zod/base/lib` are automatically synced to `/lib`
- Initial sync ensures both directories are aligned before monitoring starts
- Handles file creation, modification, deletion, and moves
- Prevents sync loops with intelligent caching

### Requirements
- Python 3 with `watchdog` library (`pip3 install watchdog`)
- The sync script will auto-install watchdog if missing

## Important Notes

- This is a fake zod ship (galaxy ~zod) for local development only
- Changes to system files in `sys/` require careful consideration as they affect the kernel
- The ship maintains an event log in `.urb/log/` - corrupting this can break the ship
- Use `|pack` periodically to perform garbage collection
- The `.urb/chk/` directory contains snapshots for faster restart
- Library files can be edited in either `/lib` or `zod/base/lib` when sync is running