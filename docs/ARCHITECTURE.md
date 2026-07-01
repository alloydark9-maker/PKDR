# PKDR Architecture

This document describes the internal architecture of PKDR and the reasoning behind its design.

PKDR is **not** a package manager, container runtime, virtual machine, or filesystem isolation tool. 
It is a development environment reconstruction utility whose primary objective is to preserve and rebuild a developer's setup with minimal manual effort.

---

# Design Philosophy

Traditional solutions focus on isolating an entire operating system or userspace.

PKDR instead focuses on preserving a developer's **working state**.

Rather than saving binaries or transferring an existing environment, PKDR stores the blueprint required to rebuild it.

This keeps exports lightweight while allowing the setup to be recreated on any compatible device.

---

# Core Principle

PKDR preserves **state**, not data.

The utility remembers:

- Installed development packages
- Environment layouts
- Runtime configuration
- Installation methods
- Environment history

When an environment is restored, PKDR reconstructs it using the stored blueprint.

---

# Architecture Overview

```
                     User
                       │
                       ▼
            PKDR Runtime Layer
      (Internal dependencies & runtime)

                       │
                       ▼
          User Environment Layer
     (Git, Python, Node, Curl, etc.)

                       │
                       ▼
             Current Project Files
```

Each layer has a single responsibility.

---

# Runtime Layer

Location:

```
~/PKDR/runtime/
```

The runtime contains everything required for PKDR itself to operate.

It includes:

```
runtime/
├── dependencies/
├── env/
├── history.log
└── events.log
```

The runtime is created during installation.

Unlike user environments, runtime dependencies are shared globally and are not duplicated for every environment.

---

# Runtime Dependencies

```
runtime/dependencies/
```

This directory stores symbolic links to commands required internally by PKDR.

Examples include:

- bash
- pkdr
- cat
- sed
- grep
- tr
- awk
- cut
- jq
- tar
- basename
- dirname
- cp
- mv
- rm
- mkdir
- printf

These are runtime requirements rather than user-installed packages.

When entering an environment, PKDR appends this directory to PATH so that internal operations continue functioning without exposing the host system's command lookup.

---

# Environment Layer

Location:

```
runtime/env/
```

Each environment receives its own isolated command directory.

Example:

```
runtime/
└── env/
    └── dev/
        └── bin/
            git
            wget
            python
            node
```

These are symbolic links generated from the environment manifest.

Only commands declared by the environment become available.

---

# Command Resolution

When entering an environment, PATH is rebuilt as:

```
Environment Commands
        ↓
Runtime Dependencies
```

This provides:

- User tools first
- PKDR runtime second
- Host command lookup disabled

As a result, commands outside the environment remain inaccessible unless they belong to the runtime.

---

# Environment Isolation

PKDR does not isolate processes, filesystems, or kernels.

Instead, it isolates **command availability**.

This allows developers to work inside controlled environments while continuing to use the same filesystem and shell.

The approach keeps PKDR lightweight while solving the actual problem of reproducible development setups.

---

# Environment Manifests

Location:

```
~/PKDR/manifests/
```

Each environment is represented as a JSON manifest.

Example:

```json
{
    "name": "dev",
    "packages": [
        "git",
        "nodejs",
        "python"
    ]
}
```

The manifest acts as the source of truth for reconstructing an environment.

---

# Runtime Logs

PKDR separates runtime logging into two categories.

## events.log

Stores operational events affecting PKDR itself.

Examples:

- Installation
- Updates
- Uninstallation
- Runtime initialization

---

## history.log

Stores user activity and environment operations.

Examples:

- Environment creation
- Package additions
- Package removal
- Environment initialization
- Environment entry
- Environment exit
- Import and export operations

---

# Import & Export

PKDR supports reconstruction at two levels.

### Environment Export

Exports a single environment including:

- Manifest
- Metadata

```
      pkdr export dev ~/Downloads
              │
              ▼
      manifests/dev.json
              │
              ▼
      temp/
      ├── pkdr.json # Metadata
      └── manifests/
          └── dev.json
              │
              ▼
      dev.tar.gz
```

---

### Full Export

Exports the complete PKDR workspace including:

- All manifests
- Metadata

```
      pkdr export dev ~/Downloads
              │
              ▼
      manifests/dev.json
              │
              ▼
      temp/
      ├── pkdr.json # Metadata
      └── manifests/
          └── dev.json
              │
              ▼
      dev.tar.gz
```

This allows an entire PKDR environment installation to be reconstructed on another compatible device.

---

### Import

Import has very simpler and manageable workflow

```
      pkdr import ~/Downloads/dev.tar.gz
              │
              ▼
      Extract to temp
              │
              ▼
      Read pkdr.json
              │
              ▼
      Find manifests/
              │
              ▼
      Loop through every manifest
              │
              ▼
      Merge / Replace / Skip
```

---

# Installation Methods

PKDR supports multiple installation strategies.

Packages installed through the native package manager are tracked normally.

Packages installed manually can store their installation commands, allowing PKDR to reproduce custom installation workflows during reconstruction.

This extends PKDR beyond a single package source while preserving user-defined installation behavior.

---

# Design Goals

- Lightweight
- Portable
- Human-readable
- Reproducible
- Open Source
- Extensible
- Runtime-driven
- Environment-focused

---

# Future Scalability

The architecture is intentionally modular.

By separating:

- Runtime
- Environment
- Manifest
- Logging
- Transfer
- Installation methods

new capabilities can be introduced without redesigning the core architecture.

This allows PKDR to evolve while preserving backward compatibility and maintaining a clear separation of responsibilities.