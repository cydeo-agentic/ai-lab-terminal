#!/usr/bin/env bash
# CI only: proves the Codespace works before students open it.
set -uo pipefail
fail=0
pass() { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
check() { local n="$1"; shift; if "$@" >/dev/null 2>&1; then pass "$n"; else bad "$n"; fi; }

check "cydeo CLI installed (cydeo --help)" cydeo --help
if java -version 2>&1 | grep -q '"21'; then pass "Java 21"; else bad "Java 21 ($(java -version 2>&1 | head -1))"; fi
check "Maven (mvn -v)" mvn -v
check "xdg-open shim for cydeo login" test -x /usr/local/bin/xdg-open
if bash .devcontainer/test-github-link.sh >/tmp/github-link.log 2>&1; then pass "GitHub link scripts (tests)"; else bad "GitHub link scripts (tests)"; cat /tmp/github-link.log; fi
if [ "$(bash -ic 'type -t cydeo' 2>/dev/null)" = "function" ]; then pass "cydeo login hook loaded in a new terminal"; else bad "cydeo login hook not loaded by ~/.bashrc"; fi
if (cd practice && mvn -q -B test >/tmp/mvn.log 2>&1); then pass "practice project: mvn test"; else bad "practice project: mvn test"; tail -20 /tmp/mvn.log; fi
timeout 15 cydeo login </dev/null >/tmp/login.log 2>&1; rc=$?
if [ "$rc" -eq 124 ]; then pass "cydeo login waits for browser approval (no crash)"; else bad "cydeo login exited $rc"; tail -5 /tmp/login.log; fi

echo
if [ "$fail" -ne 0 ]; then echo "Smoke: FAIL"; exit 1; fi
echo "Smoke: PASS"
