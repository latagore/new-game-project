#!/bin/bash
# Dev Setup Script - Installs required addons for development

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ADDONS_DIR="$PROJECT_ROOT/addons"

echo "Setting up development environment..."

# Create addons directory if it doesn't exist
mkdir -p "$ADDONS_DIR"

# Install GUT (Godot Unit Testing) v9.5.1
GUT_VERSION="v9.5.1"
GUT_DIR="$ADDONS_DIR/gut"

if [ -d "$GUT_DIR" ]; then
    echo "GUT already installed at $GUT_DIR"
else
    echo "Installing GUT $GUT_VERSION..."

    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download and extract GUT
    curl -L "https://github.com/bitwes/Gut/archive/refs/tags/${GUT_VERSION}.zip" -o gut.zip
    unzip -q gut.zip

    # Move addons/gut to project
    mv Gut-*/addons/gut "$GUT_DIR"

    # Cleanup
    cd "$PROJECT_ROOT"
    rm -rf "$TEMP_DIR"

    echo "GUT installed successfully!"
fi

echo ""
echo "Setup complete! Next steps:"
echo "1. Open the project in Godot"
echo "2. Go to Project -> Project Settings -> Plugins"
echo "3. Enable the 'gut' plugin"
echo ""
echo "Run tests with:"
echo "  godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit"
