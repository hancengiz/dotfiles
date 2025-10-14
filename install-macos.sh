#!/usr/bin/env bash

set -e

echo "Starting dotfiles installation for macOS..."

# Get the dotfiles directory (where this script is located)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACOS_DIR="$DOTFILES_DIR/local-macos"

echo "Dotfiles directory: $DOTFILES_DIR"
echo "macOS config directory: $MACOS_DIR"

# Verify macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script is for macOS only. Detected: $(uname)"
    exit 1
fi

echo "✓ macOS detected"

# Install Homebrew if not present
echo ""
echo "Checking for Homebrew..."
if command -v brew &> /dev/null; then
    echo "✓ Homebrew is already installed"
    echo "  Version: $(brew --version | head -n 1)"
else
    echo "Homebrew not found. Installing Homebrew..."
    echo "  This may take a few minutes and will require your password..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    if [ -d "/opt/homebrew/bin" ]; then
        # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "✓ Homebrew installed (Apple Silicon)"
    elif [ -d "/usr/local/bin/brew" ]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
        echo "✓ Homebrew installed (Intel Mac)"
    else
        echo "⚠ Warning: Homebrew installation completed but brew command not found"
        echo "  You may need to restart your terminal"
    fi
fi

# Create symlinks for macOS-specific dotfiles
echo ""
echo "Creating symlinks for macOS dotfiles..."

# Backup and link .bashrc
if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
    echo "Backing up existing .bashrc to .bashrc.backup"
    mv "$HOME/.bashrc" "$HOME/.bashrc.backup"
fi
echo "Linking .bashrc.macos → ~/.bashrc"
ln -sf "$MACOS_DIR/.bashrc.macos" "$HOME/.bashrc"

# Backup and link .aliases
if [ -f "$HOME/.aliases" ] && [ ! -L "$HOME/.aliases" ]; then
    echo "Backing up existing .aliases to .aliases.backup"
    mv "$HOME/.aliases" "$HOME/.aliases.backup"
fi
echo "Linking .aliases.macos → ~/.aliases"
ln -sf "$MACOS_DIR/.aliases.macos" "$HOME/.aliases"

# Backup and link .gitconfig (shared with Codespaces)
if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    echo "Backing up existing .gitconfig to .gitconfig.backup"
    mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup"
fi
echo "Linking .gitconfig → ~/.gitconfig"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

echo "✓ Dotfiles symlinked successfully"

# Install Claude Code
echo ""
echo "Installing Claude Code..."
if command -v claude &> /dev/null; then
    echo "✓ Claude Code is already installed"
else
    echo "Installing Claude Code via npm..."
    if command -v npm &> /dev/null; then
        npm install -g @anthropic-ai/claude-code
        echo "✓ Claude Code installed successfully"
    else
        echo "npm not found. Installing Node.js via Homebrew..."
        brew install node
        npm install -g @anthropic-ai/claude-code
        echo "✓ Claude Code installed successfully"
    fi
fi

# Verify Claude Code installation
if command -v claude &> /dev/null; then
    echo "✓ Claude Code version: $(claude --version 2>/dev/null || echo 'installed')"
else
    echo "⚠ Warning: Claude Code installation may have failed"
fi

# Install Happy Coder CLI
echo ""
echo "Installing Happy Coder CLI for push notifications..."
if npm list -g @happy-coder/cli &> /dev/null; then
    echo "✓ Happy Coder CLI is already installed"
else
    echo "Installing Happy Coder CLI via npm..."
    npm install -g @happy-coder/cli
    echo "✓ Happy Coder CLI installed successfully"
fi

# Configure Claude Code settings
echo ""
echo "Configuring Claude Code settings..."
if [ ! -d "$HOME/.claude" ]; then
    mkdir -p "$HOME/.claude"
fi

if [ -f "$DOTFILES_DIR/.claude-settings.json" ]; then
    echo "Setting up Claude Code settings.json..."
    cp "$DOTFILES_DIR/.claude-settings.json" "$HOME/.claude/settings.json"
    echo "✓ Claude Code settings configured"
else
    echo "⚠ .claude-settings.json not found in dotfiles"
fi

# Configure ccstatusline
echo ""
echo "Configuring ccstatusline..."
if [ ! -d "$HOME/.config/ccstatusline" ]; then
    mkdir -p "$HOME/.config/ccstatusline"
fi

if [ -f "$DOTFILES_DIR/ccstatusline.settings.json" ]; then
    echo "Setting up ccstatusline settings.json..."
    cp "$DOTFILES_DIR/ccstatusline.settings.json" "$HOME/.config/ccstatusline/settings.json"
    echo "✓ ccstatusline configured"
else
    echo "⚠ ccstatusline.settings.json not found in dotfiles"
fi

echo ""
echo "=========================================="
echo "✓ macOS dotfiles installation complete!"
echo "=========================================="
echo ""
echo "To apply changes to your current shell, run:"
echo "  source ~/.bashrc"
echo ""
echo "Claude Code is installed. To authenticate, run:"
echo "  claude"
echo ""
echo "Claude Code will guide you through the authentication process."
echo ""
echo "📱 Push notifications are configured via Claude Code hooks."
echo "   See CLAUDE_NOTIFICATIONS_SETUP.md for setup instructions."
echo ""
