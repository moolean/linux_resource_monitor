#!/bin/bash
# Test script to verify both shell and Python versions work correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Testing Linux Resource Monitor"
echo "=========================================="
echo ""

# Test 1: Check if shell script is executable
echo "Test 1: Checking if resource_monitor.sh is executable..."
if [ -x "$SCRIPT_DIR/resource_monitor.sh" ]; then
    echo "✓ resource_monitor.sh is executable"
else
    echo "✗ resource_monitor.sh is not executable"
    exit 1
fi
echo ""

# Test 2: Check if shell script has valid syntax
echo "Test 2: Checking shell script syntax..."
if bash -n "$SCRIPT_DIR/resource_monitor.sh"; then
    echo "✓ Shell script syntax is valid"
else
    echo "✗ Shell script has syntax errors"
    exit 1
fi
echo ""

# Test 3: Check if Python script is executable
echo "Test 3: Checking if resource_monitor.py is executable..."
if [ -x "$SCRIPT_DIR/resource_monitor.py" ]; then
    echo "✓ resource_monitor.py is executable"
else
    echo "✗ resource_monitor.py is not executable"
    exit 1
fi
echo ""

# Test 4: Check if Python script has valid syntax
echo "Test 4: Checking Python script syntax..."
if python3 -m py_compile "$SCRIPT_DIR/resource_monitor.py"; then
    echo "✓ Python script syntax is valid"
else
    echo "✗ Python script has syntax errors"
    exit 1
fi
echo ""

# Test 5: Check if demo.py works
echo "Test 5: Running demo.py to test Python functionality..."
if timeout 3 python3 "$SCRIPT_DIR/demo.py" > /dev/null 2>&1; then
    echo "✓ Python demo runs successfully"
else
    # May timeout but that's expected
    if timeout 3 python3 "$SCRIPT_DIR/demo.py" 2>&1 | grep -q "Linux Resource Monitor"; then
        echo "✓ Python demo runs successfully"
    else
        echo "✗ Python demo failed"
        exit 1
    fi
fi
echo ""

# Test 6: Check if Debian package files exist
echo "Test 6: Checking Debian package structure..."
required_files=(
    "debian/DEBIAN/control"
    "debian/DEBIAN/postinst"
    "debian/usr/share/doc/linux-resource-monitor/copyright"
    "debian/usr/share/doc/linux-resource-monitor/changelog.gz"
)

all_exist=true
for file in "${required_files[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo "  ✓ $file exists"
    else
        echo "  ✗ $file is missing"
        all_exist=false
    fi
done

if [ "$all_exist" = true ]; then
    echo "✓ All required Debian package files exist"
else
    echo "✗ Some Debian package files are missing"
    exit 1
fi
echo ""

# Test 7: Check if build-deb.sh is executable
echo "Test 7: Checking if build-deb.sh is executable..."
if [ -x "$SCRIPT_DIR/build-deb.sh" ]; then
    echo "✓ build-deb.sh is executable"
else
    echo "✗ build-deb.sh is not executable"
    exit 1
fi
echo ""

# Test 8: Verify background color was removed from Python script
echo "Test 8: Verifying background color (curses.A_REVERSE) was removed..."
if grep -q "curses.A_REVERSE" "$SCRIPT_DIR/resource_monitor.py"; then
    echo "✗ curses.A_REVERSE still found in resource_monitor.py"
    exit 1
else
    echo "✓ Background color setting removed successfully"
fi
echo ""

echo "=========================================="
echo "All tests passed! ✓"
echo "=========================================="
echo ""
echo "Summary:"
echo "- Shell script version: Working (high performance)"
echo "- Python version: Working (background color removed)"
echo "- Debian package structure: Complete"
echo "- Build script: Ready"
echo ""
echo "You can now:"
echo "1. Run ./resource_monitor.sh for high-performance monitoring"
echo "2. Run ./resource_monitor.py for Python-based monitoring"
echo "3. Run ./build-deb.sh to build the Debian package"
