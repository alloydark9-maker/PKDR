# Contributing to PKDR

Thank you for your interest in contributing to PKDR.

PKDR (Package Keeper Directory Runtime) is an open-source utility focused on reconstructing portable development environments for Termux. Every contribution—whether code, documentation, testing, or ideas—helps improve the project.

---

# Before Contributing

Please make sure you have:

* Read the README.
* Tested your changes locally.
* Verified that existing functionality is not broken.
* Followed the project's coding style.

---

# Ways to Contribute

You can contribute by:

* Fixing bugs.
* Improving documentation.
* Refactoring existing code.
* Adding new features that align with PKDR's purpose.
* Improving installer stability.
* Optimizing performance.
* Reporting issues.

---

# Project Philosophy

PKDR exists to solve one problem:

> Reconstruct a development environment without requiring users to remember every installation step.

Please keep new ideas aligned with this goal.

Features that increase complexity without supporting this objective may not be accepted.

---

# Development Guidelines

When contributing:

* Keep functions modular.
* Prefer readable Bash over clever Bash.
* Reuse existing helper functions whenever possible.
* Avoid unnecessary dependencies.
* Preserve backward compatibility whenever practical.

---

# Commit Messages

Examples:

```
feat: add manual installer support

fix: prevent duplicate package entries

docs: improve installation guide

refactor: split export functions into transfer.sh
```

---

# Pull Requests

Before opening a Pull Request:

* Ensure the project runs correctly.
* Update documentation if necessary.
* Update CHANGELOG.md when introducing user-visible changes.
* Keep Pull Requests focused on a single feature or fix.

---

# Reporting Issues

When reporting a bug, include:

* Termux version
* Android version
* PKDR version
* Command executed
* Expected behavior
* Actual behavior
* Error output (if available)

---

# Code Style

PKDR follows a simple philosophy:

* Small functions
* Clear names
* Minimal dependencies
* Consistent output formatting
* Human-readable code

Readable code is preferred over complex one-liners.

---

# Community

Please be respectful during discussions and code reviews.

Constructive feedback is encouraged.

The goal is to build a useful utility together.

---

Thank you for helping improve PKDR.

Built and maintained by Nishit Samar (AlloyDark).
