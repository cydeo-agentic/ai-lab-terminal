#!/usr/bin/env bash
# Shown each time you open the Codespace.
echo
echo "CYDEO AI Lab · terminal"
if [ -f "$HOME/.cydeo/config.json" ] && grep -q '"token"' "$HOME/.cydeo/config.json" 2>/dev/null; then
  echo "  You are signed in. Type:  cydeo"
else
  echo "  First time? Type:  cydeo login   then:  cydeo"
fi
echo "  Practice project: cd practice   (Java 21 + Maven + JUnit 5)"
echo "  Done for the day? Stop the Codespace so you keep your free hours (see README)."
echo
# Tell the AI Lab which GitHub account this is, in the background (silent; see link-github.sh).
(bash "$(dirname "$0")/link-github.sh" >/dev/null 2>&1 &)
