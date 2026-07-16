#!/bin/bash

# ============================================================================
# Rate Monotonic Scheduling - Test Runner Script
# ============================================================================
# This script compiles and runs the comprehensive test suite for the
# Rate_Monotonic Ada package.
#
# Usage: ./run_tests.sh
# ============================================================================

echo "=========================================================================="
echo "Rate Monotonic Scheduling - Test Runner"
echo "=========================================================================="
echo ""

# Check if we're in the right directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check for Ada compiler
echo "Checking for Ada compiler..."
if command -v gnatmake &> /dev/null; then
    echo "Found: gnatmake"
    GNATMAKE="gnatmake"
elif command -v gprbuild &> /dev/null; then
    echo "Found: gprbuild"
    GNATMAKE="gprbuild"
else
    echo "ERROR: No Ada compiler found!"
    echo "Please install GNAT (GNU Ada Compiler) or GPRbuild."
    echo ""
    echo "On Ubuntu/Debian: sudo apt-get install gnat gprbuild"
    echo "On Fedora: sudo dnf install gcc-gnat gprbuild"
    echo "On macOS (with Homebrew): brew install gnat"
    exit 1
fi

echo ""
echo "Compiling test suite..."
echo "=========================================================================="

# Create directories if they don't exist
mkdir -p tests/obj
mkdir -p tests/bin

# Compile using gprbuild if available, otherwise gnatmake
if [ "$GNATMAKE" = "gprbuild" ]; then
    cd tests
    gprbuild -P tests.gpr -v 2>&1 | grep -v "^  " | grep -v "^$"
    cd ..
else
    cd tests
    gnatmake -P tests.gpr 2>&1 | grep -v "^  " | grep -v "^$"
    cd ..
fi

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Compilation failed!"
    exit 1
fi

echo ""
echo "Compilation successful!"
echo ""
echo "Running tests..."
echo "=========================================================================="

# Run the tests
cd tests
./bin/rate_monotonic_tests
EXIT_CODE=$?
cd ..

echo ""
echo "=========================================================================="
echo "Tests completed with exit code: $EXIT_CODE"
echo "=========================================================================="

exit $EXIT_CODE
