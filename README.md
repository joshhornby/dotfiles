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

### Claude Code

Personal Claude Code config lives under `.claude/` and is symlinked into `~/.claude`
by stow. Team skills come from the separate `journey-engineering` plugin.

`.claude/CLAUDE.md` holds the global working rules that apply to every session — no
`any`, object params for functions with 2+ arguments, no gratuitous comments, British
spelling, pinned dependency versions, no-attribution commits, and behaviour-over-mocks
testing. Project-specific conventions belong in that project's own `CLAUDE.md`, not here.

`.claude/hooks/check-house-rules.py` is a warn-only PostToolUse hook that flags `any`
in code and American spellings in prose after each edit. It never blocks — see the header
comment for how to make it blocking once trusted.

#### Commands

Type `/<name>` to run one.

| Command | When to use |
|---------|-------------|
| `/commit-and-push` | Commit all changes with an auto-generated conventional message, then push |
| `/ship-and-watch` | Commit, push, open a PR, then watch CI and review comments — never auto-merges |
| `/resolve-pr-comments` | Pull PR and Copilot review comments, triage them, apply the chosen fixes as a fresh commit, then resolve the threads |
| `/save-progress` | Snapshot the current session's context so it isn't lost |
| `/recap` | Restore context from a previously saved progress snapshot |
| `/compound` | Roll session learnings into persistent, reusable knowledge |

#### Skills

Claude loads these automatically when a task matches; invoke one directly with `/<name>`.

| Skill | When to use |
|-------|-------------|
| `blueprint` | Build a feature from scratch with a spec and verification gates |
| `harness` | Add scaffolding (CLAUDE.md, docs, invariants) to make a repo AI-ready |
| `to-prd` | Turn the current conversation into a PRD on the issue tracker |
| `to-issues` | Break a plan or PRD into independently-grabbable issues |
| `grill-me` | Stress-test a plan or design by being interviewed until it holds up |
| `prototype` | Throw together a quick prototype to sanity-check a design before committing |
| `impossible-states` | Model data so invalid states can't be constructed (discriminated unions) |
| `typescript-strict` | Write or review TypeScript with strict-mode, schema-first patterns |
| `technical-writing` | Write developer-facing docs — READMEs, guides, proposals, PR descriptions |
| `josh-writing-voice` | Apply my personal voice to prose I publish, then run the humanizer pass |
| `humanizer` | Strip AI tells from any text to make it read as human-written |
| `diagrams` | Create diagrams and visualisations (Mermaid, Graphviz, and more) |
| `expectations` | Capture learnings, gotchas, and decisions into the right docs while fresh |
| `claude-doctor` | Analyse recent learnings and open a PR to improve this Claude setup |

[stow]: https://www.gnu.org/software/stow/
