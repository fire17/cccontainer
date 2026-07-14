---
name: ccc
description: Launch and fully drive a sandboxed, already-signed-in Claude Code in a container — either in a new herdr pane (`cccontainer new`) or in the CURRENT shell inside an in-container tmux session attachable/drivable from anywhere incl. another sandboxed agent (`cccontainer tmux`). The container is auto-logged-in as the host's CURRENT account (fresh `sa capture` at launch, injected as the vanilla two-file login). Batteries-included control via the global `ccc`/`cccontainer` CLI — attach, screen-read, type/say/keys into the live session, headless one-shot prompts, run any command inside, update, monitor, stop, and copy-paste entry commands (read-only / full shell / by PID). Use on /ccc, /cccontainer, "spin up a sandbox claude", "container claude in tmux", "drive a claude inside a container", "attach a claude container from another agent", or when isolating an agent run in a throwaway signed-in container.
---

# ccc — sandboxed, drivable, already-signed-in Claude Code containers

Opens a **fresh Claude Code inside a Linux container**, **auto-logged-in as the host's
current account**, and hands you a CLI (`ccc` / `cccontainer`, on PATH) to **fully control
that inner session** — not just launch it. Two launch modes:

- **`ccc new`** — splits a **herdr pane** to the right and runs Claude there.
- **`ccc tmux`** — boots in the **current shell**: Claude runs in an **in-container tmux**
  session (`main`), so it can be **attached and driven from anywhere** — including another
  sandboxed agent — over `docker exec … tmux`.

## Auto-login (guaranteed)

Both modes run a fresh `sa capture` at launch, which snapshots the account **currently
signed in on the host**, then inject it into the container as the vanilla two-file login
(`~/.claude/.credentials.json` + `~/.claude.json`). The inner Claude is signed in as the
current host account with no manual `/login`. (Pass an explicit captured `<email>` to
override.)

## Do this when `/ccc` is invoked

```bash
ccc new             # herdr pane, or:  ccc tmux   (current shell, tmux, attach-from-anywhere)
# optional: ccc new <email> / ccc tmux <email> to pick a captured account
```

`new` resolves the current herdr pane (`identify`), captures the login, splits right, boots
the container (`exec claude`). `tmux` captures the login and boots a detached container
running Claude in tmux `main`, then prints an ATTACH/DRIVE banner and auto-attaches your
shell if interactive. Report the container name and use the CLI below.

If not on PATH, call directly: `~/.claude/skills/ccc/cccontainer`.

## Controlling the inner Claude — batteries included

`cccontainer` is the whole toolbox (`cccontainer help` for the list). Highlights:

- **Observe** — `cccontainer ls` / `watch [secs]`, `info <name>`, `screen <name> [lines]`
  (read what the running Claude shows), `logs <name>`.
- **Attach** — `attach <name>` (interactive, tmux mode; `Ctrl-b d` to detach).
- **Drive the live session** — `send <name> <text>` (type), `say <name> <text>`
  (type + Enter), `key <name> Enter|Escape …`. Kind-aware: herdr-mode steers the pane TUI,
  tmux-mode drives via `docker exec … tmux send-keys` — so another agent with docker access
  drives the same way.
- **Headless** — `ask <name> <prompt>` runs a one-shot `claude -p` inside (JSON out),
  separate from the interactive session.
- **Anything inside** — `exec <name> [-- cmd…]` (default `bash`), `update <name>`
  (update Claude Code to latest), `stop <name|all>`.
- **Entry commands** — `enter <name>` prints copy-paste commands for read-only view,
  full read-write shell, and by-PID access.

## How it works (so you can extend it)

- Images: `new` uses `swapaccounts:latest` (node:22-slim + Claude Code) from the
  AccountTracker/SwapAccounts subsystem; `tmux` uses `cccontainer:latest`, built once on
  first use = `swapaccounts:latest` + `tmux`. Needs colima running (`colima start
  --vm-type qemu --dns 1.1.1.1`) and a captured login (`~/.accounttracker/logins/<email>/`).
- Labels: `ccc=1`, `ccc.kind` (`herdr`|`tmux`), `ccc.email`, and `ccc.hsession`/`ccc.pane`
  (herdr mode). The CLI finds and drives containers by these across invocations.
- Containers run `--rm`: `stop` removes them; exiting Claude ends them.
- Vanilla login = two files only (`{"claudeAiOauth":…}` + `oauthAccount` +
  `hasCompletedOnboarding`). No keychain inside the container.
- **Drive from another sandboxed agent:** give that agent access to this docker socket
  (`-v /var/run/docker.sock:/var/run/docker.sock`), then it runs the same
  `cccontainer`/`docker exec … tmux` commands to attach, read, and type.

Global: `ccc` and `cccontainer` are both symlinked onto PATH (`~/.local/bin`).
Files: `cccontainer` (the CLI — `new`/`tmux`/`attach`/…), `launch.sh` (herdr in-pane boot).
