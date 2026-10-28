#!/usr/bin/env bash
# Symlink every skill in this repo into Claude Code and Codex, so edits here
# show up in both without copying. Safe to rerun after pulling.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for dest in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
  mkdir -p "$dest"

  # Links left behind by skills that were removed from the repo.
  for link in "$dest"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$repo/skills/"*) [ -e "$link" ] || { rm "$link"; echo "removed $link"; } ;;
    esac
  done

  for skill in "$repo"/skills/*/; do
    skill="${skill%/}"
    target="$dest/$(basename "$skill")"
    # ln -sfn would nest the link inside a real directory, so never touch one.
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "skipped $target: not a symlink, remove it to install" >&2
      continue
    fi
    ln -sfn "$skill" "$target"
    echo "linked $target"
  done
done
