---
name: ccc
description: Launch and fully drive a sandboxed Claude Code container in a new pane next to the current one. Splits a fresh herdr pane, boots a Linux container running a fresh, signed-in Claude Code (vanilla login form — the host's captured account), and gives batteries-included control over that inner session via the `cccontainer` CLI — screen-read, type/say/keys into the live session, headless one-shot prompts, run any command inside, update, monitor, stop, and copy-paste entry commands (read-only / full shell / by PID). Use on /ccc, /cccontainer, "spin up a sandbox claude", "container claude next to me", "drive a claude inside a container", or when isolating an agent run in a throwaway signed-in container.
---

# ccc — sandboxed, drivable Claude Code containers

Opens a **fresh Claude Code inside a Linux container** in a **new pane beside the current
one**, signed in as the host's current account (the vanilla login form:
`~/.claude/.credentials.json` + `~/.claude.json`), and hands you a CLI to **fully control
that inner session** — not just launch it.

## Do this when `/ccc` is invoked

Run:

```bash
cccontainer new            # optional: cccontainer new <email> to pick a captured account
```

That single command: resolves the current herdr session/pane (`identify`), captures a fresh
login (`sa capture`), splits a pane to the right, and boots the container which injects the
login and `exec claude`. Report the new container name (printed as `cc-<pane>`), then use the
CLI below to observe or drive it.

If `cccontainer` is not on PATH, call it directly: `~/.claude/skills/ccc/cccontainer`.

## Controlling the inner Claude — batteries included

`cccontainer` is the whole toolbox (`cccontainer help` for the list). Highlights:

- **Observe** — `cccontainer ls` / `watch [secs]`, `info <name>`, `screen <name> [lines]`
  (read what the running Claude shows), `logs <name>`.
- **Drive the live session** — `send <name> <text>` (type), `say <name> <text>`
  (type + Enter), `key <name> Enter|Escape …`. This targets the container's TUI through its
  herdr pane, so you steer the actual interactive session.
- **Headless** — `ask <name> <prompt>` runs a one-shot `claude -p` inside (JSON out),
  separate from the interactive session.
- **Anything inside** — `exec <name> [-- cmd…]` (default `bash`), `update <name>`
  (update Claude Code to latest), `stop <name|all>`.
- **Entry commands** — `enter <name>` prints copy-paste commands for read-only view,
  full read-write shell, and by-PID access.

## How it works (so you can extend it)

- Containers use the `swapaccounts:latest` image (node:22-slim + Claude Code) built by the
  AccountTracker/SwapAccounts subsystem; the daemon must have a captured login
  (`~/.accounttracker/logins/<email>/`). Needs colima running (`colima start --vm-type qemu
  --dns 1.1.1.1`).
- Each container carries labels `ccc=1`, `ccc.email`, `ccc.hsession`, `ccc.pane` — the CLI
  finds and drives containers by these, so pane-driving survives across invocations.
- Containers run `--rm`: `stop` removes them; exiting Claude ends them.
- Vanilla login = two files only (`{"claudeAiOauth":…}` + `oauthAccount` +
  `hasCompletedOnboarding`). No keychain inside the container.

Files: `launch.sh` (in-pane container boot), `cccontainer` (the CLI, also `cccontainer new`).
