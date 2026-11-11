#!/usr/bin/env bash
# One-time Termux setup: system packages + the pip deps that have Android wheels.
# `libusb-package` is deliberately skipped (no Android wheel); device/backend.py falls back
# to the system libusb installed here.
set -euo pipefail

case "${PREFIX:-}" in
  *com.termux*) ;;
  *) echo "Run this inside Termux (PREFIX=${PREFIX:-unset})." >&2; exit 1 ;;
esac

pkg update -y
pkg install -y python libusb
python -m pip install --upgrade pyusb platformdirs rich textual

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export PYTHONPATH="$root/src"

# Self-check: libusb loads and the chip packages are discoverable from the source tree.
python - <<'PY'
import sys
import usb.backend.libusb1

backend = usb.backend.libusb1.get_backend()
if backend is None:
    sys.exit("pyusb found no libusb backend: pkg install libusb, or export LD_LIBRARY_PATH=$PREFIX/lib")

from wifit3.device.manager import supported_ids
ids = supported_ids()
if not ids:
    sys.exit("chip discovery found no drivers")

print(f"ok: libusb backend loaded, {len(ids)} supported VID:PID entries")
PY

echo
echo "Setup done. Start wifit3 with: scripts/termux-run.sh"
echo "Optional: pkg install hashcat   # vault / offline cracking"
