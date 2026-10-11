#!/usr/bin/env bash
# Runs once when the Codespace is created. Students install nothing by hand.
set -euo pipefail

echo "==> CYDEO CLI (your AI agent; it signs in with your CYDEO account)"
npm install -g @cydeo/cli@0.1.6

# `cydeo login` opens your browser with xdg-open, which a Codespace does not have.
sudo install -m 755 .devcontainer/xdg-open /usr/local/bin/xdg-open

echo "==> Warming up Maven for the practice project"
(cd practice && mvn -q -B -DskipTests dependency:resolve dependency:resolve-plugins >/dev/null 2>&1) || true

echo
echo "Setup finished."
echo "  1. cydeo login   (approve in your browser, then wait for 'Logged in.')"
echo "  2. cydeo         (start talking to your AI agent)"
