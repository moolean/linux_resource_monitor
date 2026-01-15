#!/bin/bash
# Build script for creating the Debian package

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/debian"

echo "Building Linux Resource Monitor Debian package..."
echo "=================================================="

# Check if source files exist
if [ ! -f "$SCRIPT_DIR/resource_monitor.sh" ]; then
    echo "Error: resource_monitor.sh not found"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/resource_monitor.py" ]; then
    echo "Error: resource_monitor.py not found"
    exit 1
fi

# Ensure destination directory exists
mkdir -p "$BUILD_DIR/usr/bin"

# Copy executables to the package bin directory
echo "Copying executables..."
cp "$SCRIPT_DIR/resource_monitor.sh" "$BUILD_DIR/usr/bin/"
cp "$SCRIPT_DIR/resource_monitor.py" "$BUILD_DIR/usr/bin/"

# Ensure executables have correct permissions
chmod +x "$BUILD_DIR/usr/bin/resource_monitor.sh"
chmod +x "$BUILD_DIR/usr/bin/resource_monitor.py"

# Copy documentation
echo "Copying documentation..."
cp "$SCRIPT_DIR/README.md" "$BUILD_DIR/usr/share/doc/linux-resource-monitor/"

# Build the package
echo "Building .deb package..."
dpkg-deb --build "$BUILD_DIR" linux-resource-monitor_1.0.0_all.deb

echo ""
echo "Package built successfully: linux-resource-monitor_1.0.0_all.deb"
echo ""
echo "To install the package, run:"
echo "  sudo dpkg -i linux-resource-monitor_1.0.0_all.deb"
echo ""
echo "To remove the package, run:"
echo "  sudo dpkg -r linux-resource-monitor"
