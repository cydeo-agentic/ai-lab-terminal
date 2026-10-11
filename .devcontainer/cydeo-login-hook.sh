# Sourced by ~/.bashrc (setup.sh adds the line). After a successful `cydeo login`,
# tell the CYDEO AI Lab which GitHub account this Codespace belongs to (see link-github.sh).
CYDEO_LINK_GITHUB="${CYDEO_LINK_GITHUB:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/link-github.sh}"
cydeo() {
  command cydeo "$@"
  local rc=$?
  if [ "${1:-}" = login ] && [ "$rc" -eq 0 ]; then bash "$CYDEO_LINK_GITHUB"; fi
  return "$rc"
}
