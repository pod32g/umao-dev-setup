# umao-dev-setup

Development environment setup wizard for [UmaOS](https://github.com/pod32g/umaos). Lets you pick and install dev tool stacks from a tabbed GUI with a single authentication prompt.

![Qt6/QML](https://img.shields.io/badge/Qt6-QML-green) ![Python](https://img.shields.io/badge/Python-3.10+-blue) ![Arch](https://img.shields.io/badge/Arch_Linux-pacman-1793d1)

## Stacks

Organized into five tabs:

| Tab | Stacks |
|-----|--------|
| **Languages** | Web Dev (Node/TS), Python, Rust, Go, Java, C/C++ |
| **Editors** | VS Code, Neovim, Helix, Emacs |
| **AI** | Ollama, Claude Code, Aider, OpenAI Codex, Gemini CLI, OpenCode, Cursor |
| **DevOps** | Docker & Compose, Kubernetes, Terraform, Ansible |
| **Data** | PostgreSQL, Redis, SQLite, MongoDB |

Already-installed stacks are marked with a green checkmark and skipped during installation.

## How it works

1. Select stacks across any combination of tabs
2. Click **Install** — a single `pkexec` prompt handles all `pacman` packages
3. Post-install hooks run automatically (e.g. `rustup default stable`, `npm install -g @anthropic-ai/claude-code`, `systemctl enable docker`)
4. Done screen shows a summary of what was installed

## Architecture

- **Python backend** (`umao-dev-setup`) — PyQt6 QObject exposing stack data and install signals to QML; `QThread` worker for async pacman installation via `pkexec`
- **QML frontend** (`qml/`) — SelectionScreen (tabbed checklist), InstallingScreen (progress), CompleteScreen (summary), Theme singleton (UmaOS design tokens)
- **Fallback chain** — PyQt6 QML GUI → kdialog → text mode, depending on available display server and packages

## Building

```bash
# From the repo root
makepkg -si
```

Or install as part of UmaOS via the `custom-pkgs/umao-dev-setup/PKGBUILD` in the main [umaos](https://github.com/pod32g/umaos) repo.

## Dependencies

- `python` (3.10+)
- `python-pyqt6`
- `qt6-declarative`
- Optional: `kdialog` (fallback GUI)

## License

MIT
