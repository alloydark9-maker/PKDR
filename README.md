# PKDR

> **Package Keeper Directory Runtime**

A lightweight, open-source utility for **Termux** that preserves and reconstructs your development environment.

Instead of remembering every package, command, and setup step whenever you switch devices or reinstall Termux, PKDR remembers your environment for you.

> **Save your setup once. Rebuild it anywhere.**

---

# Why PKDR?

Developers often spend unnecessary time recreating their development environment.

Typical problems include:

- Forgetting installed packages
- Forgetting setup commands
- Repeating the same installation process on every new device
- Losing environment state after clearing Termux

PKDR solves this by storing the **state of your development environment**, allowing it to be reconstructed whenever needed.

It does **not** transfer installed binaries or application data.

Instead, it stores the knowledge required to rebuild your environment.

---

# Features

- Multiple development environments
- One-command environment installation
- Add packages to environments
- View environment contents
- Export & Import environments
- Export & Import complete PKDR state
- Interactive environment shell (`pkdr enter`)
- Controlled command visibility inside environments
- Duplicate package prevention
- Lightweight and open source

---

# Installation

> **Do not try change any command for correct installation**
> **Do not dowload v1.0.0, as per that is broken**
=======
> **Do not try change any command for correct installation, Do not download v1.0.0, as per that is broken**

Clone the repository:

```bash
git clone https://github.com/alloydark9-maker/PKDR
cd PKDR
```

Run the installer:

```bash
bash installer.sh
```

Verify installation:

```bash
pkdr
```

---

# Project Philosophy

PKDR is **not** a package manager, container, or a virtualization.

PKDR is a **development environment reconstruction utility**.

Rather than storing installed binaries, PKDR stores the information required to recreate your development environment anywhere.

Think of it as a portable memory for your development setup.

---

# Roadmap

## v1.x.x

- Stable CLI
- Environment management
- Export / Import
- Interactive environments
- Multiple installation strategies
- Custom installation commands
- Improved manifest format
- Better environment validation

## Future

- Plugin system
- Environment templates
- Git synchronization
- Automatic updates
- Community environment registry

---

# VERSION

Check VERSION for the correct current version.

```
    v[Architectural].[Major].[Minor]
```

## Component Definitions

### 1. Architectural (vX.0.0)
Incremented for foundational ecosystem changes or multi-language expansions.
* **Example:** Transitioning a pure Bash codebase to a hybrid JavaScript/Python architecture.
* **Example:** Porting the core system from a monolith to microservices.

### 2. Major (v0.X.0)
Incremented for significant internal logic or algorithm overhauls within the existing tech stack, without changing the base tools.
* **Example:** Rewriting the core routing engine or replacing a legacy search algorithm with a high-performance alternative.
* **Example:** Introducing efficient data exchanges.

### 3. Minor (v0.0.X)
Incremented for ongoing maintenance, code optimization, and structural refinement.
* **Example:** Code modulation, refactoring clunky files, fixing bugs, or performance tuning.

---

# Contributing

Contributions are welcome.

Whether it's fixing bugs, improving documentation, suggesting new features, or submitting pull requests, every contribution helps improve PKDR.

For major architectural changes, please open an issue first to discuss the proposal.

---

# License

MIT License

---

# Author

**Nishit Samar** aka **AlloyDark**

Built to solve a real development workflow problem.

If PKDR saves someone from rebuilding their setup manually, then it has achieved its purpose.
