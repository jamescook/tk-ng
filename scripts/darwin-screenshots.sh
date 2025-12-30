#!/bin/bash
# Generate macOS screenshots for both Tcl 8.6 and 9.0
#
# Prerequisites:
#   brew install tcl-tk@8    # Tcl 8.6
#   brew install tcl-tk      # Tcl 9.x
#
# Usage: ./scripts/darwin-screenshots.sh
#
# After running, bless with: rake screenshots:bless:darwin

set -e

cd "$(dirname "$0")/.."

# Get paths via brew --prefix (works on both Intel and Apple Silicon)
TCL86_PATH="$(brew --prefix tcl-tk@8)"
TCL9_PATH="$(brew --prefix tcl-tk)"

# Verify installations
if [ ! -d "$TCL86_PATH" ]; then
  echo "ERROR: Tcl 8.6 not found"
  echo "Install with: brew install tcl-tk@8"
  exit 1
fi

if [ ! -d "$TCL9_PATH" ]; then
  echo "ERROR: Tcl 9.x not found"
  echo "Install with: brew install tcl-tk"
  exit 1
fi

echo "=== Tcl 8.6 path: $TCL86_PATH ==="
echo "=== Tcl 9.x path: $TCL9_PATH ==="

echo ""
echo "=== Building for Tcl/Tk 8.6 ==="
rake clean
# Tcl 8.6: headers are in include/
rake compile -- \
  --with-tcltkversion=8.6 \
  --with-tcl-lib="$TCL86_PATH/lib" \
  --with-tk-lib="$TCL86_PATH/lib" \
  --with-tcl-include="$TCL86_PATH/include" \
  --with-tk-include="$TCL86_PATH/include" \
  --without-X11

echo ""
echo "=== Generating Tcl/Tk 8.6 screenshots ==="
rake screenshots:generate

echo ""
echo "=== Building for Tcl/Tk 9.x ==="
rake clean
# Tcl 9.x: headers are in include/tcl-tk/ (Homebrew layout differs from 8.6)
rake compile -- \
  --with-tcltkversion=9.0 \
  --with-tcl-lib="$TCL9_PATH/lib" \
  --with-tk-lib="$TCL9_PATH/lib" \
  --with-tcl-include="$TCL9_PATH/include/tcl-tk" \
  --with-tk-include="$TCL9_PATH/include/tcl-tk" \
  --without-X11

echo ""
echo "=== Generating Tcl/Tk 9.x screenshots ==="
rake screenshots:generate

echo ""
echo "=== Done ==="
echo "Screenshots generated in:"
echo "  screenshots/unverified/darwin/tcl8.6/"
echo "  screenshots/unverified/darwin/tcl9.0/"
echo ""
echo "To bless: rake screenshots:bless:darwin"
