## Josh's Dotfiles

### Quick Start

```sh
git clone https://github.com/joshhornby/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/init
```

This installs Homebrew and dependencies, then symlinks everything via [stow][].

### Manual Setup

If you prefer to set things up manually:

```sh
brew install stow gh
cd ~/dotfiles
make reload
```

### Parallel Agent Workflow (Worktrunk)

Uses [Worktrunk](https://worktrunk.dev/) for git worktree management with parallel Claude Code agents.

```sh
# Install Worktrunk
brew install max-sixty/worktrunk/wt && wt config shell install

# Quick start - create worktree and launch Claude
wtcc feature-name    # alias for: wt switch -c -x claude

# Other commands
wtl                  # List worktrees with status/CI/PR links
wtm                  # Squash, merge, and cleanup
wtr                  # Remove current worktree
```

#### Laravel Sail Projects

For Laravel projects using Sail, run `wt-sail-setup` in your project root. This creates a `.config/wt.toml` that:

- Assigns unique `APP_PORT` per worktree (via `hash_port`)
- Assigns unique `FORWARD_DB_PORT` and `FORWARD_REDIS_PORT`
- Auto-runs `sail up -d` when creating/switching worktrees

Each worktree gets its own Sail containers on unique ports - no conflicts.

### Scripts

| Command | Description |
|---------|-------------|
| `wt-sail-setup` | Configure Laravel project for Worktrunk + Sail |

[stow]: https://www.gnu.org/software/stow/
