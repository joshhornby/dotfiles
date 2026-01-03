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

### Scripts

| Command | Description |
|---------|-------------|
| `agent setup` | Create git worktrees and iTerm tabs for parallel Claude Code instances |
| `agent status` | Show progress of each agent |
| `agent cleanup` | Remove worktrees and branches |

[stow]: https://www.gnu.org/software/stow/
