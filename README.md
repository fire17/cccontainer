# cccontainer

Launch and **fully drive** a fresh, signed-in **Claude Code inside a Linux container**, in a
new pane beside the one you're in.

`/ccc` (the skill) opens it. `cccontainer` (the CLI) controls it — batteries included:
read its screen, type into the live session, run headless prompts, exec anything inside,
update it, monitor it, stop it.

## What it does

Invoking `/ccc` runs `cccontainer new`, which:

1. resolves your current herdr pane (`identify`),
2. captures a fresh host login (`sa capture`, the vanilla two-file form),
3. splits a pane to the right, and
4. boots a container that injects the login and `exec claude`.

You get a disposable, signed-in Claude Code next to you — and a CLI to steer it from outside.

## Usage

```bash
cccontainer new                    # or: cccontainer new <captured-email>
cccontainer ls                     # running ccc containers
cccontainer watch [secs]           # live-refresh the list
cccontainer info  <name>           # account, version, pane, processes

# drive the live session
cccontainer screen <name> [lines]  # read what the running Claude shows
cccontainer send   <name> <text>   # type (no Enter)
cccontainer say    <name> <text>   # type + Enter
cccontainer key    <name> Enter|Escape …

# batteries
cccontainer ask    <name> <prompt> # headless one-shot (claude -p), JSON out
cccontainer exec   <name> [-- cmd] # run anything inside (default: bash)
cccontainer update <name>          # update inner Claude Code to latest
cccontainer logs   <name>          # follow container stdout
cccontainer stop   <name|all>      # stop (auto-removes)
cccontainer enter  <name>          # copy-paste: read-only / full shell / by-PID
```

## Install

```bash
# skill + CLI live here:
~/.claude/skills/ccc/           # SKILL.md, cccontainer, launch.sh
ln -sf ~/.claude/skills/ccc/cccontainer ~/.local/bin/cccontainer
```

## Requirements

- **[colima](https://github.com/abiosoft/colima)** (Docker runtime):
  `colima start --vm-type qemu --dns 1.1.1.1`
- **herdr** (`hd`) — pane split + TUI driving.
- **AccountTracker / SwapAccounts** — provides the `swapaccounts:latest` image
  (node:22-slim + Claude Code) and `sa capture` (host login →
  `~/.accounttracker/logins/<email>/`).
- The **identify** skill — resolves the current herdr pane.

## How the login works

"Signed in" is two files, injected into the container HOME:

- `~/.claude/.credentials.json` — `{"claudeAiOauth": …}`
- `~/.claude.json` — `oauthAccount` + `hasCompletedOnboarding: true`

No keychain inside the container. Containers run `--rm`: `stop` removes them; exiting Claude
ends them. Containers carry labels (`ccc=1`, `ccc.email`, `ccc.hsession`, `ccc.pane`) so the
CLI finds and drives them across invocations.

## Notes / limits

- Inner login can read **expired** if the host account was swapped after `sa capture`
  (an account can't refresh unless it's the one currently on the host). Capture while the
  target is signed in on the host, or pass an already-captured, still-valid `<email>`.
- Org/managed accounts show a managed-settings approval prompt — not auto-accepted.
- `update` needs root inside the stock image (`docker exec -u root`); a node-writable npm
  prefix would remove that.

## Status

Working, verified live 2026-07-14 (launch, ls, info, screen, drive, exec, update
2.1.207→2.1.209, stop). Built with `/ponytail` (least code that works).
