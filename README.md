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
