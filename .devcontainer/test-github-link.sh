#!/usr/bin/env bash
# Tests link-github.sh and cydeo-login-hook.sh with stub curl/cydeo. Runs in CI (smoke.sh) and on a laptop.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
fail=0
pass() { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }

mkdir -p "$work/bin"
# curl stub: records its arguments (one per line) and what it read on stdin.
cat > "$work/bin/curl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$CASE/args"
cat > "$CASE/stdin"
exit "${CURL_EXIT:-0}"
EOF
chmod +x "$work/bin/curl"

# link <case> <GITHUB_USER> <config.json content, '' for none> [curl exit code]
link() {
  CASE="$work/$1"
  mkdir -p "$CASE/home/.cydeo"
  if [ -n "$3" ]; then printf '%s' "$3" > "$CASE/home/.cydeo/config.json"; fi
  out="$(CASE="$CASE" CURL_EXIT="${4:-0}" HOME="$CASE/home" GITHUB_USER="$2" PATH="$work/bin:$PATH" \
    bash "$here/link-github.sh" 2>&1)"
  rc=$?
  if [ -f "$CASE/args" ]; then sent=1; else sent=0; fi
  args="$(cat "$CASE/args" 2>/dev/null)"
  stdin="$(cat "$CASE/stdin" 2>/dev/null)"
}
CFG='{"token":"cydeo_TESTtoken-123","proxyBaseUrl":"https://ai.cydeo.com/api/v1","model":"m"}'

link valid octo-cat "$CFG"
if [ "$rc" -eq 0 ] && [ -z "$out" ] && [ "$sent" -eq 1 ]; then pass "logged in: sends once and prints nothing"; else bad "logged in: rc=$rc sent=$sent out=$out"; fi
if printf '%s\n' "$args" | grep -qx 'https://ai.cydeo.com/api/v1/github-account'; then pass "posts to the AI Lab"; else bad "url: $args"; fi
if printf '%s\n' "$args" | grep -qx '{"login":"octo-cat"}'; then pass "body is the GitHub login"; else bad "body: $args"; fi
if printf '%s\n' "$args" | grep -q 'TESTtoken'; then bad "token is on the command line"; else pass "token never on the command line"; fi
if printf '%s\n' "$stdin" | grep -qx 'Authorization: Bearer cydeo_TESTtoken-123'; then pass "token goes to curl on stdin"; else bad "stdin: $stdin"; fi

link nouser "" "$CFG"
if [ "$sent" -eq 0 ] && [ "$rc" -eq 0 ]; then pass "no GITHUB_USER: sends nothing"; else bad "no GITHUB_USER sent"; fi

odd_ok=1
for odd in "-octocat" "octo cat" "octo;cat" 'octo"cat' "../octocat" "$(printf 'a%.0s' $(seq 1 40))"; do
  link "odd-$RANDOM$RANDOM" "$odd" "$CFG"
  if [ "$sent" -ne 0 ] || [ "$rc" -ne 0 ]; then odd_ok=0; bad "odd GITHUB_USER was sent: $odd"; fi
done
if [ "$odd_ok" -eq 1 ]; then pass "odd GITHUB_USER values: sends nothing"; fi

link nocfg octo-cat ""
if [ "$sent" -eq 0 ] && [ "$rc" -eq 0 ]; then pass "not logged in yet: sends nothing"; else bad "no config sent"; fi
link notoken octo-cat '{"proxyBaseUrl":"https://ai.cydeo.com/api/v1"}'
if [ "$sent" -eq 0 ]; then pass "config without a token: sends nothing"; else bad "no token sent"; fi
link broken octo-cat '{not json'
if [ "$sent" -eq 0 ] && [ "$rc" -eq 0 ] && [ -z "$out" ]; then pass "broken config: sends nothing, quietly"; else bad "broken config rc=$rc out=$out"; fi
link oddtoken octo-cat '{"token":"cydeo_a\r\nX-Evil: 1"}'
if [ "$sent" -eq 0 ]; then pass "token with a line break: sends nothing"; else bad "odd token sent"; fi

link custom octo-cat '{"token":"cydeo_t","proxyBaseUrl":"https://staging.example.com/api/v1/"}'
if printf '%s\n' "$args" | grep -qx 'https://staging.example.com/api/v1/github-account'; then pass "uses the CLI's own AI Lab URL"; else bad "custom url: $args"; fi
link default octo-cat '{"token":"cydeo_t"}'
if printf '%s\n' "$args" | grep -qx 'https://ai.cydeo.com/api/v1/github-account'; then pass "defaults to ai.cydeo.com"; else bad "default url: $args"; fi
link plain octo-cat '{"token":"cydeo_t","proxyBaseUrl":"http://example.com/api/v1"}'
if printf '%s\n' "$args" | grep -qx 'https://ai.cydeo.com/api/v1/github-account'; then pass "never sends the token over plain http"; else bad "http url: $args"; fi

link curlfail octo-cat "$CFG" 7
if [ "$rc" -eq 0 ] && [ -z "$out" ]; then pass "network error: exits 0, prints nothing"; else bad "network error rc=$rc out=$out"; fi

# The login hook: `cydeo login` that succeeds runs the link script; nothing else does.
cat > "$work/bin/cydeo" <<'EOF'
#!/usr/bin/env bash
exit "${CYDEO_EXIT:-0}"
EOF
chmod +x "$work/bin/cydeo"
printf '#!/usr/bin/env bash\necho linked >> "%s/linked"\n' "$work" > "$work/fake-link.sh"
hook() {
  : > "$work/linked"
  CYDEO_EXIT="$1" CYDEO_LINK_GITHUB="$work/fake-link.sh" PATH="$work/bin:$PATH" \
    bash -c ". '$here/cydeo-login-hook.sh'; cydeo $2; echo \"rc=\$?\"" 2>&1
}
r="$(hook 0 login)"
if [ "$r" = "rc=0" ] && [ "$(cat "$work/linked")" = "linked" ]; then pass "hook: successful cydeo login links GitHub"; else bad "hook login ok: $r / $(cat "$work/linked")"; fi
r="$(hook 1 login)"
if [ "$r" = "rc=1" ] && [ ! -s "$work/linked" ]; then pass "hook: failed login links nothing and keeps exit code 1"; else bad "hook login fail: $r"; fi
r="$(hook 0 '')"
if [ "$r" = "rc=0" ] && [ ! -s "$work/linked" ]; then pass "hook: plain cydeo links nothing"; else bad "hook plain: $r"; fi
r="$(hook 3 --help)"
if [ "$r" = "rc=3" ] && [ ! -s "$work/linked" ]; then pass "hook: other commands keep their exit code"; else bad "hook other: $r"; fi

echo
if [ "$fail" -ne 0 ]; then echo "GitHub link tests: FAIL"; exit 1; fi
echo "GitHub link tests: PASS"
