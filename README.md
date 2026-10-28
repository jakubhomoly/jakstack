# jakstack

fork of [tstack](https://github.com/t3dotgg/tstack) adjusted for my needs. feel free to fork, contribute or just use the skills.

## Skills

| Skill | Say | What it does |
|---|---|---|
| `full-send` | "full send" | Takes a change to a merged PR with nobody watching: proves it, reviews it, files it, babysits it, merges it. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the PR is ready for you to merge. |
| `sol-loop` | "sol loop" | Reviews a change with GPT Sol in a loop until both agents agree. |
| `takeover` | "take over" | Finishes someone else's PR, branch, or agent thread, and keeps their credit. |
| `babysit-pr` | "babysit" | Watches a PR through CI and review bots, and fixes the real findings. |
| `modernize` | "modernize" | Rebases an old PR and decides if it should still exist. |
| `leaving-pr-comments` | (automatic) | Formats comments that an agent posts on your behalf. |

Some skills call others. Install the ones they need too:

- `full-send` uses `sol-loop` and `babysit-pr`.
- `full-stop` uses `full-send`.
- `takeover` uses `modernize`, `babysit-pr`, and `leaving-pr-comments`.
- `babysit-pr` and `modernize` use `leaving-pr-comments`.

## Install

```bash
git clone https://github.com/jakubhomoly/jakstack
jakstack/install.sh
```

`install.sh` symlinks each skill into `~/.claude/skills/` (Claude Code) and
`~/.codex/skills/` (Codex), so edits to the clone show up in both. Keep the
clone where it is: the links point into it. After `git pull`, run the script
again to link new skills and remove links to deleted ones. It leaves your other
skills alone and skips any real directory with the same name as a skill here.

To copy instead of link:

```bash
cp -R jakstack/skills/* ~/.claude/skills/   # Claude Code
cp -R jakstack/skills/* ~/.codex/skills/    # Codex
```

## Requirements

- An authenticated [GitHub CLI](https://cli.github.com) (`gh`).
- `python3` for `babysit-pr`'s `pr-wait` script.
- `sol-loop` needs subagents on other providers' models. T3 Code
  does this with `delegate_task`. Otherwise you need a harness that can run
  those models.

## Make them yours

These are starting points. Edit them. Put personal settings, like which models
review your work, in your `CLAUDE.md` or `AGENTS.md`, so you can update the
skills without losing them.

## License

[MIT](LICENSE)
