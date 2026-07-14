# cccontainer

Launch and **fully drive** a fresh, **already-signed-in Claude Code inside a Linux
container** — either in a new pane beside you, or in your current shell inside a tmux
session you can attach to and drive **from anywhere, including another sandboxed agent**.

`ccc` / `cccontainer` (same CLI, both on PATH) opens and controls it — batteries included:
attach, read its screen, type into the live session, run headless prompts, exec anything
inside, update it, monitor it, stop it.

## Auto-login (guaranteed)

Every launch runs a fresh `sa capture` to snapshot the account **currently signed in on the
host**, then injects it as the vanilla two-file login. The inner Claude comes up **already
signed in as your current account** — no manual `/login`. Pass a captured `<email>` to
override.

## Two modes

- **`ccc new`** — splits a **herdr pane** to the right and runs Claude there.
- **`ccc tmux`** — boots in the **current shell**: Claude runs in an **in-container tmux**
  session (`main`). Prints an attach/drive banner and (if interactive) attaches your shell.
  Because it's tmux inside the container, any agent with docker access can attach and drive it.

## Usage

```bash
ccc new                            # herdr pane, or:
ccc tmux                           # current shell, tmux, attach-from-anywhere
                                   # (…  new <email> / tmux <email> to pick a captured account)
ccc attach <name>                  # attach the live Claude (Ctrl-b d to detach)
ccc ls                             # running ccc containers
ccc watch [secs]                   # live-refresh the list
ccc info  <name>                   # account, version, where, processes

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

## Drive from another sandboxed agent

`ccc tmux` runs Claude in tmux **inside** the container, so any process with access to the
same docker daemon can attach and drive it:

```bash
# give the other agent's container the docker socket:
docker run … -v /var/run/docker.sock:/var/run/docker.sock  your-agent-image
# then, from inside that agent:
cccontainer attach <name>                         # interactive
cccontainer say    <name> "do the thing"          # type + Enter (headless)
cccontainer screen <name>                         # read the live screen
docker exec <name> tmux send-keys -t main -l "hi"; docker exec <name> tmux send-keys -t main Enter
docker exec <name> tmux capture-pane -pt main     # raw read
```

## Install

```bash
# skill + CLI live here:
~/.claude/skills/ccc/           # SKILL.md, cccontainer, launch.sh
ln -sf ~/.claude/skills/ccc/cccontainer ~/.local/bin/cccontainer
ln -sf ~/.claude/skills/ccc/cccontainer ~/.local/bin/ccc      # short global alias
```

## Requirements

- **[colima](https://github.com/abiosoft/colima)** (Docker runtime):
  `colima start --vm-type qemu --dns 1.1.1.1`
- **herdr** (`hd`) — pane split + TUI driving (only for `ccc new`).
- **AccountTracker / SwapAccounts** — provides the `swapaccounts:latest` image
  (node:22-slim + Claude Code) and `sa capture` (host login →
  `~/.accounttracker/logins/<email>/`). `ccc tmux` builds `cccontainer:latest`
  (that image + `tmux`) once on first use.
- The **identify** skill — resolves the current herdr pane (only for `ccc new`).

## How the login works

"Signed in" is two files, injected into the container HOME:

- `~/.claude/.credentials.json` — `{"claudeAiOauth": …}`
- `~/.claude.json` — `oauthAccount` + `hasCompletedOnboarding: true`

No keychain inside the container. Containers run `--rm`: `stop` removes them; exiting Claude
ends them. Containers carry labels (`ccc=1`, `ccc.kind`, `ccc.email`, and
`ccc.hsession`/`ccc.pane` for herdr mode) so the CLI finds and drives them across invocations.

## Notes / limits

- Inner login can read **expired** if the host account was swapped after `sa capture`
  (an account can't refresh unless it's the one currently on the host). Capture while the
  target is signed in on the host, or pass an already-captured, still-valid `<email>`.
- Org/managed accounts show a managed-settings approval prompt — not auto-accepted.
- `update` needs root inside the stock image (`docker exec -u root`); a node-writable npm
  prefix would remove that.

## Status

Working, verified live 2026-07-14. `new` (herdr pane) and `tmux` (in-container tmux,
attach-from-anywhere) both boot **already signed in as the current host account**; verified
launch, ls, info, screen, drive (key/say), attach, exec, update (2.1.207→2.1.209), stop.
Built with `/ponytail` (least code that works).
