# PKDR Developer Note

Hey! I'm **Nishit Samar**, also known online as **AlloyDark**.

I'm a 17-year-old self-taught developer from **Bihar, India**. If you happen to browse through my GitHub, some of the projects may look a little difficult to believe for someone my age. That's completely fair—I hear that quite often. The truth is simply that I'm deeply curious and enjoy learning.

Programming is only one of my interests. I also spend time playing chess, drawing, creating animations, editing videos, graphic designing, writing, and exploring many other creative fields. I started programming at the age of **13**, and since then it has become one of the main ways I turn ideas into reality.

I don't enjoy building projects just for the sake of having repositories. I enjoy solving problems, designing systems, and understanding how software works internally. Most of my projects begin with a simple question: *"Can this be built in a better way?"* That curiosity is what eventually led me to PKDR.

## About PKDR

Interestingly, PKDR was never planned.

It started as a small utility to solve a personal problem while working inside Termux. I wanted isolated development environments without installing the same packages repeatedly or cluttering my primary setup. What began as a few shell scripts slowly evolved into something much larger.

Instead of becoming another wrapper around `pkg`, PKDR gradually became an environment manager built around portable manifests. Environments can be created, shared, exported, imported, rebuilt, and managed independently while remaining lightweight.

Many parts of the project were redesigned multiple times before this first stable release. The architecture you're seeing today is the result of continuous experimentation, learning, and refinement rather than a fixed plan from the beginning.

Version **1.0.1** represents the first stable foundation. The goal from here is not to continuously add features, but to improve reliability, portability, and maintainability while keeping the project simple to understand.
> Sorry for v1.0.0, I pushed in hurry, didn't verified the installer.sh but quickly realised and fixed in this patch update, so v1.0.1 is new and infact first stable version.

## Contributing

Contributions are always welcome.

Before opening a pull request, please try to keep changes consistent with the existing architecture. Prefer improving existing modules over introducing duplicate logic, keep functions modular and reusable whenever possible, and always update docs as well.

If you discover a bug, open an issue with clear reproduction steps. If you're proposing a new feature, please explain the problem it solves and how it fits within PKDR's overall philosophy.

## Roadmap

### v1.0.X

Focus: Stability and portability.

* Improve cross-platform compatibility beyond the current Termux-first implementation.
* Refine and optimize the import/export pipeline.
* Introduce package manager abstraction to reduce direct dependency on `pkg`.
* Continue internal module cleanup and code simplification.
* Improve logging consistency and error handling.
* Strengthen validation and fallback behavior across commands.
* General bug fixes and performance improvements.

### v1.X.0

Focus: Better developer experience.

* Manual installation workflow define configs once, and it will remember in the same json file of env, inside init, to init the configs also.
* Environment templates.
* Improved runtime management.
* More flexible manifest handling.
* Better command-line experience and usability improvements.
* Additional quality-of-life features based on community feedback.

### Long-Term Vision

PKDR is intended to become more than a Termux utility.

Future goals include:

* Cross-platform package manager support.
* Portable environment registries.
* Plugin and extension architecture.
* Remote environment sharing.
* Environment synchronization.
* Better reproducibility across devices.
* Cleaner internal architecture with long-term maintainability.

## Final Note

Thank you for taking the time to explore PKDR.

Whether you're reporting a bug, suggesting an improvement, contributing code, or simply using the project, I genuinely appreciate your interest. Every release is another step in my journey as a developer, and I hope PKDR continues to grow into a tool that is useful for others as well.

In future I will love people creating other releases such as Linux-v1.0.

> Well I know there can be several bugs, fast code, optimization issues, cause it was fast built to manage my on going project. Feel free to find and improve Always.

— **Nishit Samar (AlloyDark)**
