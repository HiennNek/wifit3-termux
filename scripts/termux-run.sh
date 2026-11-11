#!/usr/bin/env bash
# Start wifit3 from this repo as root. Android's /dev/bus/usb nodes are root-only and there is
# no udev, so the app must own the adapter as root.
set -euo pipefail

case "${PREFIX:-}" in
  *com.termux*) ;;
  *) echo "Run this inside Termux (PREFIX=${PREFIX:-unset})." >&2; exit 1 ;;
esac

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
py="$PREFIX/bin/python"
[ -x "$py" ] || { echo "python missing: pkg install python" >&2; exit 1; }

# env(1) carries the vars past sudo's environment reset; no shell quoting involved.
set -- env \
  "PYTHONPATH=$root/src" "HOME=$HOME" "TERM=${TERM:-xterm-256color}" \
  "LD_LIBRARY_PATH=$PREFIX/lib" "$py" -m wifit3

if [ "$(id -u)" -eq 0 ]; then
  exec "$@"
fi
exec sudo "$@"
