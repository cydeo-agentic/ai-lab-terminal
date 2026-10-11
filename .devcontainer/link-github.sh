#!/usr/bin/env bash
# Tells the CYDEO AI Lab which GitHub account this Codespace belongs to, so your
# instructors can find your work. Runs after `cydeo login` and each time the
# Codespace opens. Silent, and never fails: the Codespace works the same without it.
set -u
login="${GITHUB_USER:-}"
case "$login" in ''|-*|*[!A-Za-z0-9-]*) exit 0 ;; esac
[ "${#login}" -le 39 ] || exit 0
cfg="$HOME/.cydeo/config.json"
[ -r "$cfg" ] || exit 0

# Line 1: the token. Line 2: the AI Lab URL (the CLI's own, only if it is https).
{ read -r token; read -r base; } < <(node -e '
  try {
    const c = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))
    if (typeof c.token !== "string" || !/^[A-Za-z0-9_.-]+$/.test(c.token)) process.exit(0)
    const url = typeof c.proxyBaseUrl === "string" && c.proxyBaseUrl.startsWith("https://")
      ? c.proxyBaseUrl.replace(/\/+$/, "") : "https://ai.cydeo.com/api/v1"
    console.log(c.token + "\n" + url)
  } catch {}
' "$cfg" 2>/dev/null)
[ -n "${token:-}" ] && [ -n "${base:-}" ] || exit 0

# The token reaches curl on stdin (-H @-), so it never shows in a process list.
printf 'Authorization: Bearer %s\n' "$token" |
  curl -s -m 10 -o /dev/null -H @- -H 'Content-Type: application/json' \
    --data "{\"login\":\"$login\"}" "$base/github-account" >/dev/null 2>&1
exit 0
