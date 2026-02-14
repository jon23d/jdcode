#!/bin/bash

set -e

echo "Installing jdcode CLI tool..."

# Copy the jdcode script to a directory in PATH if possible
if command -v which >/dev/null 2>&1; then

    # Check user's preferred locations first
    if [ -d "$HOME/bin" ] && [ -w "$HOME/bin" ]; then
        TARGET_DIR="$HOME/bin"
    elif [ -d "$HOME/.local/bin" ] && [ -w "$HOME/.local/bin" ]; then
        TARGET_DIR="$HOME/.local/bin"
    elif [ -w "/usr/local/bin" ]; then
        TARGET_DIR="/usr/local/bin"
    else
        # Try to find a suitable location in PATH
        TARGET_DIR=""
        for dir in $(echo $PATH | tr ':' ' '); do
            if [ -w "$dir" ] && [ -d "$dir" ]; then
                TARGET_DIR="$dir"
                break
            fi
        done
    fi

    if [ -n "$TARGET_DIR" ]; then
        cp ./jdcode "$TARGET_DIR/jdcode"
        chmod +x "$TARGET_DIR/jdcode"
        echo "jdcode installed to $TARGET_DIR/jdcode"
        echo "You can now use: jdcode python or jdcode ts"
    else
        echo "Warning: No writable directory in PATH found"
        echo "Please copy the jdcode script to a directory in your PATH"
        echo "Or run: cp /code/jdcode ~/bin/jdcode && chmod +x ~/bin/jdcode"
    fi
else
    echo "Warning: which command not found, installation may be limited"
fi

echo ""
echo "Installation complete!"
echo "Usage examples:"
echo "  jdcode python         # Run Python variant"
echo "  jdcode ts             # Run TypeScript variant"
echo "  jdcode python --port 9000  # Run with custom port"
echo "  jdcode --help         # Show help"