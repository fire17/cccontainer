#!/usr/bin/env bash
# launch.sh <email> <name> <hsession> <pane> — runs INSIDE the freshly-split pane.
# Boots a sandbox container with a fresh, signed-in Claude Code (vanilla login form:
# ~/.claude/.credentials.json + ~/.claude.json — same state SwapAccounts captures).
set -u
export PATH="/opt/homebrew/bin:$PATH"
E="${1:?email}"; NAME="${2:?name}"; HSESSION="${3:-}"; PANE="${4:-}"
IMAGE="swapaccounts:latest"
LOG="$HOME/.accounttracker/logins/$E"; STAGE="$HOME/.accounttracker/.stage/$NAME"

[ -d "$LOG" ] || { echo "ccc: no captured login for $E — run: sa capture"; exec bash; }

echo "ccc: waiting for docker daemon…"
until docker info >/dev/null 2>&1; do sleep 2; done
docker image inspect "$IMAGE" >/dev/null 2>&1 || {
  echo "ccc: building $IMAGE…"
  docker build -t "$IMAGE" /Users/magic/Creations/AccountTracker/SwapAccounts || exec bash
}

rm -rf "$STAGE"; mkdir -p "$STAGE"
cp "$LOG/.claude/.credentials.json" "$STAGE/.credentials.json"
cp "$LOG/.claude/.claude.json"      "$STAGE/.claude.json"
chmod 644 "$STAGE"/.credentials.json "$STAGE"/.claude.json   # dotfiles: name them, globs skip them
trap 'rm -rf "$STAGE"' EXIT

echo "ccc: launching container '$NAME' (signed in as $E)…"
docker run -it --rm --name "$NAME" \
  --label ccc=1 --label "ccc.email=$E" \
  --label "ccc.hsession=$HSESSION" --label "ccc.pane=$PANE" \
  -v "$STAGE:/staging:ro" "$IMAGE" bash -c '
    mkdir -p "$HOME/.claude"
    cp /staging/.credentials.json "$HOME/.claude/.credentials.json"
    cp /staging/.claude.json      "$HOME/.claude.json"
    chmod 600 "$HOME/.claude/.credentials.json"
    exec claude
  '
echo "ccc: container '$NAME' exited."
exec bash
