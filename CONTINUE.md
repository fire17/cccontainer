# cccontainer — continue here

Snapshot of the session that built **`/ccc`** (skill) + **`cccontainer`** (CLI):
launch and *fully drive* a sandboxed, signed-in Claude Code running in a Linux container,
in a new pane beside the current one.

## What this is

- **`/ccc`** — a Claude Code skill. When invoked it runs `cccontainer new`: resolves the
  current herdr pane (`identify`), captures a fresh host login (`sa capture`), splits a
  pane to the right, and boots a container that injects the login (vanilla form) and
  `exec claude`. Result: a fresh, signed-in Claude Code in a throwaway container next to you.
- **`cccontainer`** — the batteries-included CLI to observe and DRIVE that inner session:
  `new · ls · watch · info · screen · send · say · key · ask · exec · update · logs · stop · enter`.
  See `cccontainer help`.

## Where it lives (original locations)

- Skill + CLI: `~/.claude/skills/ccc/` — `SKILL.md`, `cccontainer` (CLI, incl. `new`), `launch.sh` (in-pane boot).
- CLI on PATH via symlink: `~/.local/bin/cccontainer` → `~/.claude/skills/ccc/cccontainer`.
- Frozen copies here: `files/skills/ccc/` and `skills/ccc/`.

## Depends on (NOT copied — external subsystems it drives)

- **AccountTracker / SwapAccounts** — `~/Creations/AccountTracker/SwapAccounts/`:
  provides the `swapaccounts:latest` Docker image (node:22-slim + Claude Code), `sa capture`
  (host login → `~/.accounttracker/logins/<email>/`), and the vanilla login form
  (two files: `~/.claude/.credentials.json` = `{"claudeAiOauth":…}` + `~/.claude.json` =
  `oauthAccount` + `hasCompletedOnboarding`).
- **herdr** (`hd`) — pane splitting + driving the inner TUI (`pane split/run/read/send-text/send-keys`).
- **colima** — Docker runtime. Start once: `colima start --vm-type qemu --dns 1.1.1.1`.
- **identify** skill — resolves the current herdr session/pane by pid.

## Current state (honest)

Verified live this session against real containers:
- `new` (split pane + boot signed-in claude), `ls`, `info`, `screen`, `key`/`send`/`say`
  (drive the live TUI — cursor moved, prompt submitted), `enter`, `exec`, `update`
  (2.1.207 → 2.1.209 inside), `stop` — **all working**.
- `ask` (headless `claude -p`), `logs`, `watch` — thin `docker`/`hd` wrappers, mechanism
  proven via the others; `ask` not exercised to a completed answer.

Known/limits:
- Inner login can read **expired** if the host account was swapped after `sa capture`
  (creds can't refresh for an account not currently on the host). Fix: capture while the
  target account is the host's signed-in one, or pass `cccontainer new <email>` for an
  already-captured, still-valid login. This is SwapAccounts login-state behavior, not a
  ccc bug.
- Org/managed accounts show a "Managed settings require approval" prompt (e.g.
  `OTEL_EXPORTER_OTLP_ENDPOINT`) — not auto-accepted.
- `cmd_new` echoes "capturing fresh login for <email>" but `sa capture` always captures
  the **host** account; the `<email>` arg selects which *captured* login the container
  uses. Cosmetic wording only.
- Containers run `--rm`: `stop` removes them; exiting Claude ends them.
- `docker`/`colima` live at `/opt/homebrew/bin` (CLI prepends this to PATH).

## How to resume

- `claude --resume 822de3b6-dd72-4b9f-9d60-97f3f6ec6368` from the original cwd
  `/Users/magic/General/Sandboxes`, or read `conversation/`.
- Try it: `cccontainer new` (or `cccontainer new agibingo@gmail.com`), then
  `cccontainer ls`, `cccontainer screen <name>`, `cccontainer say <name> "hi"`.

## Next steps (ideas)

- Rebuild `swapaccounts:latest` with a node-writable npm prefix so `update` needs no root.
- `cccontainer new --detach` (headless, no pane) for pure-CLI agent runs.
- Auto-`colima start` if the daemon is down.
- Fix the `sa capture` wording; add `ask` end-to-end test.
